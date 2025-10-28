import { Module } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { DashboardController } from './dashboard.controller';
import { TypeOrmModule } from '@nestjs/typeorm';

// Importar todas as entidades que o DashboardService precisará consultar
import { Solicitacao } from 'src/solicitacoes/entities/solicitacao.entity';
import { PrefeituraEstoque } from 'src/estoque/entities/prefeitura-estoque.entity';
import { EscolaEstoque } from 'src/estoque/entities/escola-estoque.entity';
import { Cardapio } from 'src/cardapios/entities/cardapio.entity';
import { User } from 'src/users/entities/user.entity';
import { Escola } from 'src/escolas/entities/escola.entity';
import { Product } from 'src/products/entities/product.entity';
// Importar o EstoqueService para reutilizar a lógica de status/percentage
import { EstoqueModule } from 'src/estoque/estoque.module'; // Importar o Módulo
import { EstoqueService } from 'src/estoque/estoque.service'; // Importar o Serviço

@Module({
  imports: [
    TypeOrmModule.forFeature([
      // Entidades necessárias para consultas
      Solicitacao,
      PrefeituraEstoque,
      EscolaEstoque,
      Cardapio,
      User,
      Escola,
      Product,
    ]),
    EstoqueModule, // Importa o EstoqueModule para poder usar o EstoqueService
  ],
  controllers: [DashboardController],
  providers: [
    DashboardService,
    // Não precisa mais declarar o EstoqueService aqui se importou o EstoqueModule
  ],
})
export class DashboardModule {}