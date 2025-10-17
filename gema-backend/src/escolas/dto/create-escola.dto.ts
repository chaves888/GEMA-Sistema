// src/escolas/dto/create-escola.dto.ts
import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';

export class CreateEscolaDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  address: string;

  @IsUUID()
  @IsNotEmpty()
  cityId: string; // Receberemos o ID da cidade aqui
}