// src/cardapios/cardapios.service.ts
import { Injectable, UnauthorizedException, NotFoundException, ConflictException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Product } from 'src/products/entities/product.entity';
import { User } from 'src/users/entities/user.entity';
import { DataSource, Repository, LessThanOrEqual, MoreThanOrEqual } from 'typeorm'; // Importa operadores
import { CreateCardapioDto } from './dto/create-cardapio.dto';
import { CreateRefeicaoDto } from './dto/create-refeicao.dto';
import { UpdateRefeicaoItemDto } from './dto/update-refeicao-item.dto';
import { UpdateRefeicaoDto } from './dto/update-refeicao.dto';
import { Cardapio } from './entities/cardapio.entity';
import { RefeicaoItem } from './entities/refeicao-item.entity';
import { Refeicao } from './entities/refeicao.entity';
import { Escola } from 'src/escolas/entities/escola.entity'; // Mantido para futuras buscas

@Injectable()
export class CardapiosService {
  constructor(
    @InjectRepository(Cardapio)
    private readonly cardapioRepository: Repository<Cardapio>,
    @InjectRepository(Refeicao)
    private readonly refeicaoRepository: Repository<Refeicao>,
    @InjectRepository(RefeicaoItem)
    private readonly refeicaoItemRepository: Repository<RefeicaoItem>,
    @InjectRepository(User) 
    private readonly userRepository: Repository<User>, 
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    // @InjectRepository(Escola) 
    // private readonly escolaRepository: Repository<Escola>,
    private dataSource: DataSource,
  ) {}

  // --- 1. CRIAÇÃO DO CARDÁPIO (Timezone Fix) ---
  async create(createCardapioDto: CreateCardapioDto, user: User): Promise<Cardapio> {
    if (user.profile !== 'nutricionista') {
      throw new UnauthorizedException('Apenas nutricionistas podem criar cardápios.');
    }
    
    // CORREÇÃO: Passa as strings de data "YYYY-MM-DD" diretamente
    const { startDate, endDate } = createCardapioDto;

    // Validação (já feita no DTO, mas garantindo)
    if (new Date(endDate) < new Date(startDate)) {
        throw new BadRequestException('A data de fim não pode ser anterior à data de início.');
    }

    const newCardapio = this.cardapioRepository.create({
      name: createCardapioDto.name,
      startDate: startDate, // Salva a string "YYYY-MM-DD"
      endDate: endDate,     // Salva a string "YYYY-MM-DD"
      createdBy: user,      
      refeicoes: [],        
    });
    
    const savedCardapio = await this.cardapioRepository.save(newCardapio);

    // Retorna o cardápio salvo, buscando novamente para garantir relações
    return this.cardapioRepository.findOneOrFail({ 
      where: { id: savedCardapio.id },
      relations: ['createdBy'] 
    }); 
  }

  // --- 2. ADICIONAR REFEIÇÃO A UM CARDÁPIO ---
  async addRefeicao(cardapioId: string, createRefeicaoDto: CreateRefeicaoDto, user: User): Promise<Refeicao> {
     if (user.profile !== 'nutricionista') { throw new UnauthorizedException('Apenas nutricionistas podem adicionar refeições.'); }
     const queryRunner = this.dataSource.createQueryRunner(); await queryRunner.connect(); await queryRunner.startTransaction();
     try {
       const cardapio = await queryRunner.manager.findOne(Cardapio, { where: { id: cardapioId }, relations: ['createdBy'], lock: { mode: 'pessimistic_write'} });
       if (!cardapio) { throw new NotFoundException(`Cardápio com ID ${cardapioId} não encontrado.`); }
       const existingRefeicao = await queryRunner.manager.findOne(Refeicao, { where: { cardapio: { id: cardapioId }, diaSemana: createRefeicaoDto.diaSemana, tipo: createRefeicaoDto.tipo } });
       if (existingRefeicao) { throw new ConflictException(`Já existe uma refeição '${createRefeicaoDto.tipo}' para '${createRefeicaoDto.diaSemana}' neste cardápio.`); }
       if (!createRefeicaoDto.items || createRefeicaoDto.items.length === 0) { throw new BadRequestException('A refeição deve conter pelo menos um item.'); }
       const productIds = createRefeicaoDto.items.map(item => item.productId);
       if (new Set(productIds).size !== productIds.length) { throw new BadRequestException('Uma refeição não pode conter o mesmo produto duas vezes.'); }
       const novaRefeicao = queryRunner.manager.create(Refeicao, { diaSemana: createRefeicaoDto.diaSemana, tipo: createRefeicaoDto.tipo, description: createRefeicaoDto.description || null, cardapio: cardapio, items: [] });
       const refeicaoSalva = await queryRunner.manager.save(Refeicao, novaRefeicao);
       const refeicaoItems: RefeicaoItem[] = [];
       for (const itemDto of createRefeicaoDto.items) {
         const product = await queryRunner.manager.findOneBy(Product, { id: itemDto.productId });
         if (!product) { throw new NotFoundException(`Produto com ID ${itemDto.productId} não encontrado.`); }
         const newItem = queryRunner.manager.create(RefeicaoItem, { quantityPerStudent: itemDto.quantityPerStudent, product: product, refeicao: refeicaoSalva });
         refeicaoItems.push(newItem);
       }
       await queryRunner.manager.save(RefeicaoItem, refeicaoItems);
       await queryRunner.commitTransaction();
       return queryRunner.manager.findOneOrFail(Refeicao, { where: { id: refeicaoSalva.id }, relations: ['items', 'items.product'] });
     } catch (error) { await queryRunner.rollbackTransaction(); throw error; } finally { await queryRunner.release(); }
  }

