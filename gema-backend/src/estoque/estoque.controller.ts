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
import { User, UserProfile } from 'src/users/entities/user.entity'; // Verifique se UserProfile está importado
import { Request } from 'express';
import 'multer'; // Para o tipo Express.Multer.File

interface RequestWithUser extends Request {
	user: User;
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('estoque')
export class EstoqueController {
	constructor(private readonly estoqueService: EstoqueService) {}

	// --- ROTA DE IMPORTAÇÃO (Prefeitura) ---
	@Post('prefeitura/importar')
	@Roles(UserProfile.PREFEITURA)
	@UseInterceptors(FileInterceptor('file'))
	async importarEstoque(
		@UploadedFile() file: Express.Multer.File,
		@Req() req: RequestWithUser,
	) {
		if (!file) {
			throw new BadRequestException('Nenhum arquivo enviado.');
		}
		if (
			!file.mimetype.includes('spreadsheetml') && // .xlsx
			!file.mimetype.includes('excel') // .xls
		) {
			throw new BadRequestException('Formato de arquivo inválido. Envie apenas .xlsx ou .xls');
		}

		return this.estoqueService.importarEstoque(file.buffer, req.user);
	}

	// --- ROTAS DA PREFEITURA ---
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

	// --- ROTAS DA ESCOLA (GET) ---

	// --- INÍCIO DA CORREÇÃO ---
	@Get('escola')
	@Roles(UserProfile.ESCOLA, UserProfile.COZINHEIRA) // <-- ADICIONADO UserProfile.COZINHEIRA
	getMeuEstoqueEscola(@Req() req: RequestWithUser) {
		const school = req.user.school;
		if (!school || !school.id) {
			throw new ForbiddenException('Este usuário não está associado a nenhuma escola.');
		}
		return this.estoqueService.getEscolaEstoque(school.id);
	}
	// --- FIM DA CORREÇÃO ---

	@Get('escola/:schoolId')
	@Roles(UserProfile.PREFEITURA) // Prefeitura pode ver estoque de qualquer escola
	getEstoqueDeUmaEscola(@Param('schoolId') schoolId: string) {
		return this.estoqueService.getEscolaEstoque(schoolId);
	}

	// --- ROTA DA ESCOLA (PATCH) ---
	@Patch('escola')
	@Roles(UserProfile.ESCOLA) // <-- CORRETO: Apenas o Gestor (Escola) pode ajustar
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