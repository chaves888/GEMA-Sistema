// src/cardapios/dto/create-refeicao-item.dto.ts
import { IsNotEmpty, IsNumber, IsUUID, Min, IsPositive } from 'class-validator';

export class CreateRefeicaoItemDto {
  @IsUUID('4', { message: 'O ID do produto deve ser um UUID válido.' })
  @IsNotEmpty({ message: 'O ID do produto é obrigatório.' })
  productId: string;

  @IsNumber({}, { message: 'A quantidade por aluno deve ser um número.' })
  @IsPositive({ message: 'A quantidade por aluno deve ser um número positivo.' })
  @Min(0.01, { message: 'A quantidade por aluno deve ser maior que zero.' })
  quantityPerStudent: number;
}