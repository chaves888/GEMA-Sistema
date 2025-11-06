// src/cidades/cidades.controller.ts
import {
	Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, HttpCode, Req, // 1. Importar Req
} from '@nestjs/common';
import { CidadesService } from './cidades.service';
import { CreateCidadeDto } from './dto/create-cidade.dto';
import { UpdateCidadeDto } from './dto/update-cidade.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { User, UserProfile } from 'src/users/entities/user.entity'; // 2. Importar User
import { Request } from 'express'; // 3. Importar Request

// 4. Definir interface
interface RequestWithUser extends Request {
	user: User;
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('cidades')
export class CidadesController {
	constructor(private readonly cidadesService: CidadesService) {}

	@Post()
	@Roles(UserProfile.PREFEITURA)
	create(@Body() createCidadeDto: CreateCidadeDto) {
		return this.cidadesService.create(createCidadeDto);
	}

	@Get()
	findAll() {
		return this.cidadesService.findAll();
	}

	@Get(':id')
	@Roles(UserProfile.PREFEITURA)
	findOne(@Param('id') id: string) {
		return this.cidadesService.findOne(id);
	}

	@Patch(':id')
	@Roles(UserProfile.PREFEITURA)
	update(@Param('id') id: string, @Body() updateCidadeDto: UpdateCidadeDto) {
		return this.cidadesService.update(id, updateCidadeDto);
	}

	// --- 5. ROTA REMOVE ATUALIZADA ---
	@Delete(':id')
	@Roles(UserProfile.PREFEITURA)
	@HttpCode(204)
	remove(@Param('id') id: string, @Req() req: RequestWithUser) { // Recebe @Req
		// Passa o ID e o usuário logado
		return this.cidadesService.remove(id, req.user);
	}
}