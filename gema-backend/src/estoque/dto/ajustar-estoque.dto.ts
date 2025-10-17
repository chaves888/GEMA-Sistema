import { IsNotEmpty, IsNumber, IsUUID, Min } from 'class-validator';

export class AjustarEstoqueDto {
  @IsUUID()
  @IsNotEmpty()
  productId: string;

  @IsNumber()
  @Min(0)
  quantity: number;
}