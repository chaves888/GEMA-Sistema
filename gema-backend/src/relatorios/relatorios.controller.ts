import { Controller, Post, Body, UseGuards, Req, Get } from '@nestjs/common';
import { RelatorioEnvioRow, RelatoriosService, RelatorioAjusteEscolaRow, RelatorioAjustePrefeituraRow, RelatorioSnapshot } from './relatorios.service';
import { GerarRelatorioSolicitacoesDto } from './dto/gerar-relatorio-solicitacoes.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { User, UserProfile } from 'src/users/entities/user.entity';
import { Request } from 'express';

// Interface para garantir req.user
interface RequestWithUser extends Request {
  user: User;
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserProfile.PREFEITURA) // Apenas prefeitura pode ver relatórios
@Controller('relatorios')
export class RelatoriosController {
  constructor(private readonly relatoriosService: RelatoriosService) {}

  /**
   * Endpoint para gerar e visualizar o relatório em tela.
   */
  @Post('solicitacoes-por-escola')
  gerarRelatorioSolicitacoes(@Body() dto: GerarRelatorioSolicitacoesDto) {
    return this.relatoriosService.gerarRelatorioSolicitacoes(dto);
  }

  /**
   * Endpoint para disparar o envio de e-mail.
   */
  @Post('solicitacoes-por-escola/enviar-email')
  enviarRelatorioPorEmail(
    @Body() dto: GerarRelatorioSolicitacoesDto,
    @Req() req: RequestWithUser, // Pega o usuário logado
  ) {
    return this.relatoriosService.enviarRelatorioPorEmail(dto, req.user);
  }
  @Post('envios-estoque-central')
  gerarRelatorioEnvios(
    @Body() dto: GerarRelatorioSolicitacoesDto,
  ): Promise<RelatorioEnvioRow[]> {
    return this.relatoriosService.gerarRelatorioEnvios(dto);
  }

  @Post('ajustes-perdas-escolas')
  gerarRelatorioAjustesEscolas(
    @Body() dto: GerarRelatorioSolicitacoesDto,
  ): Promise<RelatorioAjusteEscolaRow[]> {
    return this.relatoriosService.gerarRelatorioAjustesEscolas(dto);
  }
  
  @Post('ajustes-perdas-escolas/enviar-email')
  enviarRelatorioAjustesEscolas(
    @Body() dto: GerarRelatorioSolicitacoesDto,
    @Req() req: RequestWithUser, // Pega o usuário logado
  ) {
    return this.relatoriosService.enviarRelatorioAjustesEscolas(dto, req.user);
  }

  @Post('ajustes-perdas-prefeitura')
  gerarRelatorioAjustesPrefeitura(
    @Body() dto: GerarRelatorioSolicitacoesDto,
  ): Promise<RelatorioAjustePrefeituraRow[]> {
    return this.relatoriosService.gerarRelatorioAjustesPrefeitura(dto);
  }

  @Get('snapshot')
  getRelatoriosSnapshot(): Promise<RelatorioSnapshot> {
    return this.relatoriosService.getRelatoriosSnapshot();
  }
}