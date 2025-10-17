import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, HttpCode } from '@nestjs/common';
import { EscolasService } from './escolas.service';
import { CreateEscolaDto } from './dto/create-escola.dto';
import { UpdateEscolaDto } from './dto/update-escola.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { UserProfile } from 'src/users/entities/user.entity';
import { Roles } from 'src/auth/decorators/roles.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('escolas')
export class EscolasController {
  constructor(private readonly escolasService: EscolasService) {}

  @Post()
  @Roles(UserProfile.PREFEITURA)
  create(@Body() createEscolaDto: CreateEscolaDto) {
    return this.escolasService.create(createEscolaDto);
  }

  @Get()
  findAll() {
    return this.escolasService.findAll();
  }

  @Get(':id')
  @Roles(UserProfile.PREFEITURA)
  findOne(@Param('id') id: string) {
    return this.escolasService.findOne(id);
  }

  @Patch(':id')
  @Roles(UserProfile.PREFEITURA)
  update(@Param('id') id: string, @Body() updateEscolaDto: UpdateEscolaDto) {
    return this.escolasService.update(id, updateEscolaDto);
  }

  @Delete(':id')
  @Roles(UserProfile.PREFEITURA)
  @HttpCode(204) // <-- CORREÇÃO APLICADA AQUI
  remove(@Param('id') id: string) {
    return this.escolasService.remove(id);
  }
}