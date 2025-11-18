<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { toast } from '$lib/toast';
  import { fade } from 'svelte/transition';

  export let item: {
    product: { id: string; name: string; unit: string };
    quantity: number;
  };

  const currentQuantity = item.quantity;
  let newQuantity = item.quantity;
  let motivoCategoria = '';
  let motivoObservacao = '';

  const dispatch = createEventDispatcher();

  $: isReduction = newQuantity < currentQuantity;
  $: if (motivoCategoria !== 'outro') {
    motivoObservacao = '';
  }

  function handleSubmit() {
    if (isReduction) {
      if (!motivoCategoria) {
        toast.error('Selecione um motivo para a redução.');
        return;
      }
      if (motivoCategoria === 'outro' && (!motivoObservacao || motivoObservacao.trim() === '')) {
        toast.error('A observação é obrigatória para o motivo "Outro".');
        return;
      }
    }
    dispatch('save', {
      productId: item.product.id,
      newQuantity: newQuantity,
      motivoCategoria: motivoCategoria || undefined,
      motivoObservacao: motivoObservacao.trim() || undefined,
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="flex flex-col h-full">
  <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-6">
    <h2 class="text-xl md:text-2xl font-bold text-gray-800 dark:text-white">Ajustar Estoque</h2>
    <p class="text-gray-600 dark:text-gray-400 mt-1 text-sm md:text-base">
      Produto: <span class="font-semibold text-gray-900 dark:text-gray-200">{item.product.name} ({item.product.unit})</span>
    </p>
    <p class="text-xs md:text-sm text-gray-500 dark:text-gray-400 mt-1">
      Quantidade Atual: <span class="font-bold text-gray-700 dark:text-gray-300">{currentQuantity}</span>
    </p>
  </div>

  <div class="space-y-5 flex-1 overflow-y-auto pr-1">
    <div>
      <label for="quantity" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Nova Quantidade</label>
      <input
        type="number"
        id="quantity"
        required
        step="0.01"
        min="0"
        bind:value={newQuantity}
        class="w-full px-4 py-3 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm text-lg placeholder-gray-400 dark:placeholder-gray-400"
      />
    </div>

    {#if isReduction}
      <div class="space-y-4 rounded-md border border-red-200 dark:border-red-800 bg-red-50 dark:bg-red-900/20 p-4" transition:fade>
        <div>
          <label for="motivoCategoria" class="block text-sm font-semibold text-red-700 dark:text-red-400 mb-1">Motivo da Redução (Obrigatório)</label>
          <select
            id="motivoCategoria"
            bind:value={motivoCategoria}
            required
            class="w-full px-4 py-2.5 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-red-500 focus:ring-2 focus:ring-red-300 transition-all shadow-sm"
          >
            <option value="" disabled>Selecione um motivo...</option>
            <option value="perda">Perda / Avaria</option>
            <option value="uso_interno">Uso Interno</option>
            <option value="vencimento">Vencimento</option>
            <option value="ajuste">Ajuste de contagem</option>
            <option value="outro">Outro</option>
          </select>
        </div>

        {#if motivoCategoria === 'outro'}
          <div transition:fade>
            <label for="motivoObservacao" class="block text-sm font-semibold text-red-700 dark:text-red-400 mb-1">Observação (Obrigatório)</label>
            <textarea
              id="motivoObservacao"
              rows="3"
              bind:value={motivoObservacao}
              placeholder="Descreva o motivo da redução..."
              class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-red-500 focus:ring-2 focus:ring-red-300 transition-all shadow-sm placeholder-gray-400 dark:placeholder-gray-400"
              required
            />
          </div>
        {/if}
      </div>
    {/if}
  </div>

  <div class="mt-8 flex flex-col-reverse sm:flex-row justify-end gap-3 border-t border-gray-200 dark:border-gray-700 pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="w-full sm:w-auto px-5 py-2.5 rounded-xl border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition-all"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold transition-all shadow-sm active:scale-95"
    >
      Salvar Ajuste
    </button>
  </div>
</form>