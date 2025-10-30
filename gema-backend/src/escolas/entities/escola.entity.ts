// src/escolas/entities/escola.entity.ts
import { Cidade } from 'src/cidades/entities/cidade.entity';
import { 
  Column, 
  Entity, 
  JoinColumn, 
  ManyToOne, 
  PrimaryGeneratedColumn 
} from 'typeorm';

@Entity('schools')
export class Escola {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column({ nullable: true }) // Endereço é opcional
  address: string;

  // --- NOVA COLUNA NÚMERO ---
  @Column({ type: 'varchar', length: 50, nullable: true })
  numero: string | null;
  // --- FIM NOVA COLUNA ---

  // --- RELACIONAMENTO AQUI ---
  @ManyToOne(() => Cidade, { eager: true }) // eager: true -> sempre carrega a cidade junto
  @JoinColumn({ name: 'city_id' }) // Nome da coluna do ID estrangeiro no banco
  city: Cidade;
}