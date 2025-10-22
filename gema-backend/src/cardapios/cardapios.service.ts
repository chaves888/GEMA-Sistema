import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Product } from 'src/products/entities/product.entity';
import { User, UserProfile } from 'src/users/entities/user.entity';
import { In, LessThanOrEqual, MoreThanOrEqual, Not, Repository } from 'typeorm';
import { Cardapio, CardapioStatus } from './entities/cardapio.entity';
import { Refeicao } from './entities/refeicao.entity';
import { CreateCardapioDto } from './dto/create-cardapio.dto';
import { UpdateCardapioDto } from './dto/update-cardapio.dto';
import { SetRefeicaoDto } from './dto/set-refeicao.dto';

@Injectable()
export class CardapiosService {
  constructor(
    @InjectRepository(Cardapio)
    private readonly cardapioRepository: Repository<Cardapio>,
    @InjectRepository(Refeicao)
    private readonly refeicaoRepository: Repository<Refeicao>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  // --- Validação de Datas ---
  private async checkDateOverlap(
    startDate: string,
    endDate: string,
    excludeId?: string,
  ): Promise<void> {
    const query = this.cardapioRepository.createQueryBuilder('cardapio');
    query
      .where('cardapio.status = :status', {
        status: CardapioStatus.PUBLICADO,
      })
      .andWhere('cardapio.startDate <= :endDate', { endDate })
      .andWhere('cardapio.endDate >= :startDate', { startDate });

    if (excludeId) {
      query.andWhere('cardapio.id != :excludeId', { excludeId });
    }

    const overlapping = await query.getOne();

    if (overlapping) {
      throw new ConflictException(
        `O período selecionado conflita com o cardápio publicado "${overlapping.name}" (${overlapping.startDate} a ${overlapping.endDate}).`,
      );
    }
  }

  // --- Funções Auxiliares de Permissão ---
  private async getCardapioAsNutricionista(
    id: string,
    user: User,
  ): Promise<Cardapio> {
    if (user.profile !== UserProfile.NUTRICIONISTA) {
      throw new ForbiddenException('Apenas nutricionistas podem editar cardápios.');
    }
    const cardapio = await this.cardapioRepository.findOneBy({ id });
    if (!cardapio) {
      throw new NotFoundException(`Cardápio com ID ${id} não encontrado.`);
    }
    return cardapio;
  }

  private async checkCardapioLocked(cardapio: Cardapio): Promise<void> {
    if (cardapio.status === CardapioStatus.PUBLICADO) {
      throw new ForbiddenException(
        'Este cardápio está publicado e não pode ser alterado.',
      );
    }
  }

  // --- CRUD Cardápio ---

  async create(dto: CreateCardapioDto, user: User): Promise<Cardapio> {
    if (new Date(dto.endDate) < new Date(dto.startDate)) {
      throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
    }
    // Verifica se o período colide com algum cardápio JÁ PUBLICADO
    await this.checkDateOverlap(dto.startDate, dto.endDate);

    const cardapio = this.cardapioRepository.create({
      ...dto,
      createdBy: user,
      status: CardapioStatus.RASCUNHO,
    });
    return this.cardapioRepository.save(cardapio);
  }

  async publish(id: string, user: User): Promise<Cardapio> {
    const cardapio = await this.getCardapioAsNutricionista(id, user);
    await this.checkCardapioLocked(cardapio); // Garante que não foi publicado
    
    // Verifica conflitos com OUTROS cardápios publicados, excluindo ele mesmo
    await this.checkDateOverlap(cardapio.startDate, cardapio.endDate, cardapio.id);

    cardapio.status = CardapioStatus.PUBLICADO;
    return this.cardapioRepository.save(cardapio);
  }

  async findAll(user: User): Promise<Cardapio[]> {
    const relations = ['createdBy', 'refeicoes', 'refeicoes.products'];

    if (user.profile === UserProfile.NUTRICIONISTA) {
      // Nutricionista vê tudo (rascunhos e publicados)
      return this.cardapioRepository.find({
        order: { startDate: 'DESC' },
        relations,
      });
    }

    // Outros perfis (Escola, Cozinheira, Prefeitura) veem apenas os PUBLICADOS
    return this.cardapioRepository.find({
      where: { status: CardapioStatus.PUBLICADO },
      order: { startDate: 'DESC' },
      relations,
    });
  }

  async findOne(id: string, user: User): Promise<Cardapio> {
    const cardapio = await this.cardapioRepository.findOne({
      where: { id },
      relations: ['createdBy', 'refeicoes', 'refeicoes.products'],
    });

    if (!cardapio) {
      throw new NotFoundException(`Cardápio com ID ${id} não encontrado.`);
    }

    // Se o usuário NÃO for nutricionista e o cardápio for RASCUNHO, nega o acesso.
    if (
      user.profile !== UserProfile.NUTRICIONISTA &&
      cardapio.status === CardapioStatus.RASCUNHO
    ) {
      throw new ForbiddenException('Você não tem permissão para ver este rascunho de cardápio.');
    }

    return cardapio;
  }

  async update(id: string, dto: UpdateCardapioDto, user: User): Promise<Cardapio> {
    const cardapio = await this.getCardapioAsNutricionista(id, user);
    await this.checkCardapioLocked(cardapio); // Não pode editar se publicado

    // Se as datas mudaram, checa novamente a sobreposição
    if (dto.startDate || dto.endDate) {
      const newStart = dto.startDate || cardapio.startDate;
      const newEnd = dto.endDate || cardapio.endDate;
      if (new Date(newEnd) < new Date(newStart)) {
        throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
      }
      await this.checkDateOverlap(newStart, newEnd, cardapio.id);
    }

    const updatedCardapio = this.cardapioRepository.merge(cardapio, dto);
    return this.cardapioRepository.save(updatedCardapio);
  }

  async remove(id: string, user: User): Promise<void> {
    const cardapio = await this.getCardapioAsNutricionista(id, user);
    await this.checkCardapioLocked(cardapio); // Só pode excluir rascunhos

    await this.cardapioRepository.remove(cardapio);
  }

  // --- Gerenciamento de Refeições ---

  async setRefeicao(
    cardapioId: string,
    dto: SetRefeicaoDto,
    user: User,
  ): Promise<Refeicao> {
    const cardapio = await this.getCardapioAsNutricionista(cardapioId, user);
    await this.checkCardapioLocked(cardapio); // Não pode adicionar refeição se publicado

    const { diaSemana, tipo, description, productIds } = dto;

    // 1. Busca os produtos
    const products = await this.productRepository.findBy({ id: In(productIds) });
    if (products.length !== productIds.length) {
      throw new NotFoundException('Um ou mais produtos não foram encontrados.');
    }

    // 2. Procura se a refeição já existe
    let refeicao = await this.refeicaoRepository.findOne({
      where: { cardapio: { id: cardapioId }, diaSemana, tipo },
    });

    if (refeicao) {
      // 3a. Se existe, atualiza
      refeicao.description = description;
      refeicao.products = products;
    } else {
      // 3b. Se não existe, cria
      refeicao = this.refeicaoRepository.create({
        cardapio,
        diaSemana,
        tipo,
        description,
        products,
      });
    }

    // 4. Salva a refeição
    return this.refeicaoRepository.save(refeicao);
  }

  async removeRefeicao(refeicaoId: string, user: User): Promise<void> {
    // Busca a refeição E seu cardápio pai
    const refeicao = await this.refeicaoRepository.findOne({
      where: { id: refeicaoId },
      relations: ['cardapio'],
    });

    if (!refeicao) {
      throw new NotFoundException(`Refeição com ID ${refeicaoId} não encontrada.`);
    }

    // Valida permissão
    await this.getCardapioAsNutricionista(refeicao.cardapio.id, user);
    await this.checkCardapioLocked(refeicao.cardapio); // Checa se está publicado

    await this.refeicaoRepository.remove(refeicao);
  }
}