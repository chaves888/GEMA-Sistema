// src/cidades/dto/create-cidade.dto.ts
import { IsNotEmpty, IsString, Length } from 'class-validator';

export class CreateCidadeDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  @Length(2, 2, { message: 'O estado deve ter exatamente 2 caracteres' })
  state: string;
}