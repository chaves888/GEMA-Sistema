// src/estoque/estoque.controller.ts
import {
	Controller, Get, Body, Patch, UseGuards, Req, Param, ForbiddenException,
	Post, UseInterceptors, UploadedFile, BadRequestException
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { EstoqueService } from './estoque.service';
import { AjustarEstoqueDto } from './dto/ajustar-estoque.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { User, UserProfile } from 'src/users/entities/user.entity';
import { Request } from 'express';
import 'multer'; // Mantenha isso
// --- NOVO IMPORT ---
import { ImportacaoResultado } from './dto/importar-estoque.dto';

interface RequestWithUser extends Request {
	user: User;
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('estoque')
export class EstoqueController {
	constructor(private readonly estoqueService: EstoqueService) {}

	@Post('prefeitura/importar')
	@Roles(UserProfile.PREFEITURA)
	@UseInterceptors(FileInterceptor('file'))
	async importarEstoque(
		@UploadedFile() file: Express.Multer.File,
		@Req() req: RequestWithUser,
	): Promise<ImportacaoResultado> { // <-- Agora o tipo é reconhecido
		if (!file) {
			throw new BadRequestException('Nenhum arquivo enviado.');
		}
		if (
			!file.mimetype.includes('spreadsheetml') &&
			!file.mimetype.includes('excel')
		) {
			throw new BadRequestException('Formato de arquivo inválido. Envie apenas .xlsx ou .xls');
		}

		return this.estoqueService.importarEstoque(file.buffer, req.user);
	}

	@Get('prefeitura')
	@Roles(UserProfile.PREFEITURA)
	getPrefeituraEstoque() {
		return this.estoqueService.getPrefeituraEstoque();
	}

	@Patch('prefeitura')
	@Roles(UserProfile.PREFEITURA)
	ajustarPrefeituraEstoque(
		@Body() ajustarEstoqueDto: AjustarEstoqueDto,
		@Req() req: RequestWithUser,
	) {
		return this.estoqueService.ajustarPrefeituraEstoque(ajustarEstoqueDto, req.user);
	}

	@Get('escola')
	@Roles(UserProfile.ESCOLA)
	getMeuEstoqueEscola(@Req() req: RequestWithUser) {
		const school = req.user.school;
		if (!school || !school.id) {
			throw new ForbiddenException('Este usuário não está associado a nenhuma escola.');
		}
		return this.estoqueService.getEscolaEstoque(school.id);
	}

	@Get('escola/:schoolId')
	@Roles(UserProfile.PREFEITURA)
	getEstoqueDeUmaEscola(@Param('schoolId') schoolId: string) {
		return this.estoqueService.getEscolaEstoque(schoolId);
	}

	@Patch('escola')
	@Roles(UserProfile.ESCOLA)
	ajustarMeuEstoqueEscola(
		@Req() req: RequestWithUser,
		@Body() ajustarEstoqueDto: AjustarEstoqueDto,
	) {
		const school = req.user.school;
		if (!school || !school.id) {
			throw new ForbiddenException('Este usuário não está associado a nenhuma escola.');
		}
		return this.estoqueService.ajustarEscolaEstoque(school.id, ajustarEstoqueDto, req.user);
	}
}