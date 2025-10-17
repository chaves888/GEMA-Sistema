// src/escolas/escolas.module.ts
import { Module } from '@nestjs/common';
import { EscolasService } from './escolas.service';
import { EscolasController } from './escolas.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Escola } from './entities/escola.entity';
import { Cidade } from 'src/cidades/entities/cidade.entity';
import { User } from 'src/users/entities/user.entity';
import { EscolaEstoque } from 'src/estoque/entities/escola-estoque.entity'; // <-- 1. IMPORTE A ENTIDADE

@Module({
  // 2. ADICIONE A ENTIDADE AO ARRAY
  imports: [TypeOrmModule.forFeature([Escola, Cidade, User, EscolaEstoque])], 
  controllers: [EscolasController],
  providers: [EscolasService],
})
export class EscolasModule {}