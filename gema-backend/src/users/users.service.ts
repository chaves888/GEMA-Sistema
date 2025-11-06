// src/users/users.service.ts
import {
	Injectable,
	NotFoundException,
	ConflictException,
	ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
// --- 1. Importar 'Not' ---
import { Repository, Not } from 'typeorm';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './entities/user.entity';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
	constructor(
		@InjectRepository(User)
		private usersRepository: Repository<User>,
		@InjectRepository(Escola)
		private escolasRepository: Repository<Escola>,
	) {}

	async create(createUserDto: CreateUserDto) {
		const { schoolId, name, email, ...userData } = createUserDto;

		// --- 2. LÓGICA DE VERIFICAÇÃO ATUALIZADA (create) ---
		// (O 'findOne' padrão só busca em registros ativos/não-deletados)
		
		// Checa 'name' duplicado (só em ativos)
		const existingName = await this.usersRepository.findOne({
			where: { name },
		});
		if (existingName) {
			throw new ConflictException(`Já existe um usuário ATIVO com o nome "${name}".`);
		}

		// Checa 'email' duplicado (só em ativos)
		const existingEmail = await this.usersRepository.findOne({
			where: { email },
		});
		if (existingEmail) {
			throw new ConflictException(`Este endereço de email já está cadastrado em um usuário ATIVO.`);
		}
		// --- FIM DA ATUALIZAÇÃO ---

		// 'isActive' será 'true' por padrão, conforme definido na entidade
		const newUser = this.usersRepository.create({ name, email, ...userData });

		if (schoolId) {
			const school = await this.escolasRepository.findOneBy({ id: schoolId });
			if (!school) {
				throw new NotFoundException(`Escola com ID ${schoolId} não encontrada.`);
			}
			newUser.school = school;
		}

		// O try/catch para 'ER_DUP_ENTRY' não é mais necessário aqui para 'email' ou 'name'
		await this.usersRepository.save(newUser);
		
		const { password, ...result } = newUser;
		return result;
	}

	async findAll() {
		// O 'find' padrão agora SÓ retorna usuários NÃO excluídos (deletedAt IS NULL)
		// Ele trará tanto ativos quanto inativos para o admin poder gerenciar
		const users = await this.usersRepository.find({ relations: ['school'] });
		return users.map(({ password, ...user }) => user);
	}

	async findOne(id: string) {
		// O 'findOneBy' padrão também respeita o soft delete
		const user = await this.usersRepository.findOne({
			where: { id },
			relations: ['school'],
		});
		if (!user) {
			throw new NotFoundException(`Usuário com ID "${id}" não encontrado`);
		}
		const { password, ...result } = user;
		return result;
	}

	async update(id: string, updateUserDto: UpdateUserDto) {
		if (updateUserDto.password) {
			updateUserDto.password = await bcrypt.hash(updateUserDto.password, 10);
		}

		const { schoolId, ...userData } = updateUserDto;
		const user = await this.usersRepository.preload({
			id: id,
			...userData,
		});

		if (!user) {
			throw new NotFoundException(`Usuário com ID "${id}" não encontrado`);
		}

		// --- 3. LÓGICA DE VERIFICAÇÃO ATUALIZADA (update) ---
		if (updateUserDto.name) {
			const existingName = await this.usersRepository.findOne({
				where: { name: updateUserDto.name, id: Not(id) }, // Procura em OUTROS usuários
			});
			if (existingName) {
				throw new ConflictException(`Já existe OUTRO usuário ATIVO com o nome "${updateUserDto.name}".`);
			}
		}
		if (updateUserDto.email) {
			const existingEmail = await this.usersRepository.findOne({
				where: { email: updateUserDto.email, id: Not(id) }, // Procura em OUTROS usuários
			});
			if (existingEmail) {
				throw new ConflictException(`Já existe OUTRO usuário ATIVO com o email "${updateUserDto.email}".`);
			}
		}
		// --- FIM DA ATUALIZAÇÃO ---

		if (schoolId) {
			const school = await this.escolasRepository.findOneBy({ id: schoolId });
			if (!school) {
				throw new NotFoundException(`Escola com ID ${schoolId} não encontrada.`);
			}
			user.school = school;
		} else if (
			(user.profile !== 'escola' && user.profile !== 'cozinheira') ||
			updateUserDto.schoolId === null
		) {
			user.school = null;
		}

		// O try/catch não é mais necessário para duplicidade
		await this.usersRepository.save(user);

		const { password, ...result } = user;
		return result;
	}

	async remove(id: string, actingUser: User): Promise<void> {
		const userToDelete = await this.usersRepository.findOneBy({ id });
		if (!userToDelete) {
			throw new NotFoundException(`Usuário com ID "${id}" não encontrado`);
		}
		if (userToDelete.id === actingUser.id) {
			throw new ForbiddenException('Você não pode excluir o seu próprio usuário.');
		}
		await this.usersRepository.softDelete(id);
		await this.usersRepository.update(id, {
			deletedBy: actingUser,
		});
	}

	// FINDONEBYEMAIL (PARA LOGIN)
	async findOneByEmail(email: string): Promise<User | null> {
		// Agora só permite o login de usuários ATIVOS e NÃO-DELETADOS
		return this.usersRepository.findOne({
			where: { email, isActive: true },
			relations: ['school'],
		});
	}

	// MÉTODOS (ATIVAR/DESATIVAR)
	async activate(id: string, actingUser: User) {
		if (id === actingUser.id) {
			throw new ForbiddenException('Você não pode ativar seu próprio usuário.');
		}
		// 'findOneBy' só encontra usuários não-deletados, o que está correto.
		const user = await this.usersRepository.findOneBy({ id });
		if (!user) {
			throw new NotFoundException(`Usuário com ID "${id}" não encontrado.`);
		}
		user.isActive = true;
		await this.usersRepository.save(user);
		const { password, ...result } = user;
		return result;
	}

	async deactivate(id: string, actingUser: User) {
		if (id === actingUser.id) {
			throw new ForbiddenException('Você não pode desativar seu próprio usuário.');
		}
		const user = await this.usersRepository.findOneBy({ id });
		if (!user) {
			throw new NotFoundException(`Usuário com ID "${id}" não encontrado.`);
		}
		user.isActive = false;
		await this.usersRepository.save(user);
		const { password, ...result } = user;
		return result;
	}

	// --- 4. FUNÇÃO ADICIONADA (Necessária para o EscolasService) ---
	async countActiveUsersBySchool(schoolId: string): Promise<number> {
		// O '.count()' padrão já ignora registros soft-deleted (deletedAt IS NOT NULL)
		// e nós só queremos contar os ATIVOS (isActive: true)
		return this.usersRepository.count({
			where: {
				school: { id: schoolId },
				isActive: true,
			},
		});
	}
}