// src/cidades/cidades.service.ts
import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
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

  async create(createCidadeDto: CreateCidadeDto): Promise<Cidade> {
    const dtoWithNulls = {
        ...createCidadeDto,
        bairro: createCidadeDto.bairro || null
    };
    const cidade = this.cidadeRepository.create(dtoWithNulls);
    try {
      return await this.cidadeRepository.save(cidade);
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        // --- MODIFICAÇÃO: Simplificado para checar apenas CEP ---
        if (error.message.includes('cep')) { 
            throw new ConflictException('Já existe uma cidade cadastrada com este CEP.'); 
        }
        throw new ConflictException('Erro ao salvar cidade. Verifique os dados únicos.');
        // --- FIM MODIFICAÇÃO ---
      }
      throw error;
    }
  }

  findAll(): Promise<Cidade[]> {
    return this.cidadeRepository.find({ order: { name: 'ASC' } });
  }

  async findOne(id: string): Promise<Cidade> {
    const cidade = await this.cidadeRepository.findOneBy({ id });
    if (!cidade) { throw new NotFoundException(`Cidade com ID "${id}" não encontrada`); }
    return cidade;
  }

  async update(id: string, updateCidadeDto: UpdateCidadeDto): Promise<Cidade> {
     const dtoWithNulls = { ...updateCidadeDto };
     if (dtoWithNulls.hasOwnProperty('bairro')) {
        dtoWithNulls.bairro = dtoWithNulls.bairro || null;
     }
     if (dtoWithNulls.hasOwnProperty('cep') && !dtoWithNulls.cep) {
         throw new BadRequestException('O campo CEP é obrigatório e não pode ser removido.');
     }

    const cidade = await this.cidadeRepository.preload({
      id: id,
      ...dtoWithNulls,
    });
    if (!cidade) {
      throw new NotFoundException(`Cidade com ID "${id}" não encontrada`);
    }
    
    try {
      return await this.cidadeRepository.save(cidade);
    } catch (error) {
       if (error.code === 'ER_DUP_ENTRY') {
            // --- MODIFICAÇÃO: Simplificado para checar apenas CEP ---
           if (error.message.includes('cep')) { 
                throw new ConflictException('Já existe outra cidade cadastrada com este CEP.'); 
            }
           throw new ConflictException('Erro ao salvar cidade. Verifique os dados únicos.');
            // --- FIM MODIFICAÇÃO ---
       }
      throw error;
    }
  }

  async remove(id: string): Promise<void> {
    const cidade = await this.findOne(id);
    const escolasVinculadas = await this.escolaRepository.count({
      where: { city: { id: cidade.id } },
    });
    if (escolasVinculadas > 0) {
      throw new ConflictException(`Exclusão bloqueada: ${escolasVinculadas} escola(s) vinculada(s).`);
    }
    await this.cidadeRepository.remove(cidade);
  }
}