<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let item: { 
    product: { id: string; name: string; unit: string; }; 
    quantity: number; 
  };

  let newQuantity = item.quantity;

  const dispatch = createEventDispatcher();

  function handleSubmit() {
    dispatch('save', {
      productId: item.product.id,
      quantity: newQuantity,
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <h2 class="text-2xl font-bold mb-2">Ajustar Estoque</h2>
  <p class="text-gray-600 mb-6">
    Produto: <span class="font-semibold">{item.product.name} ({item.product.unit})</span>
  </p>

  <div class="space-y-4">
    <div>
      <label for="quantity" class="block text-sm font-medium text-gray-700">Nova Quantidade</label>
      <input 
        type="number" 
        id="quantity" 
        step="0.01" 
        min="0"
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" 
        bind:value={newQuantity} 
        required
      >
    </div>
  </div>

  <div class="mt-8 flex justify-end space-x-3">
    <button type="button" on:click={() => dispatch('cancel')} class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded hover:bg-gray-300">
      Cancelar
    </button>
    <button type="submit" class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded">
      Salvar Ajuste
    </button>
  </div>
</form>