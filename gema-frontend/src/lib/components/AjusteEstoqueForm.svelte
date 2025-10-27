<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let item: {
    product: { id: string; name: string; unit: string };
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

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <div class="border-b pb-4">
    <h2 class="text-3xl font-bold text-gray-800">Ajustar Estoque</h2>
    <p class="text-gray-600 mt-2">
      Produto: <span class="font-semibold">{item.product.name} ({item.product.unit})</span>
    </p>
  </div>

  <div>
    <label for="quantity" class="block text-sm font-semibold text-gray-700 mb-1">Nova Quantidade</label>
    <input
      type="number"
      id="quantity"
      step="0.01"
      min="0"
      class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
      bind:value={newQuantity}
      required
    />
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
      Salvar Ajuste
    </button>
  </div>
</form>