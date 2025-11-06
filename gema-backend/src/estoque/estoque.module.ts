// src/estoque/estoque.module.ts
import { Module } from '@nestjs/common';
import { EstoqueService } from './estoque.service';
import { EstoqueController } from './estoque.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PrefeituraEstoque } from './entities/prefeitura-estoque.entity';
import { EscolaEstoque } from './entities/escola-estoque.entity';
import { Product } from 'src/products/entities/product.entity';
import { Escola } from 'src/escolas/entities/escola.entity';
import { EstoqueMovimentacao } from './entities/estoque-movimentacao.entity';
import { User } from 'src/users/entities/user.entity';

@Module({
	imports: [
		TypeOrmModule.forFeature([
			PrefeituraEstoque,
			EscolaEstoque,
			Product,
			Escola,
			EstoqueMovimentacao,
			User,
		]),
	],
	controllers: [EstoqueController],
	providers: [EstoqueService],
	exports: [EstoqueService], // Exporta o serviço para outros módulos (Ex: Solicitacoes)
})
export class EstoqueModule {}