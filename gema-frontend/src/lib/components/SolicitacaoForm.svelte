<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';
  import { PlusCircle, Trash2 } from 'lucide-svelte';

  // Tipos necessários
  type Product = { id: string; name: string; unit: string; }; // Simplificado para o form
  // Tipo para os itens que o formulário manipula internamente
  type SolicitacaoItemForm = { 
    productId: string; 
    quantityRequested: number; 
    // Propriedades extras para exibição na lista
    productName?: string; 
    productUnit?: string;
  };

  // Propriedades recebidas da página principal via bind:
  export let justificativa: string = '';
  export let items: SolicitacaoItemForm[] = []; // Lista de itens sendo montada
  
  // Estado interno do componente
  let allProducts: Product[] = []; // Lista de todos os produtos cadastrados
  let selectedProductId: string = ''; // ID do produto no dropdown
  let selectedProductQuantity: number = 1; // Quantidade no input numérico
  let isLoadingProducts = true; // Controla o carregamento do dropdown

  const dispatch = createEventDispatcher(); // Para enviar eventos (save, cancel)

  // Busca a lista de produtos quando o componente é montado
  onMount(async () => {
    try {
      allProducts = await api.get('products');
      if (allProducts.length > 0) {
        selectedProductId = allProducts[0].id; // Pré-seleciona o primeiro
      }
    } catch (e) {
      console.error("Erro ao carregar produtos:", e);
      // Poderia exibir uma mensagem de erro para o usuário
    } finally {
      isLoadingProducts = false;
    }
  });

  // Função para adicionar o produto selecionado à lista de itens do pedido
  function addProductToRequest() {
    if (!selectedProductId || selectedProductQuantity <= 0) return; // Validação básica

    const selectedProduct = allProducts.find(p => p.id === selectedProductId);
    if (!selectedProduct) return; // Produto selecionado não encontrado (improvável)

    // Verifica se o produto já está na lista 'items'
    const existingItemIndex = items.findIndex(item => item.productId === selectedProductId);

    if (existingItemIndex !== -1) {
      // Se já existe, apenas soma a quantidade
      items[existingItemIndex].quantityRequested += selectedProductQuantity;
      // Precisamos reatribuir para o Svelte detectar a mudança no array
      items = [...items]; 
    } else {
      // Se não existe, adiciona um novo item à lista
      items = [
        ...items, 
        { 
          productId: selectedProductId, 
          quantityRequested: selectedProductQuantity,
          // Guarda nome e unidade para exibir na lista (não será enviado para API)
          productName: selectedProduct.name, 
          productUnit: selectedProduct.unit   
        }
      ];
    }
    // Reseta a quantidade para o próximo item
    selectedProductQuantity = 1; 
  }

  // Função para remover um item da lista do pedido
  function removeItem(index: number) {
    items.splice(index, 1);
    items = [...items]; // Força reatividade
  }

  // Função chamada quando o formulário é enviado
  function handleSubmit() {
    if (items.length === 0) {
      alert('Adicione pelo menos um produto à solicitação.');
      return;
    }
    // Envia o evento 'save' para a página pai, contendo os dados formatados
    // exatamente como a API espera (apenas productId e quantityRequested nos itens)
    dispatch('save', { 
        justificativa: justificativa || undefined, // Envia undefined se vazio, para não salvar string vazia
        items: items.map(i => ({ 
            productId: i.productId, 
            quantityRequested: i.quantityRequested 
        })) 
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <h2 class="text-2xl font-bold mb-4 text-gray-800">Nova Solicitação</h2>

  <div>
    <label for="justificativa" class="block text-sm font-medium text-gray-700">Justificativa (Opcional)</label>
    <textarea 
      id="justificativa" 
      rows="3" 
      class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" 
      bind:value={justificativa}
      placeholder="Ex: Reposição semanal, evento especial..."
    ></textarea>
  </div>

  <div class="border-t pt-4">
    <h3 class="text-lg font-medium text-gray-800 mb-3">Adicionar Produtos ao Pedido</h3>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
      <div class="md:col-span-2">
        <label for="productSelect" class="block text-sm font-medium text-gray-700">Produto</label>
        {#if isLoadingProducts}
          <select disabled class="mt-1 block w-full rounded-md border-gray-300 shadow-sm bg-gray-100 cursor-not-allowed">
            <option>Carregando produtos...</option>
          </select>
        {:else if allProducts.length === 0}
          <select disabled class="mt-1 block w-full rounded-md border-gray-300 shadow-sm bg-gray-100 cursor-not-allowed">
            <option>Nenhum produto cadastrado</option>
          </select>
        {:else}
          <select id="productSelect" bind:value={selectedProductId} class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500">
            {#each allProducts as product (product.id)}
              <option value={product.id}>{product.name} ({product.unit})</option>
            {/each}
          </select>
        {/if}
      </div>
      <div>
        <label for="quantity" class="block text-sm font-medium text-gray-700">Quantidade</label>
        <input 
          type="number" 
          step="0.01" 
          min="0.01" 
          id="quantity" 
          bind:value={selectedProductQuantity} 
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
          disabled={allProducts.length === 0}
         >
      </div>
    </div>
     <button 
        type="button" 
        on:click={addProductToRequest}
        disabled={isLoadingProducts || allProducts.length === 0 || !selectedProductId}
        class="mt-3 inline-flex items-center gap-2 bg-accent-500 hover:bg-accent-600 text-white font-semibold py-2 px-4 rounded-lg shadow-sm transition disabled:opacity-50 disabled:cursor-not-allowed"
      >
       <PlusCircle class="w-5 h-5"/> Adicionar Item
      </button>
  </div>

   {#if items.length > 0}
   <div class="border-t pt-4">
     <h3 class="text-lg font-medium text-gray-800 mb-3">Itens na Solicitação</h3>
     <ul class="space-y-2 max-h-48 overflow-y-auto pr-2 border rounded-md p-3 bg-gray-50">
       {#each items as item, index (item.productId)}
         <li class="flex justify-between items-center bg-white p-3 rounded shadow-sm border">
           <div>
             <span class="font-medium text-gray-800">{item.productName}</span>
             <span class="text-sm text-gray-500 ml-2">({item.quantityRequested} {item.productUnit})</span>
           </div>
           <button 
             type="button" 
             on:click={() => removeItem(index)} 
             class="text-red-500 hover:text-red-700 p-1 rounded hover:bg-red-100"
             aria-label="Remover item"
            >
             <Trash2 class="w-4 h-4"/>
           </button>
         </li>
       {/each}
     </ul>
   </div>
   {/if}

  <div class="mt-8 flex justify-end space-x-3 border-t pt-6">
    <button 
      type="button" 
      on:click={() => dispatch('cancel')} 
      class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded-lg hover:bg-gray-300 transition"
    >
      Cancelar
    </button>
    <button 
      type="submit" 
      class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition"
      disabled={items.length === 0} >
      Enviar Solicitação
    </button>
  </div>
</form>