import {
  ArrayMinSize,
  IsArray,
  IsEnum,
  IsNotEmpty,
  IsString,
  IsUUID,
} from 'class-validator';
import { DiaSemana, TipoRefeicao } from '../entities/refeicao.entity';

export class SetRefeicaoDto {
  @IsEnum(DiaSemana)
  @IsNotEmpty()
  diaSemana: DiaSemana;

  @IsEnum(TipoRefeicao)
  @IsNotEmpty()
  tipo: TipoRefeicao;

  @IsString()
  @IsNotEmpty({ message: 'O nome do prato (descrição) é obrigatório.' })
  description: string;

  @IsArray()
  @ArrayMinSize(1, { message: 'Selecione pelo menos um produto.' })
  @IsUUID('all', { each: true, message: 'Cada item em productIds deve ser um UUID válido.' })
  productIds: string[];
}