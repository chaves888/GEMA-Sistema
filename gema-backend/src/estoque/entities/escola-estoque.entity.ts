import { Escola } from 'src/escolas/entities/escola.entity';
import { Product } from 'src/products/entities/product.entity';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, Unique, UpdateDateColumn, CreateDateColumn } from 'typeorm';

@Entity('escola_estoque')
@Unique(['product', 'school'])
export class EscolaEstoque {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'float', default: 0 })
  quantity: number;

  // --- MUDANÇA AQUI ---
  // A coluna minStock foi REMOVIDA desta entidade
  // --- FIM DA MUDANÇA ---

  @ManyToOne(() => Product, { eager: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'product_id' })
  product: Product;

  @ManyToOne(() => Escola, { eager: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'school_id' })
  school: Escola;

  @CreateDateColumn({ name: 'created_at'})
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at'})
  updatedAt: Date;
}