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
import { DiaSemana, Refeicao, TipoRefeicao } from './entities/refeicao.entity';
import { CreateCardapioDto } from './dto/create-cardapio.dto';
import { UpdateCardapioDto } from './dto/update-cardapio.dto';
import { SetRefeicaoDto } from './dto/set-refeicao.dto';
import { SetHolidayDto } from './dto/set-holiday.dto';
import { format, parseISO, eachDayOfInterval, getDay } from 'date-fns';
import { ptBR } from 'date-fns/locale';

const dayNumberToDiaSemana: { [key: number]: DiaSemana } = {
  1: DiaSemana.SEGUNDA, 2: DiaSemana.TERCA, 3: DiaSemana.QUARTA,
  4: DiaSemana.QUINTA, 5: DiaSemana.SEXTA,
};

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
      .where('cardapio.status = :status', { status: CardapioStatus.PUBLICADO, })
      .andWhere('cardapio.startDate <= :endDate', { endDate })
      .andWhere('cardapio.endDate >= :startDate', { startDate });
    if (excludeId) {
      query.andWhere('cardapio.id != :excludeId', { excludeId });
    }
    const overlapping = await query.getOne();
    if (overlapping) {
      throw new ConflictException(`O período conflita com "${overlapping.name}" (${overlapping.startDate} a ${overlapping.endDate}).`);
    }
  }

  // --- Funções Auxiliares de Permissão ---
  private async getCardapioAsNutricionista( id: string, user: User ): Promise<Cardapio> {
    if (user.profile !== UserProfile.NUTRICIONISTA) {
      throw new ForbiddenException('Apenas nutricionistas podem gerenciar cardápios.');
    }
    const cardapio = await this.cardapioRepository.findOneBy({ id });
    if (!cardapio) {
      throw new NotFoundException(`Cardápio com ID ${id} não encontrado.`);
    }
    return cardapio;
  }

  private async checkCardapioLocked(cardapio: Cardapio): Promise<void> {
    if (cardapio.status === CardapioStatus.PUBLICADO) {
      throw new ForbiddenException('Este cardápio está publicado e não pode ser alterado.');
    }
  }

  // --- CRUD Cardápio ---
  async create(dto: CreateCardapioDto, user: User): Promise<Cardapio> {
    if (new Date(dto.endDate) < new Date(dto.startDate)) {
      throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
    }
    const today = format(new Date(), 'yyyy-MM-dd');
    if (dto.startDate < today) {
         throw new BadRequestException('A data de início não pode ser anterior à data atual.');
    }
    await this.checkDateOverlap(dto.startDate, dto.endDate);
    try {
        const start = parseISO(dto.startDate);
        const end = parseISO(dto.endDate);
        const nomeGerado = `Cardápio ${format(start, 'dd/MM')} a ${format(end, 'dd/MM/yyyy', { locale: ptBR })}`;
        const cardapio = this.cardapioRepository.create({
          ...dto, name: nomeGerado, createdBy: user,
          status: CardapioStatus.RASCUNHO, holidayWeekdays: [],
        });
        return this.cardapioRepository.save(cardapio);
    } catch (e) { throw new BadRequestException('Formato de data inválido.'); }
  }

  async publish(id: string, user: User): Promise<Cardapio> {
    const cardapio = await this.getCardapioAsNutricionista(id, user);
    await this.checkCardapioLocked(cardapio);
    const diasNoIntervalo = eachDayOfInterval({ start: parseISO(cardapio.startDate), end: parseISO(cardapio.endDate), });
    const diasUteisNoIntervalo = diasNoIntervalo.map(date => getDay(date)).filter(dayNumber => dayNumber >= 1 && dayNumber <= 5).map(dayNumber => dayNumberToDiaSemana[dayNumber]);
    const diasNaoFeriado = diasUteisNoIntervalo.filter(dia => !cardapio.holidayWeekdays?.includes(dia));
    for (const dia of diasNaoFeriado) {
      const temManha = cardapio.refeicoes.some(r => r.diaSemana === dia && r.tipo === TipoRefeicao.MANHA);
      const temTarde = cardapio.refeicoes.some(r => r.diaSemana === dia && r.tipo === TipoRefeicao.TARDE);
      if (!temManha || !temTarde) { throw new BadRequestException(`Publicação falhou: Faltam refeições para ${dia}.`); }
    }
    await this.checkDateOverlap(cardapio.startDate, cardapio.endDate, cardapio.id);
    cardapio.status = CardapioStatus.PUBLICADO;
    return this.cardapioRepository.save(cardapio);
  }

  async findAll(user: User): Promise<Cardapio[]> {
    if (user.profile === UserProfile.NUTRICIONISTA) {
      return this.cardapioRepository.find({ order: { startDate: 'DESC' }, });
    }
    return this.cardapioRepository.find({ where: { status: CardapioStatus.PUBLICADO }, order: { startDate: 'DESC' }, });
  }

  async findOne(id: string, user: User): Promise<Cardapio> {
    const cardapio = await this.cardapioRepository.findOneBy({ id });
    if (!cardapio) { throw new NotFoundException(`Cardápio com ID ${id} não encontrado.`); }
    if (user.profile !== UserProfile.NUTRICIONISTA && cardapio.status === CardapioStatus.RASCUNHO) {
      throw new ForbiddenException('Você não tem permissão para ver este rascunho.');
    }
    return cardapio;
  }

  async update(id: string, dto: UpdateCardapioDto, user: User): Promise<Cardapio> {
    const cardapio = await this.getCardapioAsNutricionista(id, user);
    await this.checkCardapioLocked(cardapio);
    if (dto.startDate || dto.endDate) {
      const newStart = dto.startDate || cardapio.startDate; const newEnd = dto.endDate || cardapio.endDate;
      if (new Date(newEnd) < new Date(newStart)) { throw new BadRequestException('Data de fim anterior à data de início.'); }
      if (dto.startDate) { const today = format(new Date(), 'yyyy-MM-dd'); if (newStart < today) { throw new BadRequestException('Data de início anterior à data atual.'); } }
      await this.checkDateOverlap(newStart, newEnd, cardapio.id);
      try { const start = parseISO(newStart); const end = parseISO(newEnd); cardapio.name = `Cardápio ${format(start, 'dd/MM')} a ${format(end, 'dd/MM/yyyy', { locale: ptBR })}`; }
      catch (e) { throw new BadRequestException('Formato de data inválido.'); }
    }
    const updatedCardapio = this.cardapioRepository.merge(cardapio, dto);
    return this.cardapioRepository.save(updatedCardapio);
  }

  // --- MÉTODO REMOVE ATUALIZADO ---
  async remove(id: string, user: User): Promise<void> {
    const cardapio = await this.getCardapioAsNutricionista(id, user);

    // Linha comentada para permitir a exclusão de cardápios publicados.
    // await this.checkCardapioLocked(cardapio);

    await this.cardapioRepository.remove(cardapio);
  }
  // --- FIM MÉTODO REMOVE ---

  // --- Gerenciamento de Refeições ---
  async setRefeicao( cardapioId: string, dto: SetRefeicaoDto, user: User ): Promise<Refeicao> {
    const cardapio = await this.getCardapioAsNutricionista(cardapioId, user);
    await this.checkCardapioLocked(cardapio);
    if (cardapio.holidayWeekdays?.includes(dto.diaSemana)) { throw new BadRequestException(`Não é possível adicionar/editar refeições em dia de feriado (${dto.diaSemana}).`); }
    const { diaSemana, tipo, description, productIds } = dto;
    const products = await this.productRepository.findBy({ id: In(productIds) });
    if (products.length !== productIds.length) { throw new NotFoundException('Um ou mais produtos não encontrados.'); }
    let refeicao = await this.refeicaoRepository.findOne({ where: { cardapio: { id: cardapioId }, diaSemana, tipo }, });
    if (refeicao) { refeicao.description = description; refeicao.products = products; }
    else { refeicao = this.refeicaoRepository.create({ cardapio, diaSemana, tipo, description, products, }); }
    return this.refeicaoRepository.save(refeicao);
  }

  async removeRefeicao(refeicaoId: string, user: User): Promise<void> {
    const refeicao = await this.refeicaoRepository.findOne({ where: { id: refeicaoId }, relations: ['cardapio'], });
    if (!refeicao) { throw new NotFoundException(`Refeição com ID ${refeicaoId} não encontrada.`); }
    await this.getCardapioAsNutricionista(refeicao.cardapio.id, user);
    await this.checkCardapioLocked(refeicao.cardapio);
    await this.refeicaoRepository.remove(refeicao);
  }

  async setHoliday(id: string, dto: SetHolidayDto, user: User): Promise<Cardapio> {
    const cardapio = await this.getCardapioAsNutricionista(id, user);
    await this.checkCardapioLocked(cardapio);
    const { diaSemana, isHoliday } = dto;
    if (!Array.isArray(cardapio.holidayWeekdays)) { cardapio.holidayWeekdays = []; }
    if (isHoliday) { if (!cardapio.holidayWeekdays.includes(diaSemana)) { cardapio.holidayWeekdays.push(diaSemana); cardapio.holidayWeekdays.sort(); } }
    else { cardapio.holidayWeekdays = cardapio.holidayWeekdays.filter(d => d !== diaSemana); }
    return this.cardapioRepository.save(cardapio);
  }
}