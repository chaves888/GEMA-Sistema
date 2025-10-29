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

  // --- FUNÇÕES AUXILIARES ATUALIZADAS ---
  private getStatus(quantity: number, minStock: number): string {
    // minStock agora é sempre um número (default 0 no product)
    if (minStock <= 0) return 'N/A'; // Se minStock não definido ou 0, status é N/A
    if (quantity <= minStock) return 'Crítico';
    if (quantity <= minStock * 2) return 'Médio';
    return 'Bom';
  }

  private getPercentage(quantity: number, minStock: number): number {
    if (minStock <= 0) return 100; // Retorna 100% se não há mínimo definido
    const percentage = Math.round((quantity / minStock) * 100);
    return percentage;
  }
  
  // Função de formatar resposta (usada internamente apenas em 'ajustar')
  // Nota: getPrefeituraEstoque e getEscolaEstoque têm sua própria lógica de formatação agora
  private formatStockResponse(item: PrefeituraEstoque | EscolaEstoque) {
    const quantity = item.quantity;
    
    // --- LÓGICA ATUALIZADA ---
    // Determina qual minStock usar baseado no tipo da entidade
    const minStock = (item instanceof EscolaEstoque)
      ? item.product.minStockEscola
      : item.product.minStockPrefeitura;
    // --- FIM LÓGICA ---

    return {
      id: item.id,
      product: item.product,
      quantity: quantity,
      minStock: minStock, // Retorna o minStock correto
      status: this.getStatus(quantity, minStock),
      percentage: this.getPercentage(quantity, minStock),
      ...(item instanceof EscolaEstoque && { school: item.school })
    };
  }
  // --- FIM FUNÇÕES AUXILIARES ---

  async getPrefeituraEstoque() {
    // Busca produtos primeiro, pois eles contêm o minStock
    const allProducts = await this.productRepo.find({ order: { name: 'ASC' } });
    const stockItems = await this.prefeituraEstoqueRepo.find({ relations: ['product'] });
    const stockMap = new Map(stockItems.map(item => [item.product.id, item]));

    const fullStock = allProducts.map(product => {
      const stockItem = stockMap.get(product.id);
      const quantity = stockItem?.quantity ?? 0;
      // --- LÓGICA ATUALIZADA ---
      const minStock = product.minStockPrefeitura; // <-- Pega o mínimo da prefeitura
      // --- FIM LÓGICA ---

      return {
        product: product,
        quantity: quantity,
        minStock: minStock, // Retorna o minStock correto
        status: this.getStatus(quantity, minStock),
        percentage: this.getPercentage(quantity, minStock),
      };
    });

    // Ordenação (Crítico primeiro)
    fullStock.sort((a, b) => {
        const statusOrder = { 'Crítico': 1, 'Médio': 2, 'Bom': 3, 'N/A': 4 };
        const orderA = statusOrder[a.status];
        const orderB = statusOrder[b.status];
        if (orderA !== orderB) return orderA - orderB;
        return a.percentage - b.percentage;
    });
    return fullStock;
  }

  async ajustarPrefeituraEstoque(dto: AjustarEstoqueDto) {
    // DTO não tem mais minStock
    const { productId, quantity } = dto;
    let estoqueItem = await this.prefeituraEstoqueRepo.findOne({
      where: { product: { id: productId } },
      relations: ['product']
    });

    if (!estoqueItem) {
      const product = await this.productRepo.findOneBy({ id: productId });
      if (!product) throw new NotFoundException(`Produto com ID ${productId} não encontrado.`);
      estoqueItem = this.prefeituraEstoqueRepo.create({
          product,
          quantity,
          // minStock não é mais definido aqui
      });
    } else {
      estoqueItem.quantity = quantity;
      // minStock não é mais ajustado aqui
    }

    const savedItem = await this.prefeituraEstoqueRepo.save(estoqueItem);
    // Recarrega para obter dados do produto (minStockPrefeitura) para formatar
    const reloadedItem = await this.prefeituraEstoqueRepo.findOneOrFail({
        where: { id: savedItem.id },
        relations: ['product']
    });
    return this.formatStockResponse(reloadedItem); // formatResponse usará product.minStockPrefeitura
  }

  async getEscolaEstoque(schoolId: string) {
     const allProducts = await this.productRepo.find({ order: { name: 'ASC' } });
     const stockItems = await this.escolaEstoqueRepo.find({
       where: { school: { id: schoolId } },
       relations: ['product', 'school']
     });
     const stockMap = new Map(stockItems.map(item => [item.product.id, item]));

     const fullStock = allProducts.map(product => {
       const stockItem = stockMap.get(product.id);
       const quantity = stockItem?.quantity ?? 0;
       // --- LÓGICA ATUALIZADA ---
       const minStock = product.minStockEscola; // <-- Pega o mínimo da escola
       // --- FIM LÓGICA ---

       return {
         product: product,
         quantity: quantity,
         minStock: minStock, // Retorna o minStock correto
         status: this.getStatus(quantity, minStock),
         percentage: this.getPercentage(quantity, minStock),
       };
     });

     // Ordenação (Crítico primeiro)
     fullStock.sort((a, b) => {
        const statusOrder = { 'Crítico': 1, 'Médio': 2, 'Bom': 3, 'N/A': 4 };
        const orderA = statusOrder[a.status];
        const orderB = statusOrder[b.status];
        if (orderA !== orderB) return orderA - orderB;
        return a.percentage - b.percentage;
    });
    return fullStock;
  }

  async ajustarEscolaEstoque(schoolId: string, dto: AjustarEstoqueDto) {
    // DTO não tem mais minStock
    const { productId, quantity } = dto;
    const school = await this.escolaRepo.findOneBy({ id: schoolId });
    if (!school) throw new NotFoundException(`Escola com ID ${schoolId} não encontrada.`);

    let estoqueItem = await this.escolaEstoqueRepo.findOne({
      where: { product: { id: productId }, school: { id: schoolId } },
      relations: ['product', 'school']
    });

    if (!estoqueItem) {
      const product = await this.productRepo.findOneBy({ id: productId });
      if (!product) throw new NotFoundException(`Produto com ID ${productId} não encontrado.`);
      estoqueItem = this.escolaEstoqueRepo.create({
          product,
          school,
          quantity,
          // minStock não é mais definido aqui
      });
    } else {
      estoqueItem.quantity = quantity;
      // minStock não é mais ajustado aqui
    }

    const savedItem = await this.escolaEstoqueRepo.save(estoqueItem);
    // Recarrega para obter dados do produto (minStockEscola) para formatar
    const reloadedItem = await this.escolaEstoqueRepo.findOneOrFail({
        where: { id: savedItem.id },
        relations: ['product', 'school']
    });
    return this.formatStockResponse(reloadedItem); // formatResponse usará product.minStockEscola
  }
}