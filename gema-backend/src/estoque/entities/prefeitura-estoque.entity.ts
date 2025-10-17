import { Product } from 'src/products/entities/product.entity';
import { Column, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn } from 'typeorm';

@Entity('prefeitura_estoque')
export class PrefeituraEstoque {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'float', default: 0 })
  quantity: number;

  // MUDANÇA AQUI: Adicionamos o onDelete: 'CASCADE'
  @OneToOne(() => Product, { eager: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'product_id' })
  product: Product;
}