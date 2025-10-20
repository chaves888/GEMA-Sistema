// src/solicitacoes/dto/create-solicitacao.dto.ts
import { Type } from 'class-transformer';
import { IsArray, IsOptional, IsString, ValidateNested, ArrayNotEmpty, ArrayMinSize } from 'class-validator';
import { CreateSolicitacaoItemDto } from './create-solicitacao-item.dto';

export class CreateSolicitacaoDto {
  @IsString({ message: 'A justificativa deve ser um texto.' })
  @IsOptional()
  justificativa?: string;

  @IsArray({ message: 'Os itens devem ser uma lista.' })
  @ArrayNotEmpty({ message: 'A solicitação deve ter pelo menos um item.' })
  @ArrayMinSize(1, { message: 'A solicitação deve ter pelo menos um item.'})
  @ValidateNested({ each: true, message: 'Cada item da solicitação é inválido.' })
  @Type(() => CreateSolicitacaoItemDto)
  items: CreateSolicitacaoItemDto[];
}