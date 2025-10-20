// src/cardapios/cardapios.controller.ts
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Req, ParseUUIDPipe, HttpCode } from '@nestjs/common';
import { CardapiosService } from './cardapios.service';
import { CreateCardapioDto } from './dto/create-cardapio.dto';
import { CreateRefeicaoDto } from './dto/create-refeicao.dto'; 
import { UpdateRefeicaoItemDto } from './dto/update-refeicao-item.dto'; // <-- DTOs de update
import { UpdateRefeicaoDto } from './dto/update-refeicao.dto';     // <-- DTOs de update
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { User, UserProfile } from 'src/users/entities/user.entity';
import { Request } from 'express';

interface RequestWithUser extends Request { user: User; }

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('cardapios')
export class CardapiosController {
  constructor(private readonly cardapiosService: CardapiosService) {}

  @Post()
  @Roles(UserProfile.NUTRICIONISTA)
  create(@Body() createCardapioDto: CreateCardapioDto, @Req() req: RequestWithUser) {
    // Passa o DTO e o usuário
    return this.cardapiosService.create(createCardapioDto, req.user); 
  }

  @Post(':cardapioId/refeicoes')
  @Roles(UserProfile.NUTRICIONISTA)
  addRefeicao(
    @Param('cardapioId', ParseUUIDPipe) cardapioId: string,
    @Body() createRefeicaoDto: CreateRefeicaoDto,
    @Req() req: RequestWithUser
  ) {
    // Passa IDs, DTO e usuário
    return this.cardapiosService.addRefeicao(cardapioId, createRefeicaoDto, req.user); 
  }

  @Get()
  @Roles(UserProfile.NUTRICIONISTA, UserProfile.ESCOLA, UserProfile.COZINHEIRA, UserProfile.PREFEITURA)
  findAll(@Req() req: RequestWithUser) { 
    // Passa o usuário
    return this.cardapiosService.findAll(req.user); 
  }

  @Get(':id')
  @Roles(UserProfile.NUTRICIONISTA, UserProfile.ESCOLA, UserProfile.COZINHEIRA, UserProfile.PREFEITURA)
  findOne(@Param('id', ParseUUIDPipe) id: string, @Req() req: RequestWithUser) {
    // Passa o ID e o usuário
    return this.cardapiosService.findOne(id, req.user); 
  }

  // REMOVEMOS O MÉTODO UPDATE GENÉRICO QUE NÃO EXISTE NO SERVICE
  // @Patch(':id')
  // @Roles(UserProfile.NUTRICIONISTA) 
  // update(...) { ... }

  @Delete(':id')
  @Roles(UserProfile.NUTRICIONISTA) 
  @HttpCode(204)
  remove(@Param('id', ParseUUIDPipe) id: string, @Req() req: RequestWithUser) {
    // Passa o ID e o usuário
    return this.cardapiosService.remove(id, req.user); 
  }
  
  // --- Rotas de Edição/Remoção de Refeição/Item ---
  
  @Patch('refeicoes/:refeicaoId') 
  @Roles(UserProfile.NUTRICIONISTA)
  updateRefeicao(
    @Param('refeicaoId', ParseUUIDPipe) refeicaoId: string,
    @Body() dto: UpdateRefeicaoDto,
    @Req() req: RequestWithUser
  ) {
    // Passa ID, DTO e usuário
    return this.cardapiosService.updateRefeicao(refeicaoId, dto, req.user); 
  }
  
  @Patch('refeicoes/items/:itemId') 
  @Roles(UserProfile.NUTRICIONISTA)
  updateRefeicaoItem(
      @Param('itemId', ParseUUIDPipe) itemId: string,
      @Body() dto: UpdateRefeicaoItemDto,
      @Req() req: RequestWithUser
  ){
      // Passa ID, DTO e usuário
      return this.cardapiosService.updateRefeicaoItem(itemId, dto, req.user); 
  }

  @Delete('refeicoes/items/:itemId')
  @Roles(UserProfile.NUTRICIONISTA)
  @HttpCode(204)
  removeRefeicaoItem(
      @Param('itemId', ParseUUIDPipe) itemId: string,
      @Req() req: RequestWithUser
  ){
      // Passa ID e usuário
      return this.cardapiosService.removeRefeicaoItem(itemId, req.user); 
  }
}