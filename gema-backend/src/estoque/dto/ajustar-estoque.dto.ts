import { IsNotEmpty, IsNumber, IsUUID, Min } from 'class-validator';

export class AjustarEstoqueDto {
  @IsUUID()
  @IsNotEmpty()
  productId: string;

  @IsNumber({}, { message: 'Quantidade deve ser um número.'})
  @Min(0, { message: 'Quantidade não pode ser negativa.' })
  quantity: number;

  // O campo 'minStock' opcional foi removido
}