<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';
  import type { Product, Refeicao } from '$lib/types';
  import { Search } from 'lucide-svelte';
  // +++ ADICIONADO: Importar o toast +++
  import { toast } from '$lib/toast';

  export let cardapioId: string;
  export let diaSemana: 'segunda' | 'terça' | 'quarta' | 'quinta' | 'sexta';
  export let tipo: 'manha' | 'tarde';
  export let refeicao: Refeicao | null = null;

  let description = refeicao?.description || '';
  let selectedProductIds: string[] = refeicao?.products.map((p) => p.id) || [];

  let allProducts: Product[] = [];
  let filteredProducts: Product[] = [];
  let search = '';
  let isLoadingProducts = true;
  let isSaving = false;

  const dispatch = createEventDispatcher();

  onMount(async () => {
    try {
      allProducts = await api.get('products');
      filteredProducts = allProducts;
    } catch (e) {
      console.error('Erro ao carregar produtos:', e);
      // +++ ALTERADO: 'alert' por 'toast.error' +++
      toast.error('Não foi possível carregar a lista de produtos.');
    } finally {
      isLoadingProducts = false;
    }
  });

  $: filteredProducts = allProducts.filter((p) =>
    p.name.toLowerCase().includes(search.toLowerCase())
  );

  function toggleProduct(id: string) {
    if (selectedProductIds.includes(id)) {
      selectedProductIds = selectedProductIds.filter((pid) => pid !== id);
    } else {
      selectedProductIds = [...selectedProductIds, id];
    }
  }

  async function handleSubmit() {
    if (isSaving || isLoadingProducts) return;

    // --- NOVA VALIDAÇÃO (Nome do Prato) ---
    const trimmedDescription = description.trim();
    if (trimmedDescription === '') {
      toast.error('Por favor, informe o nome do prato (descrição).');
      return;
    }
    // Salva a versão "limpa"
    description = trimmedDescription;
    // --- FIM DA VALIDAÇÃO ---

    // --- VALIDAÇÃO DE PRODUTOS ---
    if (selectedProductIds.length === 0) {
      // +++ ALTERADO: 'alert' por 'toast.error' +++
      toast.error('Selecione pelo menos um produto para esta refeição.');
      return;
    }

    isSaving = true;
    const dto = { diaSemana, tipo, description, productIds: selectedProductIds };

    try {
      // NOTA: A lógica de edição/criação estava apontando para o mesmo endpoint POST.
      // O ideal seria ter um endpoint PATCH para edição.
      // Vou manter a lógica de chamar o POST, mas saiba que o backend
      // precisa lidar com "upsert" (criar ou atualizar).
      let savedRefeicao;
      if (refeicao && refeicao.id) {
        // Se a API suportar PATCH (edição)
        // savedRefeicao = await api.patch(`cardapios/refeicoes/${refeicao.id}`, dto);
        
        // Se a API suportar POST para criar/editar (Upsert)
        savedRefeicao = await api.post(`cardapios/${cardapioId}/refeicoes`, dto);
      } else {
        savedRefeicao = await api.post(`cardapios/${cardapioId}/refeicoes`, dto);
      }

      dispatch('save', savedRefeicao);
    } catch (e: any) {
      // +++ ALTERADO: 'alert' por 'toast.error' +++
      toast.error(e?.message || 'Erro ao salvar a refeição.');
      console.error(e);
    } finally {
      isSaving = false;
    }
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <div class="border-b pb-4 mb-6">
    <h2 class="text-3xl font-bold text-gray-800">
      {refeicao ? 'Editar Refeição' : 'Adicionar Refeição'}
    </h2>
    <p class="text-gray-500 capitalize mt-1">
      {diaSemana} - {tipo === 'manha' ? 'Manhã' : 'Tarde'}
    </p>
  </div>

  <div class="mb-6">
    <label for="description" class="block text-sm font-semibold text-gray-700 mb-1">
      Nome do Prato (Descrição)
    </label>
    <input
      id="description"
      type="text"
      class="w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
      bind:value={description}
      placeholder="Ex: Arroz, feijão e frango desfiado"
      required
    />
  </div>

  <div class="mb-8">
    <!-- svelte-ignore a11y-label-has-associated-control -->
    <label class="block text-sm font-semibold text-gray-700 mb-2">
      Selecione os Produtos Utilizados
    </label>

    {#if isLoadingProducts}
      <div
        class="mt-1 w-full rounded-lg border border-gray-300 bg-gray-100 text-center py-3 text-gray-500"
      >
        Carregando produtos...
      </div>
    {:else}
      <div class="relative mb-3">
        <Search class="absolute left-3 top-2.5 w-5 h-5 text-gray-400" />
        <input
          type="text"
          placeholder="Buscar produto..."
          class="w-full pl-10 pr-3 py-2 rounded-lg border border-gray-300 shadow-sm focus:ring-primary-400 focus:border-primary-500"
          bind:value={search}
        />
      </div>

      <div class="border border-gray-200 rounded-lg max-h-60 overflow-y-auto p-3 space-y-2">
        {#if filteredProducts.length === 0}
          <p class="text-gray-500 text-sm text-center py-4">Nenhum produto encontrado.</p>
        {:else}
          {#each filteredProducts as product (product.id)}
            <label
              class="flex items-center space-x-3 p-2 rounded-lg hover:bg-gray-50 cursor-pointer transition"
            >
              <input
                type="checkbox"
                value={product.id}
                checked={selectedProductIds.includes(product.id)}
                on:change={() => toggleProduct(product.id)}
                class="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
              />
              <span class="text-sm text-gray-700"
                >{product.name} <span class="text-gray-400">({product.unit})</span></span
              >
            </label>
          {/each}
        {/if}
      </div>
    {/if}
  </div>

  <div class="flex justify-end space-x-4 border-t pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm"
      disabled={isSaving}
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105 disabled:opacity-50"
      disabled={isSaving || isLoadingProducts}
    >
      {isSaving ? 'Salvando...' : refeicao ? 'Salvar Alterações' : 'Adicionar'}
    </button>
  </div>
</form>

<style>
  .max-h-60::-webkit-scrollbar {
    width: 6px;
  }
  .max-h-60::-webkit-scrollbar-thumb {
    background-color: rgba(0, 0, 0, 0.2);
    border-radius: 3px;
  }
</style>