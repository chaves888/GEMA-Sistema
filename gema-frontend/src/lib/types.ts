// src/lib/types.ts

// Este arquivo define as estruturas de dados (tipos) compartilhadas
// entre diferentes componentes e páginas do frontend.

// --- Tipo Genérico de Produto ---
// (Usado por Solicitações e Cardápios)
export type Product = {
  id: string;
  name: string;
  unit: string;
  minStock?: number; // Opcional, pode não vir em todos os contextos
};


// --- Tipos para o Módulo de Solicitações (Sem alteração) ---

export type SolicitacaoItem = {
  id: string; // ID do item da solicitação (gerado pelo backend)
  quantityRequested: number; // Quantidade pedida pela escola
  quantityApproved: number | null; // Quantidade aprovada pela prefeitura
  quantityReceived: number | null; // Quantidade recebida confirmada pela escola
  product: Product; // Usa o tipo genérico
};

export type Solicitacao = {
  id: string; // ID da solicitação principal
  createdAt: string; // Data de criação (vem como string JSON)
  updatedAt: string; // Data da última atualização (vem como string JSON)
  status: 'pendente' | 'aprovado' | 'aprovado_parcialmente' | 'negado' | 'recebido'; // Status possíveis
  justificativa: string | null; // Justificativa da escola (opcional)
  observacaoPrefeitura: string | null; // Observação da prefeitura (opcional)
  school: { 
    id: string; 
    name: string; 
  };
  requester: { 
    id: string; 
    name: string; 
  };
  items: SolicitacaoItem[]; // Lista de itens pertencentes a esta solicitação
};

// --- Tipos para o Módulo de Cardápios (ATUALIZADO PARA A NOVA LÓGICA) ---

/**
 * Representa o VÍNCULO entre um Prato (Refeição) e um Produto.
 * Ex: "Macarronada" (Refeição) é composta por "Macarrão" (Produto).
 */
export type RefeicaoItem = {
  id: string; // ID do vínculo (RefeicaoItem)
  product: Product; // O produto que compõe o prato
};

/**
 * Representa o Prato principal de uma refeição.
 */
export type Refeicao = {
  id: string;
  diaSemana: 'segunda' | 'terca' | 'quarta' | 'quinta' | 'sexta';
  tipo: 'manha' | 'tarde';
  name: string; // O "Nome do Prato" (ex: "Macarronada à bolonhesa")
  items: RefeicaoItem[]; // A lista de produtos (RefeicaoItem) que compõem este prato
};

/**
 * Tipo para o Cardápio principal (semanal).
 */
export type Cardapio = {
  id: string;
  name: string; // Ex: "Cardápio Semana 1 (20/10 a 24/10)"
  startDate: string; // Vem como string JSON "YYYY-MM-DD"
  endDate: string;   // Vem como string JSON "YYYY-MM-DD"
  status: 'rascunho' | 'publicado'; // Status para controle da Nutri
  createdAt: string; // Vem como string JSON
  createdBy: { // Informação simplificada do usuário que criou
    id: string;
    name: string;
  };
  refeicoes: Refeicao[]; // Lista de refeições (já vem com itens e produtos)
};
