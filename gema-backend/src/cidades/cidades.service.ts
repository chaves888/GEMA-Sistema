// src/cidades/cidades.service.ts
import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
import { Repository } from 'typeorm';
import { CreateCidadeDto } from './dto/create-cidade.dto';
import { UpdateCidadeDto } from './dto/update-cidade.dto';
import { Cidade } from './entities/cidade.entity';

@Injectable()
export class CidadesService {
  constructor(
    @InjectRepository(Cidade)
    private readonly cidadeRepository: Repository<Cidade>,
    @InjectRepository(Escola)
    private readonly escolaRepository: Repository<Escola>,
  ) {}

  create(createCidadeDto: CreateCidadeDto): Promise<Cidade> {
    const cidade = this.cidadeRepository.create(createCidadeDto);
    return this.cidadeRepository.save(cidade);
  }

  findAll(): Promise<Cidade[]> {
    return this.cidadeRepository.find();
  }

  // GARANTA QUE ESTE MÉTODO RETORNA Promise<Cidade>
  async findOne(id: string): Promise<Cidade> {
    const cidade = await this.cidadeRepository.findOneBy({ id });
    if (!cidade) {
      throw new NotFoundException(`Cidade com ID "${id}" não encontrada`);
    }
    return cidade;
  }

  async update(id: string, updateCidadeDto: UpdateCidadeDto): Promise<Cidade> {
    const cidade = await this.cidadeRepository.preload({
      id: id,
      ...updateCidadeDto,
    });
    if (!cidade) {
      throw new NotFoundException(`Cidade com ID "${id}" não encontrada`);
    }
    return this.cidadeRepository.save(cidade);
  }

  // MÉTODO REMOVE CORRIGIDO
  async remove(id: string): Promise<void> {
    // 1. A chamada a this.findOne(id) agora retorna corretamente um objeto Cidade
    const cidade = await this.findOne(id);

    // 2. A variável 'cidade' tem a propriedade 'id', então o erro some
    const escolasVinculadas = await this.escolaRepository.count({
      where: { city: { id: cidade.id } },
    });

    if (escolasVinculadas > 0) {
      throw new ConflictException(
        `Esta cidade não pode ser excluída pois ${escolasVinculadas} escola(s) estão vinculadas a ela.`,
      );
    }

    // 3. O remove agora recebe um objeto Cidade válido
    await this.cidadeRepository.remove(cidade);
  }
}