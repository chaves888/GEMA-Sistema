import { Module } from '@nestjs/common';
import { CardapiosService } from './cardapios.service';
import { CardapiosController } from './cardapios.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Cardapio } from './entities/cardapio.entity';
import { Refeicao } from './entities/refeicao.entity';
import { Product } from 'src/products/entities/product.entity';
import { User } from 'src/users/entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Cardapio, Refeicao, Product, User])],
  controllers: [CardapiosController],
  providers: [CardapiosService],
})
export class CardapiosModule {}