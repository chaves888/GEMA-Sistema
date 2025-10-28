import { Controller, Get, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { User } from 'src/users/entities/user.entity'; // Importa a entidade User
import { DashboardService } from './dashboard.service';
import { Request } from 'express'; // Importa o tipo Request do express

// Interface para garantir que req.user exista e tenha o tipo correto
interface RequestWithUser extends Request {
  user: User;
}

@UseGuards(JwtAuthGuard) // Protege a rota, garantindo que o usuário esteja logado
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get()
  getDashboardData(@Req() req: RequestWithUser) {
    // O JwtAuthGuard já colocou o objeto 'user' dentro do 'req'
    // Passamos o usuário logado para o serviço
    return this.dashboardService.getDashboardData(req.user);
  }
}