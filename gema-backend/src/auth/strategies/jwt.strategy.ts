// src/auth/strategies/jwt.strategy.ts
import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { jwtConstants } from '../auth.module';
import { UsersService } from 'src/users/users.service';
import { User } from 'src/users/entities/user.entity'; // Importa o tipo User

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private usersService: UsersService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: jwtConstants.secret,
    });
  }

  // --- CORREÇÃO AQUI ---
  // O tipo de retorno agora é o mesmo do UsersService.findOne
  async validate(payload: any): Promise<Omit<User, 'password' | 'hashPassword'>> {
    // Usa o ID do token (payload.sub) para buscar o usuário
    const user = await this.usersService.findOne(payload.sub); 
    
    if (!user) {
      throw new UnauthorizedException('Token inválido ou usuário não encontrado.');
    }
    
    // Retorna o objeto de dados simples
    return user; 
  }
}