<script lang="ts">
  import type { Solicitacao } from '$lib/types';
  import { format } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import { createEventDispatcher } from 'svelte';

  export let solicitacao: Solicitacao;
  const dispatch = createEventDispatcher();

  function formatQuantity(qty: number | null | undefined): string {
    if (qty === null || qty === undefined) return '—';
    return qty.toString();
  }

  function formatStatus(status: string): string {
    return status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase());
  }

  function getStatusClass(status: string): string {
    switch (status) {
      case 'pendente':
        return 'bg-yellow-100 text-yellow-800';
      case 'aprovado':
        return 'bg-green-100 text-green-800';
      case 'aprovado_parcialmente':
        return 'bg-blue-100 text-blue-800';
      case 'negado':
        return 'bg-red-100 text-red-800';
      case 'recebido':
        return 'bg-gray-200 text-gray-800';
      case 'recebido_divergente':
        return 'bg-orange-100 text-orange-800'; // Laranja
      case 'cancelado':
        return 'bg-gray-400 text-white';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  }
</script>

<div class="space-y-6">
  <div class="border-b pb-4">
    <h2 class="text-3xl font-bold text-gray-800">Detalhes da Solicitação</h2>
  </div>

  <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4 text-sm">
    <div>
      <span class="font-semibold text-gray-500">Escola:</span>
      <span class="ml-2 text-gray-800 font-bold">{solicitacao.school?.name || '(Escola Excluída)'}</span>
    </div>
    <div>
      <span class="font-semibold text-gray-500">Data:</span>
      <span class="ml-2 text-gray-700">{format(new Date(solicitacao.createdAt), 'dd/MM/yyyy HH:mm', { locale: ptBR })}</span>
    </div>
    <div>
      <span class="font-semibold text-gray-500">Status:</span>
      <span class="ml-2 px-2.5 py-0.5 rounded-full text-xs font-bold {getStatusClass(solicitacao.status)}">
        {formatStatus(solicitacao.status)}
      </span>
    </div>
    <div>
      <span class="font-semibold text-gray-500">Solicitante:</span>
      <span class="ml-2 text-gray-700">{solicitacao.requester?.name || 'N/A'}</span>
    </div>
    {#if solicitacao.justificativa}
      <div class="md:col-span-2 mt-2">
        <span class="font-semibold text-gray-500">Justificativa da Escola:</span>
        <p class="text-sm text-gray-700 mt-1 bg-gray-50 p-3 border rounded-lg shadow-inner italic">
          “{solicitacao.justificativa}”
        </p>
      </div>
    {/if}
    {#if solicitacao.observacaoPrefeitura}
      <div class="md:col-span-2 mt-2">
        <span class="font-semibold text-gray-500">Observação da Prefeitura:</span>
        <p class="text-sm text-gray-700 mt-1 bg-blue-50 p-3 border border-blue-200 rounded-lg shadow-inner italic">
          “{solicitacao.observacaoPrefeitura}”
        </p>
      </div>
    {/if}
    {#if solicitacao.observacaoEscola}
      <div class="md:col-span-2 mt-2">
        <span class="font-semibold text-gray-500">
          {#if solicitacao.status === 'cancelado'}
            Motivo do Cancelamento (Escola):
          {:else if solicitacao.status === 'recebido' || solicitacao.status === 'recebido_divergente'}
            Observação de Recebimento (Escola):
          {:else}
            Observação da Escola:
          {/if}
        </span>
        <p class="text-sm text-gray-700 mt-1 bg-yellow-50 p-3 border border-yellow-200 rounded-lg shadow-inner italic">
          “{solicitacao.observacaoEscola}”
        </p>
      </div>
    {/if}
  </div>

  <div>
    <h3 class="text-lg font-semibold text-gray-800 mb-3 border-t pt-5">Itens da Solicitação</h3>
    {#if solicitacao.items.length === 0}
      <p class="text-sm text-gray-500 italic">Nenhum item nesta solicitação.</p>
    {:else}
      <div class="overflow-x-auto border rounded-lg shadow-sm max-h-96 overflow-y-auto">
        <table class="min-w-full divide-y divide-gray-200 text-sm">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="sticky top-0 bg-gray-50 px-5 py-3 text-left font-semibold text-gray-600 uppercase tracking-wider">Produto</th>
              <th scope="col" class="sticky top-0 bg-gray-50 px-5 py-3 text-center font-semibold text-gray-600 uppercase tracking-wider">Unid.</th>
              <th scope="col" class="sticky top-0 bg-gray-50 px-5 py-3 text-right font-semibold text-gray-600 uppercase tracking-wider">Solicitado</th>
              <th scope="col" class="sticky top-0 bg-gray-50 px-5 py-3 text-right font-semibold text-gray-600 uppercase tracking-wider">Aprovado</th>
              <th scope="col" class="sticky top-0 bg-gray-50 px-5 py-3 text-right font-semibold text-gray-600 uppercase tracking-wider">Recebido</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            {#each solicitacao.items as item (item.id)}
              <tr class="hover:bg-gray-50">
                <td class="px-5 py-3 whitespace-nowrap font-semibold text-gray-900">{item.product?.name || '(Produto Excluído)'}</td>
                <td class="px-5 py-3 whitespace-nowrap text-center text-gray-500">{item.product?.unit || '(N/A)'}</td>
                <td class="px-5 py-3 whitespace-nowrap text-right text-gray-700 font-bold">{formatQuantity(item.quantityRequested)}</td>
                <td class="px-5 py-3 whitespace-nowrap text-right text-blue-700 font-bold">{formatQuantity(item.quantityApproved)}</td>
                <td class="px-5 py-3 whitespace-nowrap text-right text-green-700 font-bold">{formatQuantity(item.quantityReceived)}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    {/if}
  </div>

  <div class="mt-8 flex justify-end border-t pt-6">
    <button
      type="button"
      on:click={() => dispatch('close')}
      class="bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm"
    >
      Fechar
    </button>
  </div>
</div>