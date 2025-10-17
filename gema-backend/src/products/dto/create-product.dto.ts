import { IsEnum, IsNotEmpty, IsNumber, IsString, Min } from 'class-validator';
import { ProductUnit } from '../entities/product.entity';

export class CreateProductDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsEnum(ProductUnit)
  @IsNotEmpty()
  unit: ProductUnit;
  
  @IsNumber()
  @Min(0)
  minStock: number;
}