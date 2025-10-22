<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import { format, parseISO } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import Modal from '$lib/components/Modal.svelte';
  import CardapioForm from '$lib/components/CardapioForm.svelte';
  import { CalendarPlus, Edit, Eye } from 'lucide-svelte';
  import { goto } from '$app/navigation';

  type CardapioListItem = {
    id: string;
    name: string;
    startDate: string;
    endDate: string;
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

  function formatLocalDate(dateString: string): string {
    if (!dateString) return 'N/A';
    try {
      const date = parseISO(dateString); 
      return format(date, 'dd/MM/yy', { locale: ptBR });
    } catch (e) {
      console.error("Erro ao formatar data:", dateString, e);
      return 'Data Inválida';
    }
  }
</script>

<!-- 🌈 Container Principal -->
<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 py-8 px-6 space-y-8 animate-fadeIn">

  <!-- 🔹 Cabeçalho -->
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border">
    <div>
      <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Cardápios Semanais
      </h1>
      {#if $session?.profile === 'nutricionista'}
        <p class="text-gray-600 mt-1 text-sm">Crie, gerencie e distribua os cardápios da escola.</p>
      {:else}
        <p class="text-gray-600 mt-1 text-sm">Consulte os cardápios disponíveis desta semana.</p>
      {/if}
    </div>

    {#if $session?.profile === 'nutricionista'}
      <button 
        on:click={handleNovoCardapio}
        disabled={isActionLoading}
        class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95 disabled:opacity-50"
      >
        <CalendarPlus class="w-5 h-5"/>
        Novo Cardápio
      </button>
    {/if}
  </div>

  <!-- 🔸 Conteúdo Principal -->
  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando cardápios...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">{error}</div>
  {:else if cardapios.length === 0}
     <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300">
        <p class="text-gray-600 font-semibold text-lg">Nenhum cardápio encontrado.</p>
        {#if $session?.profile === 'nutricionista'}
          <p class="text-sm text-gray-400 mt-2">Clique em “Novo Cardápio” para começar.</p>
        {:else}
           <p class="text-sm text-gray-400 mt-2">Aguardando o envio de novos cardápios.</p>
        {/if}
     </div>
  {:else}
    <!-- 🧾 Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-8">
      {#each cardapios as cardapio (cardapio.id)}
        <div class="bg-white rounded-2xl shadow-md border border-gray-100 hover:shadow-xl hover:-translate-y-1 transition-all duration-200 overflow-hidden flex flex-col">
          <div class="p-6 flex-1">
            <h3 class="font-bold text-lg text-gray-800 truncate">{cardapio.name}</h3>
            <p class="text-sm text-gray-500 mt-2">
              <span class="font-medium text-gray-700">Período:</span><br>
              <span class="text-gray-600">{formatLocalDate(cardapio.startDate)} a {formatLocalDate(cardapio.endDate)}</span>
            </p>
            <p class="text-xs text-gray-400 mt-3">👩‍🍳 Criado por {cardapio.createdBy?.name}</p>
          </div>
          <div class="bg-gray-50 p-4 text-right rounded-b-2xl border-t mt-auto">
            {#if $session?.profile === 'nutricionista'}
              <button 
                on:click={() => handleViewEdit(cardapio.id)} 
                class="inline-flex items-center gap-2 text-primary-600 hover:text-primary-700 font-semibold text-sm transition-colors"
              >
                <Edit class="w-4 h-4"/>
                Gerenciar
              </button>
            {:else}
              <button 
                on:click={() => handleViewEdit(cardapio.id)} 
                class="inline-flex items-center gap-2 text-gray-600 hover:text-gray-800 font-semibold text-sm transition-colors"
              >
                <Eye class="w-4 h-4"/>
                Visualizar
              </button>
            {/if}
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<!-- 🪟 Modal de Criação -->
{#if showCreateModal}
<Modal show={showCreateModal} on:close={() => showCreateModal = false}>
  <CardapioForm 
    bind:cardapio={newCardapioData}
    on:save={handleSaveNewCardapio}
    on:cancel={() => showCreateModal = false}
  />
</Modal>
{/if}
