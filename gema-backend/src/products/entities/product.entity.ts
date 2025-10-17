import { 
  Column, 
  CreateDateColumn, 
  Entity, 
  PrimaryGeneratedColumn, 
  UpdateDateColumn 
} from 'typeorm';

export enum ProductUnit {
  KILOGRAMA = 'KG',
  GRAMA = 'G',
  LITRO = 'L',
  MILILITRO = 'ML',
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

  // O Estoque Mínimo volta para cá
  @Column({ type: 'float', default: 0 })
  minStock: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}