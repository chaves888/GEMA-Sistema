// src/products/products.service.ts
import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
// --- 1. Importar 'Not' ---
import { Repository, Not } from 'typeorm';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Product } from './entities/product.entity';
import { User } from 'src/users/entities/user.entity';

@Injectable()
export class ProductsService {
	constructor(
		@InjectRepository(Product)
		private readonly productRepository: Repository<Product>,
	) {}

	async create(createProductDto: CreateProductDto) {
		// --- 2. LÓGICA DE VERIFICAÇÃO ATUALIZADA (create) ---
		// Checa 'name' duplicado (só em ativos)
		const existingProduct = await this.productRepository.findOne({
			where: { name: createProductDto.name },
			// (Padrão: só busca ativos/não-deletados)
		});

		if (existingProduct) {
			throw new ConflictException('Já existe um produto ATIVO com este nome.');
		}
		// --- FIM DA ATUALIZAÇÃO ---

		const product = this.productRepository.create(createProductDto);
		// 'try/catch' por duplicidade não é mais necessário
		return await this.productRepository.save(product);
	}

	findAll() {
		return this.productRepository.find({ order: { name: 'ASC' } });
	}

	async findOne(id: string) {
		const product = await this.productRepository.findOneBy({ id });
		if (!product) {
			throw new NotFoundException(`Produto com ID "${id}" não encontrado`);
		}
		return product;
	}

	async update(id: string, updateProductDto: UpdateProductDto) {
		const product = await this.productRepository.preload({
			id: id,
			...updateProductDto,
		});
		if (!product) {
			throw new NotFoundException(`Produto com ID "${id}" não encontrado`);
		}

		// --- 3. LÓGICA DE VERIFICAÇÃO ATUALIZADA (update) ---
		if (updateProductDto.name) {
			const existingName = await this.productRepository.findOne({
				where: { name: updateProductDto.name, id: Not(id) }, // Procura em OUTROS produtos
			});
			if (existingName) {
				throw new ConflictException(`Já existe OUTRO produto ATIVO com o nome "${updateProductDto.name}".`);
			}
		}
		// --- FIM DA ATUALIZAÇÃO ---

		return await this.productRepository.save(product);
	}

	async remove(id: string, actingUser: User) {
		const product = await this.findOne(id);
		try {
			await this.productRepository.softDelete(id);
			await this.productRepository.update(id, {
				deletedBy: actingUser,
			});
		} catch (error) {
			console.error('Erro ao aplicar soft-delete no produto:', error);
			throw new ConflictException('Ocorreu um erro ao excluir o produto.');
		}
	}
}