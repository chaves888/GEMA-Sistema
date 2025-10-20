<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import { format, parseISO } from 'date-fns'; // <-- Importa parseISO
  import { ptBR } from 'date-fns/locale';
  import Modal from '$lib/components/Modal.svelte';
  import CardapioForm from '$lib/components/CardapioForm.svelte';
  import { CalendarPlus, Edit, Eye } from 'lucide-svelte';
  import { goto } from '$app/navigation'; 

  // O tipo reflete que as datas são strings
  type CardapioListItem = {
    id: string;
    name: string;
    startDate: string; // YYYY-MM-DD
    endDate: string;   // YYYY-MM-DD
    createdBy: { name: string; };
  };

  let cardapios: CardapioListItem[] = [];
  let isLoading = true;
  let error: string | null = null;
  let isActionLoading = false; 

  let showCreateModal = false;
  let newCardapioData = { 
      name: '', 
      startDate: new Date().toISOString().split('T')[0], 
      endDate: new Date().toISOString().split('T')[0] 
  };

  $: if ($session) {
    loadCardapios();
  }

  async function loadCardapios() {
    isLoading = true;
    error = null;
    try {
      cardapios = await api.get('cardapios');
    } catch (e) {
      error = 'Não foi possível carregar os cardápios.';
      console.error(e);
    } finally {
      isLoading = false;
    }
  }

  function handleNovoCardapio() {
    const today = new Date().toISOString().split('T')[0];
    newCardapioData = { name: '', startDate: today, endDate: today };
    showCreateModal = true;
  }

  async function handleSaveNewCardapio(event: any) {
    const dataToSend = event.detail;
    isActionLoading = true;
    try {
        const createdCardapio = await api.post('cardapios', dataToSend);
        showCreateModal = false;
        // Redireciona para a página de detalhes para adicionar refeições
        await goto(`/cardapios/${createdCardapio.id}`); 
    } catch (e: any) {
        if (e && e.message) { alert(`Erro: ${e.message}`); }
        else { alert('Erro ao criar o cardápio.'); }
        console.error(e);
    } finally {
        isActionLoading = false;
    }
  }
  
  function handleViewEdit(id: string) {
      goto(`/cardapios/${id}`);
  }

  // --- NOVA FUNÇÃO AUXILIAR (Timezone Fix) ---
  // Converte a string "YYYY-MM-DD" para um objeto Date no fuso horário local
  // e depois formata para "dd/MM/yy"
  function formatLocalDate(dateString: string): string {
    if (!dateString) return 'N/A';
    try {
      // parseISO('2025-11-03') entende a string como "meia-noite do dia 03"
      // Se usássemos new Date('2025-11-03'), ele interpretaria como UTC e poderia pular o dia.
      const date = parseISO(dateString); 
      return format(date, 'dd/MM/yy', { locale: ptBR });
    } catch (e) {
      console.error("Erro ao formatar data:", dateString, e);
      return 'Data Inválida';
    }
  }

</script>

<div class="space-y-6 animate-fadeIn">
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
    <div>
      <h1 class="text-3xl font-bold text-gray-900">Cardápios Semanais</h1>
      {#if $session?.profile === 'nutricionista'}
        <p class="text-gray-500 mt-1">Crie, gerencie e distribua os cardápios.</p>
      {:else}
        <p class="text-gray-500 mt-1">Consulte os cardápios da semana.</p>
      {/if}
    </div>

    {#if $session?.profile === 'nutricionista'}
      <button 
        on:click={handleNovoCardapio}
        disabled={isActionLoading}
        class="flex items-center gap-2 bg-primary-600 hover:bg-primary-700 text-white font-bold py-2.5 px-5 rounded-lg shadow-md transition-transform hover:scale-105 disabled:opacity-50"
      >
        <CalendarPlus class="w-5 h-5"/>
        Novo Cardápio Semanal
      </button>
    {/if}
  </div>

  {#if isLoading}
    <div class="text-center p-10"><p class="text-gray-500">⏳ Carregando cardápios...</p></div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg">{error}</div>
  {:else if cardapios.length === 0}
     <div class="text-center p-10 bg-white rounded-lg shadow-sm border">
        <p class="text-gray-500 font-medium">Nenhum cardápio encontrado.</p>
        {#if $session?.profile === 'nutricionista'}
          <p class="text-sm text-gray-400 mt-2">Clique em "+ Novo Cardápio" para começar.</p>
        {:else}
           <p class="text-sm text-gray-400 mt-2">Nenhum cardápio ativo cadastrado para esta semana.</p>
        {/if}
     </div>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each cardapios as cardapio (cardapio.id)}
        <div class="bg-white rounded-lg shadow-md border hover:shadow-lg transition-shadow flex flex-col">
          <div class="p-5">
            <h3 class="font-bold text-lg text-gray-800">{cardapio.name}</h3>
            <p class="text-sm text-gray-500 mt-1">
              Período:
              <span class="font-medium text-gray-600">
                {formatLocalDate(cardapio.startDate)}
                a 
                {formatLocalDate(cardapio.endDate)}
              </span>
            </p>
             <p class="text-xs text-gray-400 mt-2">Criado por: {cardapio.createdBy?.name}</p>
          </div>
          <div class="bg-gray-50 p-3 text-right rounded-b-lg border-t mt-auto">
            {#if $session?.profile === 'nutricionista'}
              <button 
                on:click={() => handleViewEdit(cardapio.id)} 
                class="inline-flex items-center gap-2 text-primary-600 hover:text-primary-800 font-semibold text-sm"
              >
                <Edit class="w-4 h-4"/>
                Gerenciar Cardápio
              </button>
            {:else}
              <button 
                on:click={() => handleViewEdit(cardapio.id)} 
                class="inline-flex items-center gap-2 text-gray-600 hover:text-gray-800 font-semibold text-sm"
              >
                <Eye class="w-4 h-4"/>
                Visualizar Cardápio
              </button>
            {/if}
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

{#if showCreateModal}
<Modal show={showCreateModal} on:close={() => showCreateModal = false}>
  <CardapioForm 
    bind:cardapio={newCardapioData}
    on:save={handleSaveNewCardapio}
    on:cancel={() => showCreateModal = false}
  />
</Modal>
{/if}