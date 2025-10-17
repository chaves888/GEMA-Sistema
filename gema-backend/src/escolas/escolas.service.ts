import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Cidade } from 'src/cidades/entities/cidade.entity';
import { EscolaEstoque } from 'src/estoque/entities/escola-estoque.entity';
import { User } from 'src/users/entities/user.entity';
import { Repository } from 'typeorm';
import { CreateEscolaDto } from './dto/create-escola.dto';
import { UpdateEscolaDto } from './dto/update-escola.dto';
import { Escola } from './entities/escola.entity';

@Injectable()
export class EscolasService {
  constructor(
    @InjectRepository(Escola)
    private readonly escolaRepository: Repository<Escola>,
    @InjectRepository(Cidade)
    private readonly cidadeRepository: Repository<Cidade>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(EscolaEstoque)
    private readonly escolaEstoqueRepository: Repository<EscolaEstoque>,
  ) {}

  async create(createEscolaDto: CreateEscolaDto): Promise<Escola> {
    const { cityId, ...rest } = createEscolaDto;
    const city = await this.cidadeRepository.findOneBy({ id: cityId });
    if (!city) {
      throw new NotFoundException(`Cidade com ID "${cityId}" não encontrada`);
    }
    const escola = this.escolaRepository.create({ ...rest, city });
    return this.escolaRepository.save(escola);
  }

  findAll(): Promise<Escola[]> {
    return this.escolaRepository.find({ relations: ['city'] });
  }

  async findOne(id: string): Promise<Escola> {
    const escola = await this.escolaRepository.findOne({ 
      where: { id },
      relations: ['city'] 
    });
    if (!escola) {
      throw new NotFoundException(`Escola com ID "${id}" não encontrada`);
    }
    return escola;
  }

  async update(id: string, updateEscolaDto: UpdateEscolaDto): Promise<Escola> {
    const { cityId, ...rest } = updateEscolaDto;
    const escola = await this.escolaRepository.preload({ id, ...rest });
    if (!escola) {
      throw new NotFoundException(`Escola com ID "${id}" não encontrada`);
    }
    if (cityId) {
      const city = await this.cidadeRepository.findOneBy({ id: cityId });
      if (!city) {
        throw new NotFoundException(`Cidade com ID "${cityId}" não encontrada`);
      }
      escola.city = city;
    }
    return this.escolaRepository.save(escola);
  }

  // --- MÉTODO 'REMOVE' COM A NOVA LÓGICA ---
  async remove(id: string): Promise<void> {
    const escola = await this.findOne(id);

    // 1. A verificação de usuários continua, pois é uma proteção crítica.
    const usuariosVinculados = await this.userRepository.count({
      where: { school: { id: escola.id } },
    });
    if (usuariosVinculados > 0) {
      throw new ConflictException(
        `Esta escola não pode ser excluída pois ${usuariosVinculados} usuário(s) estão vinculados a ela.`,
      );
    }

    // 2. NOVA LÓGICA: Em vez de bloquear, nós apagamos os itens de estoque.
    // Isso remove todos os registros da tabela 'escola_estoque' que pertencem a esta escola.
    await this.escolaEstoqueRepository.delete({ school: { id: escola.id } });

    // 3. Agora que o estoque foi limpo, a exclusão da escola é permitida.
    await this.escolaRepository.remove(escola);
  }
}
