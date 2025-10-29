<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import Modal from '$lib/components/Modal.svelte';
  import AjusteEstoqueForm from '$lib/components/AjusteEstoqueForm.svelte';
  import StatusBar from '$lib/components/StatusBar.svelte';

  // --- TIPO EstoqueItem ATUALIZADO ---
  type EstoqueItem = {
    quantity: number;
    status: 'Crítico' | 'Médio' | 'Bom' | 'N/A';
    percentage: number;
    minStock: number; // <-- minStock agora está aqui
    product: {
      id: string;
      name: string;
      unit: string;
      // minStock não está mais aqui dentro
    };
  };
  // --- FIM ATUALIZAÇÃO ---

  let estoque: EstoqueItem[] = [];
  let isLoading = true;
  let isRefreshing = false; // Para feedback visual
  let error: string | null = null;

  let showModal = false;
  let currentItem: EstoqueItem | null = null; // Usa o tipo atualizado

  $: if ($session) {
    loadStock($session.profile);
  }

  async function loadStock(userProfile: string) {
    if (!isLoading) isRefreshing = true;
    error = null;
    try {
      // API retorna a estrutura correta com minStock no nível superior
      estoque = await api.get(userProfile === 'prefeitura' ? 'estoque/prefeitura' : 'estoque/escola');
    } catch (e: any) { // Adicionado tipo 'any' para 'e'
      error = e?.message || '❌ Não foi possível carregar o estoque.'; // Mensagem de erro atualizada
      console.error(e);
    } finally {
      isLoading = false;
      isRefreshing = false;
    }
  }

  function openAjusteModal(item: EstoqueItem) {
    currentItem = { ...item }; // Guarda o item completo
    showModal = true;
  }

  async function handleSave(event: any) {
    const { productId, quantity } = event.detail; // Form só envia isso
    try {
      let updatedItem =
        $session.profile === 'prefeitura'
          ? await api.patch('estoque/prefeitura', { productId, quantity })
          : await api.patch('estoque/escola', { productId, quantity });

      const index = estoque.findIndex(i => i.product.id === productId);
      if (index !== -1) estoque[index] = updatedItem; // Substitui pelo item formatado da API

      // Reordena
      estoque.sort((a, b) => {
          const statusOrder = { 'Crítico': 1, 'Médio': 2, 'Bom': 3, 'N/A': 4 };
          const orderA = statusOrder[a.status];
          const orderB = statusOrder[b.status];
          if (orderA !== orderB) return orderA - orderB;
          return a.percentage - b.percentage;
      });
      estoque = [...estoque]; // Força reatividade
      showModal = false;
      currentItem = null; // Limpa item selecionado
    } catch (e: any) { // Adicionado tipo 'any' para 'e'
       if (e && e.message) alert(`Erro: ${e.message}`);
       else alert('Erro ao ajustar o estoque.');
      console.error(e);
    }
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-6 space-y-6 animate-fadeIn">
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border">
    <div>
      {#if $session?.profile === 'prefeitura'}
        <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent flex items-center gap-2"> Estoque Central da Prefeitura </h1>
      {:else if $session?.profile === 'escola'}
        <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent flex items-center gap-2"> Estoque da Escola: <span class="text-gray-900 font-semibold ml-1">{$session.school?.name || ''}</span> </h1>
      {/if}
      <p class="text-gray-600 mt-1 text-sm">Acompanhe os níveis e ajuste as quantidades de produtos.</p>
    </div>
  </div>

  {#if isLoading}
    <div class="flex justify-center items-center p-10"> <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando...</p> </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">{error}</div>
  {:else if estoque.length === 0}
     <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300"> <p class="text-gray-600 font-semibold text-lg">Nenhum produto.</p> <p class="text-sm text-gray-400 mt-2">Cadastre produtos e ajuste o estoque.</p> </div>
  {:else}
    <div class="grid md:grid-cols-2 xl:grid-cols-3 gap-6">
      {#each estoque as item (item.product.id)}
        <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 p-5 flex flex-col justify-between hover:shadow-lg transition-all duration-200 animate-fadeUp">
          <div class="flex justify-between items-start mb-4">
            <div>
              <h3 class="font-semibold text-gray-900 text-lg">{item.product.name}</h3>
              <p class="text-sm text-gray-500">Unidade: {item.product.unit}</p>
            </div>
            <span class="px-3 py-1 rounded-full text-xs font-semibold whitespace-nowrap {item.status === 'Crítico' ? 'bg-red-100 text-red-700' : item.status === 'Médio' ? 'bg-yellow-100 text-yellow-700' : item.status === 'Bom' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-600'}"> {item.status} </span>
          </div>
          <div>
            <StatusBar percentage={item.percentage} status={item.status} />
            <div class="flex justify-between text-sm mt-2">
              <span class="text-gray-600"> <span class="font-semibold text-gray-900 text-lg">{item.quantity}</span> {item.product.unit} </span>
              <span class="text-gray-500"> Mín: {item.minStock} </span> 
              </div>
          </div>
          <button on:click={() => openAjusteModal(item)} class="mt-5 w-full py-2.5 rounded-lg font-semibold text-sm text-primary-700 bg-primary-50 hover:bg-primary-100 hover:shadow-sm transition-all duration-200"> Ajustar Estoque </button>
        </div>
      {/each}
    </div>
  {/if}
</div>

{#if currentItem}
  <Modal show={showModal} on:close={() => (showModal = false)} size="max-w-md">
    <AjusteEstoqueForm
       item={{ product: currentItem.product, quantity: currentItem.quantity }}
       on:save={handleSave}
       on:cancel={() => (showModal = false)}
    />
    </Modal>
{/if}

<style>
  @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
  .animate-fadeIn { animation: fadeIn 0.25s ease-out; }
  @keyframes fadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
  .animate-fadeUp { animation: fadeUp 0.3s ease-out forwards; }
</style>