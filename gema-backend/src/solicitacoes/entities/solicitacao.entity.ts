// src/solicitacoes/entities/solicitacao.entity.ts
import { Escola } from 'src/escolas/entities/escola.entity';
import { User } from 'src/users/entities/user.entity';
import { 
  Column, CreateDateColumn, Entity, JoinColumn, ManyToOne, 
  OneToMany, PrimaryGeneratedColumn, UpdateDateColumn 
} from 'typeorm';
import { SolicitacaoItem } from './solicitacao-item.entity';

// Status baseado no seu fluxo
export enum SolicitacaoStatus {
  PENDENTE = 'pendente',
  APROVADO = 'aprovado',
  APROVADO_PARCIALMENTE = 'aprovado_parcialmente',
  NEGADO = 'negado',
  RECEBIDO = 'recebido',
}

@Entity('solicitacoes') // Nome da tabela no banco
export class Solicitacao {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @Column({
    type: 'enum',
    enum: SolicitacaoStatus,
    default: SolicitacaoStatus.PENDENTE,
  })
  status: SolicitacaoStatus;

  @Column({ type: 'text', nullable: true })
  justificativa: string | null; 

  @Column({ type: 'text', nullable: true, name: 'observacao_prefeitura' })
  observacaoPrefeitura: string | null; 

  @ManyToOne(() => Escola, { eager: true, onDelete: 'RESTRICT' }) 
  @JoinColumn({ name: 'school_id' })
  school: Escola;

  @ManyToOne(() => User, { eager: true, onDelete: 'SET NULL' }) 
  @JoinColumn({ name: 'requester_user_id' })
  requester: User;

  @OneToMany(() => SolicitacaoItem, (item) => item.solicitacao, { cascade: true, eager: true }) 
  items: SolicitacaoItem[];
}