// src/cidades/entities/cidade.entity.ts
import { User } from 'src/users/entities/user.entity';
import {
	Column,
	DeleteDateColumn,
	Entity,
	JoinColumn,
	ManyToOne,
	PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('cities')
export class Cidade {
	@PrimaryGeneratedColumn('uuid')
	id: string;

	@Column()
	name: string;

	@Column({ length: 2 })
	state: string;

	// --- CORREÇÃO AQUI ---
	@Column({ type: 'varchar', length: 9 }) // unique: true FOI REMOVIDO
	cep: string;
	// --- FIM DA CORREÇÃO ---

	@Column({ type: 'varchar', nullable: true })
	bairro: string | null;

	@DeleteDateColumn({ name: 'deleted_at' })
	deletedAt: Date | null;

	@ManyToOne(() => User, { nullable: true, eager: false })
	@JoinColumn({ name: 'deleted_by_user_id' })
	deletedBy: User | null;
}