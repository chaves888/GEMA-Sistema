// src/cardapios/dto/create-refeicao.dto.ts
import { Type } from 'class-transformer';
import { IsArray, IsEnum, IsNotEmpty, IsOptional, IsString, ValidateNested, ArrayMinSize } from 'class-validator';
import { DiaSemana, TipoRefeicao } from '../entities/refeicao.entity';
import { CreateRefeicaoItemDto } from './create-refeicao-item.dto';

export class CreateRefeicaoDto {
  @IsEnum(DiaSemana, { message: 'Dia da semana inválido. Use: segunda, terca, quarta, quinta, sexta.' })
  @IsNotEmpty({ message: 'O dia da semana é obrigatório.' })
  diaSemana: DiaSemana;

  @IsEnum(TipoRefeicao, { message: 'Tipo de refeição inválido. Use: manha, tarde.' })
  @IsNotEmpty({ message: 'O tipo da refeição é obrigatório.' })
  tipo: TipoRefeicao;

  @IsString({ message: 'A descrição deve ser um texto.' })
  @IsOptional()
  description?: string;

  // Garante que a refeição tenha pelo menos um item
  @IsArray({ message: 'Os itens da refeição devem ser uma lista.' })
  @ArrayMinSize(1, { message: 'A refeição deve conter pelo menos um item.' })
  @ValidateNested({ each: true, message: 'Cada item da refeição é inválido.' })
  @Type(() => CreateRefeicaoItemDto) // Necessário para validação de objetos aninhados
  items: CreateRefeicaoItemDto[];
}