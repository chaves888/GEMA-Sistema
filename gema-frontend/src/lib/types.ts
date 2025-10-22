// src/lib/types.ts

// --- Tipo Genérico de Produto ---
export type Product = {
  id: string;
  name: string;
  unit: string;
  minStock?: number; 
};

// --- Tipos para o Módulo de Solicitações ---
export type SolicitacaoItem = {
  id: string; 
  quantityRequested: number; 
  quantityApproved: number | null; 
  quantityReceived: number | null; 
  product: Product; 
};

export type Solicitacao = {
  id: string; 
  createdAt: string; 
  updatedAt: string; 
  status: 'pendente' | 'aprovado' | 'aprovado_parcialmente' | 'negado' | 'recebido'; 
  justificativa: string | null; 
  observacaoPrefeitura: string | null; 
  school: { id: string; name: string; };
  requester: { id: string; name: string; };
  items: SolicitacaoItem[]; 
};


// --- NOVOS TIPOS PARA CARDÁPIOS ---

// Um item de produto dentro de uma refeição (como o backend retorna)
type RefeicaoProductItem = {
  id: string;
  name: string;
  unit: string;
  minStock: number;
  createdAt: string;
  updatedAt: string;
};

// A Refeição (Manhã ou Tarde)
export type Refeicao = {
  id: string;
  diaSemana: 'segunda' | 'terca' | 'quarta' | 'quinta' | 'sexta';
  tipo: 'manha' | 'tarde';
  description: string; // "Nome do prato"
  products: RefeicaoProductItem[]; // Lista de produtos
};

// O Cardápio Semanal (principal)
export type Cardapio = {
  id: string;
  name: string;
  startDate: string; // Formato "YYYY-MM-DD"
  endDate: string; // Formato "YYYY-MM-DD"
  status: 'rascunho' | 'publicado';
  createdBy: { id: string; name: string; };
  refeicoes: Refeicao[]; // Lista de refeições (Manhã/Tarde de cada dia)
  createdAt: string;
  updatedAt: string;
};