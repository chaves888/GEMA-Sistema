// src/cidades/cidades.service.ts
import { Injectable, NotFoundException, ConflictException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
// --- 1. Importar o 'Not' ---
import { Repository, Not } from 'typeorm'; 
import { CreateCidadeDto } from './dto/create-cidade.dto';
import { UpdateCidadeDto } from './dto/update-cidade.dto';
import { Cidade } from './entities/cidade.entity';
import { User } from 'src/users/entities/user.entity';

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
			bairro: createCidadeDto.bairro || null,
		};
		const cidade = this.cidadeRepository.create(dtoWithNulls);

		try {
			// --- 2. LÓGICA DE VERIFICAÇÃO ATUALIZADA (create) ---
			// Procura um CEP igual, mas APENAS em registros NÃO-DELETADOS.
			// (O 'findOne' padrão já ignora os soft-deleted).
			const existingCep = await this.cidadeRepository.findOne({
				where: { cep: cidade.cep },
				// 'withDeleted: true' FOI REMOVIDO
			});

			if (existingCep) {
				// Se encontrou, significa que já existe uma cidade ATIVA com este CEP.
				throw new ConflictException('Já existe uma cidade ATIVA cadastrada com este CEP.');
			}
			// --- FIM DA ATUALIZAÇÃO ---

			return await this.cidadeRepository.save(cidade);
		
		} catch (error) {
			// Se o 'ConflictException' foi lançado, apenas o repasse
			if (error instanceof ConflictException) {
				throw error;
			}
			// Outros erros (ex: falha de conexão)
			throw error;
		}
	}

	findAll(): Promise<Cidade[]> {
		return this.cidadeRepository.find({ order: { name: 'ASC' } });
	}

	async findOne(id: string): Promise<Cidade> {
		const cidade = await this.cidadeRepository.findOneBy({ id });
		if (!cidade) {
			throw new NotFoundException(`Cidade com ID "${id}" não encontrada`);
		}
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
			// --- 3. LÓGICA DE VERIFICAÇÃO ATUALIZADA (update) ---
			// Se o CEP foi alterado, precisamos verificar se ele colide com OUTRA cidade ativa
			if (updateCidadeDto.cep) {
				const existingCep = await this.cidadeRepository.findOne({
					where: {
						cep: updateCidadeDto.cep,
						id: Not(id), // Onde o ID não seja o da cidade que estamos editando
					},
					// (só busca em registros ativos por padrão)
				});
				if (existingCep) {
					throw new ConflictException('Já existe OUTRA cidade ATIVA cadastrada com este CEP.');
				}
			}
			// --- FIM DA ATUALIZAÇÃO ---

			return await this.cidadeRepository.save(cidade);

		} catch (error) {
			if (error instanceof ConflictException) {
				throw error;
			}
			// O erro 'ER_DUP_ENTRY' não deve mais ocorrer pelo CEP
			throw error;
		}
	}

	async remove(id: string, actingUser: User): Promise<void> {
		const cidade = await this.findOne(id);

		// (O 'count' padrão já ignora escolas soft-deleted)
		const escolasVinculadas = await this.escolaRepository.count({
			where: { city: { id: cidade.id } },
		});
		
		if (escolasVinculadas > 0) {
			throw new ConflictException(
				`Exclusão bloqueada: ${escolasVinculadas} escola(s) ativa(s) está(ão) vinculada(s) a esta cidade.`,
			);
		}

		try {
			await this.cidadeRepository.softDelete(id);
			await this.cidadeRepository.update(id, {
				deletedBy: actingUser,
			});
		} catch (error) {
			console.error("Erro ao aplicar soft-delete na cidade:", error)
			throw new ConflictException('Ocorreu um erro ao excluir a cidade.');
		}
	}
}