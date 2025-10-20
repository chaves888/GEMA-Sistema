// Este arquivo define as estruturas de dados (tipos) compartilhadas
// entre diferentes componentes e páginas do frontend.

// --- Tipos para o Módulo de Solicitações ---

export type SolicitacaoItem = {
  id: string; // ID do item da solicitação (gerado pelo backend)
  quantityRequested: number; // Quantidade pedida pela escola
  quantityApproved: number | null; // Quantidade aprovada pela prefeitura
  quantityReceived: number | null; // Quantidade recebida confirmada pela escola
  product: { 
    id: string; 
    name: string; 
    unit: string; 
    minStock?: number; 
  };
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

// --- Tipos para o Módulo de Cardápios ---

// Tipo para um Produto (simplificado, como visto dentro de um cardápio)
// (Podemos criar um tipo Product mais genérico se precisarmos)
type CardapioProduct = {
  id: string;
  name: string;
  unit: string;
  minStock: number; 
};

// Tipo para um Item de Refeição (ex: 100g de Arroz)
export type RefeicaoItem = {
  id: string;
  quantityPerStudent: number;
  product: CardapioProduct;
};

// Tipo para uma Refeição (ex: Almoço de Segunda)
export type Refeicao = {
  id: string;
  diaSemana: 'segunda' | 'terca' | 'quarta' | 'quinta' | 'sexta';
  tipo: 'manha' | 'tarde';
  description: string | null;
  items: RefeicaoItem[];
};

// Tipo para o Cardápio principal (semanal)
export type Cardapio = {
  id: string;
  name: string;
  startDate: string; // Vem como string JSON
  endDate: string;   // Vem como string JSON
  createdAt: string; // Vem como string JSON
  createdBy: { // Informação simplificada do usuário que criou
    id: string;
    name: string;
  };
  refeicoes: Refeicao[]; // Lista de refeições (já vem com itens e produtos)
};