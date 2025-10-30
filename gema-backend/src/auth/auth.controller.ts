// src/auth/auth.controller.ts
import { Controller, Request, Post, UseGuards, Body, HttpCode, HttpStatus } from '@nestjs/common'; // 1. Importe Body, HttpCode, HttpStatus
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { ForgotPasswordDto } from './dto/forgot-password.dto'; // 2. Importe os DTOs
import { ResetPasswordDto } from './dto/reset-password.dto';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @UseGuards(AuthGuard('local'))
  @Post('login')
  async login(@Request() req) {
    return this.authService.login(req.user);
  }

  // --- NOVO ENDPOINT 1 ---
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK) // 3. Retorna 200 OK (ou 204 No Content)
  async forgotPassword(@Body() forgotPasswordDto: ForgotPasswordDto) {
    // Não usamos await aqui para o cliente não ter que esperar o envio do e-mail
    // Isso é chamado de "fire-and-forget"
    this.authService.requestPasswordReset(forgotPasswordDto.email);
    // Retorna uma resposta genérica imediatamente
    return { message: 'Se este e-mail estiver cadastrado, um link de redefinição será enviado.' };
  }

  // --- NOVO ENDPOINT 2 ---
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
    await this.authService.resetPassword(resetPasswordDto.token, resetPasswordDto.password);
    return { message: 'Senha redefinida com sucesso!' };
  }
}