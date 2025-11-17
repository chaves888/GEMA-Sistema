<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import Modal from '$lib/components/Modal.svelte';
  import AjusteEstoqueForm from '$lib/components/AjusteEstoqueForm.svelte';
  import StatusBar from '$lib/components/StatusBar.svelte';
  import { toast } from '$lib/toast';
  import ImportarEstoqueForm from '$lib/components/ImportarEstoqueForm.svelte';
  import { Search } from 'lucide-svelte'; // <-- 1. IMPORTAR O ÍCONE DE BUSCA

  type EstoqueItem = {
    quantity: number;
    status: 'Crítico' | 'Médio' | 'Bom' | 'N/A';
    percentage: number;
    minStock: number;
    product: {
      id: string;
      name: string;
      unit: string;
    };
  };

  let estoque: EstoqueItem[] = [];
  let isLoading = true;
  let isRefreshing = false;
  let error: string | null = null;

  let showModal = false;
  let currentItem: EstoqueItem | null = null;
  let showImportModal = false;

  // --- 2. ADICIONAR ESTADO PARA OS FILTROS ---
  let searchTerm = '';
  let filterStatus = ''; // Vazio = 'Todos'

  // --- 3. CRIAR A LISTA FILTRADA REATIVA ---
  $: filteredEstoque = estoque.filter((item) => {
    // Filtro de Status
    const statusMatch = filterStatus === '' || item.status === filterStatus;
    if (!statusMatch) return false;

    // Filtro de Busca
    const searchMatch =
      searchTerm.trim() === '' ||
      item.product.name.toLowerCase().includes(searchTerm.toLowerCase());
    
    return searchMatch;
  });
  // --- FIM DAS ADIÇÕES NO SCRIPT ---

  $: if ($session) {
    if ($session.profile === 'prefeitura') {
      loadStock('prefeitura');
    } else if ($session.profile === 'escola' || $session.profile === 'cozinheira') {
      loadStock('escola');
    }
  }

  async function loadStock(profileOrContext: string) {
    if (!isLoading) isRefreshing = true;
    error = null;
    try {
      estoque = await api.get(
        profileOrContext === 'prefeitura' ? 'estoque/prefeitura' : 'estoque/escola'
      );
    } catch (e: any) {
      error = e?.message || '❌ Não foi possível carregar o estoque.';
      console.error(e);
      if (error) {
        toast.error(error);
      }
    } finally {
      isLoading = false;
      isRefreshing = false;
    }
  }

  function openAjusteModal(item: EstoqueItem) {
    currentItem = { ...item };
    showModal = true;
  }

  async function handleSave(event: any) {
    const { productId, newQuantity, motivoCategoria, motivoObservacao } = event.detail;

    try {
      const dtoToSend = { productId, newQuantity, motivoCategoria, motivoObservacao };

      let updatedItem =
        $session.profile === 'prefeitura'
          ? await api.patch('estoque/prefeitura', dtoToSend)
          : await api.patch('estoque/escola', dtoToSend);

      const index = estoque.findIndex((i) => i.product.id === productId);
      if (index !== -1) estoque[index] = updatedItem;

      estoque.sort((a, b) => {
        const statusOrder = { Crítico: 1, Médio: 2, Bom: 3, 'N/A': 4 };
        const orderA = statusOrder[a.status];
        const orderB = statusOrder[b.status];
        if (orderA !== orderB) return orderA - orderB;
        return a.percentage - b.percentage;
      });
      estoque = [...estoque];
      showModal = false;
      currentItem = null;

      toast.success('Estoque ajustado com sucesso!');
    } catch (e: any) {
      const errorMessage = e?.message || 'Erro ao ajustar o estoque.';
      toast.error(errorMessage);
      console.error(e);
    }
  }

  function onEstoqueImportado() {
    loadStock($session.profile);
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-4 lg:p-6 space-y-6 animate-fadeIn">
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border">
    <div>
      {#if $session?.profile === 'prefeitura'}
        <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent flex items-center gap-2">Estoque Central da Prefeitura</h1>
      {:else if $session?.profile === 'escola' || $session?.profile === 'cozinheira'}
        <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent flex items-center gap-2">Estoque da Escola: {$session.school?.name || ''}</h1>
      {/if}
      {#if $session?.profile === 'cozinheira'}
        <p class="text-gray-600 mt-1 text-sm">Acompanhe os níveis de estoque da sua escola.</p>
      {:else}
        <p class="text-gray-600 mt-1 text-sm">Acompanhe os níveis e ajuste as quantidades de produtos.</p>
      {/if}
    </div>
    {#if $session?.profile === 'prefeitura'}
      <button on:click={() => (showImportModal = true)} class="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95">
        Importar Planilha
      </button>
    {/if}
  </div>

  <div class="bg-white/80 backdrop-blur-md p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col md:flex-row flex-wrap gap-4 items-end">
    <div class="flex-1 w-full md:min-w-[250px]">
      <label for="searchTerm" class="block text-sm font-medium text-gray-700">Buscar por Nome</label>
      <div class="relative mt-1">
        <input type="text" id="searchTerm" bind:value={searchTerm} placeholder="Digite o nome do produto..." class="block w-full py-2 px-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pl-10" />
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Search class="w-5 h-5 text-gray-400" />
        </div>
      </div>
    </div>
    <div class="flex-1 w-full md:min-w-[150px]">
      <label for="filterStatus" class="block text-sm font-medium text-gray-700">Filtrar por Status</label>
      <select id="filterStatus" bind:value={filterStatus} class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm">
        <option value="">Todos os Status</option>
        <option value="Crítico">Crítico</option>
        <option value="Médio">Médio</option>
        <option value="Bom">Bom</option>
        <option value="N/A">N/A (sem mín.)</option>
      </select>
    </div>
  </div>

  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">
      {error}
    </div>
  {:else if estoque.length === 0}
    <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300">
      <p class="text-gray-600 font-semibold text-lg">Nenhum produto.</p>
    </div>
  {:else if filteredEstoque.length === 0}
    <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300">
      <p class="text-gray-600 font-semibold text-lg">Nenhum produto encontrado.</p>
    </div>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      {#each filteredEstoque as item (item.product.id)}
        <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 p-5 flex flex-col justify-between hover:shadow-lg transition-all duration-200 animate-fadeUp">
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="font-semibold text-gray-900 text-lg">{item.product.name}</h3>
              <p class="text-sm text-gray-500">Unidade: {item.product.unit}</p>
            </div>
            <span class="px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap {item.status === 'Crítico' ? 'bg-red-100 text-red-700' : item.status === 'Médio' ? 'bg-yellow-100 text-yellow-700' : item.status === 'Bom' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}">
              {item.status}
            </span>
          </div>
          <div>
            <StatusBar percentage={item.percentage} status={item.status} />
            <div class="flex justify-between text-sm mt-2">
              <span class="text-gray-600"><span class="font-semibold text-gray-900 text-lg">{item.quantity}</span> {item.product.unit}</span>
              <span class="text-gray-500"> Mín: {item.minStock} </span>
            </div>
          </div>
          {#if $session?.profile === 'prefeitura' || $session?.profile === 'escola'}
            <button on:click={() => openAjusteModal(item)} class="mt-5 w-full py-2.5 rounded-lg font-semibold text-sm text-primary-700 bg-primary-50 hover:bg-primary-100 hover:shadow-sm transition-all duration-200">Ajustar Estoque</button>
          {/if}
        </div>
      {/each}
    </div>
  {/if}
</div>

{#if currentItem && ($session?.profile === 'prefeitura' || $session?.profile === 'escola')}
  <Modal show={showModal} on:close={() => (showModal = false)} size="max-w-md">
    <AjusteEstoqueForm item={{ product: currentItem.product, quantity: currentItem.quantity }} on:save={handleSave} on:cancel={() => (showModal = false)} />
  </Modal>
{/if}
{#if showImportModal && $session?.profile === 'prefeitura'}
  <Modal show={showImportModal} on:close={() => (showImportModal = false)} size="max-w-2xl">
    <ImportarEstoqueForm on:cancel={() => (showImportModal = false)} on:imported={onEstoqueImportado} />
  </Modal>
{/if}

<style>
  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }
  .animate-fadeIn {
    animation: fadeIn 0.25s ease-out;
  }
  @keyframes fadeUp {
    from {
      opacity: 0;
      transform: translateY(10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  .animate-fadeUp {
    animation: fadeUp 0.3s ease-out forwards;
  }
  :global([transition\:fade]) {
    opacity: 0;
    animation: fadeIn 0.3s ease-out forwards;
  }
</style>