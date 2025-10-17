import { Injectable } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(email: string, pass: string): Promise<any> {
    const user = await this.usersService.findOneByEmail(email);
    if (user && (await bcrypt.compare(pass, user.password))) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(user: any) {
    // A mudança está aqui: adicionamos 'school: user.school' ao payload.
    // Agora, a informação da escola do usuário é salva dentro do token.
    const payload = { 
      email: user.email, 
      sub: user.id, 
      profile: user.profile,
      school: user.school 
    };
    return {
      access_token: this.jwtService.sign(payload),
    };
  }
}
