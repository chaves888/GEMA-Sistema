<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import ProductForm from '$lib/components/ProductForm.svelte';
  import { session } from '$lib/sessionStore';

  type Product = { 
    id: string; 
    name: string; 
    unit: string; 
    minStock: number;
  };
  
  let products: Product[] = [];
  let isLoading = true;
  let error: string | null = null;
  let showModal = false;
  let isEditing = false;
  let currentProduct: any = {};

  onMount(async () => {
    try {
      products = await api.get('products');
    } catch (e) {
      error = 'Não foi possível carregar os produtos.';
      console.error(e);
    } finally {
      isLoading = false;
    }
  });

  function openAddModal() {
    isEditing = false;
    currentProduct = { name: '', unit: 'UN', minStock: 0 };
    showModal = true;
  }

  function openEditModal(product: Product) {
    isEditing = true;
    currentProduct = { ...product };
    showModal = true;
  }

  async function handleSave(event: any) {
    const productToSave = event.detail;
    try {
      if (isEditing) {
        const updatedProduct = await api.patch(`products/${productToSave.id}`, productToSave);
        products = products.map(p => p.id === updatedProduct.id ? updatedProduct : p);
      } else {
        const newProduct = await api.post('products', productToSave);
        products = [...products, newProduct];
      }
      showModal = false;
    } catch (e: any) {
      if (e && e.message) { 
        alert(`Erro: ${e.message}`); 
      } else { 
        alert('Erro ao salvar o produto.'); 
      }
      console.error(e);
    }
  }

  async function deleteProduct(productId: string, productName: string) {
    if (!confirm(`Tem certeza que deseja excluir o produto "${productName}"?`)) return;
    try {
      await api.del(`products/${productId}`);
      products = products.filter(p => p.id !== productId);
    } catch (e: any) {
      if (e && e.message) { alert(`Erro: ${e.message}`); }
      else { alert('Falha ao excluir o produto.'); }
      console.error(e);
    }
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 py-10 px-6 space-y-8 animate-fadeIn">

  <!-- 🔹 Cabeçalho -->
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-6 rounded-xl shadow-sm border border-gray-100">
    <div>
      <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Gerenciamento de Produtos
      </h1>
      <p class="text-gray-600 mt-1 text-sm">Adicione, edite e remova produtos do sistema com facilidade.</p>
    </div>

    {#if $session?.profile === 'prefeitura'}
      <button 
        on:click={openAddModal}
        class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95"
      >
        <span class="text-lg">＋</span> Novo Produto
      </button>
    {/if}
  </div>

  <!-- 🔸 Conteúdo -->
  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando produtos...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">{error}</div>
  {:else if products.length === 0}
    <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300">
      <p class="text-gray-600 font-semibold text-lg">Nenhum produto encontrado.</p>
      <p class="text-sm text-gray-400 mt-2">Clique em “Novo Produto” para adicionar o primeiro.</p>
    </div>
  {:else}
    <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gradient-to-r from-gray-50 to-gray-100">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Nome</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Unidade</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Estoque Mínimo</th>
            {#if $session?.profile === 'prefeitura'}
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">Ações</th>
            {/if}
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-100">
          {#each products as product (product.id)}
            <tr class="hover:bg-primary-50/40 transition-all duration-150">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800">{product.name}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{product.unit}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{product.minStock}</td>
              {#if $session?.profile === 'prefeitura'}
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4">
                  <button on:click={() => openEditModal(product)} class="text-primary-600 hover:text-primary-800 transition-colors">Editar</button>
                  <button on:click={() => deleteProduct(product.id, product.name)} class="text-red-600 hover:text-red-800 transition-colors">Excluir</button>
                </td>
              {/if}
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<!-- 🔹 Modal -->
<Modal show={showModal} on:close={() => showModal = false}>
  <ProductForm bind:product={currentProduct} {isEditing} on:save={handleSave} on:cancel={() => showModal = false} />
</Modal>

<style>
  @keyframes fadeIn {
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
  }

  .animate-fadeIn {
    animation: fadeIn 0.25s ease-out;
  }

  th:first-child {
    border-top-left-radius: 1rem;
  }

  th:last-child {
    border-top-right-radius: 1rem;
  }
</style>
