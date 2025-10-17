<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import ProductForm from '$lib/components/ProductForm.svelte';
  import { session } from '$lib/sessionStore';

  // 1. TIPO ATUALIZADO (SEM createdAt)
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
      // 2. ALERTA INTELIGENTE (COMO NOS USUÁRIOS)
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

<div class="space-y-6">
  <div class="flex justify-between items-center">
    <h1 class="text-3xl font-bold text-gray-800">Gerenciamento de Produtos</h1>
    {#if $session?.profile === 'prefeitura'}
      <button on:click={openAddModal} class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded-lg shadow-md transition-transform hover:scale-105">
        + Adicionar Produto
      </button>
    {/if}
  </div>

  {#if isLoading}
    <p class="text-gray-500">Carregando produtos...</p>
  {:else if error}
    <p class="text-red-500">{error}</p>
  {:else}
    <div class="bg-white shadow-md rounded-lg overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nome</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Unidade</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estoque Mínimo</th>
            <!-- 3. COLUNA "CRIADO EM" REMOVIDA -->
            {#if $session?.profile === 'prefeitura'}
              <th scope="col" class="relative px-6 py-3"><span class="sr-only">Ações</span></th>
            {/if}
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          {#each products as product (product.id)}
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{product.name}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{product.unit}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{product.minStock}</td>
              <!-- 4. CÉLULA "CRIADO EM" REMOVIDA -->
              {#if $session?.profile === 'prefeitura'}
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4">
                  <button on:click={() => openEditModal(product)} class="text-primary-600 hover:text-primary-900">Editar</button>
                  <button on:click={() => deleteProduct(product.id, product.name)} class="text-red-600 hover:text-red-900">Excluir</button>
                </td>
              {/if}
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<Modal show={showModal} on:close={() => showModal = false}>
  <ProductForm bind:product={currentProduct} {isEditing} on:save={handleSave} on:cancel={() => showModal = false} />
</Modal>
