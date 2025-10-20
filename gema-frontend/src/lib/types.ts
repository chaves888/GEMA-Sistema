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
    // Incluímos o minStock aqui para referência, embora não seja usado diretamente no fluxo da solicitação
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

// --- Outros Tipos (Podem ser adicionados aqui no futuro) ---

// Exemplo:
// export type User = { ... };
// export type Product = { ... };