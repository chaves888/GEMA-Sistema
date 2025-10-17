// src/auth/guards/roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserProfile } from 'src/users/entities/user.entity';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<UserProfile[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) {
      return true; // Se não há cargos definidos, permite o acesso
    }
    const { user } = context.switchToHttp().getRequest();
    // Verifica se o cargo do usuário logado está na lista de cargos permitidos
    return requiredRoles.some((role) => user.profile?.includes(role));
  }
}