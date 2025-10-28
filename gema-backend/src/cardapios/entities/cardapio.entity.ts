// src/cardapios/entities/cardapio.entity.ts
import { User } from 'src/users/entities/user.entity';
import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Refeicao, DiaSemana } from './refeicao.entity'; // Importar DiaSemana

export enum CardapioStatus {
  RASCUNHO = 'rascunho', // Em criação pela nutricionista
  PUBLICADO = 'publicado', // Visível para todos (escolas, prefeitura)
}

@Entity('cardapios') // Nome da tabela no banco
export class Cardapio {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column() // Nome gerado automaticamente no service
  name: string;

  @Column({ type: 'date' }) // Armazena como YYYY-MM-DD
  startDate: string;

  @Column({ type: 'date' }) // Armazena como YYYY-MM-DD
  endDate: string;

  @Column({
    type: 'enum',
    enum: CardapioStatus,
    default: CardapioStatus.RASCUNHO,
  })
  status: CardapioStatus;

  // --- CAMPO ATUALIZADO ---
  @Column('simple-array', { nullable: true }) // Armazena como texto, permite NULL. Sem valor padrão explícito.
  holidayWeekdays: DiaSemana[]; // Ex: ['terca', 'quinta']
  // --- FIM ATUALIZAÇÃO ---

  @ManyToOne(() => User, { eager: true, onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'created_by_user_id' })
  createdBy: User | null;

  @OneToMany(() => Refeicao, (refeicao) => refeicao.cardapio, {
    cascade: true, // Se deletar cardápio, deleta refeições associadas
    eager: true,   // Sempre carrega as refeições ao buscar um cardápio
  })
  refeicoes: Refeicao[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}