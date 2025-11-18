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
      case 'pendente': return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200';
      case 'aprovado': return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200';
      case 'aprovado_parcialmente': return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200';
      case 'negado': return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200';
      case 'recebido': return 'bg-gray-200 text-gray-800 dark:bg-gray-700 dark:text-gray-200';
      case 'recebido_divergente': return 'bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200';
      case 'cancelado': return 'bg-gray-400 text-white dark:bg-gray-600 dark:text-gray-100';
      default: return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200';
    }
  }
</script>

<div class="flex flex-col h-full overflow-hidden">
  <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-4 flex-shrink-0">
    <h2 class="text-2xl md:text-3xl font-bold text-gray-800 dark:text-white">Detalhes da Solicitação</h2>
  </div>

  <div class="flex-1 overflow-y-auto pr-1">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4 text-sm mb-6">
        <div>
          <span class="font-semibold text-gray-500 dark:text-gray-400 block md:inline">Escola:</span>
          <span class="md:ml-2 text-gray-800 dark:text-gray-200 font-bold block md:inline">{solicitacao.school?.name || '(Escola Excluída)'}</span>
        </div>
        <div>
          <span class="font-semibold text-gray-500 dark:text-gray-400 block md:inline">Data:</span>
          <span class="md:ml-2 text-gray-700 dark:text-gray-300 block md:inline">{format(new Date(solicitacao.createdAt), 'dd/MM/yyyy HH:mm', { locale: ptBR })}</span>
        </div>
        <div>
          <span class="font-semibold text-gray-500 dark:text-gray-400 block md:inline mb-1 md:mb-0">Status:</span>
          <span class="md:ml-2 px-2.5 py-0.5 rounded-full text-xs font-bold inline-block {getStatusClass(solicitacao.status)}">
            {formatStatus(solicitacao.status)}
          </span>
        </div>
        <div>
          <span class="font-semibold text-gray-500 dark:text-gray-400 block md:inline">Solicitante:</span>
          <span class="md:ml-2 text-gray-700 dark:text-gray-300 block md:inline">{solicitacao.requester?.name || 'N/A'}</span>
        </div>
        
        {#if solicitacao.justificativa}
          <div class="md:col-span-2 mt-2">
            <span class="font-semibold text-gray-500 dark:text-gray-400 block mb-1">Justificativa da Escola:</span>
            <div class="text-sm text-gray-700 dark:text-gray-300 bg-gray-50 dark:bg-gray-700/50 p-3 border border-gray-200 dark:border-gray-600 rounded-lg shadow-inner italic">
              “{solicitacao.justificativa}”
            </div>
          </div>
        {/if}
        
        {#if solicitacao.observacaoPrefeitura}
          <div class="md:col-span-2 mt-2">
            <span class="font-semibold text-gray-500 dark:text-gray-400 block mb-1">Observação da Prefeitura:</span>
            <div class="text-sm text-blue-700 dark:text-blue-200 bg-blue-50 dark:bg-blue-900/20 p-3 border border-blue-200 dark:border-blue-800 rounded-lg shadow-inner italic">
              “{solicitacao.observacaoPrefeitura}”
            </div>
          </div>
        {/if}
        
        {#if solicitacao.observacaoEscola}
          <div class="md:col-span-2 mt-2">
            <span class="font-semibold text-gray-500 dark:text-gray-400 block mb-1">
              {#if solicitacao.status === 'cancelado'}
                Motivo do Cancelamento (Escola):
              {:else if solicitacao.status === 'recebido' || solicitacao.status === 'recebido_divergente'}
                Observação de Recebimento (Escola):
              {:else}
                Observação da Escola:
              {/if}
            </span>
            <div class="text-sm text-gray-700 dark:text-gray-300 bg-yellow-50 dark:bg-yellow-900/20 p-3 border border-yellow-200 dark:border-yellow-800 rounded-lg shadow-inner italic">
              “{solicitacao.observacaoEscola}”
            </div>
          </div>
        {/if}
      </div>

      <div>
        <h3 class="text-lg font-semibold text-gray-800 dark:text-gray-200 mb-3 border-t border-gray-200 dark:border-gray-700 pt-5 flex-shrink-0">Itens da Solicitação</h3>
        
        {#if solicitacao.items.length === 0}
          <p class="text-sm text-gray-500 dark:text-gray-400 italic">Nenhum item nesta solicitação.</p>
        {:else}
          <div class="overflow-x-auto border border-gray-200 dark:border-gray-700 rounded-lg shadow-sm bg-white dark:bg-gray-800 flex-1">
            <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700 text-sm">
              <thead class="bg-gray-50 dark:bg-gray-700 sticky top-0 z-10">
                <tr>
                  <th scope="col" class="px-4 py-3 text-left font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider whitespace-nowrap">Produto</th>
                  <th scope="col" class="px-2 py-3 text-center font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider whitespace-nowrap">Unid.</th>
                  <th scope="col" class="px-2 py-3 text-right font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider whitespace-nowrap">Solic.</th>
                  <th scope="col" class="px-2 py-3 text-right font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider whitespace-nowrap">Aprov.</th>
                  <th scope="col" class="px-4 py-3 text-right font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider whitespace-nowrap">Receb.</th>
                </tr>
              </thead>
              <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                {#each solicitacao.items as item (item.id)}
                  <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                    <td class="px-4 py-3 font-semibold text-gray-900 dark:text-gray-100 min-w-[150px]">{item.product?.name || '(Produto Excluído)'}</td>
                    <td class="px-2 py-3 text-center text-gray-500 dark:text-gray-400">{item.product?.unit || '-'}</td>
                    <td class="px-2 py-3 text-right text-gray-700 dark:text-gray-300 font-medium">{formatQuantity(item.quantityRequested)}</td>
                    <td class="px-2 py-3 text-right text-blue-700 dark:text-blue-400 font-bold">{formatQuantity(item.quantityApproved)}</td>
                    <td class="px-4 py-3 text-right text-green-700 dark:text-green-400 font-bold">{formatQuantity(item.quantityReceived)}</td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        {/if}
      </div>
  </div>

  <div class="mt-4 flex justify-end border-t border-gray-200 dark:border-gray-700 pt-4 flex-shrink-0">
    <button
      type="button"
      on:click={() => dispatch('close')}
      class="w-full sm:w-auto bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-200 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition shadow-sm active:scale-95"
    >
      Fechar
    </button>
  </div>
</div>