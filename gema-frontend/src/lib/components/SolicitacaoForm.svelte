<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';
  import { PlusCircle, Trash2 } from 'lucide-svelte';
  import { browser } from '$app/environment';

  type Product = { id: string; name: string; unit: string };
  type SolicitacaoItemForm = {
    productId: string;
    quantityRequested: number;
    productName?: string;
    productUnit?: string;
  };

  export let justificativa: string = '';
  export let items: SolicitacaoItemForm[] = [];

  let allProducts: Product[] = [];
  let selectedProductId: string = '';
  let selectedProductQuantity: number = 1;
  let isLoadingProducts = true;

  const dispatch = createEventDispatcher();

  $: availableProducts = allProducts.filter(p => !items.some(item => item.productId === p.id));
  
  $: if (browser && availableProducts.length > 0 && !availableProducts.find(p => p.id === selectedProductId)) {
    selectedProductId = availableProducts[0].id;
  }

  onMount(async () => {
    try {
      allProducts = await api.get('products');
    } catch (e) {
      console.error('Erro ao carregar produtos:', e);
    } finally {
      isLoadingProducts = false;
    }
  });

  function addProductToRequest() {
    if (!selectedProductId || selectedProductQuantity <= 0) return;
    const selectedProduct = allProducts.find(p => p.id === selectedProductId);
    if (!selectedProduct) return;

    const existingItemIndex = items.findIndex(item => item.productId === selectedProductId);

    if (existingItemIndex !== -1) {
      items[existingItemIndex].quantityRequested += selectedProductQuantity;
      items = [...items]; 
    } else {
      items = [
        ...items,
        {
          productId: selectedProductId,
          quantityRequested: selectedProductQuantity,
          productName: selectedProduct.name,
          productUnit: selectedProduct.unit,
        },
      ];
    }
    selectedProductQuantity = 1; 
  }

  function removeItem(index: number) {
    items.splice(index, 1);
    items = [...items]; 
  }

  function handleSubmit() {
    if (items.length === 0) {
      alert('Adicione pelo menos um produto à solicitação.');
      return;
    }
    dispatch('save', {
      justificativa: justificativa || undefined,
      items: items.map(i => ({
        productId: i.productId,
        quantityRequested: i.quantityRequested,
      })),
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="flex flex-col h-full">
  <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-6">
      <h2 class="text-2xl md:text-3xl font-bold text-gray-800 dark:text-white">Nova Solicitação</h2>
      <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">Preencha os dados abaixo para solicitar reposição.</p>
  </div>

  <div class="flex-1 overflow-y-auto pr-1 space-y-6">
      <div>
        <label for="justificativa" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Justificativa (Opcional)</label>
        <textarea
          id="justificativa"
          rows="3"
          class="w-full rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition placeholder-gray-400 dark:placeholder-gray-400"
          bind:value={justificativa}
          placeholder="Ex: Reposição semanal, evento especial..."
        ></textarea>
      </div>

      <div class="border-t border-gray-200 dark:border-gray-700 pt-5">
        <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-3">Adicionar Produtos</h3>
        
        <div class="grid grid-cols-1 sm:grid-cols-12 gap-4 items-end">
          <div class="sm:col-span-8">
            <label for="productSelect" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Produto</label>
            <select
              id="productSelect"
              bind:value={selectedProductId}
              class="w-full rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2.5 transition"
              disabled={isLoadingProducts || allProducts.length === 0}
            >
              {#if isLoadingProducts}
                <option value="">Carregando produtos...</option>
              {:else if allProducts.length === 0}
                <option value="">Nenhum produto cadastrado</option>
              {:else if availableProducts.length === 0}
                <option value="">Todos os produtos já foram adicionados</option>
              {:else}
                {#each availableProducts as product (product.id)}
                  <option value={product.id}>{product.name} ({product.unit})</option>
                {/each}
              {/if}
            </select>
          </div>
          
          <div class="sm:col-span-4 flex items-end gap-2">
              <div class="flex-1">
                  <label for="quantity" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Qtd.</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0.01"
                    id="quantity"
                    bind:value={selectedProductQuantity}
                    class="w-full rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2.5 transition placeholder-gray-400 dark:placeholder-gray-400"
                    disabled={allProducts.length === 0}
                  />
              </div>
              <button
                type="button"
                on:click={addProductToRequest}
                disabled={isLoadingProducts || availableProducts.length === 0 || !selectedProductId}
                class="inline-flex items-center justify-center bg-accent-500 hover:bg-accent-600 text-white font-semibold p-2.5 rounded-lg shadow-sm transition disabled:opacity-50 disabled:cursor-not-allowed h-[42px] w-[42px] flex-shrink-0"
                title="Adicionar item"
              >
                <PlusCircle class="w-6 h-6" />
              </button>
          </div>
        </div>
      </div>

      {#if items.length > 0}
        <div class="border-t border-gray-200 dark:border-gray-700 pt-5">
          <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-3">Itens na Solicitação</h3>
          <div class="space-y-2 max-h-48 overflow-y-auto pr-2 border border-gray-200 dark:border-gray-700 rounded-lg p-3 bg-gray-50 dark:bg-gray-800/50 shadow-inner custom-scrollbar">
            {#each items as item, index (item.productId)}
              <div class="flex justify-between items-center bg-white dark:bg-gray-700 p-3 rounded-lg shadow-sm border border-gray-100 dark:border-gray-600 gap-3 transition-colors">
                <div class="flex-1 min-w-0">
                  <span class="font-semibold text-gray-800 dark:text-gray-100 block truncate">{item.productName}</span>
                  <span class="text-sm text-gray-500 dark:text-gray-300">Qtd: <strong class="text-gray-700 dark:text-gray-200">{item.quantityRequested}</strong> {item.productUnit}</span>
                </div>
                <button
                  type="button"
                  on:click={() => removeItem(index)}
                  class="text-red-500 dark:text-red-400 hover:text-red-700 dark:hover:text-red-300 p-2 rounded-full hover:bg-red-100 dark:hover:bg-red-900/30 transition-colors flex-shrink-0"
                  aria-label="Remover item"
                >
                  <Trash2 class="w-5 h-5" />
                </button>
              </div>
            {/each}
          </div>
        </div>
      {/if}
  </div>

  <div class="mt-8 flex flex-col-reverse sm:flex-row justify-end gap-3 border-t border-gray-200 dark:border-gray-700 pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="w-full sm:w-auto px-5 py-2.5 rounded-xl border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition-all"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold transition-all shadow-md transform hover:scale-105 disabled:opacity-50 active:scale-95"
      disabled={items.length === 0}
    >
      Enviar Solicitação
    </button>
  </div>
</form>