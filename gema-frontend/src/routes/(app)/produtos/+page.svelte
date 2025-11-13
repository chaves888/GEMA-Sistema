<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import ProductForm from '$lib/components/ProductForm.svelte';
  import { session } from '$lib/sessionStore';
  import { toast } from '$lib/toast';

  // 1. IMPORTAMOS O NOVO DIÁLOGO DE CONFIRMAÇÃO E O ÍCONE DE BUSCA
  import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';
  import { Search } from 'lucide-svelte';

  // --- TIPO Product ATUALIZADO ---
  type Product = {
    id: string;
    name: string;
    unit: string;
    minStockPrefeitura: number; // Campo atualizado
    minStockEscola: number; // Campo atualizado
  };
  // --- FIM ATUALIZAÇÃO ---

  let products: Product[] = [];
  let isLoading = true;
  let error: string | null = null;

  // --- 2. ADICIONAR ESTADO PARA O FILTRO ---
  let searchTerm = '';

  // --- 3. ADICIONAR LISTA FILTRADA REATIVA ---
  $: filteredProducts = products.filter((product) => {
    return (
      searchTerm.trim() === '' ||
      product.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
  });

  // Estado do Modal de Edição/Criação
  let showModal = false;
  let isEditing = false;
  let currentProduct: {
    id?: string;
    name: string;
    unit: string;
    minStockPrefeitura: number;
    minStockEscola: number;
  } = { name: '', unit: 'UN', minStockPrefeitura: 0, minStockEscola: 0 };

  // 2. ADICIONAMOS ESTADO PARA O MODAL DE CONFIRMAÇÃO
  let showConfirmModal = false;
  let productToDelete: Product | null = null;
  let confirmMessage = '';

  onMount(async () => {
    try {
      // A API já deve retornar os novos campos minStock
      products = await api.get('products');
    } catch (e: any) {
      // Adicionado tipo 'any'
      error = e?.message || 'Não foi possível carregar os produtos.'; // Mensagem de erro atualizada
      console.error(e);
    } finally {
      isLoading = false;
    }
  });

  function openAddModal() {
    isEditing = false;
    // --- ATUALIZADO: Define valores padrão para os novos campos ---
    currentProduct = { name: '', unit: 'UN', minStockPrefeitura: 0, minStockEscola: 0 };
    // --- FIM ATUALIZAÇÃO ---
    showModal = true;
  }

  function openEditModal(product: Product) {
    isEditing = true;
    // --- ATUALIZADO: Passa os novos campos para edição ---
    currentProduct = { ...product }; // Copia todos os campos, incluindo os novos minStock
    // --- FIM ATUALIZAÇÃO ---
    showModal = true;
  }

  async function handleSave(event: any) {
    const productToSave = event.detail;

    // Validação de espaços
    const trimmedName = productToSave.name ? productToSave.name.trim() : '';
    if (trimmedName === '') {
      toast.error('O nome do produto não pode estar vazio ou conter apenas espaços.');
      return;
    }
    productToSave.name = trimmedName;

    try {
      if (isEditing) {
        const updatedProduct = await api.patch(
          `products/${productToSave.id}`,
          productToSave
        );
        products = products.map((p) =>
          p.id === updatedProduct.id ? updatedProduct : p
        );

        toast.success('Produto atualizado com sucesso!');
      } else {
        const newProduct = await api.post('products', productToSave);
        products = [...products, newProduct];
        products.sort((a, b) => a.name.localeCompare(b.name));

        toast.success('Produto criado com sucesso!');
      }
      showModal = false;
    } catch (e: any) {
      if (e && e.message) {
        toast.error(`Erro: ${e.message}`);
      } else {
        toast.error('Erro ao salvar o produto.');
      }
      console.error(e);
    }
  }

  // 3. ESTA FUNÇÃO AGORA APENAS ABRE O MODAL
  function openConfirmDeleteModal(product: Product) {
    productToDelete = product;
    confirmMessage = `Tem certeza que deseja excluir o produto "${product.name}"? Esta ação não pode ser desfeita.`;
    showConfirmModal = true;
  }

  // 4. ESTA FUNÇÃO EXECUTA A EXCLUSÃO (é chamada pelo modal)
  async function handleConfirmDelete() {
    if (!productToDelete) return;

    const idToDelete = productToDelete.id;

    // Fecha o modal e limpa o estado
    showConfirmModal = false;
    productToDelete = null;

    try {
      await api.del(`products/${idToDelete}`);
      products = products.filter((p) => p.id !== idToDelete);
      toast.success('Produto excluído com sucesso!');
    } catch (e: any) {
      const errorMessage = e?.message || 'Falha ao excluir o produto.';
      toast.error(errorMessage);
      console.error(e);
    }
  }

  // 5. FUNÇÃO PARA CANCELAR A EXCLUSÃO
  function onCancelDelete() {
    showConfirmModal = false;
    productToDelete = null;
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-6 space-y-6 animate-fadeIn">
  <div
    class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border"
  >
    <div>
      <h1
        class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent"
      >
        Gerenciamento de Produtos
      </h1>
      <p class="text-gray-600 mt-1 text-sm">Adicione, edite e remova produtos do sistema.</p>
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

  <div
    class="bg-white/80 backdrop-blur-md p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col md:flex-row flex-wrap gap-4"
  >
    <div class="flex-1 min-w-[250px]">
      <label for="searchTerm" class="block text-sm font-medium text-gray-700">Buscar por Nome</label>
      <div class="relative mt-1">
        <input
          type="text"
          id="searchTerm"
          bind:value={searchTerm}
          placeholder="Digite o nome do produto..."
          class="block w-full py-2 px-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pl-10"
        />
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Search class="w-5 h-5 text-gray-400" />
        </div>
      </div>
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
  {:else if products.length === 0}
    <div
      class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300"
    >
      <p class="text-gray-600 font-semibold text-lg">Nenhum produto.</p>
      <p class="text-sm text-gray-400 mt-2">Clique em “Novo Produto” para adicionar.</p>
    </div>
  {:else if filteredProducts.length === 0}
    <div
      class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300"
    >
      <p class="text-gray-600 font-semibold text-lg">Nenhum produto encontrado.</p>
      <p class="text-sm text-gray-400 mt-2">Tente ajustar o filtro de busca.</p>
    </div>
  {:else}
    <div
      class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 overflow-x-auto"
    >
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gradient-to-r from-gray-50 to-gray-100">
          <tr>
            <th
              class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
              >Nome</th
            >
            <th
              class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
              >Unidade</th
            >
            <th
              class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
              >Mín. Prefeitura</th
            >
            <th
              class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
              >Mín. Escola</th
            >
            {#if $session?.profile === 'prefeitura'}
              <th
                class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Ações</th
              >
            {/if}
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-100">
          {#each filteredProducts as product (product.id)}
            <tr class="hover:bg-primary-50/40 transition-all duration-150">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800"
                >{product.name}</td
              >
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600"
                >{product.unit}</td
              >
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600"
                >{product.minStockPrefeitura}</td
              >
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600"
                >{product.minStockEscola}</td
              >
              {#if $session?.profile === 'prefeitura'}
                <td
                  class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4"
                >
                  <button
                    on:click={() => openEditModal(product)}
                    class="text-primary-600 hover:text-primary-800 transition-colors"
                    >Editar</button
                  >
                  <button
                    on:click={() => openConfirmDeleteModal(product)}
                    class="text-red-600 hover:text-red-800 transition-colors"
                    >Excluir</button
                  >
                </td>
              {/if}
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<Modal show={showModal} on:close={() => (showModal = false)} size="max-w-lg">
  <ProductForm
    bind:product={currentProduct}
    {isEditing}
    on:save={handleSave}
    on:cancel={() => (showModal = false)}
  />
</Modal>

<Modal show={showConfirmModal} on:close={onCancelDelete} size="max-w-md">
  <ConfirmDialog
    title="Excluir Produto"
    message={confirmMessage}
    confirmText="Sim, Excluir"
    on:confirm={handleConfirmDelete}
    on:cancel={onCancelDelete}
  />
</Modal>

<style>
  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: scale(0.98);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
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