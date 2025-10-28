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

// Não precisamos mais do EstoqueService aqui, vamos usar os repositórios diretamente na transação
// import { EstoqueService } from 'src/estoque/estoque.service';

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
        // Validação: Quantidade solicitada deve ser positiva
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

      // Retorna a solicitação criada com todos os dados carregados
      return this.findOne(solicitacaoSalva.id);

    } catch (error) {
      await queryRunner.rollbackTransaction();
      // Re-lança o erro para ser tratado pelo NestJS (ex: validações, not found)
      throw error;
    } finally {
      // Libera o queryRunner independentemente de sucesso ou falha
      await queryRunner.release();
    }
  }

  // --- 2. LISTAGEM DE SOLICITAÇÕES ---
  async findAll(user: User): Promise<Solicitacao[]> {
    const relations = ['school', 'requester', 'items', 'items.product'];

    if (user.profile === 'escola') {
      if (!user.school) return []; // Escola sem associação não tem solicitações
      return this.solicitacaoRepository.find({
        where: { school: { id: user.school.id } },
        order: { createdAt: 'DESC' },
        relations,
      });
    } else if (user.profile === 'prefeitura') {
      // Prefeitura vê todas
      return this.solicitacaoRepository.find({
        order: { createdAt: 'DESC' },
        relations,
      });
    }
    // Outros perfis (nutricionista, cozinheira) não veem a lista principal por padrão
    return [];
  }

  // --- 3. BUSCA DETALHADA ---
  async findOne(id: string): Promise<Solicitacao> {
    const solicitacao = await this.solicitacaoRepository.findOne({
        where: { id },
        // Carrega todas as relações necessárias para exibição detalhada
        relations: ['school', 'requester', 'items', 'items.product'],
    });
    if (!solicitacao) {
        throw new NotFoundException(`Solicitação com ID "${id}" não encontrada.`);
    }
    return solicitacao;
  }

  // --- 4. ANÁLISE PELA PREFEITURA ---
  // (Código da análise continua igual ao que você enviou, pois não foi o foco)
  async analyze(id: string, analyzeDto: AnalyzeSolicitacaoDto): Promise<Solicitacao> {

    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const solicitacao = await queryRunner.manager.findOne(Solicitacao, {
          where: { id },
          relations: ['items', 'items.product', 'school'], // Carrega a escola aqui
          lock: { mode: 'pessimistic_write' } // Trava a linha para evitar concorrência
      });

      if (!solicitacao) { throw new NotFoundException(`Solicitação com ID ${id} não encontrada.`); }
      if (solicitacao.status !== SolicitacaoStatus.PENDENTE) {
        throw new BadRequestException(`Esta solicitação não está mais pendente (status atual: ${solicitacao.status}).`);
      }
      // Se status for diferente de NEGADO, os itens são obrigatórios
      if (analyzeDto.status !== SolicitacaoStatus.NEGADO && (!analyzeDto.items || analyzeDto.items.length === 0)) {
          throw new BadRequestException('Para aprovar (total ou parcialmente), é necessário fornecer a análise dos itens.');
      }

      // Se for NEGADO, atualiza status e observação e encerra
      if (analyzeDto.status === SolicitacaoStatus.NEGADO) {
        solicitacao.status = SolicitacaoStatus.NEGADO;
        solicitacao.observacaoPrefeitura = analyzeDto.observacaoPrefeitura || null;
        await queryRunner.manager.save(Solicitacao, solicitacao);
        await queryRunner.commitTransaction();
        return this.findOne(id); // Retorna a solicitação atualizada
      }

      // --- Processamento para APROVADO ou APROVADO_PARCIALMENTE ---

      // 1. Pré-Validação de Estoque da Prefeitura (bloqueia se não tiver o suficiente)
      for (const itemDto of analyzeDto.items!) { // Usa ! pois já validamos que items existe se não for NEGADO
          const itemSolicitado = solicitacao.items.find(item => item.id === itemDto.itemId);
          if (!itemSolicitado) {
            throw new NotFoundException(`Item com ID ${itemDto.itemId} não pertence à solicitação ${id}.`);
          }
          const quantityApproved = itemDto.quantityApproved ?? 0; // Trata nulo como 0
          if (quantityApproved < 0) throw new BadRequestException(`Quantidade aprovada não pode ser negativa para o item ${itemSolicitado.product.name}.`);

          // Verifica estoque da prefeitura APENAS se for aprovar alguma quantidade
          if (quantityApproved > 0) {
              const estoquePrefeitura = await queryRunner.manager.findOne(PrefeituraEstoque, {
                  where: { product: { id: itemSolicitado.product.id } },
                  lock: { mode: 'pessimistic_write' } // Trava para leitura/escrita
              });
              if (!estoquePrefeitura || estoquePrefeitura.quantity < quantityApproved) {
                  throw new ConflictException(`Estoque insuficiente na prefeitura para "${itemSolicitado.product.name}". Necessário: ${quantityApproved}, Disponível: ${estoquePrefeitura?.quantity ?? 0}`);
              }
          }
      }

      // 2. Atualização dos Itens da Solicitação e Débito/Crédito dos Estoques (Se passou na validação)
      const itemsParaSalvar: SolicitacaoItem[] = [];
      let totalRequested = 0;
      let totalApproved = 0;

      for (const itemDto of analyzeDto.items!) {
        const itemSolicitado = solicitacao.items.find(item => item.id === itemDto.itemId)!; // Sabemos que existe pela validação anterior
        const quantityApproved = itemDto.quantityApproved ?? 0;

        itemSolicitado.quantityApproved = quantityApproved;
        itemsParaSalvar.push(itemSolicitado);
        totalRequested += itemSolicitado.quantityRequested;
        totalApproved += quantityApproved;

        // Somente debita/credita se alguma quantidade foi aprovada
        if (quantityApproved > 0) {
          // --- Débito do Estoque da Prefeitura ---
          // Busca novamente com lock para garantir que a quantidade não mudou
          let estoquePrefeitura = await queryRunner.manager.findOneOrFail(PrefeituraEstoque, {
              where: { product: { id: itemSolicitado.product.id } },
              lock: { mode: 'pessimistic_write' }
          });
          // Verifica novamente (paranóia, mas seguro em alta concorrência)
          if (estoquePrefeitura.quantity < quantityApproved) {
             throw new ConflictException(`Concorrência detectada: Estoque insuficiente na prefeitura para "${itemSolicitado.product.name}" após lock.`);
          }
          estoquePrefeitura.quantity -= quantityApproved;
          await queryRunner.manager.save(PrefeituraEstoque, estoquePrefeitura);

          // --- Crédito (PENDENTE DE CONFIRMAÇÃO) no Estoque da Escola ---
          // Nesta etapa, NÃO creditamos o estoque da escola ainda. Apenas reservamos na prefeitura.
          // O crédito real ocorrerá na função `confirmRecebimento`.
        }
      }

      // 3. Define o Status Final da Solicitação e Observação
      if (totalApproved <= 0) {
        solicitacao.status = SolicitacaoStatus.NEGADO; // Se nada foi aprovado, vira NEGADO
      } else if (totalApproved < totalRequested) {
        solicitacao.status = SolicitacaoStatus.APROVADO_PARCIALMENTE;
      } else {
        solicitacao.status = SolicitacaoStatus.APROVADO;
      }
      solicitacao.observacaoPrefeitura = analyzeDto.observacaoPrefeitura || null;

      // 4. Salva as Alterações na Solicitação e seus Itens
      await queryRunner.manager.save(SolicitacaoItem, itemsParaSalvar);
      await queryRunner.manager.save(Solicitacao, solicitacao);

      // Finaliza a transação
      await queryRunner.commitTransaction();
      return this.findOne(id); // Retorna a solicitação atualizada

    } catch (error) {
      // Se qualquer erro ocorrer, desfaz tudo
      await queryRunner.rollbackTransaction();
      throw error; // Re-lança o erro
    } finally {
      // Libera o queryRunner
      await queryRunner.release();
    }
  }

  // --- 5. CONFIRMAÇÃO PELA ESCOLA (COM ATUALIZAÇÃO DE ESTOQUE) ---
  async confirmRecebimento(id: string, confirmDto: ConfirmRecebimentoDto, user: User): Promise<Solicitacao> {
    
    // Inicia a transação
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      // Busca a solicitação com lock para evitar problemas de concorrência
      const solicitacao = await queryRunner.manager.findOne(Solicitacao, {
        where: { id },
        relations: ['school', 'items', 'items.product'], // Carrega relações necessárias
        lock: { mode: 'pessimistic_write' }, // Trava a solicitação
      });

      // Validações iniciais
      if (!solicitacao) { throw new NotFoundException(`Solicitação com ID ${id} não encontrada.`); }
      if (solicitacao.school.id !== user.school?.id) {
        throw new ForbiddenException('Você não tem permissão para confirmar o recebimento desta solicitação.');
      }
      if (solicitacao.status !== SolicitacaoStatus.APROVADO && solicitacao.status !== SolicitacaoStatus.APROVADO_PARCIALMENTE) {
        throw new BadRequestException(`Esta solicitação não pode ser confirmada (status atual: ${solicitacao.status}).`);
      }

      const itemsParaSalvarSolicitacao: SolicitacaoItem[] = [];
      const estoquesParaSalvarEscola: EscolaEstoque[] = [];

      // Loop para processar cada item confirmado
      for (const itemDto of confirmDto.items) {
        // Encontra o item correspondente na solicitação carregada
        const itemSolicitado = solicitacao.items.find(item => item.id === itemDto.itemId);
        
        // Se o item do DTO não existe na solicitação (estranho, mas seguro verificar)
        if (!itemSolicitado) {
          console.warn(`Item com ID ${itemDto.itemId} não encontrado na solicitação ${id} durante a confirmação.`);
          continue; // Pula para o próximo item do DTO
        }

        const maxRecebivel = itemSolicitado.quantityApproved ?? 0; // Máximo que pode ser recebido é o que foi aprovado
        const quantityReceived = itemDto.quantityReceived ?? 0; // Quantidade informada como recebida (trata nulo como 0)

        // Validações da quantidade recebida
        if (quantityReceived < 0) {
            throw new BadRequestException(`A quantidade recebida não pode ser negativa para "${itemSolicitado.product.name}".`);
        }
        if (quantityReceived > maxRecebivel) {
            throw new BadRequestException(`A quantidade recebida (${quantityReceived}) para "${itemSolicitado.product.name}" não pode ser maior que a aprovada (${maxRecebivel}).`);
        }

        // Atualiza a quantidade recebida no item da solicitação
        itemSolicitado.quantityReceived = quantityReceived;
        itemsParaSalvarSolicitacao.push(itemSolicitado);

        // *** INÍCIO DA LÓGICA DE ATUALIZAÇÃO DE ESTOQUE ***
        if (quantityReceived > 0) {
          // Busca o estoque da escola para este produto, com lock
          let estoqueEscola = await queryRunner.manager.findOne(EscolaEstoque, {
            where: {
              product: { id: itemSolicitado.product.id },
              school: { id: solicitacao.school.id }
            },
            relations: ['product', 'school'], // Carrega relações para salvar
            lock: { mode: 'pessimistic_write' } // Trava o estoque da escola
          });

          // Se não existe estoque para esse produto nessa escola, cria um novo
          if (!estoqueEscola) {
            estoqueEscola = queryRunner.manager.create(EscolaEstoque, {
              product: itemSolicitado.product,
              school: solicitacao.school,
              quantity: quantityReceived,
              minStock: 0 // Assume 0 inicialmente, pode ser ajustado depois
            });
          } else {
            // Se já existe, apenas adiciona a quantidade recebida
            estoqueEscola.quantity += quantityReceived;
          }
          // Adiciona à lista para salvar depois
          estoquesParaSalvarEscola.push(estoqueEscola);
        }
        // *** FIM DA LÓGICA DE ATUALIZAÇÃO DE ESTOQUE ***
      } // Fim do loop pelos itens

      // Atualiza o status geral da solicitação para RECEBIDO
      solicitacao.status = SolicitacaoStatus.RECEBIDO;

      // Salva todas as alterações no banco de dados DENTRO da transação
      await queryRunner.manager.save(SolicitacaoItem, itemsParaSalvarSolicitacao);
      await queryRunner.manager.save(EscolaEstoque, estoquesParaSalvarEscola); // Salva as atualizações/criações de estoque
      await queryRunner.manager.save(Solicitacao, solicitacao); // Salva a solicitação com o novo status

      // Se tudo deu certo, confirma a transação
      await queryRunner.commitTransaction();

    } catch (error) {
      // Se qualquer erro ocorrer, desfaz tudo
      await queryRunner.rollbackTransaction();
      throw error; // Re-lança o erro para o NestJS tratar
    } finally {
      // Libera o queryRunner, independentemente de sucesso ou falha
      await queryRunner.release();
    }

    // Retorna a solicitação atualizada após a confirmação
    return this.findOne(id);
  }


  // --- 6. REMOÇÃO DE SOLICITAÇÃO ---
  async remove(id: string): Promise<void> {
    // Busca a solicitação (findOne já lança NotFoundException se não existir)
    const solicitacao = await this.findOne(id);

    // Regra de Negócio: Só permite remover se estiver PENDENTE
    if (solicitacao.status !== SolicitacaoStatus.PENDENTE) {
      throw new BadRequestException('Não é possível remover uma solicitação que já foi analisada ou recebida.');
    }

    // A remoção da solicitação deve automaticamente remover os itens
    // se a relação no `solicitacao.entity.ts` estiver configurada com `cascade: true` ou `onDelete: 'CASCADE'`
    // Caso contrário, você precisaria remover os itens manualmente antes:
    // await this.itemRepository.delete({ solicitacao: { id: id } });

    await this.solicitacaoRepository.remove(solicitacao);
    // Não retorna nada em caso de sucesso (HttpCode 204 no controller)
  }
}
