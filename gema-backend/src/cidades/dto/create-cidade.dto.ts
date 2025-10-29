// src/cidades/dto/create-cidade.dto.ts
import { IsNotEmpty, IsString, Length, Matches, IsOptional } from 'class-validator'; // Adicionar IsOptional

const UFS_BRASIL = ['AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'] as const;
type UfBrasil = typeof UFS_BRASIL[number];

export class CreateCidadeDto {
  @IsString()
  @IsNotEmpty({ message: 'O nome da cidade é obrigatório.'})
  name: string;

  @IsString()
  @IsNotEmpty({ message: 'O estado (UF) é obrigatório.'})
  @Length(2, 2, { message: 'O estado (UF) deve ter exatamente 2 caracteres.' })
  state: UfBrasil;

  @IsString()
  @IsNotEmpty({ message: 'O CEP é obrigatório.' })
  @Matches(/^\d{5}-?\d{3}$/, { message: 'CEP inválido. Use o formato XXXXX-XXX ou XXXXXXXX.' })
  cep: string;

  // --- NOVO CAMPO BAIRRO (Opcional) ---
  @IsString()
  @IsOptional() // Bairro é opcional, pois nem todo CEP/cidade o terá
  bairro?: string | null;
  // --- FIM NOVO CAMPO ---
}