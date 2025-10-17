// src/app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { ProductsModule } from './products/products.module';
import { CidadesModule } from './cidades/cidades.module';
import { EscolasModule } from './escolas/escolas.module';
import { EstoqueModule } from './estoque/estoque.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: 'localhost',
      port: 3306,
      username: 'root', // Usuário padrão do XAMPP
      password: '', // Senha padrão do XAMPP é vazia
      database: 'gema_db',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: true, // IMPORTANTE: Em desenvolvimento, cria as tabelas automaticamente
    }),
    UsersModule,
    AuthModule,
    ProductsModule,
    CidadesModule,
    EscolasModule,
    EstoqueModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}