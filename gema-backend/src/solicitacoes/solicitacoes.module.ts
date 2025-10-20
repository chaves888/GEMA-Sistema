// src/solicitacoes/solicitacoes.module.ts
import { Module } from '@nestjs/common';
import { SolicitacoesService } from './solicitacoes.service';
import { SolicitacoesController } from './solicitacoes.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Solicitacao } from './entities/solicitacao.entity';
import { SolicitacaoItem } from './entities/solicitacao-item.entity';
import { Product } from 'src/products/entities/product.entity';
import { EscolaEstoque } from 'src/estoque/entities/escola-estoque.entity';
import { PrefeituraEstoque } from 'src/estoque/entities/prefeitura-estoque.entity';
import { User } from 'src/users/entities/user.entity'; 
import { Escola } from 'src/escolas/entities/escola.entity';
import { EstoqueService } from 'src/estoque/estoque.service'; // Importa o EstoqueService

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Solicitacao, 
      SolicitacaoItem,
      Product,        
      Escola,         
      User,           
      EscolaEstoque,    
      PrefeituraEstoque, 
    ])
  ],
  controllers: [SolicitacoesController],
  // Disponibiliza o SolicitacoesService e também o EstoqueService para ser usado aqui dentro
  providers: [SolicitacoesService, EstoqueService], 
})
export class SolicitacoesModule {}