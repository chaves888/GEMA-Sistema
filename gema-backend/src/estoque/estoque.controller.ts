// src/estoque/estoque.controller.ts
import { Controller, Get, Body, Patch, UseGuards, Req, Param, ForbiddenException } from '@nestjs/common';
import { EstoqueService } from './estoque.service';
import { AjustarEstoqueDto } from './dto/ajustar-estoque.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { UserProfile } from 'src/users/entities/user.entity';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('estoque')
export class EstoqueController {
  constructor(private readonly estoqueService: EstoqueService) {}

  @Get('prefeitura')
  @Roles(UserProfile.PREFEITURA)
  getPrefeituraEstoque() {
    return this.estoqueService.getPrefeituraEstoque();
  }

  @Patch('prefeitura')
  @Roles(UserProfile.PREFEITURA)
  ajustarPrefeituraEstoque(@Body() ajustarEstoqueDto: AjustarEstoqueDto) {
    return this.estoqueService.ajustarPrefeituraEstoque(ajustarEstoqueDto);
  }

  @Get('escola')
  @Roles(UserProfile.ESCOLA)
  getMeuEstoqueEscola(@Req() req) {
    const school = req.user.school;
    if (!school || !school.id) {
      throw new ForbiddenException('Este usuário não está associado a nenhuma escola.');
    }
    return this.estoqueService.getEscolaEstoque(school.id);
  }

  @Get('escola/:schoolId')
  @Roles(UserProfile.PREFEITURA)
  getEstoqueDeUmaEscola(@Param('schoolId') schoolId: string) {
    // A chamada aqui está correta, pois a função existe no service acima
    return this.estoqueService.getEscolaEstoque(schoolId);
  }

  @Patch('escola')
  @Roles(UserProfile.ESCOLA)
  ajustarMeuEstoqueEscola(@Req() req, @Body() ajustarEstoqueDto: AjustarEstoqueDto) {
    const school = req.user.school;
    if (!school || !school.id) {
      throw new ForbiddenException('Este usuário não está associado a nenhuma escola.');
    }
    return this.estoqueService.ajustarEscolaEstoque(school.id, ajustarEstoqueDto);
  }
}