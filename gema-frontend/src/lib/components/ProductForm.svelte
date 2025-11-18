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

<form on:submit|preventDefault={handleSubmit} class="h-full flex flex-col">
  <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-6">
    <h2 class="text-2xl lg:text-3xl font-bold text-gray-800 dark:text-white">
      {isEditing ? 'Editar Produto' : 'Novo Produto'}
    </h2>
  </div>

  <div class="space-y-5 flex-1 overflow-y-auto pr-1">
    <div>
      <label for="name" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Nome do Produto</label>
      <input
        type="text"
        id="name"
        required
        bind:value={product.name}
        class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm placeholder-gray-400 dark:placeholder-gray-400"
      />
    </div>

    <div>
      <label for="unit" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Unidade de Medida</label>
      <select
        id="unit"
        required
        bind:value={product.unit}
        class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
      >
        <option value="UN">Unidade (UN)</option>
      </select>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <label for="minStockPrefeitura" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Estoque Mín. Prefeitura</label>
        <input
          type="number"
          id="minStockPrefeitura"
          required
          step="0.01"
          min="0"
          bind:value={product.minStockPrefeitura}
          class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
        />
        <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">Nível crítico no estoque central.</p>
      </div>

      <div>
        <label for="minStockEscola" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Estoque Mín. Escola</label>
        <input
          type="number"
          id="minStockEscola"
          required
          step="0.01"
          min="0"
          bind:value={product.minStockEscola}
          class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
        />
        <p class="mt-1 text-xs text-gray-500 dark:text-gray-400">Nível crítico no estoque das escolas.</p>
      </div>
    </div>
  </div>

  <div class="mt-8 flex flex-col-reverse sm:flex-row justify-end gap-3 sm:gap-3 border-t border-gray-200 dark:border-gray-700 pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="w-full sm:w-auto px-5 py-2 rounded-xl border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition-all"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="w-full sm:w-auto px-5 py-2 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-semibold transition-all shadow-sm"
    >
      Salvar
    </button>
  </div>
</form>