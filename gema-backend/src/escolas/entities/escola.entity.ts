// src/escolas/entities/escola.entity.ts
import { Cidade } from 'src/cidades/entities/cidade.entity';
import { User } from 'src/users/entities/user.entity'; // 1. Importar User
import {
	Column,
	DeleteDateColumn, // 2. Importar
	Entity,
	JoinColumn,
	ManyToOne,
	PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('schools')
export class Escola {
	@PrimaryGeneratedColumn('uuid')
	id: string;

	@Column()
	name: string;

	@Column({ nullable: true })
	address: string;

	@Column({ type: 'varchar', length: 50, nullable: true })
	numero: string | null;

	@ManyToOne(() => Cidade, { eager: true })
	@JoinColumn({ name: 'city_id' })
	city: Cidade;

	// --- 3. CAMPOS ADICIONADOS ---
	@DeleteDateColumn({ name: 'deleted_at' })
	deletedAt: Date | null;

	@ManyToOne(() => User, { nullable: true, eager: false })
	@JoinColumn({ name: 'deleted_by_user_id' })
	deletedBy: User | null;
	// --- FIM DOS NOVOS CAMPOS ---
}