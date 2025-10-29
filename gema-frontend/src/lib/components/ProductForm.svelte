<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  // --- ATUALIZAR TIPO AQUI ---
  export let product: {
    id?: string;
    name: string;
    unit: string;
    minStockPrefeitura: number; // Novo campo
    minStockEscola: number;     // Novo campo
  } = {
    name: '',
    unit: 'UN',
    minStockPrefeitura: 0, // Valor padrão
    minStockEscola: 0,     // Valor padrão
  };
  // --- FIM ATUALIZAÇÃO ---

  export let isEditing = false;
  const dispatch = createEventDispatcher();

  function handleSubmit() {
    dispatch('save', product);
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <div class="border-b pb-4 mb-6">
    <h2 class="text-2xl font-bold text-gray-800">
      {isEditing ? 'Editar Produto' : 'Novo Produto'}
    </h2>
  </div>

  <div class="space-y-5">
    <div>
      <label for="name" class="block text-sm font-semibold text-gray-700 mb-1">Nome do Produto</label>
      <input
        type="text" id="name" required bind:value={product.name}
        class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
      />
    </div>

    <div>
      <label for="unit" class="block text-sm font-semibold text-gray-700 mb-1">Unidade de Medida</label>
      <select
        id="unit" required bind:value={product.unit}
        class="w-full px-4 py-2 rounded-lg border border-gray-300 bg-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
      >
        <option value="L">Litro (L)</option>
        <option value="UN">Unidade (UN)</option>
      </select>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <label for="minStockPrefeitura" class="block text-sm font-semibold text-gray-700 mb-1">Estoque Mín. Prefeitura</label>
        <input
          type="number" id="minStockPrefeitura" required step="0.01" min="0"
          bind:value={product.minStockPrefeitura}
          class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
        />
         <p class="mt-1 text-xs text-gray-500">Nível crítico no estoque central.</p>
      </div>

       <div>
        <label for="minStockEscola" class="block text-sm font-semibold text-gray-700 mb-1">Estoque Mín. Escola (Padrão)</label>
        <input
          type="number" id="minStockEscola" required step="0.01" min="0"
          bind:value={product.minStockEscola}
          class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
        />
        <p class="mt-1 text-xs text-gray-500">Nível crítico no estoque das escolas.</p>
      </div>
    </div>
     </div>

  <div class="mt-8 flex justify-end space-x-3 border-t pt-6">
    <button type="button" on:click={() => dispatch('cancel')} class="px-5 py-2 rounded-xl border border-gray-300 text-gray-700 font-semibold bg-gray-100 hover:bg-gray-200 transition-all">
      Cancelar
    </button>
    <button type="submit" class="px-5 py-2 rounded-xl bg-primary-600 text-white font-semibold hover:bg-primary-700 transition-all shadow-sm">
      Salvar
    </button>
  </div>
</form>