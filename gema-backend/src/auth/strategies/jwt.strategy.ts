import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable } from '@nestjs/common';
import { jwtConstants } from '../auth.module';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: jwtConstants.secret,
    });
  }

  async validate(payload: any) {
    // A mudança está aqui: adicionamos 'school: payload.school'.
    // O objeto retornado aqui se torna o 'req.user' nos controllers,
    // agora contendo os dados da escola.
    return { 
      userId: payload.sub, 
      email: payload.email, 
      profile: payload.profile,
      school: payload.school 
    };
  }
}
