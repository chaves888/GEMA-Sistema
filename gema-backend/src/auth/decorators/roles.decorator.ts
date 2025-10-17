// src/auth/decorators/roles.decorator.ts
import { SetMetadata } from '@nestjs/common';
import { UserProfile } from 'src/users/entities/user.entity';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: UserProfile[]) => SetMetadata(ROLES_KEY, roles);