import { IsNotEmpty, IsNumber, IsPositive, Min } from 'class-validator';
export class UpdateRefeicaoItemDto {
  @IsNumber({}, { message: 'A quantidade por aluno deve ser um número.' })
  @IsPositive({ message: 'A quantidade por aluno deve ser um número positivo.' })
  @Min(0.01, { message: 'A quantidade por aluno deve ser maior que zero.' })
  @IsNotEmpty({ message: 'A nova quantidade é obrigatória.' })
  quantityPerStudent: number;
}