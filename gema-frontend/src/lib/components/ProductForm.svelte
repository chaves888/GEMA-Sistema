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
    minStock: 0
  };

  export let isEditing = false;
  
  const dispatch = createEventDispatcher();

  function handleSubmit() {
    dispatch('save', product);
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <h2 class="text-2xl font-bold mb-6">
    {isEditing ? 'Editar Produto' : 'Adicionar Novo Produto'}
  </h2>

  <div class="space-y-4">
    <div>
      <label for="name" class="block text-sm font-medium text-gray-700">Nome do Produto</label>
      <input type="text" id="name" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={product.name} required>
    </div>
    
    <div>
      <label for="unit" class="block text-sm font-medium text-gray-700">Unidade de Medida</label>
      <select id="unit" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={product.unit} required>
        <option value="KG">Quilograma (KG)</option>
        <option value="G">Grama (G)</option>
        <option value="L">Litro (L)</option>
        <option value="ML">Mililitro (ML)</option>
        <option value="UN">Unidade (UN)</option>
      </select>
    </div>

    <div>
      <label for="minStock" class="block text-sm font-medium text-gray-700">Estoque Mínimo Global</label>
      <input 
        type="number" 
        id="minStock" 
        step="0.01"
        min="0"
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" 
        bind:value={product.minStock} 
        required
      >
      <p class="mt-1 text-xs text-gray-500">Define o nível para o alerta de estoque crítico.</p>
    </div>
  </div>

  <div class="mt-8 flex justify-end space-x-3">
    <button type="button" on:click={() => dispatch('cancel')} class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded hover:bg-gray-300">
      Cancelar
    </button>
    <button type="submit" class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded">
      Salvar
    </button>
  </div>
</form>