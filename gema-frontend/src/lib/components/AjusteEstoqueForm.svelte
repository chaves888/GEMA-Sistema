<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  // Propriedades recebidas (item de estoque)
  export let item: {
    product: { id: string; name: string; unit: string };
    quantity: number;
    // minStock NÃO é recebido aqui
  };

  // Estado local apenas para a nova quantidade
  let newQuantity = item.quantity;
  const dispatch = createEventDispatcher();

  function handleSubmit() {
    // Envia apenas o ID do produto e a nova quantidade
    dispatch('save', {
      productId: item.product.id,
      quantity: newQuantity,
      // minStock NÃO é enviado daqui
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <div class="border-b pb-4 mb-6">
    <h2 class="text-2xl font-bold text-gray-800">Ajustar Estoque</h2>
    <p class="text-gray-600 mt-1">
      Produto: <span class="font-semibold">{item.product.name} ({item.product.unit})</span>
    </p>
  </div>

  <div class="space-y-5">
    <div>
      <label for="quantity" class="block text-sm font-semibold text-gray-700 mb-1">Nova Quantidade</label>
      <input
        type="number" id="quantity" required step="0.01" min="0"
        bind:value={newQuantity}
        class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
      />
    </div>
    </div>

  <div class="mt-8 flex justify-end space-x-3 border-t pt-6">
    <button type="button" on:click={() => dispatch('cancel')} class="px-5 py-2 rounded-xl border border-gray-300 text-gray-700 font-semibold bg-gray-100 hover:bg-gray-200 transition-all">
      Cancelar
    </button>
    <button type="submit" class="px-5 py-2 rounded-xl bg-primary-600 text-white font-semibold hover:bg-primary-700 transition-all shadow-sm">
      Salvar Ajuste
    </button>
  </div>
</form> 