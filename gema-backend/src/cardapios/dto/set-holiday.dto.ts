import { IsBoolean, IsEnum, IsNotEmpty } from 'class-validator';
import { DiaSemana } from '../entities/refeicao.entity';

export class SetHolidayDto {
  @IsEnum(DiaSemana, { message: 'Dia da semana inválido.'})
  @IsNotEmpty({ message: 'O dia da semana é obrigatório.' })
  diaSemana: DiaSemana;

  @IsBoolean({ message: 'O status de feriado deve ser verdadeiro ou falso.' })
  @IsNotEmpty({ message: 'É obrigatório informar se é feriado ou não.'})
  isHoliday: boolean;
}