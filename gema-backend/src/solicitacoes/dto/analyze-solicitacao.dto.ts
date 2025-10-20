// src/solicitacoes/dto/analyze-solicitacao.dto.ts
import { Type } from 'class-transformer';
import { IsArray, IsEnum, IsNotEmpty, IsOptional, IsString, ValidateNested } from 'class-validator';
import { SolicitacaoStatus } from '../entities/solicitacao.entity';
import { AnalyzeSolicitacaoItemDto } from './analyze-solicitacao-item.dto';

export class AnalyzeSolicitacaoDto {
  @IsEnum(SolicitacaoStatus, { 
    message: `Status inválido. Valores permitidos: ${SolicitacaoStatus.APROVADO}, ${SolicitacaoStatus.APROVADO_PARCIALMENTE}, ${SolicitacaoStatus.NEGADO}`
  })
  @IsNotEmpty({ message: 'O status da análise é obrigatório.'})
  status: SolicitacaoStatus.APROVADO | SolicitacaoStatus.APROVADO_PARCIALMENTE | SolicitacaoStatus.NEGADO;

  @IsString({ message: 'A observação deve ser um texto.'})
  @IsOptional()
  observacaoPrefeitura?: string;

  @IsArray({ message: 'Os itens devem ser uma lista.' })
  @ValidateNested({ each: true, message: 'Cada item da análise é inválido.' }) 
  @Type(() => AnalyzeSolicitacaoItemDto)
  @IsOptional() // Pode não ter itens se for status NEGADO
  items?: AnalyzeSolicitacaoItemDto[];
}