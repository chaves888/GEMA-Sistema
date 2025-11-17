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
            case 'pendente': return 'bg-yellow-100 text-yellow-800';
            case 'aprovado': return 'bg-green-100 text-green-800';
            case 'aprovado_parcialmente': return 'bg-blue-100 text-blue-800';
            case 'negado': return 'bg-red-100 text-red-800';
            case 'recebido': return 'bg-gray-200 text-gray-800';
            case 'recebido_divergente': return 'bg-orange-100 text-orange-800';
            case 'cancelado': return 'bg-gray-400 text-white';
            default: return 'bg-gray-100 text-gray-800';
        }
    }
</script>

<div class="space-y-6 flex flex-col h-full">
    <div class="border-b pb-4 flex-shrink-0">
        <h2 class="text-2xl md:text-3xl font-bold text-gray-800">Detalhes da Solicitação</h2>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-4 text-sm flex-shrink-0">
        <div>
            <span class="font-semibold text-gray-500 block sm:inline">Escola:</span>
            <span class="sm:ml-2 text-gray-800 font-bold block sm:inline">{solicitacao.school?.name || '(Escola Excluída)'}</span>
        </div>
        <div>
            <span class="font-semibold text-gray-500 block sm:inline">Data:</span>
            <span class="sm:ml-2 text-gray-700 block sm:inline">{format(new Date(solicitacao.createdAt), 'dd/MM/yyyy HH:mm', { locale: ptBR })}</span>
        </div>
        <div>
            <span class="font-semibold text-gray-500 block sm:inline">Status:</span>
            <span class="sm:ml-2 px-2.5 py-0.5 rounded-full text-xs font-bold inline-block mt-1 sm:mt-0 {getStatusClass(solicitacao.status)}">
                {formatStatus(solicitacao.status)}
            </span>
        </div>
        <div>
            <span class="font-semibold text-gray-500 block sm:inline">Solicitante:</span>
            <span class="sm:ml-2 text-gray-700 block sm:inline">{solicitacao.requester?.name || 'N/A'}</span>
        </div>
        
        {#if solicitacao.justificativa}
            <div class="sm:col-span-2 mt-2">
                <span class="font-semibold text-gray-500 block mb-1">Justificativa da Escola:</span>
                <div class="text-sm text-gray-700 bg-gray-50 p-3 border rounded-lg shadow-inner italic">
                    “{solicitacao.justificativa}”
                </div>
            </div>
        {/if}
        
        {#if solicitacao.observacaoPrefeitura}
            <div class="sm:col-span-2 mt-2">
                <span class="font-semibold text-gray-500 block mb-1">Observação da Prefeitura:</span>
                <div class="text-sm text-gray-700 bg-blue-50 p-3 border border-blue-200 rounded-lg shadow-inner italic">
                    “{solicitacao.observacaoPrefeitura}”
                </div>
            </div>
        {/if}
        
        {#if solicitacao.observacaoEscola}
            <div class="sm:col-span-2 mt-2">
                <span class="font-semibold text-gray-500 block mb-1">
                    {#if solicitacao.status === 'cancelado'}
                        Motivo do Cancelamento (Escola):
                    {:else if solicitacao.status === 'recebido' || solicitacao.status === 'recebido_divergente'}
                        Observação de Recebimento (Escola):
                    {:else}
                        Observação da Escola:
                    {/if}
                </span>
                <div class="text-sm text-gray-700 bg-yellow-50 p-3 border border-yellow-200 rounded-lg shadow-inner italic">
                    “{solicitacao.observacaoEscola}”
                </div>
            </div>
        {/if}
    </div>

    <div class="flex-1 min-h-0 flex flex-col">
        <h3 class="text-lg font-semibold text-gray-800 mb-3 border-t pt-5 flex-shrink-0">Itens da Solicitação</h3>
        
        {#if solicitacao.items.length === 0}
            <p class="text-sm text-gray-500 italic">Nenhum item nesta solicitação.</p>
        {:else}
            <div class="overflow-auto border rounded-lg shadow-sm bg-white flex-1">
                <table class="min-w-full divide-y divide-gray-200 text-sm">
                    <thead class="bg-gray-50 sticky top-0 z-10">
                        <tr>
                            <th scope="col" class="px-4 py-3 text-left font-semibold text-gray-600 uppercase tracking-wider whitespace-nowrap">Produto</th>
                            <th scope="col" class="px-2 py-3 text-center font-semibold text-gray-600 uppercase tracking-wider whitespace-nowrap">Unid.</th>
                            <th scope="col" class="px-2 py-3 text-right font-semibold text-gray-600 uppercase tracking-wider whitespace-nowrap">Solic.</th>
                            <th scope="col" class="px-2 py-3 text-right font-semibold text-gray-600 uppercase tracking-wider whitespace-nowrap">Aprov.</th>
                            <th scope="col" class="px-4 py-3 text-right font-semibold text-gray-600 uppercase tracking-wider whitespace-nowrap">Receb.</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        {#each solicitacao.items as item (item.id)}
                            <tr class="hover:bg-gray-50">
                                <td class="px-4 py-3 font-semibold text-gray-900 min-w-[150px]">{item.product?.name || '(Produto Excluído)'}</td>
                                <td class="px-2 py-3 text-center text-gray-500">{item.product?.unit || '-'}</td>
                                <td class="px-2 py-3 text-right text-gray-700 font-medium">{formatQuantity(item.quantityRequested)}</td>
                                <td class="px-2 py-3 text-right text-blue-700 font-bold">{formatQuantity(item.quantityApproved)}</td>
                                <td class="px-4 py-3 text-right text-green-700 font-bold">{formatQuantity(item.quantityReceived)}</td>
                            </tr>
                        {/each}
                    </tbody>
                </table>
            </div>
        {/if}
    </div>

    <div class="mt-4 flex justify-end border-t pt-4 flex-shrink-0">
        <button
            type="button"
            on:click={() => dispatch('close')}
            class="w-full sm:w-auto bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm active:scale-95"
        >
            Fechar
        </button>
    </div>
</div>