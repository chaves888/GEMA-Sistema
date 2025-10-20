// src/cardapios/entities/refeicao.entity.ts
import { Column, Entity, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn, Unique } from 'typeorm';
import { Cardapio } from './cardapio.entity';
import { RefeicaoItem } from './refeicao-item.entity'; // Será criado a seguir

// Dias da semana úteis (Segunda a Sexta)
export enum DiaSemana {
  SEGUNDA = 'segunda',
  TERCA = 'terca',
  QUARTA = 'quarta',
  QUINTA = 'quinta',
  SEXTA = 'sexta',
}

// Tipos de Refeição (Manhã/Tarde)
export enum TipoRefeicao {
  MANHA = 'manha',   // Refeição das 10h
  TARDE = 'tarde',   // Refeição das 15h
}

@Entity('refeicoes') // Nome da tabela
// Garante unicidade: não pode haver duas refeições de Manhã na Segunda no mesmo cardápio
@Unique(['cardapio', 'diaSemana', 'tipo']) 
export class Refeicao {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'enum', enum: DiaSemana })
  diaSemana: DiaSemana;

  @Column({ type: 'enum', enum: TipoRefeicao })
  tipo: TipoRefeicao;

  @Column({ type: 'text', nullable: true }) // Descrição opcional
  description: string | null;

  // Relação: A qual Cardápio esta Refeição pertence?
  // onDelete: 'CASCADE' -> Se o Cardapio for excluído, a Refeicao também será.
  @ManyToOne(() => Cardapio, (cardapio) => cardapio.refeicoes, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'cardapio_id' })
  cardapio: Cardapio; // A entidade Cardapio (não apenas o ID)

  // Relação: Quais Itens (produtos) compõem esta Refeição?
  // cascade: true -> Salvar/Remover Refeicao afeta RefeicaoItens
  // eager: true -> Carregar Refeicao carrega Itens junto
  @OneToMany(() => RefeicaoItem, (item) => item.refeicao, { cascade: true, eager: true })
  items: RefeicaoItem[];
}