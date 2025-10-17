// src/users/users.module.ts
import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { Escola } from 'src/escolas/entities/escola.entity'; // <-- 1. Importe a Escola

@Module({
  imports: [TypeOrmModule.forFeature([User, Escola])], // <-- 2. Adicione a Escola aqui
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}