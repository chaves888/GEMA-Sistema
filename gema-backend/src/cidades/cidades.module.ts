// src/cidades/cidades.module.ts
import { Module } from '@nestjs/common';
import { CidadesService } from './cidades.service';
import { CidadesController } from './cidades.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Cidade } from './entities/cidade.entity';
import { Escola } from 'src/escolas/entities/escola.entity';
import { User } from 'src/users/entities/user.entity'; // 1. Importar User

@Module({
	imports: [TypeOrmModule.forFeature([Cidade, Escola, User])], // 2. Adicionar User
	controllers: [CidadesController],
	providers: [CidadesService],
})
export class CidadesModule {}