<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Solicitacao } from '$lib/types';
  import { format } from 'date-fns';
  import { toast } from '$lib/toast';

  export let solicitacao: Solicitacao;

  let comDivergencia: boolean = false;
  let observacaoEscola: string = '';

  let itemsParaConfirmar = solicitacao.items
    .filter(
      (item) => item.product && item.quantityApproved && item.quantityApproved > 0
    )
    .map((item) => ({
      itemId: item.id,
      productName: item.product.name,
      productUnit: item.product.unit,
      quantityApproved: item.quantityApproved,
      quantityReceived: item.quantityReceived ?? item.quantityApproved,
    }));

  const itemsRemovidos = solicitacao.items.filter(
    (item) => !item.product && item.quantityApproved && item.quantityApproved > 0
  );

  const dispatch = createEventDispatcher();

  let hasQuantityDivergence = false;

  $: hasQuantityDivergence = itemsParaConfirmar.some(
    (item) => (item.quantityReceived ?? 0) !== (item.quantityApproved ?? 0)
  );

  $: if (hasQuantityDivergence) {
    comDivergencia = true;
  }

  function handleSubmit() {
    const invalidItems = itemsParaConfirmar.filter(
      (item) => (item.quantityReceived ?? 0) > (item.quantityApproved ?? 0)
    );
    if (invalidItems.length > 0) {
      toast.error('Erro: A quantidade recebida não pode ser maior que a quantidade aprovada.');
      return;
    }

    if (comDivergencia && !observacaoEscola) {
      toast.error('A observação é obrigatória ao receber com divergência.');
      return;
    }

    dispatch('save', {
      items: itemsParaConfirmar.map((item) => ({
        itemId: item.itemId,
        quantityReceived: item.quantityReceived ?? 0,
      })),
      comDivergencia: comDivergencia,
      observacaoEscola: comDivergencia ? observacaoEscola : undefined,
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="flex flex-col h-full">
  <div class="border-b pb-4 mb-4">
    <h2 class="text-2xl md:text-3xl font-bold text-gray-800">Confirmar Recebimento</h2>
    <p class="text-sm text-gray-600 mt-2">
      Escola: <span class="font-semibold">{solicitacao.school?.name || '(Escola Excluída)'}</span>
    </p>
    <p class="text-sm text-gray-600">
      Data da Solicitação: {format(new Date(solicitacao.createdAt), 'dd/MM/yyyy')}
    </p>
    {#if solicitacao.observacaoPrefeitura}
      <div class="text-sm text-gray-700 mt-3 bg-blue-50 p-3 border border-blue-200 rounded-lg shadow-inner">
        <span class="font-semibold text-blue-800 block mb-1">Observação da Prefeitura:</span>
        <span class="italic text-blue-700">“{solicitacao.observacaoPrefeitura}”</span>
      </div>
    {/if}
  </div>

  <div class="flex-1 overflow-y-auto pr-1">
    <h3 class="text-lg font-semibold text-gray-800 mb-3">Itens Aprovados</h3>
    {#if itemsParaConfirmar.length === 0 && itemsRemovidos.length === 0}
      <p class="text-gray-500 text-sm italic">
        Nenhum item foi aprovado com quantidade maior que zero.
      </p>
    {:else}
      <div class="space-y-4 border rounded-lg p-4 bg-gray-50 shadow-inner">
        {#if itemsRemovidos.length > 0}
          <div class="bg-red-50 border border-red-200 text-red-700 p-3 rounded-md text-sm mb-4">
            <p class="font-semibold">Atenção: {itemsRemovidos.length} item(ns) aprovados nesta solicitação foram removidos do sistema e não podem ser recebidos.</p>
          </div>
        {/if}

        <div class="divide-y divide-gray-200">
          {#each itemsParaConfirmar as item, index (item.itemId)}
            <div class="py-4 first:pt-0 last:pb-0 grid grid-cols-1 sm:grid-cols-12 gap-4 items-center">
              
              <div class="sm:col-span-5 md:col-span-6">
                <span class="font-semibold text-gray-800 block text-base">{item.productName}</span>
                <span class="text-xs text-gray-500 uppercase tracking-wide">Unidade: {item.productUnit}</span>
              </div>

              <div class="flex justify-between sm:block sm:col-span-3 md:col-span-2 text-left sm:text-center bg-white sm:bg-transparent p-2 sm:p-0 rounded border sm:border-0">
                <span class="text-xs font-semibold text-gray-500 sm:block mb-1">Aprovado</span>
                <span class="font-bold text-gray-700 text-lg">{item.quantityApproved}</span>
              </div>

              <div class="sm:col-span-4 md:col-span-4">
                <label for={`received-${index}`} class="block text-xs font-semibold text-gray-700 mb-1">
                  Recebido
                </label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  max={item.quantityApproved}
                  id={`received-${index}`}
                  bind:value={item.quantityReceived}
                  class="w-full rounded-lg border border-gray-300 focus:border-green-500 focus:ring-2 focus:ring-green-400 shadow-sm px-3 py-2 transition text-center font-medium text-gray-900"
                  required
                />
              </div>

            </div>
          {/each}
        </div>
      </div>
    {/if}

    <div class="space-y-4 border-t pt-5 mt-5">
      <div class="flex items-start">
        <div class="flex h-5 items-center">
          <input
            id="comDivergencia"
            type="checkbox"
            bind:checked={comDivergencia}
            disabled={hasQuantityDivergence}
            class="h-5 w-5 text-primary-600 border-gray-300 rounded focus:ring-primary-500 disabled:opacity-70 disabled:cursor-not-allowed"
          />
        </div>
        <div class="ml-3 text-sm">
          <label for="comDivergencia" class="font-semibold text-gray-800 cursor-pointer select-none">Recebido com Divergência?</label>
          {#if hasQuantityDivergence}
            <p class="text-orange-600 font-medium text-xs mt-0.5">
              (Marcado automaticamente por diferença de quantidade)
            </p>
          {/if}
        </div>
      </div>

      {#if comDivergencia}
        <div class="animate-fadeIn">
          <label for="observacaoEscola" class="block text-sm font-semibold text-gray-700 mb-1">
            Descreva a Divergência (Obrigatório)
          </label>
          <textarea
            id="observacaoEscola"
            rows="3"
            class="w-full rounded-lg border border-gray-300 focus:border-red-500 focus:ring-2 focus:ring-red-400 shadow-sm px-4 py-2 transition"
            bind:value={observacaoEscola}
            placeholder="Ex: Veio 2kg de arroz a menos (recebi 8kg de 10kg aprovados) ou recebeu porém estragado/vencido."
          />
        </div>
      {/if}
    </div>
  </div>

  <div class="mt-8 flex flex-col-reverse sm:flex-row justify-end gap-3 border-t pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="w-full sm:w-auto bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="w-full sm:w-auto bg-green-600 hover:bg-green-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105 disabled:opacity-50 active:scale-95"
      disabled={itemsParaConfirmar.length === 0}
    >
      Confirmar Recebimento
    </button>
  </div>
</form>

<style>
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(-5px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .animate-fadeIn {
    animation: fadeIn 0.2s ease-out forwards;
  }
</style>