// src/cardapios/dto/create-cardapio.dto.ts
import { IsDateString, IsNotEmpty, IsString, Validate, ValidationArguments, ValidatorConstraint, ValidatorConstraintInterface } from 'class-validator';
import { Transform } from 'class-transformer';

// Validador customizado para garantir endDate >= startDate
@ValidatorConstraint({ name: 'isEndDateAfterStartDate', async: false })
export class IsEndDateAfterStartDateConstraint implements ValidatorConstraintInterface {
  validate(endDate: string, args: ValidationArguments) {
    const object = args.object as CreateCardapioDto;
    const startDate = object.startDate;
    if (!startDate || !endDate) return true; // Não valida se uma data falta
    return new Date(endDate) >= new Date(startDate);
  }
  defaultMessage(args: ValidationArguments) {
    return 'A data de fim não pode ser anterior à data de início.';
  }
}

export class CreateCardapioDto {
  @IsString({ message: 'O nome do cardápio deve ser um texto.' })
  @IsNotEmpty({ message: 'O nome do cardápio é obrigatório.' })
  @Transform(({ value }) => value?.trim()) // Remove espaços
  name: string;

  @IsDateString({}, { message: 'A data de início deve estar no formato YYYY-MM-DD.' })
  @IsNotEmpty({ message: 'A data de início é obrigatória.' })
  @Transform(({ value }) => value?.trim())
  startDate: string;

  @IsDateString({}, { message: 'A data de fim deve estar no formato YYYY-MM-DD.' })
  @IsNotEmpty({ message: 'A data de fim é obrigatória.' })
  @Transform(({ value }) => value?.trim())
  @Validate(IsEndDateAfterStartDateConstraint) // Usa o validador customizado
  endDate: string;
}