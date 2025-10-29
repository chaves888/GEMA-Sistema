import { Product } from 'src/products/entities/product.entity';
import { Column, Entity, JoinColumn, OneToOne, PrimaryGeneratedColumn, UpdateDateColumn, CreateDateColumn } from 'typeorm';

@Entity('prefeitura_estoque')
export class PrefeituraEstoque {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'float', default: 0 })
  quantity: number;

  // --- MUDANÇA AQUI ---
  // A coluna minStock foi REMOVIDA desta entidade
  // --- FIM DA MUDANÇA ---

  @OneToOne(() => Product, { eager: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @CreateDateColumn({ name: 'created_at'})
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at'})
  updatedAt: Date;
}