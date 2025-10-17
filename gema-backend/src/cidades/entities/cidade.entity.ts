// src/cidades/entities/cidade.entity.ts
import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('cities')
export class Cidade {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({ length: 2 }) // Ex: SP, RJ, MG
  state: string;
}