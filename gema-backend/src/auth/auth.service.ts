import { Injectable, Logger, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { MailerService } from '@nestjs-modules/mailer';
import { jwtConstants } from './auth.module';

@Injectable()
export class AuthService {
  // 2. Adicione um Logger para depuração
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
    private readonly mailerService: MailerService, // 3. Injete o MailerService
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

  async requestPasswordReset(email: string): Promise<void> {
    const user = await this.usersService.findOneByEmail(email);

    // Por segurança, não informamos se o e-mail foi encontrado ou não.
    // Apenas executamos o envio se o usuário existir.
    if (user) {
      // 4. Cria um token JWT *específico* para reset, com validade curta (ex: 15 minutos)
      const payload = { sub: user.id, type: 'reset' };
      const token = this.jwtService.sign(payload, { expiresIn: '15m' });

      // 5. Define a URL do frontend (ajuste a porta se necessário)
      const resetUrl = `http://localhost:5173/resetar-senha/${token}`;

      // 6. Envia o e-mail
      try {
        await this.mailerService.sendMail({
          to: user.email,
          subject: '[GEMA] Redefinição de Senha',
          
          // 1. Ative o template
          template: 'password-reset', // (nome do arquivo .hbs)
          
          // 2. Envie as variáveis 'name' e 'url' para o HTML
          context: { 
            name: user.name, 
            url: resetUrl 
          },
          
          // 3. Comente ou apague o HTML simples
          /*
          html: `
            <p>Olá ${user.name},</p>
            <p>Você solicitou a redefinição...</p>
            <a href="${resetUrl}" target="_blank">Redefinir minha senha</a>
            <p>Este link é válido por 15 minutos.</p>
            <p>Se você não solicitou isso, por favor, ignore este e-mail.</p>
          `,
          */
        });
        this.logger.log(`Link de reset enviado para: ${user.email}`);
      } catch (error) {
        this.logger.error(`Falha ao enviar e-mail para ${user.email}`, error.stack);
        // (Opcional) Tratar falha no envio
      }
    } else {
      this.logger.warn(`Solicitação de reset para e-mail não cadastrado: ${email}`);
    }
    
    // Retorna sucesso (vazio) em ambos os casos.
    return;
  }
  async resetPassword(token: string, newPass: string): Promise<void> {
    let payload: any;
    try {
      // 7. Verifica se o token é válido (e não expirou)
      payload = this.jwtService.verify(token, { secret: jwtConstants.secret });
    } catch (error) {
      throw new UnauthorizedException('Token inválido ou expirado.');
    }

    // 8. Verifica se é um token do tipo 'reset'
    if (payload.type !== 'reset') {
      throw new UnauthorizedException('Token inválido.');
    }

    // 9. Hash da nova senha (o users.service já faz isso, mas é bom garantir)
    const hashedPassword = await bcrypt.hash(newPass, 10);

    // 10. Atualiza o usuário no banco
    try {
      await this.usersService.update(payload.sub, { password: hashedPassword });
    } catch (error) {
      // Trata caso o usuário tenha sido deletado enquanto o token era válido
      if (error instanceof NotFoundException) {
        throw new UnauthorizedException('Usuário não encontrado.');
      }
      throw error;
    }
  }

}
