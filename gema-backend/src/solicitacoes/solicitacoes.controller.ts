// src/solicitacoes/solicitacoes.controller.ts
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Req, HttpCode, ParseUUIDPipe } from '@nestjs/common';
import { SolicitacoesService } from './solicitacoes.service';
import { CreateSolicitacaoDto } from './dto/create-solicitacao.dto';
import { AnalyzeSolicitacaoDto } from './dto/analyze-solicitacao.dto';
import { ConfirmRecebimentoDto } from './dto/confirm-recebimento.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { UserProfile, User } from 'src/users/entities/user.entity';
import { Request } from 'express';
import { CancelSolicitacaoDto } from './dto/cancel-solicitacao.dto'; // <-- NOVO IMPORT

interface RequestWithUser extends Request { user: User; }

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('solicitacoes')
export class SolicitacoesController {
  constructor(private readonly solicitacoesService: SolicitacoesService) {}

  // --- ROTA DE CRIAÇÃO (ESCOLA) ---
  @Post()
	@Roles(UserProfile.ESCOLA)
	create(@Body() createSolicitacaoDto: CreateSolicitacaoDto, @Req() req: RequestWithUser) {
		return this.solicitacoesService.create(createSolicitacaoDto, req.user);
	}

	@Get()
	@Roles(UserProfile.PREFEITURA, UserProfile.ESCOLA)
	findAll(@Req() req: RequestWithUser) {
		return this.solicitacoesService.findAll(req.user);
	}

	@Get('pendentes/count')
	@Roles(UserProfile.PREFEITURA)
	getPendentesCount() {
		return this.solicitacoesService.getPendentesCount();
	}

	@Get(':id')
	@Roles(UserProfile.PREFEITURA, UserProfile.ESCOLA)
	findOne(@Param('id', ParseUUIDPipe) id: string) {
		return this.solicitacoesService.findOne(id);
	}


	// --- ROTA ANALYZE MODIFICADA ---
	@Patch(':id/analisar')
	@Roles(UserProfile.PREFEITURA)
	analyze(
		@Param('id', ParseUUIDPipe) id: string,
		@Body() analyzeDto: AnalyzeSolicitacaoDto,
		@Req() req: RequestWithUser, // <-- ADICIONADO: Pegar o usuário logado
	) {
		// Passa o usuário logado (req.user) para o serviço
		return this.solicitacoesService.analyze(id, analyzeDto, req.user); 
	}
	// --- FIM DA MODIFICAÇÃO ---

	@Patch(':id/confirmar')
	@Roles(UserProfile.ESCOLA)
	confirmRecebimento(
		@Param('id', ParseUUIDPipe) id: string,
		@Body() confirmDto: ConfirmRecebimentoDto,
		@Req() req: RequestWithUser,
	) {
		return this.solicitacoesService.confirmRecebimento(id, confirmDto, req.user);
	}

	@Patch(':id/cancelar')
	@Roles(UserProfile.ESCOLA)
	cancelar(
		@Param('id', ParseUUIDPipe) id: string,
		@Body() cancelDto: CancelSolicitacaoDto,
		@Req() req: RequestWithUser,
	) {
		return this.solicitacoesService.cancelar(id, req.user, cancelDto);
	}

	@Delete(':id')
	@Roles(UserProfile.PREFEITURA)
	@HttpCode(204)
	remove(@Param('id', ParseUUIDPipe) id: string) {
		return this.solicitacoesService.remove(id);
	}
}