// src/estoque/estoque.module.ts
import { Module } from '@nestjs/common';
import { EstoqueService } from './estoque.service';
import { EstoqueController } from './estoque.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PrefeituraEstoque } from './entities/prefeitura-estoque.entity';
import { EscolaEstoque } from './entities/escola-estoque.entity';
import { Product } from 'src/products/entities/product.entity';
import { Escola } from 'src/escolas/entities/escola.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      PrefeituraEstoque,
      EscolaEstoque,
      Product,
      Escola,
    ]),
  ],
  controllers: [EstoqueController],
  providers: [EstoqueService],
})
export class EstoqueModule {}