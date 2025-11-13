import { IsDateString, IsNotEmpty } from 'class-validator';

export class GerarRelatorioSolicitacoesDto {
  @IsDateString()
  @IsNotEmpty({ message: 'A data de início é obrigatória.' })
  startDate: string;

  @IsDateString()
  @IsNotEmpty({ message: 'A data de fim é obrigatória.' })
  endDate: string;
}