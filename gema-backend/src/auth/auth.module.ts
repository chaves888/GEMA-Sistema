// src/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { UsersModule } from 'src/users/users.module';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { LocalStrategy } from './strategies/local.strategy'; // Criaremos em breve
import { JwtStrategy } from './strategies/jwt.strategy';     // Criaremos em breve


export const jwtConstants = {
    // IMPORTANTE: Mude isso e coloque em um arquivo de segredos (.env)!
    secret: 'SEGREDO_SUPER_SECRETO_PARA_PROJETO_GEMA',
};

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.register({
      secret: jwtConstants.secret,
      signOptions: { expiresIn: '8h' }, // Token expira em 8 horas
    }),
  ],
  providers: [AuthService, LocalStrategy, JwtStrategy], // Adicione as estratégias
  controllers: [AuthController],
})
export class AuthModule {}