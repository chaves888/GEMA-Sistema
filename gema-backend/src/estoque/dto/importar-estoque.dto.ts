// src/estoque/dto/importar-estoque.dto.ts

// 1. Corrigido: PRODUTO_NOME pode ser string ou null,
// pois a validação no serviço já trata o 'null'.
export interface PlanilhaRow {
	PRODUTO_NOME: string | null; 
	QUANTIDADE_AJUSTE: number | null; // <-- RENOMEADO DE 'QUANTIDADE_NOVA'
	Linha: number;
}

// 2. Esta interface agora é exportada
export interface ImportacaoResultado {
	message: string;
	processados: number;
	erros: string[];
}