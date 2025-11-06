// src/users/users.controller.ts
import {
  Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, HttpCode, Req, // 1. Importar Req
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { User, UserProfile } from './entities/user.entity'; // 2. Importar User
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Request } from 'express'; // 3. Importar Request

// 4. Definir interface (pode estar em outro lugar, mas funciona aqui)
interface RequestWithUser extends Request {
  user: User;
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @Roles(UserProfile.PREFEITURA)
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  @Roles(UserProfile.PREFEITURA)
  findAll() {
    return this.usersService.findAll();
  }

  @Get(':id')
  @Roles(UserProfile.PREFEITURA)
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(id);
  }

  @Patch(':id')
  @Roles(UserProfile.PREFEITURA)
  update(@Param('id') id: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(id, updateUserDto);
  }

  // 5. ROTA REMOVE ATUALIZADA
  @Delete(':id')
  @Roles(UserProfile.PREFEITURA)
  @HttpCode(204)
  remove(@Param('id') id: string, @Req() req: RequestWithUser) { // Adicionado @Req
    return this.usersService.remove(id, req.user); // Passa o usuário logado
  }

  // --- 6. NOVAS ROTAS ---

  @Patch(':id/activate')
  @Roles(UserProfile.PREFEITURA)
  activate(@Param('id') id: string, @Req() req: RequestWithUser) {
    return this.usersService.activate(id, req.user);
  }

  @Patch(':id/deactivate')
  @Roles(UserProfile.PREFEITURA)
  deactivate(@Param('id') id: string, @Req() req: RequestWithUser) {
    return this.usersService.deactivate(id, req.user);
  }
}