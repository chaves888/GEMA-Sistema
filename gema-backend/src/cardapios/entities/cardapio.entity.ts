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
import { Refeicao } from './refeicao.entity';

export enum CardapioStatus {
  RASCUNHO = 'rascunho',
  PUBLICADO = 'publicado',
}

@Entity('cardapios')
export class Cardapio {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ type: 'date' })
  startDate: string;

  @Column({ type: 'date' })
  endDate: string;

  @Column({
    type: 'enum',
    enum: CardapioStatus,
    default: CardapioStatus.RASCUNHO,
  })
  status: CardapioStatus;

  @ManyToOne(() => User, { eager: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'created_by_user_id' })
  createdBy: User;

  @OneToMany(() => Refeicao, (refeicao) => refeicao.cardapio, {
    cascade: true,
    eager: true,
  })
  refeicoes: Refeicao[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}