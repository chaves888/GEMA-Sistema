import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
  HttpCode,
  ParseUUIDPipe,
} from '@nestjs/common';
import { CardapiosService } from './cardapios.service';
import { CreateCardapioDto } from './dto/create-cardapio.dto';
import { UpdateCardapioDto } from './dto/update-cardapio.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt-auth.guard';
import { RolesGuard } from 'src/auth/guards/roles.guard';
import { Roles } from 'src/auth/decorators/roles.decorator';
import { User, UserProfile } from 'src/users/entities/user.entity';
import { SetRefeicaoDto } from './dto/set-refeicao.dto';

interface RequestWithUser extends Request {
  user: User;
}

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('cardapios')
export class CardapiosController {
  constructor(private readonly cardapiosService: CardapiosService) {}

  // --- Gestão do Cardápio Semanal ---

  @Post()
  @Roles(UserProfile.NUTRICIONISTA)
  create(@Body() createCardapioDto: CreateCardapioDto, @Req() req: RequestWithUser) {
    return this.cardapiosService.create(createCardapioDto, req.user);
  }

  @Patch(':id/publish')
  @Roles(UserProfile.NUTRICIONISTA)
  publish(@Param('id', ParseUUIDPipe) id: string, @Req() req: RequestWithUser) {
    return this.cardapiosService.publish(id, req.user);
  }

  // Todos os perfis logados podem listar cardápios (Serviço cuida da regra)
  @Get()
  @Roles(UserProfile.NUTRICIONISTA, UserProfile.PREFEITURA, UserProfile.ESCOLA, UserProfile.COZINHEIRA)
  findAll(@Req() req: RequestWithUser) {
    return this.cardapiosService.findAll(req.user);
  }

  // Todos os perfis logados podem ver detalhes (Serviço cuida da regra)
  @Get(':id')
  @Roles(UserProfile.NUTRICIONISTA, UserProfile.PREFEITURA, UserProfile.ESCOLA, UserProfile.COZINHEIRA)
  findOne(@Param('id', ParseUUIDPipe) id: string, @Req() req: RequestWithUser) {
    return this.cardapiosService.findOne(id, req.user);
  }

  @Patch(':id')
  @Roles(UserProfile.NUTRICIONISTA)
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateCardapioDto: UpdateCardapioDto,
    @Req() req: RequestWithUser,
  ) {
    return this.cardapiosService.update(id, updateCardapioDto, req.user);
  }

  @Delete(':id')
  @Roles(UserProfile.NUTRICIONISTA)
  @HttpCode(204)
  remove(@Param('id', ParseUUIDPipe) id: string, @Req() req: RequestWithUser) {
    return this.cardapiosService.remove(id, req.user);
  }

  // --- Gestão das Refeições (Manhã/Tarde) ---

  @Post(':id/refeicoes')
  @Roles(UserProfile.NUTRICIONISTA)
  setRefeicao(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() setRefeicaoDto: SetRefeicaoDto,
    @Req() req: RequestWithUser,
  ) {
    return this.cardapiosService.setRefeicao(id, setRefeicaoDto, req.user);
  }

  @Delete('refeicoes/:refeicaoId')
  @Roles(UserProfile.NUTRICIONISTA)
  @HttpCode(204)
  removeRefeicao(
    @Param('refeicaoId', ParseUUIDPipe) refeicaoId: string,
    @Req() req: RequestWithUser,
  ) {
    return this.cardapiosService.removeRefeicao(refeicaoId, req.user);
  }
}