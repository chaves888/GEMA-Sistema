// src/escolas/escolas.controller.ts
import {
	Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, HttpCode, Req, // 1. Importar Req
} from '@nestjs/common';
import { EscolasService } from './escolas.service';
import { CreateEscolaDto } from './dto/create-escola.dto';
import { UpdateEscolaDto } from './dto/update-escola.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { User, UserProfile } from 'src/users/entities/user.entity'; // 2. Importar User
import { Roles } from 'src/auth/decorators/roles.decorator';
import { Request } from 'express'; // 3. Importar Request

// 4. Definir interface
interface RequestWithUser extends Request {
	user: User;
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('escolas')
export class EscolasController {
	constructor(private readonly escolasService: EscolasService) {}

	@Post()
	@Roles(UserProfile.PREFEITURA)
	create(@Body() createEscolaDto: CreateEscolaDto) {
		return this.escolasService.create(createEscolaDto);
	}

	@Get()
	findAll() {
		return this.escolasService.findAll();
	}

	@Get(':id')
	@Roles(UserProfile.PREFEITURA)
	findOne(@Param('id') id: string) {
		return this.escolasService.findOne(id);
	}

	@Patch(':id')
	@Roles(UserProfile.PREFEITURA)
	update(@Param('id') id: string, @Body() updateEscolaDto: UpdateEscolaDto) {
		return this.escolasService.update(id, updateEscolaDto);
	}

	// --- 5. ROTA REMOVE ATUALIZADA ---
	@Delete(':id')
	@Roles(UserProfile.PREFEITURA)
	@HttpCode(204)
	remove(@Param('id') id: string, @Req() req: RequestWithUser) { // Recebe @Req
		// Passa o ID e o usuário logado
		return this.escolasService.remove(id, req.user);
	}
}