// src/estoque/estoque.service.ts
import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Escola } from 'src/escolas/entities/escola.entity';
import { Product } from 'src/products/entities/product.entity';
import { DataSource, Repository } from 'typeorm';
import { AjustarEstoqueDto } from './dto/ajustar-estoque.dto';
import { EscolaEstoque } from './entities/escola-estoque.entity';
import { PrefeituraEstoque } from './entities/prefeitura-estoque.entity';
import { User } from 'src/users/entities/user.entity';
import {
	EstoqueMovimentacao,
	MotivoMovimentacao,
	TipoMovimentacao,
} from './entities/estoque-movimentacao.entity';
import * as xlsx from 'xlsx';
import {
	ImportacaoResultado,
	PlanilhaRow,
} from './dto/importar-estoque.dto';

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
		@InjectRepository(EstoqueMovimentacao)
		private readonly movimentacaoRepo: Repository<EstoqueMovimentacao>,
		private readonly dataSource: DataSource,
	) {}

	// --- FUNÇÕES AUXILIARES (Cálculo de Status) ---
	private getStatus(quantity: number, minStock: number): string {
		if (minStock <= 0) return 'N/A';
		if (quantity <= minStock) return 'Crítico';
		if (quantity <= minStock * 2) return 'Médio';
		return 'Bom';
	}
	private getPercentage(quantity: number, minStock: number): number {
		if (minStock <= 0) return 100;
		const percentage = Math.round((quantity / minStock) * 100);
		return percentage;
	}
	private formatStockResponse(item: PrefeituraEstoque | EscolaEstoque) {
		const quantity = item.quantity;
		const minStock =
			item instanceof EscolaEstoque
				? item.product.minStockEscola
				: item.product.minStockPrefeitura;
		return {
			id: item.id,
			product: item.product,
			quantity: quantity,
			minStock: minStock,
			status: this.getStatus(quantity, minStock),
			percentage: this.getPercentage(quantity, minStock),
			...(item instanceof EscolaEstoque && { school: item.school }),
		};
	}
	// --- FIM FUNÇÕES AUXILIARES ---

	// --- GET ESTOQUE PREFEITURA ---
	async getPrefeituraEstoque() {
		const allProducts = await this.productRepo.find({ order: { name: 'ASC' } });
		const stockItems = await this.prefeituraEstoqueRepo.find({
			relations: ['product'],
		});
		const stockMap = new Map(
			stockItems
				.filter((item) => item.product !== null)
				.map((item) => [item.product.id, item]),
		);
		const fullStock = allProducts.map((product) => {
			const stockItem = stockMap.get(product.id);
			const quantity = stockItem?.quantity ?? 0;
			const minStock = product.minStockPrefeitura;
			return {
				product: product,
				quantity: quantity,
				minStock: minStock,
				status: this.getStatus(quantity, minStock),
				percentage: this.getPercentage(quantity, minStock),
			};
		});
		fullStock.sort((a, b) => {
			const statusOrder = { Crítico: 1, Médio: 2, Bom: 3, 'N/A': 4 };
			const orderA = statusOrder[a.status];
			const orderB = statusOrder[b.status];
			if (orderA !== orderB) return orderA - orderB;
			return a.percentage - b.percentage;
		});
		return fullStock;
	}

	// --- AJUSTAR ESTOQUE PREFEITURA (COM LOG) ---
	async ajustarPrefeituraEstoque(dto: AjustarEstoqueDto, user: User) {
		const { productId, newQuantity, motivoCategoria, motivoObservacao } = dto;
		const queryRunner = this.dataSource.createQueryRunner();
		await queryRunner.connect();
		await queryRunner.startTransaction();
		try {
			let estoqueItem = await queryRunner.manager.findOne(PrefeituraEstoque, {
				where: { product: { id: productId } },
				relations: ['product'],
				lock: { mode: 'pessimistic_write' },
			});
			const product = await queryRunner.manager.findOneBy(Product, { id: productId });
			if (!product) {
				throw new NotFoundException(`Produto com ID ${productId} não encontrado.`);
			}
			if (!estoqueItem) {
				estoqueItem = queryRunner.manager.create(PrefeituraEstoque, {
					product,
					quantity: 0,
				});
			}
			const currentQuantity = estoqueItem.quantity;
			const diferenca = newQuantity - currentQuantity;
			if (diferenca === 0) {
				await queryRunner.rollbackTransaction();
				return this.formatStockResponse(estoqueItem);
			}
			const tipoMovimentacao = diferenca > 0 ? TipoMovimentacao.ENTRADA : TipoMovimentacao.SAIDA;
			let finalMotivoCategoria: MotivoMovimentacao;
			let finalMotivoObservacao: string | null = motivoObservacao || null;
			if (tipoMovimentacao === TipoMovimentacao.SAIDA) {
				if (!motivoCategoria) {
					throw new BadRequestException('A categoria do motivo é obrigatória ao reduzir o estoque.');
				}
				finalMotivoCategoria = motivoCategoria;
			} else {
				finalMotivoCategoria = motivoCategoria || MotivoMovimentacao.AJUSTE;
			}
			const movimentacao = queryRunner.manager.create(EstoqueMovimentacao, {
				contexto: 'prefeitura',
				product: product,
				school: null,
				user: user,
				tipo: tipoMovimentacao,
				quantidade: Math.abs(diferenca),
				motivoCategoria: finalMotivoCategoria,
				motivoObservacao: finalMotivoObservacao,
			});
			await queryRunner.manager.save(EstoqueMovimentacao, movimentacao);
			estoqueItem.quantity = newQuantity;
			const savedItem = await queryRunner.manager.save(PrefeituraEstoque, estoqueItem);
			await queryRunner.commitTransaction();
			return this.formatStockResponse(savedItem);
		} catch (error) {
			await queryRunner.rollbackTransaction();
			throw error;
		} finally {
			await queryRunner.release();
		}
	}

	// --- GET ESTOQUE ESCOLA ---
	async getEscolaEstoque(schoolId: string) {
		const allProducts = await this.productRepo.find({ order: { name: 'ASC' } });
		const stockItems = await this.escolaEstoqueRepo.find({
			where: { school: { id: schoolId } },
			relations: ['product', 'school'],
		});
		const stockMap = new Map(
			stockItems
				.filter((item) => item.product !== null)
				.map((item) => [item.product.id, item]),
		);
		const fullStock = allProducts.map((product) => {
			const stockItem = stockMap.get(product.id);
			const quantity = stockItem?.quantity ?? 0;
			const minStock = product.minStockEscola;
			return {
				product: product,
				quantity: quantity,
				minStock: minStock,
				status: this.getStatus(quantity, minStock),
				percentage: this.getPercentage(quantity, minStock),
			};
		});
		fullStock.sort((a, b) => {
			const statusOrder = { Crítico: 1, Médio: 2, Bom: 3, 'N/A': 4 };
			const orderA = statusOrder[a.status];
			const orderB = statusOrder[b.status];
			if (orderA !== orderB) return orderA - orderB;
			return a.percentage - b.percentage;
		});
		return fullStock;
	}

	// --- AJUSTAR ESTOQUE ESCOLA (COM LOG) ---
	async ajustarEscolaEstoque(schoolId: string, dto: AjustarEstoqueDto, user: User) {
		const { productId, newQuantity, motivoCategoria, motivoObservacao } = dto;
		const queryRunner = this.dataSource.createQueryRunner();
		await queryRunner.connect();
		await queryRunner.startTransaction();
		try {
			const school = await queryRunner.manager.findOneBy(Escola, { id: schoolId });
			if (!school) {
				throw new NotFoundException(`Escola com ID ${schoolId} não encontrada.`);
			}
			const product = await queryRunner.manager.findOneBy(Product, { id: productId });
			if (!product) {
				throw new NotFoundException(`Produto com ID ${productId} não encontrado.`);
			}
			let estoqueItem = await queryRunner.manager.findOne(EscolaEstoque, {
				where: { product: { id: productId }, school: { id: schoolId } },
				relations: ['product', 'school'],
				lock: { mode: 'pessimistic_write' },
			});
			if (!estoqueItem) {
				estoqueItem = queryRunner.manager.create(EscolaEstoque, {
					product,
					school,
					quantity: 0,
				});
			}
			const currentQuantity = estoqueItem.quantity;
			const diferenca = newQuantity - currentQuantity;
			if (diferenca === 0) {
				await queryRunner.rollbackTransaction();
				return this.formatStockResponse(estoqueItem);
			}
			const tipoMovimentacao = diferenca > 0 ? TipoMovimentacao.ENTRADA : TipoMovimentacao.SAIDA;
			let finalMotivoCategoria: MotivoMovimentacao;
			let finalMotivoObservacao: string | null = motivoObservacao || null;
			if (tipoMovimentacao === TipoMovimentacao.SAIDA) {
				if (!motivoCategoria) {
					throw new BadRequestException('A categoria do motivo é obrigatória ao reduzir o estoque.');
				}
				finalMotivoCategoria = motivoCategoria;
			} else {
				finalMotivoCategoria = motivoCategoria || MotivoMovimentacao.AJUSTE;
			}
			const movimentacao = queryRunner.manager.create(EstoqueMovimentacao, {
				contexto: 'escola',
				product: product,
				school: school,
				user: user,
				tipo: tipoMovimentacao,
				quantidade: Math.abs(diferenca),
				motivoCategoria: finalMotivoCategoria,
				motivoObservacao: finalMotivoObservacao,
			});
			await queryRunner.manager.save(EstoqueMovimentacao, movimentacao);
			estoqueItem.quantity = newQuantity;
			const savedItem = await queryRunner.manager.save(EscolaEstoque, estoqueItem);
			await queryRunner.commitTransaction();
			return this.formatStockResponse(savedItem);
		} catch (error) {
			await queryRunner.rollbackTransaction();
			throw error;
		} finally {
			await queryRunner.release();
		}
	}

	// --- FUNÇÃO DE IMPORTAÇÃO (LÓGICA DE SOMA) ---
	async importarEstoque(
		fileBuffer: Buffer,
		user: User,
	): Promise<ImportacaoResultado> {
		
		let data: PlanilhaRow[] = [];
		try {
			const workbook = xlsx.read(fileBuffer, { type: 'buffer' });
			const sheetName = workbook.SheetNames[0];
			const worksheet = workbook.Sheets[sheetName];
			
			const rawJson: any[] = xlsx.utils.sheet_to_json(worksheet, {
				header: 1,
				defval: null,
			});

			if (rawJson.length < 2) {
				throw new BadRequestException('Planilha vazia ou sem dados.');
			}

			const headers: string[] = rawJson.shift().map(h => String(h || '').trim().toUpperCase());
			
			const nomeIndex = headers.indexOf('PRODUTO_NOME');
			// --- MUDANÇA 1 ---
			const qtdeIndex = headers.indexOf('QUANTIDADE_AJUSTE');

			if (nomeIndex === -1 || qtdeIndex === -1) {
				throw new BadRequestException("Cabeçalhos inválidos. A planilha deve conter 'PRODUTO_NOME' e 'QUANTIDADE_AJUSTE'.");
			}
			
			data = rawJson.map((row, index) => ({
				PRODUTO_NOME: row[nomeIndex] ? String(row[nomeIndex]).trim() : null,
				// --- MUDANÇA 2 ---
				QUANTIDADE_AJUSTE: row[qtdeIndex] ? parseFloat(String(row[qtdeIndex])) : null,
				Linha: index + 2,
			}));

		} catch (error) {
			throw new BadRequestException(`Erro ao ler o arquivo Excel: ${error.message}`);
		}

		// --- ETAPA 2: Pré-validação ---
		const allProducts = await this.productRepo.find();
		const productMap = new Map(
			allProducts.map(p => [p.name.trim().toLowerCase(), p])
		);

		const erros: string[] = [];
		// --- MUDANÇA 3 ---
		const produtosValidos: { product: Product; quantidadeAjuste: number; linha: number }[] = [];

		for (const row of data) {
			if (!row.PRODUTO_NOME) {
				erros.push(`Linha ${row.Linha}: 'PRODUTO_NOME' está em branco.`);
				continue;
			}
			// --- MUDANÇA 4 ---
			// Agora a quantidade pode ser 0 (sem ajuste), mas não pode ser nula
			if (row.QUANTIDADE_AJUSTE === null || isNaN(row.QUANTIDADE_AJUSTE)) {
				erros.push(`Linha ${row.Linha}: 'QUANTIDADE_AJUSTE' ('${row.QUANTIDADE_AJUSTE}') é inválida.`);
				continue;
			}

			const product = productMap.get(row.PRODUTO_NOME.toLowerCase());
			if (!product) {
				erros.push(`Linha ${row.Linha}: Produto "${row.PRODUTO_NOME}" não encontrado no cadastro.`);
				continue;
			}

			// --- MUDANÇA 5 ---
			produtosValidos.push({ 
				product, 
				quantidadeAjuste: row.QUANTIDADE_AJUSTE,
				linha: row.Linha // Guarda a linha para logs de erro
			});
		}

		if (erros.length > 0) {
			throw new BadRequestException({
				message: 'A importação falhou. Corrija os erros na planilha e tente novamente.',
				erros: erros,
			});
		}

		// --- ETAPA 3: Executar a Importação (Transação) ---
		const queryRunner = this.dataSource.createQueryRunner();
		await queryRunner.connect();
		await queryRunner.startTransaction();

		let processadosCount = 0;

		try {
			for (const item of produtosValidos) {
				// --- MUDANÇA 6: LÓGICA DE SOMA ---
				const { product, quantidadeAjuste, linha } = item;
				
				// Pula se o ajuste for 0
				if (quantidadeAjuste === 0) {
					continue;
				}

				let estoqueItem = await queryRunner.manager.findOne(PrefeituraEstoque, {
					where: { product: { id: product.id } },
					lock: { mode: 'pessimistic_write' },
				});

				if (!estoqueItem) {
					estoqueItem = queryRunner.manager.create(PrefeituraEstoque, {
						product,
						quantity: 0,
					});
				}

				const currentQuantity = estoqueItem.quantity;
				const newQuantity = currentQuantity + quantidadeAjuste; // <-- LÓGICA DE SOMA
				const diferenca = quantidadeAjuste; // A diferença é o próprio ajuste

				// Validação de estoque negativo
				if (newQuantity < 0) {
					throw new BadRequestException(`Linha ${linha}: Não é possível remover ${Math.abs(diferenca)} de "${product.name}". O estoque ficaria negativo (${newQuantity}). Estoque atual: ${currentQuantity}.`);
				}

				const tipoMovimentacao = diferenca > 0 ? TipoMovimentacao.ENTRADA : TipoMovimentacao.SAIDA;
				
				const movimentacao = queryRunner.manager.create(EstoqueMovimentacao, {
					contexto: 'prefeitura',
					product: product,
					school: null,
					user: user,
					tipo: tipoMovimentacao,
					quantidade: Math.abs(diferenca),
					motivoCategoria: MotivoMovimentacao.AJUSTE,
					motivoObservacao: `Importação via planilha (Ajuste: ${diferenca > 0 ? '+' : ''}${diferenca})`,
				});
				await queryRunner.manager.save(EstoqueMovimentacao, movimentacao);

				estoqueItem.quantity = newQuantity; // <-- Salva a nova quantidade somada
				await queryRunner.manager.save(PrefeituraEstoque, estoqueItem);
				
				processadosCount++;
				// --- FIM DA MUDANÇA 6 ---
			}

			await queryRunner.commitTransaction();

			if (processadosCount === 0) {
				return {
					message: 'Importação concluída. Nenhum ajuste de estoque foi necessário (valores zerados).',
					processados: 0,
					erros: [],
				};
			}

			return {
				message: `${processadosCount} produto(s) tiveram o estoque atualizado com sucesso.`,
				processados: processadosCount,
				erros: [],
			};

		} catch (error) {
			await queryRunner.rollbackTransaction();
			console.error('Erro na transação de importação:', error);
			// Se for um BadRequest (estoque negativo), passa o erro adiante
			if (error instanceof BadRequestException) {
				throw error;
			}
			throw new Error(`Erro interno ao salvar os dados: ${error.message}`);
		} finally {
			await queryRunner.release();
		}
	}
}