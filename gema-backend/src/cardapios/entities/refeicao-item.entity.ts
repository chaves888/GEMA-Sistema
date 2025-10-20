// src/cardapios/entities/refeicao-item.entity.ts
import { Product } from 'src/products/entities/product.entity';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, Unique } from 'typeorm';
import { Refeicao } from './refeicao.entity';

@Entity('refeicao_items') // Nome da tabela
// Garante unicidade: não pode ter o mesmo produto duas vezes na mesma refeição
@Unique(['refeicao', 'product']) 
export class RefeicaoItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Quantidade estimada POR ALUNO (a unidade vem do produto)
  @Column({ type: 'float', name: 'quantity_per_student' })
  quantityPerStudent: number;

  // Relação: A qual Refeição este Item pertence?
  // onDelete: 'CASCADE' -> Se a Refeicao for excluída, este Item também será.
  @ManyToOne(() => Refeicao, (refeicao) => refeicao.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'refeicao_id' })
  refeicao: Refeicao; // A entidade Refeicao

  // Relação: Qual Produto é este Item?
  // eager: true -> Carrega os dados do produto (nome, unidade) junto.
  // onDelete: 'RESTRICT' -> Impede excluir um Produto se ele estiver em uso.
  @ManyToOne(() => Product, { eager: true, onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'product_id' })
  product: Product; // A entidade Product
}