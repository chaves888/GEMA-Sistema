import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn
} from 'typeorm';

export enum ProductUnit {
  LITRO = 'L',
  UNIDADE = 'UN',
}

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({
    type: 'enum',
    enum: ProductUnit,
  })
  unit: ProductUnit;

  // --- MUDANÇA AQUI ---
  // Removemos o minStock único

  @Column({ type: 'float', default: 0, name: 'min_stock_prefeitura' })
  minStockPrefeitura: number;

  @Column({ type: 'float', default: 0, name: 'min_stock_escola' })
  minStockEscola: number;
  // --- FIM DA MUDANÇA ---

  @CreateDateColumn({ name: 'created_at'})
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at'})
  updatedAt: Date;
}