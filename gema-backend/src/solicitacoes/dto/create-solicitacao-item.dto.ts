// src/solicitacoes/dto/create-solicitacao-item.dto.ts
import { IsNotEmpty, IsNumber, IsUUID, Min } from 'class-validator';

export class CreateSolicitacaoItemDto {
  @IsUUID()
  @IsNotEmpty({ message: 'O ID do produto é obrigatório.' })
  productId: string;

  @IsNumber({}, { message: 'A quantidade deve ser um número.' })
  @Min(0.01, { message: 'A quantidade solicitada deve ser maior que zero.' })
  quantityRequested: number;
}