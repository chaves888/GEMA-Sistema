// src/cidades/cidades.controller.ts
import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, HttpCode } from '@nestjs/common';
import { CidadesService } from './cidades.service';
import { CreateCidadeDto } from './dto/create-cidade.dto';
import { UpdateCidadeDto } from './dto/update-cidade.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { UserProfile } from 'src/users/entities/user.entity';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('cidades')
export class CidadesController {
  constructor(private readonly cidadesService: CidadesService) {}

  @Post()
  @Roles(UserProfile.PREFEITURA)
  create(@Body() createCidadeDto: CreateCidadeDto) {
    return this.cidadesService.create(createCidadeDto);
  }

  @Get()
  // Todos os perfis logados podem ver as cidades
  findAll() {
    return this.cidadesService.findAll();
  }

  @Get(':id')
  @Roles(UserProfile.PREFEITURA)
  findOne(@Param('id') id: string) {
    return this.cidadesService.findOne(id);
  }

  @Patch(':id')
  @Roles(UserProfile.PREFEITURA)
  update(@Param('id') id: string, @Body() updateCidadeDto: UpdateCidadeDto) {
    return this.cidadesService.update(id, updateCidadeDto);
  }

  @Delete(':id')
  @Roles(UserProfile.PREFEITURA)
  @HttpCode(204) // Retorna o status 'No Content' em caso de sucesso
  remove(@Param('id') id: string) {
    return this.cidadesService.remove(id);
  }
}