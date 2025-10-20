// src/solicitacoes/solicitacoes.service.ts
import { Injectable, NotFoundException, UnauthorizedException, BadRequestException, ConflictException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
import { EscolaEstoque } from 'src/estoque/entities/escola-estoque.entity';
import { PrefeituraEstoque } from 'src/estoque/entities/prefeitura-estoque.entity';
import { Product } from 'src/products/entities/product.entity';
import { User } from 'src/users/entities/user.entity';
import { DataSource, Repository } from 'typeorm'; // Importar DataSource para transações
import { AnalyzeSolicitacaoDto } from './dto/analyze-solicitacao.dto';
import { ConfirmRecebimentoDto } from './dto/confirm-recebimento.dto';
import { CreateSolicitacaoDto } from './dto/create-solicitacao.dto';
import { SolicitacaoItem } from './entities/solicitacao-item.entity';
import { Solicitacao, SolicitacaoStatus } from './entities/solicitacao.entity';

@Injectable()
export class SolicitacoesService {
  constructor(
    @InjectRepository(Solicitacao)
    private readonly solicitacaoRepository: Repository<Solicitacao>,
    @InjectRepository(SolicitacaoItem)
    private readonly itemRepository: Repository<SolicitacaoItem>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(PrefeituraEstoque)
    private readonly prefeituraEstoqueRepo: Repository<PrefeituraEstoque>,
    @InjectRepository(EscolaEstoque)
    private readonly escolaEstoqueRepo: Repository<EscolaEstoque>,
    // DataSource para controle de transação
    private dataSource: DataSource,
  ) {}

  // --- 1. CRIAÇÃO DE SOLICITAÇÃO (PELA ESCOLA) ---
  async create(createSolicitacaoDto: CreateSolicitacaoDto, user: User): Promise<Solicitacao> {
    if (!user.school || user.profile !== 'escola') {
      throw new UnauthorizedException('Apenas gestores de escola associados podem criar solicitações.');
    }

    const { justificativa, items } = createSolicitacaoDto;
    if (!items || items.length === 0) {
        throw new BadRequestException('A solicitação deve conter pelo menos um item.');
    }
    const productIds = items.map(item => item.productId);
    if (new Set(productIds).size !== productIds.length) {
      throw new BadRequestException('A solicitação não pode conter produtos duplicados.');
    }

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const novaSolicitacao = queryRunner.manager.create(Solicitacao, {
        justificativa: justificativa || null,
        requester: user,
        school: user.school,
        status: SolicitacaoStatus.PENDENTE,
      });
      const solicitacaoSalva = await queryRunner.manager.save(Solicitacao, novaSolicitacao);

      const solicitacaoItems: SolicitacaoItem[] = [];
      for (const itemDto of items) {
        const product = await queryRunner.manager.findOneBy(Product, { id: itemDto.productId });
        if (!product) {
          throw new NotFoundException(`Produto com ID ${itemDto.productId} não encontrado.`);
        }
        const newItem = queryRunner.manager.create(SolicitacaoItem, {
          quantityRequested: itemDto.quantityRequested,
          product: product,
          solicitacao: solicitacaoSalva,
        });
        solicitacaoItems.push(newItem);
      }
      
      await queryRunner.manager.save(SolicitacaoItem, solicitacaoItems);

      await queryRunner.commitTransaction();

      return this.findOne(solicitacaoSalva.id);

    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  // --- 2. LISTAGEM DE SOLICITAÇÕES ---
  async findAll(user: User): Promise<Solicitacao[]> {
    const relations = ['school', 'requester', 'items', 'items.product'];

    if (user.profile === 'escola') {
      if (!user.school) return [];
      return this.solicitacaoRepository.find({
        where: { school: { id: user.school.id } },
        order: { createdAt: 'DESC' },
        relations,
      });
    } else if (user.profile === 'prefeitura') {
      return this.solicitacaoRepository.find({
        order: { createdAt: 'DESC' },
        relations,
      });
    }
    return [];
  }

  // --- 3. BUSCA DETALHADA ---
  async findOne(id: string): Promise<Solicitacao> {
    const solicitacao = await this.solicitacaoRepository.findOne({
        where: { id },
        relations: ['school', 'requester', 'items', 'items.product'],
    });
    if (!solicitacao) {
        throw new NotFoundException(`Solicitação com ID "${id}" não encontrada.`);
    }
    return solicitacao;
  }

  // --- 4. ANÁLISE PELA PREFEITURA ---
  async analyze(id: string, analyzeDto: AnalyzeSolicitacaoDto): Promise<Solicitacao> {

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const solicitacao = await queryRunner.manager.findOne(Solicitacao, {
          where: { id },
          relations: ['items', 'items.product', 'school'],
          lock: { mode: 'pessimistic_write' }
      });

      if (!solicitacao) { throw new NotFoundException(`Solicitação com ID ${id} não encontrada.`); }
      if (solicitacao.status !== SolicitacaoStatus.PENDENTE) {
        throw new BadRequestException(`Esta solicitação não está mais pendente (status atual: ${solicitacao.status}).`);
      }
      if (analyzeDto.status !== SolicitacaoStatus.NEGADO && (!analyzeDto.items || analyzeDto.items.length === 0)) {
          throw new BadRequestException('Para aprovar (total ou parcialmente), é necessário fornecer a análise dos itens.');
      }

      // Se for NEGADO, atualiza status e observação e encerra
      if (analyzeDto.status === SolicitacaoStatus.NEGADO) {
        solicitacao.status = SolicitacaoStatus.NEGADO;
        solicitacao.observacaoPrefeitura = analyzeDto.observacaoPrefeitura || null;
        await queryRunner.manager.save(Solicitacao, solicitacao);
        await queryRunner.commitTransaction();
        return this.findOne(id);
      }

      // --- Processamento para APROVADO ou APROVADO_PARCIALMENTE ---

      // 1. Pré-Validação de Estoque
      for (const itemDto of analyzeDto.items!) {
          const itemSolicitado = solicitacao.items.find(item => item.id === itemDto.itemId);
          if (!itemSolicitado) {
            throw new NotFoundException(`Item com ID ${itemDto.itemId} não pertence à solicitação ${id}.`);
          }
          const quantityApproved = itemDto.quantityApproved ?? 0;
          if (quantityApproved < 0) throw new BadRequestException(`Quantidade aprovada não pode ser negativa para o item ${itemSolicitado.product.name}.`);

          if (quantityApproved > 0) {
              const estoquePrefeitura = await queryRunner.manager.findOne(PrefeituraEstoque, {
                  where: { product: { id: itemSolicitado.product.id } },
                  lock: { mode: 'pessimistic_write' }
              });
              if (!estoquePrefeitura || estoquePrefeitura.quantity < quantityApproved) {
                  throw new ConflictException(`Estoque insuficiente na prefeitura para "${itemSolicitado.product.name}". Necessário: ${quantityApproved}, Disponível: ${estoquePrefeitura?.quantity ?? 0}`);
              }
          }
      }

      // 2. Atualização dos Itens e Estoques (Se passou na validação)
      const itemsParaSalvar: SolicitacaoItem[] = [];
      let totalRequested = 0;
      let totalApproved = 0;

      for (const itemDto of analyzeDto.items!) {
        const itemSolicitado = solicitacao.items.find(item => item.id === itemDto.itemId)!;
        const quantityApproved = itemDto.quantityApproved ?? 0;

        itemSolicitado.quantityApproved = quantityApproved;
        itemsParaSalvar.push(itemSolicitado);
        totalRequested += itemSolicitado.quantityRequested;
        totalApproved += quantityApproved;

        if (quantityApproved > 0) {
          // Débito do Estoque da Prefeitura
          let estoquePrefeitura = await queryRunner.manager.findOneOrFail(PrefeituraEstoque, {
              where: { product: { id: itemSolicitado.product.id } },
              lock: { mode: 'pessimistic_write' }
          });
          estoquePrefeitura.quantity -= quantityApproved;
          await queryRunner.manager.save(PrefeituraEstoque, estoquePrefeitura);

          // Crédito no Estoque da Escola
          let estoqueEscola = await queryRunner.manager.findOne(EscolaEstoque, {
              where: { product: { id: itemSolicitado.product.id }, school: { id: solicitacao.school.id } },
              relations: ['product', 'school'], // Necessário carregar para salvar corretamente
              lock: { mode: 'pessimistic_write' }
            });
          if (!estoqueEscola) {
            estoqueEscola = queryRunner.manager.create(EscolaEstoque, {
              product: itemSolicitado.product,
              school: solicitacao.school,
              quantity: quantityApproved,
              minStock: 0 // Assume 0 inicialmente
            });
          } else {
            estoqueEscola.quantity += quantityApproved;
          }
          await queryRunner.manager.save(EscolaEstoque, estoqueEscola);
        }
      }

      // 3. Define o Status Final e Observação
      if (totalApproved <= 0) {
        solicitacao.status = SolicitacaoStatus.NEGADO;
      } else if (totalApproved < totalRequested) {
        solicitacao.status = SolicitacaoStatus.APROVADO_PARCIALMENTE;
      } else {
        solicitacao.status = SolicitacaoStatus.APROVADO;
      }
      solicitacao.observacaoPrefeitura = analyzeDto.observacaoPrefeitura || null;

      // 4. Salva as Alterações
      await queryRunner.manager.save(SolicitacaoItem, itemsParaSalvar);
      await queryRunner.manager.save(Solicitacao, solicitacao);

      await queryRunner.commitTransaction();
      return this.findOne(id);

    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  // --- 5. CONFIRMAÇÃO PELA ESCOLA ---
  async confirmRecebimento(id: string, confirmDto: ConfirmRecebimentoDto, user: User): Promise<Solicitacao> {
    const solicitacao = await this.solicitacaoRepository.findOne({
      where: { id },
      relations: ['school', 'items', 'items.product'],
    });

    if (!solicitacao) { throw new NotFoundException(`Solicitação com ID ${id} não encontrada.`); }
    if (solicitacao.school.id !== user.school?.id) {
      throw new ForbiddenException('Você não tem permissão para confirmar o recebimento desta solicitação.');
    }
    if (solicitacao.status !== SolicitacaoStatus.APROVADO && solicitacao.status !== SolicitacaoStatus.APROVADO_PARCIALMENTE) {
      throw new BadRequestException(`Esta solicitação não pode ser confirmada (status atual: ${solicitacao.status}).`);
    }

    const itemsParaSalvar: SolicitacaoItem[] = [];
    for (const itemDto of confirmDto.items) {
      const itemSolicitado = solicitacao.items.find(item => item.id === itemDto.itemId);
      if (!itemSolicitado) {
        console.warn(`Item com ID ${itemDto.itemId} não encontrado na solicitação ${id} durante a confirmação.`);
        continue;
      }

      const maxRecebivel = itemSolicitado.quantityApproved ?? 0;
      const quantityReceived = itemDto.quantityReceived ?? 0;

      if (quantityReceived < 0) {
         throw new BadRequestException(`A quantidade recebida não pode ser negativa para "${itemSolicitado.product.name}".`);
      }
      if (quantityReceived > maxRecebivel) {
          throw new BadRequestException(`A quantidade recebida (${quantityReceived}) para "${itemSolicitado.product.name}" não pode ser maior que a aprovada (${maxRecebivel}).`);
      }

      itemSolicitado.quantityReceived = quantityReceived;
      itemsParaSalvar.push(itemSolicitado);
    }

    solicitacao.status = SolicitacaoStatus.RECEBIDO;

    // Usamos transação aqui também para garantir a atomicidade da atualização
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();
    try {
      await queryRunner.manager.save(SolicitacaoItem, itemsParaSalvar);
      await queryRunner.manager.save(Solicitacao, solicitacao);
      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }

    return this.findOne(id);
  }

  // --- 6. REMOÇÃO DE SOLICITAÇÃO ---
  async remove(id: string): Promise<void> {
    const solicitacao = await this.findOne(id);
    // Adicionar regra aqui se necessário (ex: só pode remover se PENDENTE?)
    // if (solicitacao.status !== SolicitacaoStatus.PENDENTE) {
    //   throw new BadRequestException('Não é possível remover uma solicitação que já foi processada.');
    // }
    await this.solicitacaoRepository.remove(solicitacao);
  }
}