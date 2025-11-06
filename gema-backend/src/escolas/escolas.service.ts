// src/escolas/escolas.service.ts
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
		const { cityId, name, ...rest } = createEscolaDto;

		const city = await this.cidadeRepository.findOneBy({ id: cityId });
		if (!city) {
			throw new NotFoundException(`Cidade com ID "${cityId}" não encontrada`);
		}

		// Checa se já existe escola com esse nome (incluindo deletadas)
		const existingEscola = await this.escolaRepository.findOne({
			where: { name },
			withDeleted: true, // <-- Checa deletados
		});

		if (existingEscola) {
			throw new ConflictException(`Já existe uma escola com o nome "${name}".`);
		}

		const escola = this.escolaRepository.create({ ...rest, name, city });
		return this.escolaRepository.save(escola);
	}

	findAll(): Promise<Escola[]> {
		// 'find' agora só retorna escolas não-deletadas
		return this.escolaRepository.find({ relations: ['city'] });
	}

	async findOne(id: string): Promise<Escola> {
		// 'findOne' agora só retorna escolas não-deletadas
		const escola = await this.escolaRepository.findOne({
			where: { id },
			relations: ['city'],
		});
		if (!escola) {
			throw new NotFoundException(`Escola com ID "${id}" não encontrada`);
		}
		return escola;
	}

	async update(id: string, updateEscolaDto: UpdateEscolaDto): Promise<Escola> {
		const { cityId, ...rest } = updateEscolaDto;
		// 'preload' só funciona em registros não-deletados
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

	// --- MÉTODO 'REMOVE' ATUALIZADO (SOFT DELETE) ---
	async remove(id: string, actingUser: User): Promise<void> {
		// 1. Verifica se a escola existe
		const escola = await this.findOne(id);

		// 2. Checa usuários ATIVOS (não-deletados)
		const usuariosVinculados = await this.userRepository.count({
			where: { school: { id: escola.id } },
		});
		
		if (usuariosVinculados > 0) {
			throw new ConflictException(
				`Esta escola não pode ser excluída pois ${usuariosVinculados} usuário(s) ativos estão vinculados a ela.`,
			);
		}

		// 3. Limpa o estoque (como já fazíamos)
		await this.escolaEstoqueRepository.delete({ school: { id: escola.id } });

		// 4. Executa o Soft Delete e registra quem deletou
		try {
			await this.escolaRepository.softDelete(id);
			await this.escolaRepository.update(id, {
				deletedBy: actingUser,
			});
		} catch (error) {
			console.error("Erro ao aplicar soft-delete na escola:", error)
			throw new ConflictException('Ocorreu um erro ao excluir a escola.');
		}
	}
}