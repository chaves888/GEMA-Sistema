import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Product } from './entities/product.entity';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  async create(createProductDto: CreateProductDto) {
    const product = this.productRepository.create(createProductDto);
    try {
      return await this.productRepository.save(product);
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw new ConflictException('Já existe um produto com este nome.');
      }
      throw error;
    }
  }

  findAll() {
    // Assumindo que você ainda não implementou o soft-delete.
    // Se/quando implementar, adicione { where: { isActive: true } }
    return this.productRepository.find({ order: { name: 'ASC' } });
  }

  async findOne(id: string) {
    // Assumindo { where: { isActive: true } } para soft-delete no futuro
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
    try {
      return await this.productRepository.save(product);
    } catch (error) {
      if (error.code === 'ER_DUP_ENTRY') {
        throw new ConflictException('Já existe um produto com este nome.');
      }
      throw error;
    }
  }

  async remove(id: string) {
    const product = await this.findOne(id); // Busca o produto para garantir que ele existe
    try {
      await this.productRepository.remove(product);
    } catch (error) {
      // ER_ROW_IS_REFERENCED_2 é o código de erro do MySQL para FK constraint
      if (error.code === 'ER_ROW_IS_REFERENCED_2') {
        // Aqui está a nova mensagem solicitada
        throw new ConflictException(
          'Este produto não pode ser excluído, pois já está vinculado a estoques, cardápios ou solicitações.',
        );
      }
      // Lança outros erros (ex: falha de conexão com o banco)
      throw error;
    }
  }
}
