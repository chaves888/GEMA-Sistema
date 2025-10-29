import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Cardapio, CardapioStatus } from 'src/cardapios/entities/cardapio.entity';
import { Escola } from 'src/escolas/entities/escola.entity';
import { EscolaEstoque } from 'src/estoque/entities/escola-estoque.entity';
import { PrefeituraEstoque } from 'src/estoque/entities/prefeitura-estoque.entity';
import { EstoqueService } from 'src/estoque/estoque.service';
import { Product } from 'src/products/entities/product.entity';
import { Solicitacao, SolicitacaoStatus } from 'src/solicitacoes/entities/solicitacao.entity';
import { User, UserProfile } from 'src/users/entities/user.entity';
import { LessThanOrEqual, MoreThanOrEqual, Repository } from 'typeorm';
import { format, parseISO } from 'date-fns';

// --- Interface ATUALIZADA ---
// A estrutura interna dos itens críticos agora vem do EstoqueService
interface SchoolStockSummary {
  schoolId: string;
  schoolName: string;
  criticalItems: Array<{ // Estrutura retornada por EstoqueService
    product: Product;
    quantity: number;
    minStock: number; // Este minStock agora é o product.minStockEscola
    status: string;
    percentage: number;
  }>;
}
// --- FIM ATUALIZAÇÃO ---


@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(User) private readonly userRepository: Repository<User>,
    @InjectRepository(Escola) private readonly escolaRepository: Repository<Escola>,
    @InjectRepository(Solicitacao) private readonly solicitacaoRepository: Repository<Solicitacao>,
    @InjectRepository(PrefeituraEstoque) private readonly prefeituraEstoqueRepo: Repository<PrefeituraEstoque>,
    @InjectRepository(EscolaEstoque) private readonly escolaEstoqueRepo: Repository<EscolaEstoque>,
    @InjectRepository(Cardapio) private readonly cardapioRepository: Repository<Cardapio>,
    @InjectRepository(Product) private readonly productRepository: Repository<Product>,
    private readonly estoqueService: EstoqueService,
  ) {}

  async getDashboardData(user: User): Promise<any> {
    switch (user.profile) {
      case UserProfile.PREFEITURA:
        return this.getPrefeituraData();
      case UserProfile.ESCOLA:
        return this.getEscolaData(user);
      case UserProfile.NUTRICIONISTA:
        return this.getNutricionistaData();
      case UserProfile.COZINHEIRA:
        return this.getCozinheiraData(user);
      default:
        return { message: 'Perfil de usuário não suportado para dashboard.' };
    }
  }

  // --- Lógica de getPrefeituraData e getEscolaData não precisa mudar ---
  // Elas já dependem da resposta do EstoqueService, que nós acabamos de corrigir.
  // A estrutura (status, percentage, minStock) retornada pelo EstoqueService continua a mesma,
  // apenas o *valor* de minStock e o cálculo do status mudaram internamente no EstoqueService.

  private async getPrefeituraData() {
    const totalUsers = await this.userRepository.count();
    const totalEscolas = await this.escolaRepository.count();
    const pendingSolicitacoes = await this.solicitacaoRepository.count({
      where: { status: SolicitacaoStatus.PENDENTE },
    });

    const fullStockPrefeitura = await this.estoqueService.getPrefeituraEstoque();
    const criticalStockPrefeitura = fullStockPrefeitura.filter(
      item => item.status === 'Crítico' || item.status === 'Médio'
    );

    const allEscolas = await this.escolaRepository.find({ order: { name: 'ASC' } });
    const schoolStockSummaries: SchoolStockSummary[] = [];

    for (const escola of allEscolas) {
      const fullStockEscola = await this.estoqueService.getEscolaEstoque(escola.id);
      const criticalItemsEscola = fullStockEscola
        .filter(item => item.status === 'Crítico' || item.status === 'Médio')
        .slice(0, 15);

      schoolStockSummaries.push({
        schoolId: escola.id,
        schoolName: escola.name,
        criticalItems: criticalItemsEscola, // Esta estrutura agora bate com a Interface
      });
    }

    return {
      stats: {
        users: totalUsers,
        schools: totalEscolas,
        pendingSolicitacoes: pendingSolicitacoes,
      },
      criticalStockPrefeitura: criticalStockPrefeitura.slice(0, 15),
      schoolStocks: schoolStockSummaries,
    };
  }


  private async getEscolaData(user: User) {
    if (!user.school?.id) return { error: 'Usuário não associado a uma escola.' };
    const schoolId = user.school.id;
    const recentSolicitacoes = await this.solicitacaoRepository.find({
      where: { school: { id: schoolId } }, order: { createdAt: 'DESC' }, take: 5, select: ['id', 'createdAt', 'status'],
    });
    
    // EstoqueService agora usa product.minStockEscola para calcular status/percentage
    const fullStock = await this.estoqueService.getEscolaEstoque(schoolId);
    const criticalStockItems = fullStock.filter(item => item.status === 'Crítico' || item.status === 'Médio');

    const today = format(new Date(), 'yyyy-MM-dd');
    const currentCardapio = await this.cardapioRepository.findOne({
      where: { status: CardapioStatus.PUBLICADO, startDate: LessThanOrEqual(today), endDate: MoreThanOrEqual(today), },
      select: ['id', 'name', 'startDate', 'endDate'],
    });
    return { recentSolicitacoes, criticalStock: criticalStockItems.slice(0, 5), currentCardapio, };
  }

  private async getNutricionistaData() {
    const draftCardapios = await this.cardapioRepository.find({
      where: { status: CardapioStatus.RASCUNHO }, order: { createdAt: 'DESC' }, take: 5, select: ['id', 'name', 'startDate', 'endDate', 'createdAt'],
    });
    return { draftCardapios, };
  }
  private async getCozinheiraData(user: User) {
    if (!user.school?.id) return { error: 'Usuário não associado a uma escola.' };
    const today = format(new Date(), 'yyyy-MM-dd');
    const currentCardapio = await this.cardapioRepository.findOne({
      where: { status: CardapioStatus.PUBLICADO, startDate: LessThanOrEqual(today), endDate: MoreThanOrEqual(today), },
      relations: ['refeicoes', 'refeicoes.products'],
    });
    return { currentCardapio, };
  }
}