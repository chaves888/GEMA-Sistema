<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import { format } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import Modal from '$lib/components/Modal.svelte';
  import SolicitacaoForm from '$lib/components/SolicitacaoForm.svelte';
  import AnaliseSolicitacaoForm from '$lib/components/AnaliseSolicitacaoForm.svelte';
  import ConfirmRecebimentoForm from '$lib/components/ConfirmRecebimentoForm.svelte';
  import DetalhesSolicitacao from '$lib/components/DetalhesSolicitacao.svelte'; // <- Importa o componente de detalhes
  import type { Solicitacao } from '$lib/types';

  let solicitacoes: Solicitacao[] = [];
  let isLoading = true;
  let isActionLoading = false;
  let error: string | null = null;

  // Modais
  let showCreateModal = false;
  let newSolicitacaoJustificativa = '';
  let newSolicitacaoItems: { productId: string; quantityRequested: number; productName?: string; productUnit?: string }[] = [];
  
  let showAnalyzeModal = false;
  let solicitacaoToAnalyze: Solicitacao | null = null;

  let showConfirmModal = false; 
  let solicitacaoToConfirm: Solicitacao | null = null; 

  // --- Estado para o Modal de Detalhes ---
  let showDetailsModal = false;
  let solicitacaoToView: Solicitacao | null = null;
  // --- Fim do Estado ---


  $: if ($session) { loadSolicitacoes(); }

  async function loadSolicitacoes() {
    isLoading = true;
    error = null;
    try {
      solicitacoes = await api.get('solicitacoes');
    } catch (e) {
      error = 'Não foi possível carregar as solicitações.';
      console.error('Erro ao carregar solicitações:', e);
    } finally {
      isLoading = false;
    }
  }

  // Funções de formatação
  function getStatusClass(status: string): string {
    switch (status) {
      case 'pendente': return 'bg-yellow-100 text-yellow-800';
      case 'aprovado': return 'bg-green-100 text-green-800';
      case 'aprovado_parcialmente': return 'bg-blue-100 text-blue-800';
      case 'negado': return 'bg-red-100 text-red-800';
      case 'recebido': return 'bg-gray-200 text-gray-800 font-medium';
      default: return 'bg-gray-100 text-gray-800';
    }
  }
  function formatStatus(status: string): string {
    return status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase());
  }

  // --- AÇÕES PRINCIPAIS ---
  
  // 1. Criação
  function handleNovaSolicitacao() {
      newSolicitacaoJustificativa = '';
      newSolicitacaoItems = [];
      showCreateModal = true;
  }
  async function handleSaveNewSolicitacao(event: any) {
    const dataToSend = event.detail;
    isActionLoading = true;
    try {
        const createdSolicitacao = await api.post('solicitacoes', dataToSend);
        solicitacoes = [createdSolicitacao, ...solicitacoes];
        showCreateModal = false;
    } catch (e: any) {
        if (e && e.message) { alert(`Erro: ${e.message}`); }
        else { alert('Erro ao criar a solicitação.'); }
        console.error('Erro ao salvar nova solicitação:', e);
    } finally {
        isActionLoading = false;
    }
  }
  
  // 2. Análise
  async function handleAnalisar(id: string) {
      isActionLoading = true;
      try {
          solicitacaoToAnalyze = await api.get(`solicitacoes/${id}`);
          showAnalyzeModal = true;
      } catch (e) {
          alert('Erro ao carregar detalhes da solicitação para análise.');
          console.error('Erro ao carregar para análise:', e);
      } finally {
          isActionLoading = false;
      }
  }
  async function handleSaveAnalysis(event: any) {
    if (!solicitacaoToAnalyze) return;
    const dataToSend = event.detail;
    isActionLoading = true;
    try {
        const updatedSolicitacao = await api.patch(`solicitacoes/${solicitacaoToAnalyze.id}/analisar`, dataToSend);
        solicitacoes = solicitacoes.map(s => s.id === updatedSolicitacao.id ? updatedSolicitacao : s);
        showAnalyzeModal = false;
        solicitacaoToAnalyze = null;
    } catch (e: any) {
        if (e && e.message) { alert(`Erro: ${e.message}`); }
        else { alert('Erro ao salvar a análise.'); }
        console.error('Erro ao salvar análise:', e);
    } finally {
        isActionLoading = false;
    }
  }

  // 3. Confirmação
  async function handleConfirmar(id: string) { 
      isActionLoading = true;
      try {
          solicitacaoToConfirm = await api.get(`solicitacoes/${id}`); 
          showConfirmModal = true;
      } catch (e) {
          alert('Erro ao carregar detalhes da solicitação para confirmação.');
          console.error('Erro ao carregar para confirmação:', e);
      } finally {
          isActionLoading = false;
      }
  }
  async function handleSaveConfirmation(event: any) { 
    if (!solicitacaoToConfirm) return;
    const dataToSend = event.detail; 
    isActionLoading = true;
    try {
        const updatedSolicitacao = await api.patch(`solicitacoes/${solicitacaoToConfirm.id}/confirmar`, dataToSend);
        solicitacoes = solicitacoes.map(s => s.id === updatedSolicitacao.id ? updatedSolicitacao : s);
        showConfirmModal = false; 
        solicitacaoToConfirm = null; 
    } catch (e: any) {
        if (e && e.message) { alert(`Erro: ${e.message}`); } 
        else { alert('Erro ao salvar a confirmação.'); }
        console.error('Erro ao salvar confirmação:', e);
    } finally {
        isActionLoading = false;
    }
  }

  // 4. Ver Detalhes
  function handleVerDetalhes(id: string) { 
    const found = solicitacoes.find(s => s.id === id);
    if (found) {
        solicitacaoToView = found;
        showDetailsModal = true;
    } else {
        alert('Erro: Não foi possível encontrar os detalhes desta solicitação.');
        console.error(`Solicitação com ID ${id} não encontrada na lista local.`);
    }
  }

