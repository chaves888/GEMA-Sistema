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

  // --- RELACIONAMENTO AQUI ---
  // Muitas escolas (Many) podem pertencer a Uma cidade (ToOne)
  @ManyToOne(() => Cidade, { eager: true }) // eager: true -> sempre carrega a cidade junto
  @JoinColumn({ name: 'city_id' }) // Nome da coluna do ID estrangeiro no banco
  city: Cidade;
}