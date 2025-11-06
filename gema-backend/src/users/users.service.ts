// src/users/users.service.ts
import {
  Injectable,
  NotFoundException,
  ConflictException,
  ForbiddenException, // 1. Importar ForbiddenException
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
import { Repository } from 'typeorm';
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
    const { schoolId, name, ...userData } = createUserDto;

    const existingUser = await this.usersRepository.findOne({
      where: { name },
      withDeleted: true, // Verifica até nos excluídos
    });

    if (existingUser) {
      throw new ConflictException(`Já existe um usuário cadastrado com o nome "${name}".`);
    }
    
    // isActive será 'true' por padrão, conforme definido na entidade
    const newUser = this.usersRepository.create({ name, ...userData });

    if (schoolId) {
      const school = await this.escolasRepository.findOneBy({ id: schoolId });
      if (!school) {
        throw new NotFoundException(`Escola com ID ${schoolId} não encontrada.`);
      }
      newUser.school = school;
    }

    try {
      await this.usersRepository.save(newUser);
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw new ConflictException('Este endereço de email já está cadastrado.');
      }
      throw error;
    }

    const { password, ...result } = newUser;
    return result;
  }

  async findAll() {
    // 2. O 'find' padrão agora SÓ retorna usuários NÃO excluídos (deletedAt IS NULL)
    // Ele trará tanto ativos quanto inativos para o admin poder gerenciar
    const users = await this.usersRepository.find({ relations: ['school'] });
    return users.map(({ password, ...user }) => user);
  }

  async findOne(id: string) {
    // 3. O 'findOneBy' padrão também respeita o soft delete
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

    try {
      await this.usersRepository.save(user);
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw new ConflictException('Este endereço de email já está cadastrado.');
      }
      throw error;
    }

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

  // 5. FINDONEBYEMAIL ATUALIZADO (PARA LOGIN)
  async findOneByEmail(email: string): Promise<User | null> {
    // Agora só permite o login de usuários ATIVOS e NÃO-DELETADOS
    return this.usersRepository.findOne({
      where: { email, isActive: true },
      relations: ['school'],
    });
  }

  // --- 6. NOVOS MÉTODOS (ATIVAR/DESATIVAR) ---

  async activate(id: string, actingUser: User) {
    if (id === actingUser.id) {
      throw new ForbiddenException('Você não pode ativar seu próprio usuário.');
    }
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
}