import { BeforeInsert, Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
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
  // A MUDANÇA ESTÁ AQUI: A propriedade agora pode ser um objeto Escola ou null.
  school: Escola | null;

  @BeforeInsert()
  async hashPassword() {
    this.password = await bcrypt.hash(this.password, 10);
  }
}