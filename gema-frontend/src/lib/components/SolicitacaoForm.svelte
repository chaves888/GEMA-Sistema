<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';
  import { PlusCircle, Trash2 } from 'lucide-svelte';
  import { browser } from '$app/environment'; // <-- NOVO IMPORT

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

  // --- NOVO: FILTRO INTELIGENTE ---
  // Filtra produtos que ainda não estão na lista 'items'
  $: availableProducts = allProducts.filter(p => !items.some(item => item.productId === p.id));
  
  // Atualiza o select padrão quando a lista de disponíveis mudar
  // (e garante que só rode no browser)
  $: if (browser && availableProducts.length > 0 && !availableProducts.find(p => p.id === selectedProductId)) {
    selectedProductId = availableProducts[0].id;
  }
  // --- FIM FILTRO ---

  onMount(async () => {
    try {
      allProducts = await api.get('products');
      // O 'selectedProductId' será definido pela lógica reativa acima
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
      // Se já existe, apenas soma a quantidade
      items[existingItemIndex].quantityRequested += selectedProductQuantity;
      items = [...items]; // Força a reatividade
    } else {
      // Se não existe, adiciona novo
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
    // Reseta a quantidade e deixa a lógica reativa cuidar do selectedProductId
    selectedProductQuantity = 1; 
  }

  function removeItem(index: number) {
    items.splice(index, 1);
    items = [...items]; // Força a reatividade (e o filtro a recalcular)
  }

  function handleSubmit() {
    if (items.length === 0) {
      // O usuário pediu para não mudar o estilo, então mantemos o alert
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

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <h2 class="text-2xl lg:text-3xl font-bold text-gray-800 border-b pb-4">Nova Solicitação</h2>

  <div>
    <label for="justificativa" class="block text-sm font-semibold text-gray-700 mb-1">Justificativa (Opcional)</label>
    <textarea
      id="justificativa"
      rows="3"
      class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
      bind:value={justificativa}
      placeholder="Ex: Reposição semanal, evento especial..."
    ></textarea>
  </div>

  <div class="border-t pt-5">
    <h3 class="text-lg font-semibold text-gray-800 mb-3">Adicionar Produtos</h3>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
      <div class="md:col-span-2">
        <label for="productSelect" class="block text-sm font-semibold text-gray-700 mb-1">Produto</label>
        <select
          id="productSelect"
          bind:value={selectedProductId}
          class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition bg-white"
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
      <div>
        <label for="quantity" class="block text-sm font-semibold text-gray-700 mb-1">Quantidade</label>
        <input
          type="number"
          step="0.01"
          min="0.01"
          id="quantity"
          bind:value={selectedProductQuantity}
          class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
          disabled={allProducts.length === 0}
        />
      </div>
    </div>
    <button
      type="button"
      on:click={addProductToRequest}
      disabled={isLoadingProducts || availableProducts.length === 0 || !selectedProductId}
      class="mt-4 w-full md:w-auto inline-flex items-center justify-center gap-2 bg-accent-500 hover:bg-accent-600 text-white font-semibold py-2.5 px-5 rounded-lg shadow-sm transition disabled:opacity-50 disabled:cursor-not-allowed"
    >
      <PlusCircle class="w-5 h-5" /> Adicionar Item
    </button>
  </div>

  {#if items.length > 0}
    <div class="border-t pt-5">
      <h3 class="text-lg font-semibold text-gray-800 mb-3">Itens na Solicitação</h3>
      <div class="space-y-2 max-h-48 overflow-y-auto pr-2 border rounded-lg p-3 bg-gray-50 shadow-inner">
        {#each items as item, index (item.productId)}
          <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center bg-white p-3 rounded-lg shadow-sm border gap-2">
            <div>
              <span class="font-semibold text-gray-800 block">{item.productName}</span>
              <span class="text-sm text-gray-600">({item.quantityRequested} {item.productUnit})</span>
            </div>
            <button
              type="button"
              on:click={() => removeItem(index)}
              class="text-red-500 hover:text-red-700 p-1.5 rounded-full hover:bg-red-100 transition-colors self-end sm:self-auto"
              aria-label="Remover item"
            >
              <Trash2 class="w-4 h-4" />
            </button>
          </div>
        {/each}
      </div>
    </div>
  {/if}

  <div class="mt-8 flex flex-col-reverse sm:flex-row justify-end gap-3 sm:gap-4 border-t pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="w-full sm:w-auto bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="w-full sm:w-auto bg-primary-600 hover:bg-primary-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105 disabled:opacity-50"
      disabled={items.length === 0}
    >
      Enviar Solicitação
    </button>
  </div>
</form>