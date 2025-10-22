import { Product } from 'src/products/entities/product.entity';
import {
  Column,
  Entity,
  JoinTable,
  ManyToMany,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
} from 'typeorm';
import { Cardapio } from './cardapio.entity';

export enum DiaSemana {
  SEGUNDA = 'segunda',
  TERCA = 'terca',
  QUARTA = 'quarta',
  QUINTA = 'quinta',
  SEXTA = 'sexta',
}

export enum TipoRefeicao {
  MANHA = 'manha', // 10h
  TARDE = 'tarde', // 15h
}

@Entity('refeicoes')
@Unique(['cardapio', 'diaSemana', 'tipo']) // Garante que só exista uma refeição (ex: Manhã de Segunda) por cardápio
export class Refeicao {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'enum', enum: DiaSemana })
  diaSemana: DiaSemana;

  @Column({ type: 'enum', enum: TipoRefeicao })
  tipo: TipoRefeicao;

  @Column({ type: 'text' })
  description: string; // "Nome do prato"

  @ManyToOne(() => Cardapio, (cardapio) => cardapio.refeicoes, {
    onDelete: 'CASCADE',
  })
  cardapio: Cardapio;

  // Relação "lista de produtos" (sem quantidade, conforme especificado)
  @ManyToMany(() => Product, { eager: true })
  @JoinTable({
    name: 'refeicao_products',
    joinColumn: { name: 'refeicao_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'product_id', referencedColumnName: 'id' },
  })
  products: Product[];
}