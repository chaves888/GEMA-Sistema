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

<div class="min-h-screen py-10 px-6 space-y-8 bg-gradient-to-b from-gray-50 to-gray-100 animate-fadeIn">

  <!-- 🔹 Cabeçalho -->
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-6 rounded-xl shadow-sm border border-gray-100">
    <div>
      {#if $session?.profile === 'prefeitura'}
        <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent flex items-center gap-2">
          Estoque Central da Prefeitura
        </h1>
      {:else if $session?.profile === 'escola'}
        <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent flex items-center gap-2">
          Estoque da Escola: <span class="text-gray-900 font-semibold ml-1">{$session.school?.name || ''}</span>
        </h1>
      {/if}
      <p class="text-gray-600 mt-1 text-sm">Acompanhe os níveis e ajuste as quantidades de produtos.</p>
    </div>
  </div>

  <!-- 🔸 Conteúdo -->
  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando estoque...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">{error}</div>
  {:else}
    <div class="grid md:grid-cols-2 xl:grid-cols-3 gap-6">
      {#each estoque as item (item.product.id)}
        <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 p-5 flex flex-col justify-between hover:shadow-lg transition-all duration-200 animate-fadeUp">
          
          <!-- Info Produto -->
          <div class="flex justify-between items-start mb-4">
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

          <!-- Barra de Status -->
          <div>
            <StatusBar percentage={item.percentage} status={item.status} />
            <div class="flex justify-between text-sm mt-2">
              <span class="text-gray-600">
                <span class="font-semibold text-gray-900">{item.quantity}</span> unidades
              </span>
              <span class="text-gray-500">mín: {item.product.minStock}</span>
            </div>
          </div>

          <!-- Botão Ajustar -->
          <button
            on:click={() => openAjusteModal(item)}
            class="mt-5 w-full py-2 rounded-lg font-semibold text-primary-600 hover:bg-primary-50 hover:shadow transition-all duration-200"
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
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
  }
  .animate-fadeIn {
    animation: fadeIn 0.25s ease-out;
  }

  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .animate-fadeUp {
    animation: fadeUp 0.3s ease-out forwards;
  }
</style>
