<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Solicitacao } from '$lib/types'; // Usa o tipo central
  import { format } from 'date-fns';

  // Recebe a solicitação completa
  export let solicitacao: Solicitacao;

  // Mapeia apenas os itens que foram APROVADOS (com quantidade > 0)
  let itemsParaConfirmar = solicitacao.items
    .filter(item => item.quantityApproved && item.quantityApproved > 0)
    .map(item => ({
        itemId: item.id,
        productName: item.product.name,
        productUnit: item.product.unit,
        quantityApproved: item.quantityApproved,
        // Inicializa a quantidade recebida com a quantidade aprovada
        quantityReceived: item.quantityReceived ?? item.quantityApproved 
    }));

  const dispatch = createEventDispatcher();

  function handleSubmit() {
    // 1. Validação simples: Quantidade recebida não pode ser maior que a aprovada.
    const invalidItems = itemsParaConfirmar.filter(
        item => (item.quantityReceived ?? 0) > (item.quantityApproved ?? 0)
    );
    if (invalidItems.length > 0) {
        alert('Erro: A quantidade recebida não pode ser maior que a quantidade aprovada.');
        return;
    }

    // 2. Envia o evento 'save' com os dados formatados para a API
    dispatch('save', {
      items: itemsParaConfirmar.map(item => ({
        itemId: item.itemId,
        quantityReceived: item.quantityReceived ?? 0 // Garante que seja um número (0 se vazio)
      }))
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <div class="border-b pb-4 mb-4">
    <h2 class="text-2xl font-bold text-gray-800">Confirmar Recebimento</h2>
    <p class="text-sm text-gray-600">Escola: <span class="font-semibold">{solicitacao.school.name}</span></p>
    <p class="text-sm text-gray-600">Confirme as quantidades recebidas da solicitação de {format(new Date(solicitacao.createdAt), 'dd/MM/yyyy')}.</p>
    {#if solicitacao.observacaoPrefeitura}
        <p class="text-sm text-gray-500 mt-2 bg-blue-50 border border-blue-200 p-2 rounded-md">
            <span class="font-semibold">Observação da Prefeitura:</span> {solicitacao.observacaoPrefeitura}
        </p>
    {/if}
  </div>

  <div>
    <h3 class="text-lg font-medium text-gray-800 mb-3">Itens Aprovados</h3>
    {#if itemsParaConfirmar.length === 0}
        <p class="text-gray-500 text-sm">Nenhum item foi aprovado com quantidade maior que zero.</p>
    {:else}
        <div class="space-y-3 max-h-60 overflow-y-auto pr-2 border rounded-md p-3 bg-gray-50">
        {#each itemsParaConfirmar as item, index (item.itemId)}
            <div class="grid grid-cols-3 gap-4 items-center border-b pb-3 last:border-b-0">
            <div class="col-span-1">
                <span class="font-medium text-gray-800">{item.productName}</span>
                <span class="text-sm text-gray-500 ml-1">({item.productUnit})</span>
            </div>
            <div class="col-span-1 text-center">
                <!-- svelte-ignore a11y-label-has-associated-control -->
                <label class="block text-xs text-gray-500 mb-1">Aprovado</label>
                <span class="font-semibold text-gray-700">{item.quantityApproved}</span>
            </div>
            <div class="col-span-1">
                <label for={`received-${index}`} class="block text-xs font-medium text-gray-700 mb-1">Recebido</label>
                <input 
                type="number" 
                step="0.01" 
                min="0"
                max={item.quantityApproved}
                id={`received-${index}`} 
                bind:value={item.quantityReceived}
                class="block w-full rounded-md border-gray-300 shadow-sm text-sm focus:border-green-500 focus:ring-green-500"
                required
                >
            </div>
            </div>
        {/each}
        </div>
    {/if}
  </div>

  <div class="mt-8 flex justify-end space-x-3 border-t pt-6">
    <button type="button" on:click={() => dispatch('cancel')} class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded-lg hover:bg-gray-300 transition">
      Cancelar
    </button>
    <button 
      type="submit" 
      class="bg-green-600 hover:bg-green-700 text-white font-bold py-2 px-4 rounded-lg shadow-md transition"
      disabled={itemsParaConfirmar.length === 0}
    >
      Confirmar Recebimento
    </button>
  </div>
</form>