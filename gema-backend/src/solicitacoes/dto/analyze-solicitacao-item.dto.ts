// src/solicitacoes/dto/analyze-solicitacao-item.dto.ts
import { IsNotEmpty, IsNumber, IsUUID, Min, IsOptional } from 'class-validator';

export class AnalyzeSolicitacaoItemDto {
  @IsUUID()
  @IsNotEmpty()
  itemId: string; // ID do item *original* da solicitação (da tabela solicitacao_items)

  @IsNumber({}, { message: 'A quantidade aprovada deve ser um número.' })
  @Min(0, { message: 'A quantidade aprovada não pode ser negativa.' })
  @IsOptional() 
  quantityApproved?: number | null; 
}