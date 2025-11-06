import {
  BeforeInsert,
  Column,
  DeleteDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import * as bcrypt from 'bcrypt';
import { Escola } from 'src/escolas/entities/escola.entity';

export enum UserProfile {
  PREFEITURA = 'prefeitura',
  ESCOLA = 'escola',
  NUTRICIONISTA = 'nutricionista',
  COZINHEIRA = 'cozinheira',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ unique: true })
  email: string;

  @Column()
  password: string;

  @Column({
    type: 'enum',
    enum: UserProfile,
  })
  profile: UserProfile;

  @ManyToOne(() => Escola, { nullable: true, eager: true })
  @JoinColumn({ name: 'school_id' })
  school: Escola | null;

  @Column({ type: 'boolean', default: true, name: 'is_active' })
  isActive: boolean;

  // --- CORREÇÃO AQUI ---
  // A propriedade deve ser 'Date | null' para bater com o decorator.
  @DeleteDateColumn({ name: 'deleted_at' })
  deletedAt: Date | null;
  // --- FIM DA CORREÇÃO ---

  @ManyToOne(() => User, { nullable: true, eager: false })
  @JoinColumn({ name: 'deleted_by_user_id' })
  deletedBy: User | null;

  @BeforeInsert()
  async hashPassword() {
    this.password = await bcrypt.hash(this.password, 10);
  }
}