  // --- 3. ATUALIZAR ITEM DE REFEIÇÃO ---
  async updateRefeicaoItem(itemId: string, dto: UpdateRefeicaoItemDto, user: User): Promise<RefeicaoItem> {
    if (user.profile !== 'nutricionista') { throw new UnauthorizedException('Apenas nutricionistas podem editar itens de refeição.'); }
    const item = await this.refeicaoItemRepository.findOne({ where: { id: itemId }, relations: ['refeicao', 'refeicao.cardapio', 'refeicao.cardapio.createdBy', 'product'] });
    if (!item) { throw new NotFoundException(`Item de refeição com ID ${itemId} não encontrado.`); }
    item.quantityPerStudent = dto.quantityPerStudent;
    return this.refeicaoItemRepository.save(item);
  }

  // --- 4. REMOVER ITEM DE REFEIÇÃO ---
  async removeRefeicaoItem(itemId: string, user: User): Promise<void> {
     if (user.profile !== 'nutricionista') { throw new UnauthorizedException('Apenas nutricionistas podem remover itens de refeição.'); }
     const item = await this.refeicaoItemRepository.findOne({ where: { id: itemId }, relations: ['refeicao', 'refeicao.items', 'refeicao.cardapio', 'refeicao.cardapio.createdBy'] });
     if (!item) { throw new NotFoundException(`Item de refeição com ID ${itemId} não encontrado.`); }
     if (item.refeicao.items.length <= 1) { throw new BadRequestException('Não é possível remover o último item de uma refeição. Remova a refeição inteira se necessário.'); }
     await this.refeicaoItemRepository.remove(item);
  }

  // --- 5. ATUALIZAR DESCRIÇÃO DA REFEIÇÃO ---
  async updateRefeicao(refeicaoId: string, dto: UpdateRefeicaoDto, user: User): Promise<Refeicao> {
     if (user.profile !== 'nutricionista') { throw new UnauthorizedException('Apenas nutricionistas podem editar refeições.'); }
     const refeicao = await this.refeicaoRepository.findOne({ where: { id: refeicaoId }, relations: ['cardapio', 'cardapio.createdBy', 'items', 'items.product'] });
     if (!refeicao) { throw new NotFoundException(`Refeição com ID ${refeicaoId} não encontrada.`); }
     if (dto.description !== undefined) { refeicao.description = dto.description; }
     return this.refeicaoRepository.save(refeicao);
  }

  // --- 6. LISTAR CARDÁPIOS (Timezone Fix) ---
  async findAll(user: User): Promise<Cardapio[]> { 
    
    if (user.profile === 'nutricionista' || user.profile === 'prefeitura') {
      return this.cardapioRepository.find({
          order: { startDate: 'DESC' }, 
          relations: ['createdBy'], 
      });
    }

    if (user.profile === 'escola' || user.profile === 'cozinheira') {
      // CORREÇÃO: Converte 'today' para string "YYYY-MM-DD" para comparar com o varchar no banco
      const today = new Date().toISOString().split('T')[0]; 
      
      return this.cardapioRepository.find({
          where: {
            startDate: LessThanOrEqual(today), // Compara string com string
            endDate: MoreThanOrEqual(today),   // Compara string com string
          },
          order: { startDate: 'DESC' },
          relations: ['createdBy'],
      });
    }

    return [];
  }

  // --- 7. BUSCAR UM CARDÁPIO DETALHADO ---
  async findOne(id: string, user: User): Promise<Cardapio> { 
    const cardapio = await this.cardapioRepository.findOne({ 
        where: { id }, 
        relations: [ 'createdBy', 'refeicoes', 'refeicoes.items', 'refeicoes.items.product' ], 
        order: { refeicoes: { diaSemana: 'ASC', tipo: 'ASC' } } 
    });
     if (!cardapio) {
        throw new NotFoundException(`Cardápio com ID "${id}" não encontrado.`);
    }
    return cardapio;
  }

  // --- 8. REMOVER UM CARDÁPIO ---
  async remove(id: string, user: User): Promise<void> { 
     if (user.profile !== 'nutricionista') {
      throw new UnauthorizedException('Apenas nutricionistas podem remover cardápios.');
    }
     const cardapio = await this.cardapioRepository.findOne({ where: { id }, relations: ['createdBy'] });
     if (!cardapio) {
         throw new NotFoundException(`Cardápio com ID "${id}" não encontrado.`);
     }
     await this.cardapioRepository.remove(cardapio); 
  }
}