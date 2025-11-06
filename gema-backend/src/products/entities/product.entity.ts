// src/products/entities/product.entity.ts
import { User } from 'src/users/entities/user.entity';
import {
	Column,
	CreateDateColumn,
	DeleteDateColumn,
	Entity,
	JoinColumn,
	ManyToOne,
	PrimaryGeneratedColumn,
	UpdateDateColumn,
} from 'typeorm';

export enum ProductUnit {
	UNIDADE = 'UN',
}

@Entity('products')
export class Product {
	@PrimaryGeneratedColumn('uuid')
	id: string;

	// --- CORREÇÃO: 'unique: true' REMOVIDO ---
	@Column()
	name: string;
	// --- FIM DA CORREÇÃO ---

	@Column({
		type: 'enum',
		enum: ProductUnit,
	})
	unit: ProductUnit;

	@Column({ type: 'float', default: 0, name: 'min_stock_prefeitura' })
	minStockPrefeitura: number;

	@Column({ type: 'float', default: 0, name: 'min_stock_escola' })
	minStockEscola: number;

	@CreateDateColumn({ name: 'created_at' })
	createdAt: Date;

	@UpdateDateColumn({ name: 'updated_at' })
	updatedAt: Date;

	@DeleteDateColumn({ name: 'deleted_at' })
	deletedAt: Date | null;

	@ManyToOne(() => User, { nullable: true, eager: false })
	@JoinColumn({ name: 'deleted_by_user_id' })
	deletedBy: User | null;
}