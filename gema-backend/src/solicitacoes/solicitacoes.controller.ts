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

interface RequestWithUser extends Request { user: User; }

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('solicitacoes')
export class SolicitacoesController {
  constructor(private readonly solicitacoesService: SolicitacoesService) {}

  // --- ROTA DE CRIAÇÃO (ESCOLA) ---
  @Post()
  @Roles(UserProfile.ESCOLA)
  create(@Body() createSolicitacaoDto: CreateSolicitacaoDto, @Req() req: RequestWithUser) {
    // Passa o DTO e o usuário logado para o serviço criar a solicitação
    return this.solicitacoesService.create(createSolicitacaoDto, req.user);
  }

  // --- ROTA DE LISTAGEM (ESCOLA E PREFEITURA) ---
  @Get()
  @Roles(UserProfile.PREFEITURA, UserProfile.ESCOLA) 
  findAll(@Req() req: RequestWithUser) {
    // Passa o usuário logado para o serviço filtrar a lista corretamente
    return this.solicitacoesService.findAll(req.user);
  }

  // --- ROTA PARA VER DETALHES DE UMA SOLICITAÇÃO ---
  @Get(':id')
  @Roles(UserProfile.PREFEITURA, UserProfile.ESCOLA) // Ambos podem ver detalhes
  findOne(@Param('id', ParseUUIDPipe) id: string) { 
     return this.solicitacoesService.findOne(id);
  }

  // --- ROTAS A SEREM IMPLEMENTADAS DEPOIS ---

  @Patch(':id/analisar')
  @Roles(UserProfile.PREFEITURA)
  analyze(@Param('id', ParseUUIDPipe) id: string, @Body() analyzeDto: AnalyzeSolicitacaoDto) {
    return this.solicitacoesService.analyze(id, analyzeDto);
  }

  @Patch(':id/confirmar')
  @Roles(UserProfile.ESCOLA) 
  confirmRecebimento(
    @Param('id', ParseUUIDPipe) id: string, 
    @Body() confirmDto: ConfirmRecebimentoDto,
    @Req() req: RequestWithUser 
  ) {
    return this.solicitacoesService.confirmRecebimento(id, confirmDto, req.user);
  }

  @Delete(':id')
  @Roles(UserProfile.PREFEITURA) 
  @HttpCode(204)
  remove(@Param('id', ParseUUIDPipe) id: string) {
     return this.solicitacoesService.remove(id);
  }
}