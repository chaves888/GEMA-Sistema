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
import { SolicitacoesModule } from './solicitacoes/solicitacoes.module';
import { CardapiosModule } from './cardapios/cardapios.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { MailerModule } from '@nestjs-modules/mailer';
import * as path from 'path';
import { HandlebarsAdapter } from '@nestjs-modules/mailer/dist/adapters/handlebars.adapter';
import { RelatoriosModule } from './relatorios/relatorios.module';

@Module({
  imports: [
    MailerModule.forRoot({
      transport: {
        host: 'smtp.gmail.com', // Ex: 'smtp.gmail.com'
        port: 465,
        secure: true, // true para 465, false para outras portas
        auth: {
          user: 'chavitista@gmail.com', // <-- COLOQUE SEU E-MAIL (ou process.env.MAIL_USER)
          pass: 'zqjmugkvofstqgez', // <-- COLOQUE SUA SENHA (ou process.env.MAIL_PASS)
        },
      },
      defaults: {
        from: '"GEMA Sistema" <nao-responda@gema.com>',
      },
      // (Opcional) Se quiser usar templates HTML para os e-mails
      template: {
        dir: path.join(__dirname, '..', 'templates'),
        adapter: new HandlebarsAdapter(),
        options: {
          strict: true,
        },
      },
    }),

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
    SolicitacoesModule,
    CardapiosModule,
    DashboardModule,
    RelatoriosModule,
  ],
  
  controllers: [AppController],
  providers: [AppService],

})
export class AppModule {}