// src/auth/auth.controller.ts
import { Controller, Request, Post, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @UseGuards(AuthGuard('local')) // Usa a nossa LocalStrategy
  @Post('login')
  async login(@Request() req) {
    // Se chegar aqui, o usuário já foi validado pelo AuthGuard
    return this.authService.login(req.user);
  }
}