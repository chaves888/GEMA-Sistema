import { Injectable, NotFoundException, UnauthorizedException, BadRequestException, ConflictException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
import { EscolaEstoque } from 'src/estoque/entities/escola-estoque.entity';
import { PrefeituraEstoque } from 'src/estoque/entities/prefeitura-estoque.entity';
import { Product } from 'src/products/entities/product.entity';
import { User } from 'src/users/entities/user.entity';
import { DataSource, Repository } from 'typeorm';
import { AnalyzeSolicitacaoDto } from './dto/analyze-solicitacao.dto';
import { ConfirmRecebimentoDto } from './dto/confirm-recebimento.dto';
import { CreateSolicitacaoDto } from './dto/create-solicitacao.dto';
import { SolicitacaoItem } from './entities/solicitacao-item.entity';
import { Solicitacao, SolicitacaoStatus } from './entities/solicitacao.entity';
import { CancelSolicitacaoDto } from './dto/cancel-solicitacao.dto';

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
        if (itemDto.quantityRequested <= 0) {
          throw new BadRequestException(`A quantidade solicitada para "${product.name}" deve ser maior que zero.`);
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

      if (analyzeDto.status === SolicitacaoStatus.NEGADO) {
        if (!analyzeDto.observacaoPrefeitura) {
           throw new BadRequestException('A observação é obrigatória ao negar a solicitação.');
        }
        solicitacao.status = SolicitacaoStatus.NEGADO;
        solicitacao.observacaoPrefeitura = analyzeDto.observacaoPrefeitura || null;
        
        for (const item of solicitacao.items) {
          item.quantityApproved = 0;
        }
        await queryRunner.manager.save(SolicitacaoItem, solicitacao.items);
        await queryRunner.manager.save(Solicitacao, solicitacao);

        await queryRunner.commitTransaction();
        return this.findOne(id);
      }

      if (!analyzeDto.items || analyzeDto.items.length === 0) {
        throw new BadRequestException('Para aprovar (total ou parcialmente), é necessário fornecer a análise dos itens.');
      }
      
      const hasZeroApprovedItem = analyzeDto.items.some(item => (item.quantityApproved ?? 0) === 0);
      if (hasZeroApprovedItem && !analyzeDto.observacaoPrefeitura) {
          throw new BadRequestException('A observação é obrigatória se algum item individual for negado (quantidade aprovada 0).');
      }

      for (const itemDto of analyzeDto.items!) {
          const itemSolicitado = solicitacao.items.find(item => item.id === itemDto.itemId);
          if (!itemSolicitado) {
            throw new NotFoundException(`Item com ID ${itemDto.itemId} não pertence à solicitação ${id}.`);
          }
          const quantityApproved = itemDto.quantityApproved ?? 0;
          if (quantityApproved < 0) throw new BadRequestException(`Quantidade aprovada não pode ser negativa para o item ${itemSolicitado.product.name}.`);
          
          if (quantityApproved > itemSolicitado.quantityRequested) {
             throw new BadRequestException(`Quantidade aprovada (${quantityApproved}) para "${itemSolicitado.product.name}" não pode ser maior que a solicitada (${itemSolicitado.quantityRequested}).`);
          }

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

      const itemsParaSalvar: SolicitacaoItem[] = [];
      for (const itemDto of analyzeDto.items!) {
        const itemSolicitado = solicitacao.items.find(item => item.id === itemDto.itemId)!;
        const quantityApproved = itemDto.quantityApproved ?? 0;

        itemSolicitado.quantityApproved = quantityApproved;
        itemsParaSalvar.push(itemSolicitado);

        if (quantityApproved > 0) {
          let estoquePrefeitura = await queryRunner.manager.findOneOrFail(PrefeituraEstoque, {
              where: { product: { id: itemSolicitado.product.id } },
              lock: { mode: 'pessimistic_write' }
          });
          if (estoquePrefeitura.quantity < quantityApproved) {
              throw new ConflictException(`Concorrência detectada: Estoque insuficiente na prefeitura para "${itemSolicitado.product.name}" após lock.`);
          }
          estoquePrefeitura.quantity -= quantityApproved;
          await queryRunner.manager.save(PrefeituraEstoque, estoquePrefeitura);
        }
      }

      solicitacao.status = analyzeDto.status;
      solicitacao.observacaoPrefeitura = analyzeDto.observacaoPrefeitura || null;

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

  // --- 5. CONFIRMAÇÃO PELA ESCOLA (COM ATUALIZAÇÃO DE ESTOQUE) ---
  async confirmRecebimento(id: string, confirmDto: ConfirmRecebimentoDto, user: User): Promise<Solicitacao> {
    
    const { items, comDivergencia, observacaoEscola } = confirmDto;

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const solicitacao = await queryRunner.manager.findOne(Solicitacao, {
        where: { id },
        relations: ['school', 'items', 'items.product'], 
        lock: { mode: 'pessimistic_write' }, 
      });

      if (!solicitacao) { throw new NotFoundException(`Solicitação com ID ${id} não encontrada.`); }
      if (solicitacao.school.id !== user.school?.id) {
        throw new ForbiddenException('Você não tem permissão para confirmar o recebimento desta solicitação.');
      }
      if (solicitacao.status !== SolicitacaoStatus.APROVADO && solicitacao.status !== SolicitacaoStatus.APROVADO_PARCIALMENTE) {
        throw new BadRequestException(`Esta solicitação não pode ser confirmada (status atual: ${solicitacao.status}).`);
      }

      const itemsParaSalvarSolicitacao: SolicitacaoItem[] = [];
      const estoquesParaSalvarEscola: EscolaEstoque[] = [];
      
      let hasQuantityDivergence = false; // Flag para detecção automática

      for (const itemDto of items) {
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

        // Detecção automática de divergência
        if (quantityReceived !== itemSolicitado.quantityApproved) {
            hasQuantityDivergence = true;
        }

        itemSolicitado.quantityReceived = quantityReceived;
        itemsParaSalvarSolicitacao.push(itemSolicitado);

        if (quantityReceived > 0) {
          let estoqueEscola = await queryRunner.manager.findOne(EscolaEstoque, {
            where: {
              product: { id: itemSolicitado.product.id },
              school: { id: solicitacao.school.id }
            },
            relations: ['product', 'school'], 
            lock: { mode: 'pessimistic_write' } 
          });

          if (!estoqueEscola) {
            estoqueEscola = queryRunner.manager.create(EscolaEstoque, {
              product: itemSolicitado.product,
              school: solicitacao.school,
              quantity: quantityReceived,
              minStock: 0 
            });
          } else {
            estoqueEscola.quantity += quantityReceived;
          }
          estoquesParaSalvarEscola.push(estoqueEscola);
        }
      } // Fim do loop 'for'

      // Verifica a divergência final (manual OU automática)
      const finalDivergence = comDivergencia || hasQuantityDivergence;

      if (finalDivergence && !observacaoEscola) {
         throw new BadRequestException('A observação é obrigatória quando há divergência (seja na quantidade ou marcada manualmente).');
      }
      
      if (finalDivergence) {
        solicitacao.status = SolicitacaoStatus.RECEBIDO_COM_DIVERGENCIA;
      } else {
        solicitacao.status = SolicitacaoStatus.RECEBIDO;
      }
      
      solicitacao.observacaoEscola = finalDivergence ? (observacaoEscola || null) : null;

      await queryRunner.manager.save(SolicitacaoItem, itemsParaSalvarSolicitacao);
      await queryRunner.manager.save(EscolaEstoque, estoquesParaSalvarEscola); 
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

    if (solicitacao.status !== SolicitacaoStatus.PENDENTE) {
      throw new BadRequestException('Não é possível remover uma solicitação que já foi analisada ou recebida.');
    }

    await this.solicitacaoRepository.remove(solicitacao);
  }

  // --- 7. CONTAGEM DE PENDENTES (PARA PREFEITURA) ---
  async getPendentesCount(): Promise<{ count: number }> {
    const count = await this.solicitacaoRepository.count({
      where: { status: SolicitacaoStatus.PENDENTE },
    });
    return { count };
  }

  // --- 8. CANCELAMENTO PELA ESCOLA ---
  async cancelar(id: string, user: User, cancelDto: CancelSolicitacaoDto): Promise<Solicitacao> {
    const solicitacao = await this.solicitacaoRepository.findOne({
      where: { id },
      relations: ['school'], 
    });

    if (!solicitacao) {
      throw new NotFoundException(`Solicitação com ID "${id}" não encontrada.`);
    }

    if (!user.school || solicitacao.school.id !== user.school.id) {
      throw new ForbiddenException('Você não tem permissão para cancelar esta solicitação.');
    }

    if (solicitacao.status !== SolicitacaoStatus.PENDENTE) {
      throw new BadRequestException(`Apenas solicitações pendentes podem ser canceladas (status atual: ${solicitacao.status}).`);
    }

    solicitacao.status = SolicitacaoStatus.CANCELADO;
    solicitacao.observacaoEscola = cancelDto.motivoCancelamento || null; 
    
    await this.solicitacaoRepository.save(solicitacao);
    return this.findOne(id);
  }
}