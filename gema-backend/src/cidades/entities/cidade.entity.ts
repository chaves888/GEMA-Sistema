// src/cidades/entities/cidade.entity.ts
import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('cities')
export class Cidade {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // --- MODIFICAÇÃO: 'name' não é mais unique ---
  @Column()
  name: string;
  // --- FIM MODIFICAÇÃO ---

  @Column({ length: 2 })
  state: string;

  @Column({ type: 'varchar', length: 9, unique: true }) // CEP é obrigatório e único
  cep: string;

  @Column({ type: 'varchar', nullable: true }) // Bairro é opcional
  bairro: string | null;
}