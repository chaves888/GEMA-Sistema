import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
import { Product } from 'src/products/entities/product.entity';
import { Repository } from 'typeorm';
import { AjustarEstoqueDto } from './dto/ajustar-estoque.dto';
import { EscolaEstoque } from './entities/escola-estoque.entity';
import { PrefeituraEstoque } from './entities/prefeitura-estoque.entity';

@Injectable()
export class EstoqueService {
  constructor(
    @InjectRepository(PrefeituraEstoque)
    private readonly prefeituraEstoqueRepo: Repository<PrefeituraEstoque>,
    @InjectRepository(EscolaEstoque)
    private readonly escolaEstoqueRepo: Repository<EscolaEstoque>,
    @InjectRepository(Product)
    private readonly productRepo: Repository<Product>,
    @InjectRepository(Escola)
    private readonly escolaRepo: Repository<Escola>,
  ) {}

  private getStatus(quantity: number, minStock: number): string {
    if (minStock <= 0) return 'N/A';
    if (quantity <= minStock) return 'Crítico';
    if (quantity <= minStock * 2) return 'Médio';
    return 'Bom';
  }

  private getPercentage(quantity: number, minStock: number): number {
    if (minStock <= 0) return 100;
    return Math.round((quantity / minStock) * 100);
  }

  // Função genérica para formatar, agora buscando minStock do produto
  private formatStockResponse(item: PrefeituraEstoque | EscolaEstoque) {
    const quantity = item.quantity;
    const minStock = item.product.minStock;

    return {
      ...item,
      status: this.getStatus(quantity, minStock),
      percentage: this.getPercentage(quantity, minStock),
    };
  }

  async getPrefeituraEstoque() {
    const allProducts = await this.productRepo.find({ order: { name: 'ASC' } });
    const stockItems = await this.prefeituraEstoqueRepo.find({ relations: ['product'] });
    const stockMap = new Map(stockItems.map(item => [item.product.id, item]));

    const fullStock = allProducts.map(product => {
      const stockItem = stockMap.get(product.id);
      const quantity = stockItem?.quantity ?? 0;
      const minStock = product.minStock;
      
      return {
        product: product,
        quantity: quantity,
        minStock: minStock,
        status: this.getStatus(quantity, minStock),
        percentage: this.getPercentage(quantity, minStock),
      };
    });

    fullStock.sort((a, b) => a.percentage - b.percentage);
    return fullStock;
  }

  async ajustarPrefeituraEstoque(dto: AjustarEstoqueDto) {
    const { productId, quantity } = dto;
    let estoqueItem = await this.prefeituraEstoqueRepo.findOne({ where: { product: { id: productId } }, relations: ['product'] });

    if (!estoqueItem) {
      const product = await this.productRepo.findOneBy({ id: productId });
      if (!product) throw new NotFoundException(`Produto com ID ${productId} não encontrado.`);
      estoqueItem = this.prefeituraEstoqueRepo.create({ product, quantity });
    } else {
      estoqueItem.quantity = quantity;
    }
    
    const savedItem = await this.prefeituraEstoqueRepo.save(estoqueItem);
    return this.formatStockResponse(savedItem);
  }

  async getEscolaEstoque(schoolId: string) {
    const allProducts = await this.productRepo.find({ order: { name: 'ASC' } });
    const stockItems = await this.escolaEstoqueRepo.find({ where: { school: { id: schoolId } }, relations: ['product', 'school'] });
    const stockMap = new Map(stockItems.map(item => [item.product.id, item]));

    const fullStock = allProducts.map(product => {
      const stockItem = stockMap.get(product.id);
      const quantity = stockItem?.quantity ?? 0;
      const minStock = product.minStock;
      return {
        product: product,
        quantity: quantity,
        minStock: minStock,
        status: this.getStatus(quantity, minStock),
        percentage: this.getPercentage(quantity, minStock),
      };
    });

    fullStock.sort((a, b) => a.percentage - b.percentage);
    return fullStock;
  }

  async ajustarEscolaEstoque(schoolId: string, dto: AjustarEstoqueDto) {
    const { productId, quantity } = dto;
    const school = await this.escolaRepo.findOneBy({ id: schoolId });
    if (!school) throw new NotFoundException(`Escola com ID ${schoolId} não encontrada.`);
    
    let estoqueItem = await this.escolaEstoqueRepo.findOne({ where: { product: { id: productId }, school: { id: schoolId } }, relations: ['product', 'school'] });

    if (!estoqueItem) {
      const product = await this.productRepo.findOneBy({ id: productId });
      if (!product) throw new NotFoundException(`Produto com ID ${productId} não encontrado.`);
      estoqueItem = this.escolaEstoqueRepo.create({ product, school, quantity });
    } else {
      estoqueItem.quantity = quantity;
    }

    const savedItem = await this.escolaEstoqueRepo.save(estoqueItem);
    return this.formatStockResponse(savedItem);
  }
}