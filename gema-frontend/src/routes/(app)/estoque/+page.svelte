<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import Modal from '$lib/components/Modal.svelte';
  import AjusteEstoqueForm from '$lib/components/AjusteEstoqueForm.svelte';
  import StatusBar from '$lib/components/StatusBar.svelte';

  type EstoqueItem = {
    quantity: number;
    status: 'Crítico' | 'Médio' | 'Bom' | 'N/A';
    percentage: number;
    product: {
      id: string;
      name: string;
      unit: string;
      minStock: number;
    };
  };

  let estoque: EstoqueItem[] = [];
  let isLoading = true;
  let isRefreshing = false;
  let error: string | null = null;

  let showModal = false;
  let currentItem: EstoqueItem | null = null;

  $: if ($session) {
    loadStock($session.profile);
  }

  async function loadStock(userProfile: string) {
    if (!isLoading) isRefreshing = true;
    error = null;

    try {
      estoque = await api.get(
        userProfile === 'prefeitura'
          ? 'estoque/prefeitura'
          : 'estoque/escola'
      );
    } catch (e) {
      error = '❌ Não foi possível carregar o estoque.';
      console.error(e);
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
    const { productId, quantity } = event.detail;
    try {
      let updatedItem =
        $session.profile === 'prefeitura'
          ? await api.patch('estoque/prefeitura', { productId, quantity })
          : await api.patch('estoque/escola', { productId, quantity });

      const index = estoque.findIndex((i) => i.product.id === productId);
      if (index !== -1) estoque[index] = updatedItem;

      estoque.sort((a, b) => a.percentage - b.percentage);
      estoque = [...estoque];
      showModal = false;
    } catch (e) {
      alert('Erro ao ajustar o estoque.');
      console.error(e);
    }
  }
</script>

<div class="space-y-6 animate-fadeIn">
  <!-- Cabeçalho -->
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
    <div>
      {#if $session?.profile === 'prefeitura'}
        <h1 class="text-3xl font-bold text-gray-900">🏛️ Estoque Central da Prefeitura</h1>
      {:else if $session?.profile === 'escola'}
        <h1 class="text-3xl font-bold text-gray-900">
          🎓 Estoque da Escola: 
          <span class="text-primary-600 font-semibold">{$session.school?.name || ''}</span>
        </h1>
      {/if}
      <p class="text-gray-500 mt-1">Acompanhe os níveis e ajuste as quantidades de produtos.</p>
    </div>

    <button 
      on:click={() => loadStock($session.profile)} 
      disabled={isRefreshing}
      class="flex items-center gap-2 bg-gradient-to-r from-primary-500 to-primary-600 text-white font-semibold py-2.5 px-5 rounded-xl shadow-md hover:opacity-90 transition-all duration-200 disabled:opacity-50"
    >
      {#if isRefreshing}
        <svg class="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.3 0 0 5.3 0 12h4z"></path>
        </svg>
        Atualizando...
      {:else}
        <svg class="h-5 w-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582M20 20v-5h-.581M4.582 9A7.963 7.963 0 0112 4c3.183 0 5.996 1.868 7.418 4.582M19.419 15A7.963 7.963 0 0112 20c-3.183 0-5.996-1.868-7.418-4.582"/>
        </svg>
        Atualizar
      {/if}
    </button>
  </div>

  <!-- Conteúdo -->
  {#if isLoading}
    <div class="text-center p-10">
      <p class="text-gray-500">⏳ Carregando estoque...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm border border-red-300">{error}</div>
  {:else}
    <div class="grid md:grid-cols-2 xl:grid-cols-3 gap-5">
      {#each estoque as item (item.product.id)}
        <div
          class="bg-white rounded-2xl shadow-md hover:shadow-lg transition-all duration-200 border border-gray-100 p-5 flex flex-col justify-between animate-fadeUp"
        >
          <div class="flex justify-between items-start">
            <div>
              <h3 class="font-semibold text-gray-900 text-lg">{item.product.name}</h3>
              <p class="text-sm text-gray-500">Unidade: {item.product.unit}</p>
            </div>

            <span
              class="px-3 py-1 rounded-full text-xs font-semibold"
              class:bg-red-100={item.status === 'Crítico'}
              class:text-red-700={item.status === 'Crítico'}
              class:bg-yellow-100={item.status === 'Médio'}
              class:text-yellow-700={item.status === 'Médio'}
              class:bg-green-100={item.status === 'Bom'}
              class:text-green-700={item.status === 'Bom'}
              class:bg-gray-100={item.status === 'N/A'}
              class:text-gray-600={item.status === 'N/A'}
            >
              {item.status}
            </span>
          </div>

          <div class="mt-4">
            <StatusBar percentage={item.percentage} status={item.status} />
            <div class="flex justify-between text-sm mt-2">
              <span class="text-gray-600">
                <span class="font-semibold text-gray-900">{item.quantity}</span> unidades
              </span>
              <span class="text-gray-500">mín: {item.product.minStock}</span>
            </div>
          </div>

          <button
            on:click={() => openAjusteModal(item)}
            class="mt-5 w-full text-center py-2 rounded-lg font-semibold text-primary-600 hover:bg-primary-50 transition-all"
          >
            Ajustar Estoque
          </button>
        </div>
      {/each}
    </div>
  {/if}
</div>

{#if currentItem}
  <Modal show={showModal} on:close={() => showModal = false}>
    <AjusteEstoqueForm
      item={currentItem}
      on:save={handleSave}
      on:cancel={() => showModal = false}
    />
  </Modal>
{/if}

<style>
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .animate-fadeIn {
    animation: fadeIn 0.4s ease-out forwards;
  }

  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(15px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .animate-fadeUp {
    animation: fadeUp 0.3s ease-out forwards;
  }
</style>
