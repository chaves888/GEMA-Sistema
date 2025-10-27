<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Solicitacao } from '$lib/types';
  import { format } from 'date-fns';

  export let solicitacao: Solicitacao;

  let observacaoPrefeitura: string = solicitacao.observacaoPrefeitura || '';

  let itemsAnalisados = solicitacao.items.map(item => ({
    itemId: item.id,
    productName: item.product.name,
    productUnit: item.product.unit,
    quantityRequested: item.quantityRequested,
    quantityApproved: item.quantityApproved ?? item.quantityRequested,
  }));

  const dispatch = createEventDispatcher();

  function handleSubmit() {
    let finalStatus: 'aprovado' | 'aprovado_parcialmente' | 'negado';

    const totalRequested = itemsAnalisados.reduce((sum, item) => sum + item.quantityRequested, 0);
    const totalApproved = itemsAnalisados.reduce((sum, item) => sum + (item.quantityApproved ?? 0), 0);

    const invalidItems = itemsAnalisados.filter(
      item => (item.quantityApproved ?? 0) > item.quantityRequested
    );
    if (invalidItems.length > 0) {
      alert(
        `Erro: A quantidade aprovada para "${invalidItems[0].productName}" não pode ser maior que a solicitada.`
      );
      return;
    }

    if (totalApproved <= 0) {
      finalStatus = 'negado';
    } else if (totalApproved < totalRequested) {
      finalStatus = 'aprovado_parcialmente';
    } else {
      finalStatus = 'aprovado';
    }

    dispatch('save', {
      status: finalStatus,
      observacaoPrefeitura: observacaoPrefeitura || undefined,
      items: itemsAnalisados.map(item => ({
        itemId: item.itemId,
        quantityApproved: item.quantityApproved ?? 0,
      })),
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <div class="border-b pb-4 mb-4">
    <h2 class="text-3xl font-bold text-gray-800">Analisar Solicitação</h2>
    <p class="text-sm text-gray-600 mt-2">Escola: <span class="font-semibold">{solicitacao.school.name}</span></p>
    <p class="text-sm text-gray-600">Data: {format(new Date(solicitacao.createdAt), 'dd/MM/yyyy')}</p>
    {#if solicitacao.justificativa}
      <p class="text-sm text-gray-700 mt-3 bg-gray-50 p-3 border rounded-lg shadow-inner">
        <span class="font-semibold">Justificativa:</span>
        <span class="italic">“{solicitacao.justificativa}”</span>
      </p>
    {/if}
  </div>

  <div>
    <h3 class="text-lg font-semibold text-gray-800 mb-3">Itens Solicitados</h3>
    {#if itemsAnalisados.length === 0}
      <p class="text-sm text-gray-500 italic">Esta solicitação não contém itens.</p>
    {:else}
      <div class="space-y-4 max-h-60 overflow-y-auto pr-2 border rounded-lg p-4 bg-gray-50 shadow-inner">
        {#each itemsAnalisados as item, index (item.itemId)}
          <div class="grid grid-cols-5 gap-4 items-center border-b pb-4 last:border-b-0">
            <div class="col-span-2">
              <span class="font-semibold text-gray-800 block">{item.productName}</span>
              <span class="text-xs text-gray-500">Unidade: {item.productUnit}</span>
            </div>
            <div class="col-span-1 text-center">
              <!-- svelte-ignore a11y-label-has-associated-control -->
              <label class="block text-xs font-semibold text-gray-500 mb-1">Solicitado</label>
              <span class="font-bold text-gray-700 text-lg">{item.quantityRequested}</span>
            </div>
            <div class="col-span-2">
              <label for={`approved-${index}`} class="block text-sm font-semibold text-gray-700 mb-1">Aprovado</label>
              <input
                type="number"
                step="0.01"
                min="0"
                max={item.quantityRequested}
                id={`approved-${index}`}
                bind:value={item.quantityApproved}
                class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
                required
              />
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>

  <div>
    <label for="observacao" class="block text-sm font-semibold text-gray-700 mb-1">Observações da Prefeitura (Opcional)</label>
    <textarea
      id="observacao"
      rows="3"
      class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
      bind:value={observacaoPrefeitura}
      placeholder="Ex: Item X indisponível no momento, entrega parcial..."
    ></textarea>
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
      disabled={itemsAnalisados.length === 0}
    >
      Salvar Análise
    </button>
  </div>
</form>