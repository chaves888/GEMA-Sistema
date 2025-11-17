<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Solicitacao } from '$lib/types';
  import { format } from 'date-fns';
  import { toast } from '$lib/toast';

  export let solicitacao: Solicitacao;

  let observacaoPrefeitura: string = solicitacao.observacaoPrefeitura || '';

  // --- CORREÇÃO (Soft Delete) ---
  let itemsAnalisados = solicitacao.items
    .filter((item) => item.product)
    .map((item) => ({
      itemId: item.id,
      productName: item.product.name,
      productUnit: item.product.unit,
      quantityRequested: item.quantityRequested,
      quantityApproved: item.quantityApproved ?? item.quantityRequested,
    }));

  const itemsRemovidos = solicitacao.items.filter((item) => !item.product);
  // --- FIM DA CORREÇÃO ---

  const dispatch = createEventDispatcher();
  let isNegando = false;

  $: totalApproved = itemsAnalisados.reduce(
    (sum, item) => sum + (Number(item.quantityApproved) || 0),
    0
  );

  function handleSubmit() {
    if (!isNegando) {
      const invalidItems = itemsAnalisados.filter(
        (item) => (item.quantityApproved ?? 0) > item.quantityRequested
      );
      if (invalidItems.length > 0) {
        toast.error(
          `Erro: A quantidade aprovada para "${invalidItems[0].productName}" não pode ser maior que a solicitada.`
        );
        return;
      }

      const hasZeroItem = itemsAnalisados.some((item) => (item.quantityApproved ?? 0) === 0);
      if (hasZeroItem && !observacaoPrefeitura) {
        toast.error('Observação é obrigatória se a quantidade de algum item for 0.');
        return;
      }

      let finalStatus: 'aprovado' | 'aprovado_parcialmente' | 'negado';

      if (totalApproved <= 0) {
        finalStatus = 'negado';
        if (!observacaoPrefeitura) {
          toast.error('Observação é obrigatória se nenhum item for aprovado.');
          return;
        }
      } else if (
        totalApproved < itemsAnalisados.reduce((sum, item) => sum + item.quantityRequested, 0)
      ) {
        finalStatus = 'aprovado_parcialmente';
      } else {
        finalStatus = 'aprovado';
      }

      dispatch('save', {
        status: finalStatus,
        observacaoPrefeitura: observacaoPrefeitura || undefined,
        items: itemsAnalisados.map((item) => ({
          itemId: item.itemId,
          quantityApproved: item.quantityApproved ?? 0,
        })),
      });
    } else {
      if (!observacaoPrefeitura) {
        toast.error('A observação é obrigatória para negar a solicitação.');
        return;
      }
      dispatch('save', {
        status: 'negado',
        observacaoPrefeitura: observacaoPrefeitura,
        items: [],
      });
    }
  }

  function handleNegar() {
    isNegando = true;
    handleSubmit();
  }

  function handleSalvarAnalise() {
    isNegando = false;
    handleSubmit();
  }
</script>

<form on:submit|preventDefault={handleSalvarAnalise} class="flex flex-col h-full">
  <div class="border-b pb-4 mb-4">
    <h2 class="text-2xl md:text-3xl font-bold text-gray-800">Analisar Solicitação</h2>
    <p class="text-sm text-gray-600 mt-2">
      Escola: <span class="font-semibold">{solicitacao.school?.name || '(Escola Excluída)'}</span>
    </p>
    <p class="text-sm text-gray-600">
      Data: {format(new Date(solicitacao.createdAt), 'dd/MM/yyyy')}
    </p>
    {#if solicitacao.justificativa}
      <div class="text-sm text-gray-700 mt-3 bg-gray-50 p-3 border rounded-lg shadow-inner">
        <span class="font-semibold block mb-1">Justificativa:</span>
        <span class="italic">“{solicitacao.justificativa}”</span>
      </div>
    {/if}
  </div>

  <div class="flex-1 overflow-y-auto pr-1">
    <h3 class="text-lg font-semibold text-gray-800 mb-3">Itens Solicitados</h3>
    {#if itemsAnalisados.length === 0 && itemsRemovidos.length === 0}
      <p class="text-sm text-gray-500 italic">Esta solicitação não contém itens.</p>
    {:else}
      <div class="space-y-4 border rounded-lg p-4 bg-gray-50 shadow-inner">
        {#if itemsRemovidos.length > 0}
          <div class="bg-red-50 border border-red-200 text-red-700 p-3 rounded-md text-sm mb-4">
            <p class="font-semibold">Atenção: {itemsRemovidos.length} item(ns) desta solicitação foram removidos do sistema e não podem ser analisados.</p>
          </div>
        {/if}

        <div class="divide-y divide-gray-200">
          {#each itemsAnalisados as item, index (item.itemId)}
            <div class="py-4 first:pt-0 last:pb-0 grid grid-cols-1 sm:grid-cols-12 gap-4 items-center">
              
              <div class="sm:col-span-5 md:col-span-6">
                <span class="font-semibold text-gray-800 block text-base">{item.productName}</span>
                <span class="text-xs text-gray-500 uppercase tracking-wide">Unidade: {item.productUnit}</span>
              </div>

              <div class="flex justify-between sm:block sm:col-span-3 md:col-span-2 text-left sm:text-center bg-white sm:bg-transparent p-2 sm:p-0 rounded border sm:border-0">
                <span class="text-xs font-semibold text-gray-500 sm:block mb-1">Solicitado</span>
                <span class="font-bold text-gray-700 text-lg">{item.quantityRequested}</span>
              </div>

              <div class="sm:col-span-4 md:col-span-4">
                <label for={`approved-${index}`} class="block text-xs font-semibold text-gray-700 mb-1">
                  Aprovado
                </label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  max={item.quantityRequested}
                  id={`approved-${index}`}
                  bind:value={item.quantityApproved}
                  class="w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-3 py-2 transition text-center font-medium text-gray-900"
                  required
                />
              </div>

            </div>
          {/each}
        </div>
      </div>
    {/if}

    <div class="mt-6">
      <label for="observacao" class="block text-sm font-semibold text-gray-700 mb-1">
        Observações da Prefeitura (Obrigatório se negar)
      </label>
      <textarea
        id="observacao"
        rows="3"
        class="w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
        bind:value={observacaoPrefeitura}
        placeholder="Ex: Item X indisponível no momento, entrega parcial..."
      />
    </div>
  </div>

  <div class="mt-8 flex flex-col-reverse sm:flex-row justify-between items-center gap-4 border-t pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="w-full sm:w-auto bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm"
    >
      Cancelar
    </button>

    <div class="flex flex-col sm:flex-row gap-3 w-full sm:w-auto">
      <button
        type="button"
        on:click={handleNegar}
        class="w-full sm:w-auto bg-red-100 text-red-700 hover:bg-red-200 border border-red-200 font-bold py-2.5 px-6 rounded-lg shadow-sm transition disabled:opacity-50"
        disabled={itemsAnalisados.length === 0}
      >
        Negar Solicitação
      </button>

      {#if totalApproved > 0}
        <button
          type="submit"
          class="w-full sm:w-auto bg-primary-600 hover:bg-primary-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105 disabled:opacity-50"
          disabled={itemsAnalisados.length === 0}
        >
          Aprovar Solicitação
        </button>
      {/if}
    </div>
  </div>
</form>