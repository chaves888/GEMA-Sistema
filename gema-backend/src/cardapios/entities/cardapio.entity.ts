// src/cardapios/entities/cardapio.entity.ts
import { User } from 'src/users/entities/user.entity';
import { 
  Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, 
  OneToMany, PrimaryGeneratedColumn, UpdateDateColumn 
} from 'typeorm';
import { Refeicao } from './refeicao.entity';

@Entity('cardapios')
export class Cardapio {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 150 })
  name: string;

  // --- MUDANÇA AQUI ---
  // Mudamos o tipo da coluna e da propriedade para 'string'
  @Column({ type: 'varchar', length: 10 }) // Salva como "YYYY-MM-DD"
  startDate: string;

  @Column({ type: 'varchar', length: 10 }) // Salva como "YYYY-MM-DD"
  endDate: string;
  // --- FIM DA MUDANÇA ---

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User, { eager: true, onDelete: 'SET NULL', nullable: true }) 
  @JoinColumn({ name: 'created_by_user_id' })
  createdBy: User | null;

  @OneToMany(() => Refeicao, (refeicao) => refeicao.cardapio, { cascade: true, eager: true })
  refeicoes: Refeicao[]; 
}