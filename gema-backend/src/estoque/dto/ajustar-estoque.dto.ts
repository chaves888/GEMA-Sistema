// src/estoque/dto/ajustar-estoque.dto.ts
import {
	IsNotEmpty, IsNumber, IsUUID, Min, IsOptional, IsString, MinLength, IsEnum, ValidateIf
} from 'class-validator';
import { MotivoMovimentacao } from '../entities/estoque-movimentacao.entity';

export class AjustarEstoqueDto {
	@IsUUID()
	@IsNotEmpty()
	productId: string;

	@IsNumber({}, { message: 'Quantidade deve ser um número.' })
	@Min(0, { message: 'Quantidade não pode ser negativa.' })
	newQuantity: number;

	@IsEnum(MotivoMovimentacao, { message: 'Categoria do motivo inválida.' })
	@IsOptional() // Opcional para entradas, obrigatório para saídas (validado no serviço)
	motivoCategoria?: MotivoMovimentacao;

	@IsString()
	@MinLength(3, { message: 'A observação deve ter pelo menos 3 caracteres.' })
	// Validação: Obrigatório se a categoria for 'outro'
	@ValidateIf(o => o.motivoCategoria === MotivoMovimentacao.OUTRO)
	@IsNotEmpty({ message: 'A observação é obrigatória quando o motivo é "Outro".' })
	@IsOptional()
	motivoObservacao?: string;
}