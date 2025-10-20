<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import type { Solicitacao } from '$lib/types'; // Importa o tipo central
  import { format } from 'date-fns';

  // Recebe a solicitação completa para exibir os dados e preencher o form
  export let solicitacao: Solicitacao;

  // Variáveis locais para os campos do formulário
  let observacaoPrefeitura: string = solicitacao.observacaoPrefeitura || '';
  
  // Mapeia os itens da solicitação para um formato editável dentro do formulário
  // Inclui validação para quantidade aprovada não exceder a solicitada
  let itemsAnalisados = solicitacao.items.map(item => ({
      itemId: item.id,
      productName: item.product.name,
      productUnit: item.product.unit,
      quantityRequested: item.quantityRequested,
      // Inicializa 'quantityApproved' com a quantidade solicitada, mas permite edição
      quantityApproved: item.quantityApproved ?? item.quantityRequested 
  }));

  const dispatch = createEventDispatcher(); // Para enviar eventos (save, cancel)

  // Função chamada ao enviar o formulário
  function handleSubmit() {
    let finalStatus: 'aprovado' | 'aprovado_parcialmente' | 'negado';
    
    // Calcula totais para determinar o status final
    const totalRequested = itemsAnalisados.reduce((sum, item) => sum + item.quantityRequested, 0);
    // Garante que quantityApproved seja tratado como 0 se for null ou undefined
    const totalApproved = itemsAnalisados.reduce((sum, item) => sum + (item.quantityApproved ?? 0), 0); 

    // Validação extra: Quantidade aprovada não pode ser maior que a solicitada
    const invalidItems = itemsAnalisados.filter(item => (item.quantityApproved ?? 0) > item.quantityRequested);
    if(invalidItems.length > 0) {
        alert(`Erro: A quantidade aprovada para "${invalidItems[0].productName}" não pode ser maior que a solicitada.`);
        return; // Impede o envio
    }

    // Lógica para definir o status final
    if (totalApproved <= 0) {
        finalStatus = 'negado';
    } else if (totalApproved < totalRequested) {
        finalStatus = 'aprovado_parcialmente';
    } else {
        finalStatus = 'aprovado';
    }

    // Envia o evento 'save' com os dados formatados para a API
    dispatch('save', {
      status: finalStatus,
      observacaoPrefeitura: observacaoPrefeitura || undefined, // Envia undefined se vazio
      // Mapeia de volta para o formato esperado pela API
      items: itemsAnalisados.map(item => ({
        itemId: item.itemId,
        quantityApproved: item.quantityApproved ?? 0 // Garante que seja 0 se null/undefined
      }))
    });
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <div class="border-b pb-4 mb-4">
    <h2 class="text-2xl font-bold text-gray-800">Analisar Solicitação</h2>
    <p class="text-sm text-gray-600">Escola: <span class="font-semibold">{solicitacao.school.name}</span></p>
    <p class="text-sm text-gray-600">Data: {format(new Date(solicitacao.createdAt), 'dd/MM/yyyy')}</p>
    {#if solicitacao.justificativa}
      <p class="text-sm text-gray-600 mt-2 bg-gray-50 p-2 border rounded">Justificativa: <span class="italic">{solicitacao.justificativa}</span></p>
    {/if}
  </div>

  <div>
    <h3 class="text-lg font-medium text-gray-800 mb-3">Itens Solicitados</h3>
    {#if itemsAnalisados.length === 0}
        <p class="text-sm text-gray-500 italic">Esta solicitação não contém itens.</p>
    {:else}
        <div class="space-y-4 max-h-60 overflow-y-auto pr-2 border rounded-md p-4 bg-gray-50">
        {#each itemsAnalisados as item, index (item.itemId)}
            <div class="grid grid-cols-5 gap-4 items-center border-b pb-3 last:border-b-0">
            <div class="col-span-2">
                <span class="font-medium text-gray-800 block">{item.productName}</span>
                <span class="text-xs text-gray-500">Unidade: {item.productUnit}</span>
            </div>
            <div class="col-span-1 text-center">
                <!-- svelte-ignore a11y-label-has-associated-control -->
                <label class="block text-xs text-gray-500 mb-1">Solicitado</label>
                <span class="font-semibold text-gray-700">{item.quantityRequested}</span>
            </div>
            <div class="col-span-2">
                <label for={`approved-${index}`} class="block text-xs font-medium text-gray-700 mb-1">Aprovado</label>
                <input 
                type="number" 
                step="0.01" 
                min="0"
                max={item.quantityRequested} id={`approved-${index}`} 
                bind:value={item.quantityApproved}
                class="block w-full rounded-md border-gray-300 shadow-sm text-sm focus:border-primary-500 focus:ring-primary-500"
                required >
            </div>
            </div>
        {/each}
        </div>
    {/if}
  </div>

  <div>
    <label for="observacao" class="block text-sm font-medium text-gray-700">Observações da Prefeitura (Opcional)</label>
    <textarea 
      id="observacao" 
      rows="3" 
      class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" 
      bind:value={observacaoPrefeitura}
      placeholder="Ex: Item X indisponível no momento, entrega parcial..."
    ></textarea>
  </div>
  
  <div class="mt-8 flex justify-end space-x-3 border-t pt-6">
    <button type="button" on:click={() => dispatch('cancel')} class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded-lg hover:bg-gray-300 transition">
      Cancelar
    </button>
    <button 
      type="submit" 
      class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded-lg transition"
      disabled={itemsAnalisados.length === 0}
      >
      Salvar Análise
    </button>
  </div>
</form>