// src/solicitacoes/dto/confirm-recebimento.dto.ts
import { Type } from 'class-transformer';
import { 
  IsArray, IsNotEmpty, ValidateNested, ArrayNotEmpty, 
  IsBoolean, IsOptional, ValidateIf, IsString 
} from 'class-validator';
import { ConfirmRecebimentoItemDto } from './confirm-recebimento-item.dto';

export class ConfirmRecebimentoDto {
  @IsArray({ message: 'Os itens recebidos devem ser uma lista.' })
  @ArrayNotEmpty({ message: 'É necessário informar os itens recebidos.' })
  @ValidateNested({ each: true, message: 'Cada item recebido é inválido.' }) 
  @Type(() => ConfirmRecebimentoItemDto)
  items: ConfirmRecebimentoItemDto[];

  // <-- NOVOS CAMPOS -->
  @IsBoolean()
  @IsOptional()
  comDivergencia?: boolean;

  @ValidateIf(o => o.comDivergencia === true)
  @IsNotEmpty({ message: 'A observação é obrigatória ao marcar recebimento com divergência.' })
  @IsString()
  @IsOptional()
  observacaoEscola?: string;
  // <-- FIM DOS NOVOS CAMPOS -->
}