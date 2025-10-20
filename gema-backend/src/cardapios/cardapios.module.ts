// src/cardapios/cardapios.module.ts
import { Module } from '@nestjs/common';
import { CardapiosService } from './cardapios.service';
import { CardapiosController } from './cardapios.controller';
import { TypeOrmModule } from '@nestjs/typeorm';

// Importa as entidades que criamos para este módulo
import { Cardapio } from './entities/cardapio.entity';
import { Refeicao } from './entities/refeicao.entity';
import { RefeicaoItem } from './entities/refeicao-item.entity';

// Importa entidades de outros módulos que serão usadas pelo CardapiosService
import { Product } from 'src/products/entities/product.entity';
import { User } from 'src/users/entities/user.entity';
import { Escola } from 'src/escolas/entities/escola.entity'; // Pode ser útil no futuro

@Module({
  imports: [
    // Registra todas as entidades necessárias para este módulo no TypeORM
    TypeOrmModule.forFeature([
      // Entidades principais do módulo
      Cardapio,
      Refeicao,
      RefeicaoItem,
      // Entidades relacionadas que o CardapiosService precisará acessar
      Product, 
      User, 
      Escola, 
    ])
  ],
  controllers: [CardapiosController], // O controller gerado pelo CLI
  providers: [CardapiosService], // O service gerado pelo CLI
})
export class CardapiosModule {}