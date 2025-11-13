import { Module } from '@nestjs/common';
import { RelatoriosService } from './relatorios.service';
import { RelatoriosController } from './relatorios.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Solicitacao } from 'src/solicitacoes/entities/solicitacao.entity';
import { SolicitacaoItem } from 'src/solicitacoes/entities/solicitacao-item.entity';
import { Escola } from 'src/escolas/entities/escola.entity';
import { User } from 'src/users/entities/user.entity';
import { UsersModule } from 'src/users/users.module';
import { EstoqueMovimentacao } from 'src/estoque/entities/estoque-movimentacao.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Solicitacao,
      SolicitacaoItem,
      Escola,
      User,
      EstoqueMovimentacao,
    ]),
    UsersModule, // Importamos para ter acesso ao UsersService
  ],
  controllers: [RelatoriosController],
  providers: [RelatoriosService],
})
export class RelatoriosModule {}