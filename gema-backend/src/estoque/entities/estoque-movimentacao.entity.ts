// src/estoque/entities/estoque-movimentacao.entity.ts
import {
	Column,
	CreateDateColumn,
	Entity,
	JoinColumn,
	ManyToOne,
	PrimaryGeneratedColumn,
} from 'typeorm';
import { Product } from 'src/products/entities/product.entity';
import { User } from 'src/users/entities/user.entity';
import { Escola } from 'src/escolas/entities/escola.entity';

export enum TipoMovimentacao {
	ENTRADA = 'entrada',
	SAIDA = 'saida',
}

// Categorias de Motivo
export enum MotivoMovimentacao {
	AJUSTE = 'ajuste', // Para entradas ou saídas manuais (contagem)
	PERDA = 'perda',
	USO_INTERNO = 'uso_interno',
	VENCIMENTO = 'vencimento',
	OUTRO = 'outro',
	// (Motivos de entrada/saída automáticos)
	ENTRADA_SOLICITACAO = 'entrada_solicitacao', // Quando a escola recebe
	SAIDA_SOLICITACAO = 'saida_solicitacao', // Quando a prefeitura envia
}

@Entity('estoque_movimentacoes')
export class EstoqueMovimentacao {
	@PrimaryGeneratedColumn('uuid')
	id: string;

	// 'prefeitura' ou 'escola'
	@Column({ type: 'varchar', length: 20 })
	contexto: string;

	@ManyToOne(() => Product, { eager: true, onDelete: 'RESTRICT' })
	@JoinColumn({ name: 'product_id' })
	product: Product;

	// Nulo se for estoque da prefeitura
	@ManyToOne(() => Escola, { nullable: true, eager: false, onDelete: 'CASCADE' })
	@JoinColumn({ name: 'school_id' })
	school: Escola | null;

	// Quem fez a movimentação
	@ManyToOne(() => User, { eager: false, onDelete: 'SET NULL' })
	@JoinColumn({ name: 'user_id' })
	user: User;

	@Column({ type: 'enum', enum: TipoMovimentacao })
	tipo: TipoMovimentacao;

	@Column({ type: 'float' })
	quantidade: number; // Sempre um valor positivo

	// --- Colunas de Motivo ---
	@Column({ type: 'enum', enum: MotivoMovimentacao })
	motivoCategoria: MotivoMovimentacao;

	@Column({ type: 'text', nullable: true })
	motivoObservacao: string | null;
	// --- Fim ---

	@CreateDateColumn({ name: 'created_at' })
	createdAt: Date;
}