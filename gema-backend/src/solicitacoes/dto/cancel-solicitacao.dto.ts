// src/solicitacoes/dto/cancel-solicitacao.dto.ts
import { IsOptional, IsString } from 'class-validator';

export class CancelSolicitacaoDto {
  @IsString({ message: 'O motivo deve ser um texto.' })
  @IsOptional()
  motivoCancelamento?: string;
}