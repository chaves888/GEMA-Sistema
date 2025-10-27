<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let product: {
    id?: string;
    name: string;
    unit: string;
    minStock: number;
  } = {
    name: '',
    unit: 'UN',
    minStock: 0,
  };

  export let isEditing = false;
  const dispatch = createEventDispatcher();

  function handleSubmit() {
    dispatch('save', product);
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <h2 class="text-3xl font-bold text-gray-800 border-b pb-4">
    {isEditing ? 'Editar Produto' : 'Novo Produto'}
  </h2>

  <div class="space-y-5">
    <div>
      <label for="name" class="block text-sm font-semibold text-gray-700 mb-1">Nome do Produto</label>
      <input
        type="text"
        id="name"
        class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
        bind:value={product.name}
        required
      />
    </div>

    <div>
      <label for="unit" class="block text-sm font-semibold text-gray-700 mb-1">Unidade de Medida</label>
      <select
        id="unit"
        class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition bg-white"
        bind:value={product.unit}
        required
      >
        <option value="KG">Quilograma (KG)</option>
        <option value="G">Grama (G)</option>
        <option value="L">Litro (L)</option>
        <option value="ML">Mililitro (ML)</option>
        <option value="UN">Unidade (UN)</option>
      </select>
    </div>

    <div>
      <label for="minStock" class="block text-sm font-semibold text-gray-700 mb-1">Estoque Mínimo Global</label>
      <input
        type="number"
        id="minStock"
        step="0.01"
        min="0"
        class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
        bind:value={product.minStock}
        required
      />
      <p class="mt-1.5 text-xs text-gray-500">Define o nível para o alerta de estoque crítico.</p>
    </div>
  </div>

  <div class="mt-8 flex justify-end space-x-4 border-t pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105"
    >
      Salvar
    </button>
  </div>
</form>