import { BadRequestException, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
import { Solicitacao, SolicitacaoStatus } from 'src/solicitacoes/entities/solicitacao.entity';
import { Between, In, Repository } from 'typeorm';
import { GerarRelatorioSolicitacoesDto } from './dto/gerar-relatorio-solicitacoes.dto';
import { User, UserProfile } from 'src/users/entities/user.entity';
import { UsersService } from 'src/users/users.service';
import { MailerService } from '@nestjs-modules/mailer';
import { format, parseISO } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { EstoqueMovimentacao, MotivoMovimentacao, TipoMovimentacao } from 'src/estoque/entities/estoque-movimentacao.entity';

// Interface para a linha do relatório
export interface RelatorioRow {
  escolaId: string;
  escolaName: string;
  totalSolicitacoes: number;
  totalItensSolicitados: number;
  totalItensAprovados: number;
  totalComDivergencia: number;
  taxaAtendimento: number;
}

export interface RelatorioSnapshot {
  totalSolicitacoes: number;
  totalItensEnviados: number;
  totalPerdasPrefeitura: number;
  totalPerdasEscolas: number;
}

export interface RelatorioAjustePrefeituraRow {
  productId: string;
  productName: string;
  unit: string;
  motivoCategoria: MotivoMovimentacao;
  motivoObservacao: string | null;
  quantidadeTotal: number;
}

export interface RelatorioEntradaPrefeituraRow {
  productId: string;
  productName: string;
  unit: string;
  quantidadeAdicionada: number;
  motivoObservacao: string | null;
  userName: string; // Quem fez a adição
}

export interface RelatorioAjusteEscolaRow {
  escolaId: string;
  escolaName: string;
  productId: string;
  productName: string;
  unit: string;
  motivoCategoria: MotivoMovimentacao;
  motivoObservacao: string | null;
  quantidadeTotal: number;
}

export interface RelatorioEnvioRow {
  dataEnvio: Date;
  escolaName: string;
  productName: string;
  unit: string;
  quantidadeEnviada: number;
  solicitacaoId: string;
}

@Injectable()
export class RelatoriosService {
  constructor(
    @InjectRepository(Escola)
    private readonly escolaRepository: Repository<Escola>,
    @InjectRepository(Solicitacao)
    private readonly solicitacaoRepository: Repository<Solicitacao>,
    @InjectRepository(EstoqueMovimentacao)
    private readonly movimentacaoRepo: Repository<EstoqueMovimentacao>,
    private readonly usersService: UsersService, // Para buscar e-mails
    private readonly mailerService: MailerService, // Para enviar e-mail
  ) {}

  /**
   * Lógica principal de geração do relatório.
   * Usamos processamento em Typescript para facilitar a leitura e manutenção.
   */
  async gerarRelatorioSolicitacoes(
    dto: GerarRelatorioSolicitacoesDto,
  ): Promise<RelatorioRow[]> {
    const { startDate, endDate } = dto;

    if (new Date(endDate) < new Date(startDate)) {
      throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
    }

    // 1. Busca todas as escolas (para garantir que escolas sem pedidos apareçam)
    const allEscolas = await this.escolaRepository.find({ order: { name: 'ASC' } });

    // 2. Busca todas as solicitações no período, com seus itens
    const solicitacoesNoPeriodo = await this.solicitacaoRepository.find({
      where: {
        createdAt: Between(new Date(startDate), new Date(endDate + ' 23:59:59')),
      },
      relations: ['school', 'items'],
    });

    // 3. Inicia o mapa do relatório com todas as escolas
    const reportMap = new Map<string, RelatorioRow>();
    for (const escola of allEscolas) {
      reportMap.set(escola.id, {
        escolaId: escola.id,
        escolaName: escola.name,
        totalSolicitacoes: 0,
        totalItensSolicitados: 0,
        totalItensAprovados: 0,
        totalComDivergencia: 0,
        taxaAtendimento: 0,
      });
    }

    // 4. Processa as solicitações
    for (const s of solicitacoesNoPeriodo) {
      if (!s.school || !reportMap.has(s.school.id)) {
        continue; // Ignora solicitações de escolas excluídas
      }

      const row = reportMap.get(s.school.id)!;
      row.totalSolicitacoes++;

      if (s.status === SolicitacaoStatus.RECEBIDO_COM_DIVERGENCIA) {
        row.totalComDivergencia++;
      }

      // Soma os itens
      for (const item of s.items) {
        row.totalItensSolicitados += item.quantityRequested || 0;
        row.totalItensAprovados += item.quantityApproved || 0;
      }
    }

    // 5. Converte o Mapa para Array e calcula a Taxa de Atendimento
    const finalReport = Array.from(reportMap.values()).map((row) => {
      const taxaAtendimento =
        row.totalItensSolicitados > 0
          ? (row.totalItensAprovados / row.totalItensSolicitados) * 100
          : 0;

      return {
        ...row,
        taxaAtendimento: parseFloat(taxaAtendimento.toFixed(2)), // Arredonda para 2 casas
      };
    });

    finalReport.sort((a, b) => {
      // 1. Ordena por Itens Solicitados (Maior para Menor)
      if (a.totalItensSolicitados !== b.totalItensSolicitados) {
        return b.totalItensSolicitados - a.totalItensSolicitados;
      }
      // 2. Se empatar, ordena por Total de Pedidos (Maior para Menor)
      return b.totalSolicitacoes - a.totalSolicitacoes;
    });

    return finalReport;
  }

  /**
   * Envia o relatório por e-mail para os gestores.
   */
  async enviarRelatorioPorEmail(
    dto: GerarRelatorioSolicitacoesDto,
    requester: User, // Usuário (Prefeitura) que solicitou o envio
  ) {
    // 1. Gera os dados do relatório
    const reportData = await this.gerarRelatorioSolicitacoes(dto);
    
    // 2. Calcula os totais gerais
    const totalGeral = reportData.reduce(
      (acc, row) => {
        acc.solicitacoes += row.totalSolicitacoes;
        acc.itensSolicitados += row.totalItensSolicitados;
        acc.itensAprovados += row.totalItensAprovados;
        acc.divergencias += row.totalComDivergencia;
        return acc;
      },
      { solicitacoes: 0, itensSolicitados: 0, itensAprovados: 0, divergencias: 0 },
    );
    
    // 3. Busca os e-mails dos Gestores de Escola
    const gestores = await this.usersService.findAllByProfile(UserProfile.ESCOLA);
    const emailsBcc = gestores.map((g) => g.email).filter(Boolean); // Remove nulos/vazios

    if (emailsBcc.length === 0) {
      throw new NotFoundException('Nenhum gestor de escola ativo encontrado para enviar o e-mail.');
    }

    // 4. Formata datas para o template
    const dataInicioFmt = format(parseISO(dto.startDate), 'dd/MM/yyyy', { locale: ptBR });
    const dataFimFmt = format(parseISO(dto.endDate), 'dd/MM/yyyy', { locale: ptBR });

    // 5. Envia o e-mail
    try {
      await this.mailerService.sendMail({
        to: requester.email, // Envia para quem solicitou
        bcc: emailsBcc, // Envia em cópia oculta para todos os gestores
        subject: `[GEMA] Relatório Consolidado de Solicitações (${dataInicioFmt} a ${dataFimFmt})`,
        template: 'relatorio-solicitacoes', // Nome do arquivo .hbs
        context: {
          dataInicio: dataInicioFmt,
          dataFim: dataFimFmt,
          reportData: reportData,
          totalGeral: totalGeral,
          requesterName: requester.name,
        },
      });
      return { message: `Relatório enviado com sucesso para ${emailsBcc.length + 1} destinatário(s).` };
    } catch (error) {
      this.logger.error(`Falha ao enviar e-mail de relatório: ${error.message}`, error.stack);
      throw new BadRequestException('Falha ao enviar o e-mail do relatório.');
    }
  }
  async gerarRelatorioEnvios(
    dto: GerarRelatorioSolicitacoesDto,
  ): Promise<RelatorioEnvioRow[]> {
    const { startDate, endDate } = dto;

    if (new Date(endDate) < new Date(startDate)) {
      throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
    }

    // 1. Busca as movimentações de saída da prefeitura para solicitações
    const movimentacoes = await this.movimentacaoRepo.find({
      where: {
        contexto: 'prefeitura',
        motivoCategoria: MotivoMovimentacao.SAIDA_SOLICITACAO,
        createdAt: Between(new Date(startDate), new Date(endDate + ' 23:59:59')),
      },
      relations: ['product'], // 'product' já é eager, mas garantimos
      order: {
        createdAt: 'DESC', // Ordena por mais recente
      },
    });

    // 2. Regex para extrair dados da observação
    // Ex: "Saída p/ Solicitação Escola: Escola Modelo (ID: a1b2c3d4)"
    const regex = /Saída p\/ Solicitação Escola: (.*?) \(ID: (.*?)\)/;

    // 3. Formata os dados
    const reportData: RelatorioEnvioRow[] = [];
    for (const mov of movimentacoes) {
      if (!mov.product) continue; // Ignora se o produto foi deletado

      let escolaName = 'N/A';
      let solicitacaoId = 'N/A';

      // Tenta extrair dados da observação
      if (mov.motivoObservacao) {
        const match = mov.motivoObservacao.match(regex);
        if (match && match[1] && match[2]) {
          escolaName = match[1].trim();
          solicitacaoId = match[2].trim();
        }
      }

      reportData.push({
        dataEnvio: mov.createdAt,
        escolaName: escolaName,
        productName: mov.product.name,
        unit: mov.product.unit,
        quantidadeEnviada: mov.quantidade,
        solicitacaoId: solicitacaoId,
      });
    }

    // 4. Agrupa os resultados por escola (como solicitado)
    // Primeiro, criamos um mapa
    const grouped = new Map<string, Map<string, RelatorioEnvioRow>>();

    for (const row of reportData) {
      if (!grouped.has(row.escolaName)) {
        grouped.set(row.escolaName, new Map<string, RelatorioEnvioRow>());
      }
      const escolaMap = grouped.get(row.escolaName)!;

      if (!escolaMap.has(row.productName)) {
        // Se é a primeira vez desse produto para essa escola, adiciona
        escolaMap.set(row.productName, { ...row });
      } else {
        // Se já existe, apenas soma a quantidade
        const existingRow = escolaMap.get(row.productName)!;
        existingRow.quantidadeEnviada += row.quantidadeEnviada;
      }
    }

    // 5. Achata o mapa agrupado para o formato final
    const finalReport: RelatorioEnvioRow[] = [];
    grouped.forEach((productMap) => {
      productMap.forEach((row) => {
        finalReport.push(row);
      });
    });

    // 6. Ordena por nome da escola e nome do produto
    finalReport.sort((a, b) => {
      if (a.escolaName !== b.escolaName) {
        return a.escolaName.localeCompare(b.escolaName);
      }
      return a.productName.localeCompare(b.productName);
    });

    return finalReport;
  }

  async gerarRelatorioAjustesEscolas(
    dto: GerarRelatorioSolicitacoesDto,
  ): Promise<RelatorioAjusteEscolaRow[]> {
    const { startDate, endDate } = dto;

    if (new Date(endDate) < new Date(startDate)) {
      throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
    }

    // 1. Define os motivos manuais que queremos capturar
    const motivosManuaisSaida = [
      MotivoMovimentacao.AJUSTE,
      MotivoMovimentacao.PERDA,
      MotivoMovimentacao.USO_INTERNO,
      MotivoMovimentacao.VENCIMENTO,
      MotivoMovimentacao.OUTRO,
    ];

    // 2. Busca as movimentações que batem com os critérios
    const movimentacoes = await this.movimentacaoRepo.find({
      where: {
        contexto: 'escola',
        tipo: TipoMovimentacao.SAIDA,
        motivoCategoria: In(motivosManuaisSaida), // Apenas os motivos que queremos
        createdAt: Between(new Date(startDate), new Date(endDate + ' 23:59:59')),
      },
      relations: ['product', 'school'], // Carrega o produto e a escola
      order: {
        createdAt: 'DESC',
      },
    });

    // 3. Agrupa os resultados (soma as quantidades)
    // Chave do mapa: "escolaId-productId-motivoCategoria-observacao"
    const reportMap = new Map<string, RelatorioAjusteEscolaRow>();

    for (const mov of movimentacoes) {
      // Ignora movimentações sem escola ou produto (dados órfãos)
      if (!mov.school || !mov.product) {
        continue;
      }

      const obs = mov.motivoObservacao || ''; // Trata observação nula
      const key = `${mov.school.id}-${mov.product.id}-${mov.motivoCategoria}-${obs}`;

      if (reportMap.has(key)) {
        // Se já existe, apenas soma a quantidade
        const row = reportMap.get(key)!;
        row.quantidadeTotal += mov.quantidade;
      } else {
        // Se não existe, cria a nova linha
        reportMap.set(key, {
          escolaId: mov.school.id,
          escolaName: mov.school.name,
          productId: mov.product.id,
          productName: mov.product.name,
          unit: mov.product.unit,
          motivoCategoria: mov.motivoCategoria,
          motivoObservacao: mov.motivoObservacao,
          quantidadeTotal: mov.quantidade,
        });
      }
    }

    // 4. Converte o mapa em um array e ordena
    const finalReport = Array.from(reportMap.values());
    finalReport.sort((a, b) => {
      if (a.escolaName !== b.escolaName) {
        return a.escolaName.localeCompare(b.escolaName);
      }
      if (a.productName !== b.productName) {
        return a.productName.localeCompare(b.productName);
      }
      return a.motivoCategoria.localeCompare(b.motivoCategoria);
    });

    return finalReport;
  }

  async gerarRelatorioAjustesPrefeitura(
    dto: GerarRelatorioSolicitacoesDto,
  ): Promise<RelatorioAjustePrefeituraRow[]> {
    const { startDate, endDate } = dto;

    if (new Date(endDate) < new Date(startDate)) {
      throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
    }

    // 1. Define os motivos manuais que queremos capturar (exclui SAIDA_SOLICITACAO)
    const motivosManuaisSaida = [
      MotivoMovimentacao.AJUSTE,
      MotivoMovimentacao.PERDA,
      MotivoMovimentacao.USO_INTERNO,
      MotivoMovimentacao.VENCIMENTO,
      MotivoMovimentacao.OUTRO,
    ];

    // 2. Busca as movimentações que batem com os critérios
    const movimentacoes = await this.movimentacaoRepo.find({
      where: {
        contexto: 'prefeitura', // <-- MUDANÇA AQUI
        tipo: TipoMovimentacao.SAIDA,
        motivoCategoria: In(motivosManuaisSaida), // Apenas os motivos manuais
        createdAt: Between(new Date(startDate), new Date(endDate + ' 23:59:59')),
      },
      relations: ['product'], // Carrega o produto
      order: {
        createdAt: 'DESC',
      },
    });

    // 3. Agrupa os resultados (soma as quantidades)
    // Chave do mapa: "productId-motivoCategoria-observacao"
    const reportMap = new Map<string, RelatorioAjustePrefeituraRow>();

    for (const mov of movimentacoes) {
      if (!mov.product) {
        continue; // Ignora se produto foi deletado
      }

      const obs = mov.motivoObservacao || ''; // Trata observação nula
      const key = `${mov.product.id}-${mov.motivoCategoria}-${obs}`;

      if (reportMap.has(key)) {
        // Se já existe, apenas soma a quantidade
        const row = reportMap.get(key)!;
        row.quantidadeTotal += mov.quantidade;
      } else {
        // Se não existe, cria a nova linha
        reportMap.set(key, {
          productId: mov.product.id,
          productName: mov.product.name,
          unit: mov.product.unit,
          motivoCategoria: mov.motivoCategoria,
          motivoObservacao: mov.motivoObservacao,
          quantidadeTotal: mov.quantidade,
        });
      }
    }

    // 4. Converte o mapa em um array e ordena
    const finalReport = Array.from(reportMap.values());
    finalReport.sort((a, b) => {
      if (a.productName !== b.productName) {
        return a.productName.localeCompare(b.productName);
      }
      return a.motivoCategoria.localeCompare(b.motivoCategoria);
    });

    return finalReport;
  }

  async getRelatoriosSnapshot(): Promise<RelatorioSnapshot> {
    
    // 1. Total de Solicitações (Geral)
    const totalSolicitacoes = await this.solicitacaoRepository.count();

    // 2. Total de Itens Enviados (Saídas da Prefeitura para Escolas)
    const enviosResult = await this.movimentacaoRepo
      .createQueryBuilder('mov')
      .select('SUM(mov.quantidade)', 'total')
      .where('mov.contexto = :contexto', { contexto: 'prefeitura' })
      .andWhere('mov.motivoCategoria = :motivo', { motivo: MotivoMovimentacao.SAIDA_SOLICITACAO })
      .getRawOne();
    const totalItensEnviados = parseFloat(enviosResult.total) || 0;

    // 3. Total de Perdas (Prefeitura) - (Saídas manuais)
    const motivosPerda = [
      MotivoMovimentacao.AJUSTE,
      MotivoMovimentacao.PERDA,
      MotivoMovimentacao.USO_INTERNO,
      MotivoMovimentacao.VENCIMENTO,
      MotivoMovimentacao.OUTRO,
    ];
    const perdasPrefeituraResult = await this.movimentacaoRepo
      .createQueryBuilder('mov')
      .select('SUM(mov.quantidade)', 'total')
      .where('mov.contexto = :contexto', { contexto: 'prefeitura' })
      .andWhere('mov.tipo = :tipo', { tipo: TipoMovimentacao.SAIDA })
      .andWhere('mov.motivoCategoria IN (:...motivos)', { motivos: motivosPerda })
      .getRawOne();
    const totalPerdasPrefeitura = parseFloat(perdasPrefeituraResult.total) || 0;

    // 4. Total de Perdas (Escolas) - (Qualquer saída, pois escolas só registram saídas manuais)
    const perdasEscolasResult = await this.movimentacaoRepo
      .createQueryBuilder('mov')
      .select('SUM(mov.quantidade)', 'total')
      .where('mov.contexto = :contexto', { contexto: 'escola' })
      .andWhere('mov.tipo = :tipo', { tipo: TipoMovimentacao.SAIDA })
      .getRawOne();
    const totalPerdasEscolas = parseFloat(perdasEscolasResult.total) || 0;

    return {
      totalSolicitacoes,
      totalItensEnviados,
      totalPerdasPrefeitura,
      totalPerdasEscolas,
    };
  }

  async enviarRelatorioAjustesEscolas(
    dto: GerarRelatorioSolicitacoesDto,
    requester: User, // Usuário (Prefeitura) que solicitou o envio
  ) {
    // 1. Gera os dados do relatório
    const reportData = await this.gerarRelatorioAjustesEscolas(dto);

    // 2. Calcula os totais gerais
    const totalGeral = reportData.reduce(
      (acc, row) => {
        acc.quantidadeTotal += row.quantidadeTotal;
        return acc;
      },
      { quantidadeTotal: 0 },
    );

    // 3. Busca os e-mails dos Gestores de Escola
    const gestores = await this.usersService.findAllByProfile(UserProfile.ESCOLA);
    const emailsBcc = gestores.map((g) => g.email).filter(Boolean);

    if (emailsBcc.length === 0) {
      throw new NotFoundException('Nenhum gestor de escola ativo encontrado para enviar o e-mail.');
    }

    // 4. Formata datas para o template
    const dataInicioFmt = format(parseISO(dto.startDate), 'dd/MM/yyyy', { locale: ptBR });
    const dataFimFmt = format(parseISO(dto.endDate), 'dd/MM/yyyy', { locale: ptBR });

    // 5. Envia o e-mail
    try {
      await this.mailerService.sendMail({
        to: requester.email, // Envia para quem solicitou
        bcc: emailsBcc, // Envia em cópia oculta para todos os gestores
        subject: `[GEMA] Relatório de Ajustes e Perdas nas Escolas (${dataInicioFmt} a ${dataFimFmt})`,
        template: 'relatorio-ajustes-escolas', // <-- Novo template .hbs
        context: {
          dataInicio: dataInicioFmt,
          dataFim: dataFimFmt,
          reportData: reportData,
          totalGeral: totalGeral,
          requesterName: requester.name,
        },
      });
      return { message: `Relatório enviado com sucesso para ${emailsBcc.length + 1} destinatário(s).` };
    } catch (error) {
      this.logger.error(`Falha ao enviar e-mail de relatório de ajustes: ${error.message}`, error.stack);
      throw new BadRequestException('Falha ao enviar o e-mail do relatório.');
    }
  }

  async gerarRelatorioEntradasPrefeitura(
    dto: GerarRelatorioSolicitacoesDto,
  ): Promise<RelatorioEntradaPrefeituraRow[]> {
    const { startDate, endDate } = dto;

    if (new Date(endDate) < new Date(startDate)) {
      throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
    }

    // 1. Busca as movimentações de ENTRADA no estoque da PREFEITURA
    //    que foram feitas por AJUSTE (isso inclui importação por planilha)
    const movimentacoes = await this.movimentacaoRepo.find({
      where: {
        contexto: 'prefeitura',
        tipo: TipoMovimentacao.ENTRADA,
        motivoCategoria: MotivoMovimentacao.AJUSTE, // Captura tanto ajuste manual quanto importação
        createdAt: Between(new Date(startDate), new Date(endDate + ' 23:59:59')),
      },
      relations: ['product', 'user'], // Carrega o produto e o usuário que fez
      order: {
        createdAt: 'DESC',
      },
    });

    // 3. Agrupa os resultados (soma as quantidades)
    // Chave do mapa: "productId-observacao-userId"
    const reportMap = new Map<string, RelatorioEntradaPrefeituraRow>();

    for (const mov of movimentacoes) {
      // Ignora movimentações sem produto ou usuário (dados órfãos)
      if (!mov.product || !mov.user) {
        continue;
      }

      const obs = mov.motivoObservacao || '';
      const key = `${mov.product.id}-${obs}-${mov.user.id}`;

      if (reportMap.has(key)) {
        // Se já existe, apenas soma a quantidade
        const row = reportMap.get(key)!;
        row.quantidadeAdicionada += mov.quantidade;
      } else {
        // Se não existe, cria a nova linha
        reportMap.set(key, {
          productId: mov.product.id,
          productName: mov.product.name,
          unit: mov.product.unit,
          quantidadeAdicionada: mov.quantidade,
          motivoObservacao: mov.motivoObservacao,
          userName: mov.user.name,
        });
      }
    }

    // 4. Converte o mapa em um array e ordena
    const finalReport = Array.from(reportMap.values());
    finalReport.sort((a, b) => {
      if (a.productName !== b.productName) {
        return a.productName.localeCompare(b.productName);
      }
      return a.userName.localeCompare(b.userName);
    });

    return finalReport;
  }

  private readonly logger = new Logger(RelatoriosService.name);
}