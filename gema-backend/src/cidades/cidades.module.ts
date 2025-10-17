// src/cidades/cidades.module.ts
import { Module } from '@nestjs/common';
import { CidadesService } from './cidades.service';
import { CidadesController } from './cidades.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Cidade } from './entities/cidade.entity';
import { Escola } from 'src/escolas/entities/escola.entity'; // <-- 1. IMPORTE A ESCOLA

@Module({
  imports: [TypeOrmModule.forFeature([Cidade, Escola])], // <-- 2. ADICIONE A ESCOLA AQUI
  controllers: [CidadesController],
  providers: [CidadesService],
})
export class CidadesModule {}