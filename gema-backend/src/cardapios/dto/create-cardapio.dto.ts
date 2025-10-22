import { IsDateString, IsNotEmpty, IsString, Matches } from 'class-validator';

export class CreateCardapioDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsDateString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, {
    message: 'startDate deve estar no formato YYYY-MM-DD',
  })
  startDate: string;

  @IsDateString()
  @Matches(/^\d{4}-\d{2}-\d{2}$/, {
    message: 'endDate deve estar no formato YYYY-MM-DD',
  })
  endDate: string;
}