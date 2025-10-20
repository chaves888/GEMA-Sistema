// src/solicitacoes/entities/solicitacao-item.entity.ts
import { Product } from 'src/products/entities/product.entity';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { Solicitacao } from './solicitacao.entity';

@Entity('solicitacao_items') // Nome da tabela no banco
export class SolicitacaoItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'float', name: 'quantity_requested' })
  quantityRequested: number;

  @Column({ type: 'float', nullable: true, name: 'quantity_approved' })
  quantityApproved: number | null;

  @Column({ type: 'float', nullable: true, name: 'quantity_received' })
  quantityReceived: number | null;

  @ManyToOne(() => Solicitacao, (solicitacao) => solicitacao.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'solicitacao_id' })
  solicitacao: Solicitacao;

  @ManyToOne(() => Product, { eager: true, onDelete: 'RESTRICT' }) 
  @JoinColumn({ name: 'product_id' })
  product: Product;
}