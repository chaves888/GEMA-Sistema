import {
  Injectable,
  NotFoundException,
  ConflictException,
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
    const { schoolId, ...userData } = createUserDto;

    const newUser = this.usersRepository.create(userData);

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
    const users = await this.usersRepository.find({ relations: ['school'] });
    return users.map(({ password, ...user }) => user);
  }

  async findOne(id: string) {
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

  async remove(id: string): Promise<void> {
    const findUser = await this.usersRepository.findOneBy({ id });
    if (!findUser) {
      throw new NotFoundException(`Usuário com ID "${id}" não encontrado`);
    }
    await this.usersRepository.remove(findUser);
  }

  async findOneByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email }, relations: ['school'] });
  }
}