</script>

<div class="min-h-screen py-10 px-6 space-y-8 bg-gradient-to-b from-gray-50 to-gray-100 animate-fadeIn">

  <!-- 🔹 Cabeçalho -->
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-6 rounded-xl shadow-sm border border-gray-100">
    <div>
      <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Solicitações de Produtos
      </h1>
      {#if $session?.profile === 'escola'}
        <p class="text-gray-600 mt-1 text-sm">Crie e acompanhe os pedidos de reposição para sua escola.</p>
      {:else if $session?.profile === 'prefeitura'}
        <p class="text-gray-600 mt-1 text-sm">Analise e gerencie as solicitações recebidas das escolas.</p>
      {/if}
    </div>

    {#if $session?.profile === 'escola'}
      <button 
        on:click={handleNovaSolicitacao}
        disabled={isActionLoading || isLoading}
        class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        + Nova Solicitação
      </button>
    {/if}
  </div>

  <!-- 🔸 Conteúdo -->
  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando solicitações...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">{error}</div>
  {:else if solicitacoes.length === 0}
     <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300">
        <p class="text-gray-600 font-semibold text-lg">Nenhuma solicitação encontrada.</p>
     </div>
  {:else}
    <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Data</th>
            {#if $session?.profile === 'prefeitura'}
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Escola</th>
            {/if}
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Itens</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Status</th>
            <th class="px-6 py-3"><span class="sr-only">Ações</span></th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-100">
          {#each solicitacoes as s (s.id)}
            <tr class="hover:bg-gray-50 transition-colors duration-150">
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {format(new Date(s.createdAt), 'dd/MM/yyyy HH:mm', { locale: ptBR })}
              </td>
              {#if $session?.profile === 'prefeitura'}
                 <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{s.school.name}</td>
              {/if}
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{s.items.length}</td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span class="px-2.5 py-0.5 inline-flex text-xs font-semibold rounded-full {getStatusClass(s.status)}">
                  {formatStatus(s.status)}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-3">
                 {#if $session?.profile === 'prefeitura' && s.status === 'pendente'}
                    <button 
                      on:click={() => handleAnalisar(s.id)} 
                      disabled={isActionLoading}
                      class="text-primary-600 hover:text-primary-800 font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
                    >Analisar</button>
                {:else if $session?.profile === 'escola' && (s.status === 'aprovado' || s.status === 'aprovado_parcialmente')}
                    <button 
                      on:click={() => handleConfirmar(s.id)} 
                      disabled={isActionLoading}
                      class="text-green-600 hover:text-green-800 font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
                    >Confirmar</button>
                {/if}
                 <button 
                   on:click={() => handleVerDetalhes(s.id)} 
                   disabled={isActionLoading}
                   class="text-gray-500 hover:text-gray-800 font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
                 >Ver Detalhes</button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<!-- 🔹 Modais -->
{#if showCreateModal}
  <Modal show={showCreateModal} on:close={() => showCreateModal = false}>
    <SolicitacaoForm 
      bind:justificativa={newSolicitacaoJustificativa}
      bind:items={newSolicitacaoItems}
      on:save={handleSaveNewSolicitacao}
      on:cancel={() => showCreateModal = false}
    />
  </Modal>
{/if}

{#if solicitacaoToAnalyze}
  <Modal show={showAnalyzeModal} on:close={() => {showAnalyzeModal = false; solicitacaoToAnalyze = null;}}>
    <AnaliseSolicitacaoForm 
      solicitacao={solicitacaoToAnalyze}
      on:save={handleSaveAnalysis}
      on:cancel={() => {showAnalyzeModal = false; solicitacaoToAnalyze = null;}}
    />
  </Modal>
{/if}

{#if solicitacaoToConfirm}
  <Modal show={showConfirmModal} on:close={() => {showConfirmModal = false; solicitacaoToConfirm = null;}}>
    <ConfirmRecebimentoForm 
      solicitacao={solicitacaoToConfirm}
      on:save={handleSaveConfirmation}
      on:cancel={() => {showConfirmModal = false; solicitacaoToConfirm = null;}}
    />
  </Modal>
{/if}

{#if solicitacaoToView}
  <Modal show={showDetailsModal} on:close={() => {showDetailsModal = false; solicitacaoToView = null;}}>
    <DetalhesSolicitacao 
      solicitacao={solicitacaoToView}
      on:close={() => {showDetailsModal = false; solicitacaoToView = null;}}
    />
  </Modal>
{/if}

<style>
  @keyframes fadeIn {
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
  }
  .animate-fadeIn { animation: fadeIn 0.25s ease-out; }
</style>
