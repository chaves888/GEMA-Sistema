import { IsEnum, IsNotEmpty, IsNumber, IsString, Min } from 'class-validator';
import { ProductUnit } from '../entities/product.entity';

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEnum(ProductUnit)
  @IsNotEmpty()
  unit: ProductUnit;
  
  // --- MUDANÇA AQUI ---
  @IsNumber({}, { message: 'Estoque mínimo da prefeitura deve ser um número.'})
  @Min(0)
  minStockPrefeitura: number;

  @IsNumber({}, { message: 'Estoque mínimo da escola deve ser um número.'})
  @Min(0)
  minStockEscola: number;
  // --- FIM DA MUDANÇA ---

  
}