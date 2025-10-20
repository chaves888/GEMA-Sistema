<script lang="ts">
  import type { Solicitacao } from '$lib/types';
  import { format } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import { createEventDispatcher } from 'svelte';
  import { X } from 'lucide-svelte'; // Ícone para fechar

  // Recebe a solicitação completa
  export let solicitacao: Solicitacao;

  const dispatch = createEventDispatcher();

  // Função simples para formatar números ou exibir '-'
  function formatQuantity(qty: number | null | undefined): string {
    if (qty === null || qty === undefined) return '-';
    return qty.toString();
  }
</script>

<div class="space-y-6 p-1">
  <div class="flex justify-between items-center border-b pb-3 mb-5">
    <h2 class="text-2xl font-semibold text-gray-800">Detalhes da Solicitação</h2>
    <button 
      on:click={() => dispatch('close')} 
      class="text-gray-400 hover:text-gray-600 transition"
      aria-label="Fechar modal"
     >
      <X class="w-6 h-6"/>
    </button>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-3 text-sm">
    <div>
      <span class="font-medium text-gray-500">Escola:</span>
      <span class="ml-2 text-gray-800 font-semibold">{solicitacao.school.name}</span>
    </div>
    <div>
      <span class="font-medium text-gray-500">Data:</span>
      <span class="ml-2 text-gray-700">{format(new Date(solicitacao.createdAt), 'dd/MM/yyyy HH:mm', { locale: ptBR })}</span>
    </div>
    <div>
      <span class="font-medium text-gray-500">Status:</span>
      <span class="ml-2 px-2 py-0.5 rounded-full text-xs font-semibold {
        solicitacao.status === 'pendente' ? 'bg-yellow-100 text-yellow-800' :
        solicitacao.status === 'aprovado' ? 'bg-green-100 text-green-800' :
        solicitacao.status === 'aprovado_parcialmente' ? 'bg-blue-100 text-blue-800' :
        solicitacao.status === 'negado' ? 'bg-red-100 text-red-800' :
        'bg-gray-200 text-gray-800'
      }">
        {solicitacao.status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase())}
      </span>
    </div>
    <div>
      <span class="font-medium text-gray-500">Solicitante:</span>
      <span class="ml-2 text-gray-700">{solicitacao.requester?.name || 'N/A'}</span>
    </div>
    {#if solicitacao.justificativa}
      <div class="md:col-span-2 mt-1">
        <span class="font-medium text-gray-500">Justificativa:</span>
        <p class="ml-2 text-gray-700 italic bg-gray-50 p-2 border rounded mt-1">{solicitacao.justificativa}</p>
      </div>
    {/if}
     {#if solicitacao.observacaoPrefeitura}
      <div class="md:col-span-2 mt-1">
        <span class="font-medium text-gray-500">Observação da Prefeitura:</span>
        <p class="ml-2 text-gray-700 italic bg-blue-50 p-2 border border-blue-200 rounded mt-1">{solicitacao.observacaoPrefeitura}</p>
      </div>
    {/if}
  </div>

  <div>
    <h3 class="text-lg font-medium text-gray-800 mb-3 border-t pt-4">Itens da Solicitação</h3>
    {#if solicitacao.items.length === 0}
      <p class="text-sm text-gray-500 italic">Nenhum item nesta solicitação.</p>
    {:else}
      <div class="overflow-x-auto border rounded-lg">
        <table class="min-w-full divide-y divide-gray-200 text-sm">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-4 py-2 text-left font-medium text-gray-500 uppercase tracking-wider">Produto</th>
              <th scope="col" class="px-4 py-2 text-center font-medium text-gray-500 uppercase tracking-wider">Unid.</th>
              <th scope="col" class="px-4 py-2 text-right font-medium text-gray-500 uppercase tracking-wider">Solicitado</th>
              <th scope="col" class="px-4 py-2 text-right font-medium text-gray-500 uppercase tracking-wider">Aprovado</th>
              <th scope="col" class="px-4 py-2 text-right font-medium text-gray-500 uppercase tracking-wider">Recebido</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each solicitacao.items as item (item.id)}
              <tr>
                <td class="px-4 py-2 whitespace-nowrap font-medium text-gray-900">{item.product.name}</td>
                <td class="px-4 py-2 whitespace-nowrap text-center text-gray-500">{item.product.unit}</td>
                <td class="px-4 py-2 whitespace-nowrap text-right text-gray-700 font-semibold">{formatQuantity(item.quantityRequested)}</td>
                <td class="px-4 py-2 whitespace-nowrap text-right text-blue-700">{formatQuantity(item.quantityApproved)}</td>
                <td class="px-4 py-2 whitespace-nowrap text-right text-green-700">{formatQuantity(item.quantityReceived)}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>

  <div class="mt-6 flex justify-end border-t pt-4">
    <button 
      type="button" 
      on:click={() => dispatch('close')} 
      class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded-lg hover:bg-gray-300 transition"
    >
      Fechar
    </button>
  </div>
</div>