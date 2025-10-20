// src/solicitacoes/dto/confirm-recebimento-item.dto.ts
import { IsNotEmpty, IsNumber, IsUUID, Min, IsOptional } from 'class-validator';

export class ConfirmRecebimentoItemDto {
  @IsUUID()
  @IsNotEmpty()
  itemId: string; // ID do item *original* da solicitação

  @IsNumber({}, { message: 'A quantidade recebida deve ser um número.' })
  @Min(0, { message: 'A quantidade recebida não pode ser negativa.' })
  @IsOptional() 
  quantityReceived?: number | null;
}