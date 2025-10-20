import { IsOptional, IsString } from 'class-validator';
export class UpdateRefeicaoDto {
  @IsString({ message: 'A descrição deve ser um texto.' })
  @IsOptional() 
  description?: string | null; 
}