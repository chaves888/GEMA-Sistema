// src/solicitacoes/dto/confirm-recebimento.dto.ts
import { Type } from 'class-transformer';
import { IsArray, IsNotEmpty, ValidateNested, ArrayNotEmpty } from 'class-validator';
import { ConfirmRecebimentoItemDto } from './confirm-recebimento-item.dto';

export class ConfirmRecebimentoDto {
  @IsArray({ message: 'Os itens recebidos devem ser uma lista.' })
  @ArrayNotEmpty({ message: 'É necessário informar os itens recebidos.' })
  @ValidateNested({ each: true, message: 'Cada item recebido é inválido.' }) 
  @Type(() => ConfirmRecebimentoItemDto)
  items: ConfirmRecebimentoItemDto[];
}