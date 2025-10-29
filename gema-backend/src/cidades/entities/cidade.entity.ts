// src/cidades/entities/cidade.entity.ts
import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('cities')
export class Cidade {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({ length: 2 })
  state: string;

  @Column({ type: 'varchar', length: 9, unique: true }) // CEP é obrigatório e único
  cep: string;

  // --- NOVA COLUNA BAIRRO ---
  @Column({ type: 'varchar', nullable: true }) // Bairro é opcional
  bairro: string | null;
  // --- FIM NOVA COLUNA ---
}