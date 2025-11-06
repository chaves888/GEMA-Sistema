<script lang="ts">
	import { createEventDispatcher } from 'svelte';
	import type { Solicitacao } from '$lib/types';
	import { format } from 'date-fns';
	import { toast } from '$lib/toast';

	export let solicitacao: Solicitacao;

	let comDivergencia: boolean = false;
	let observacaoEscola: string = '';

	// --- INÍCIO DA CORREÇÃO (Soft Delete) ---
	let itemsParaConfirmar = solicitacao.items
		.filter(
			(item) => item.product && item.quantityApproved && item.quantityApproved > 0
		) // Filtra produtos nulos E não aprovados
		.map((item) => ({
			itemId: item.id,
			productName: item.product.name,
			productUnit: item.product.unit,
			quantityApproved: item.quantityApproved,
			quantityReceived: item.quantityReceived ?? item.quantityApproved,
		}));

	// Itens que foram aprovados mas removidos do sistema
	const itemsRemovidos = solicitacao.items.filter(
		(item) => !item.product && item.quantityApproved && item.quantityApproved > 0
	);
	// --- FIM DA CORREÇÃO ---

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

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
	<div class="border-b pb-4 mb-4">
		<h2 class="text-3xl font-bold text-gray-800">Confirmar Recebimento</h2>
		<p class="text-sm text-gray-600 mt-2">
			Escola: <span class="font-semibold">{solicitacao.school?.name || '(Escola Excluída)'}</span>
		</p>
		<p class="text-sm text-gray-600">
			Confirme as quantidades recebidas da solicitação de {format(
				new Date(solicitacao.createdAt),
				'dd/MM/yyyy'
			)}.
		</p>
		{#if solicitacao.observacaoPrefeitura}
			<p
				class="text-sm text-gray-700 mt-3 bg-blue-50 p-3 border border-blue-200 rounded-lg shadow-inner"
			>
				<span class="font-semibold text-blue-800">Observação da Prefeitura:</span>
				<span class="italic text-blue-700">“{solicitacao.observacaoPrefeitura}”</span>
			</p>
		{/if}
	</div>

	<div>
		<h3 class="text-lg font-semibold text-gray-800 mb-3">Itens Aprovados</h3>
		{#if itemsParaConfirmar.length === 0 && itemsRemovidos.length === 0}
			<p class="text-gray-500 text-sm">
				Nenhum item foi aprovado com quantidade maior que zero.
			</p>
		{:else}
			<div
				class="space-y-4 max-h-96 overflow-y-auto pr-2 border rounded-lg p-4 bg-gray-50 shadow-inner"
			>
				{#if itemsRemovidos.length > 0}
					<div class="bg-red-50 border border-red-200 text-red-700 p-3 rounded-md text-sm">
						<p class="font-semibold">Atenção: {itemsRemovidos.length} item(ns) aprovados nesta solicitação foram removidos do sistema e não podem ser recebidos.</p>
					</div>
				{/if}

				{#each itemsParaConfirmar as item, index (item.itemId)}
					<div class="grid grid-cols-3 gap-4 items-center border-b pb-4 last:border-b-0">
						<div class="col-span-1">
							<span class="font-semibold text-gray-800">{item.productName}</span>
							<span class="text-sm text-gray-500 ml-1">({item.productUnit})</span>
						</div>
						<div class="col-span-1 text-center">
              <!-- svelte-ignore a11y-label-has-associated-control -->
              <label class="block text-xs font-semibold text-gray-500 mb-1">Aprovado</label>
							<span class="font-bold text-gray-700 text-lg">{item.quantityApproved}</span>
						</div>
						<div class="col-span-1">
							<label for={`received-${index}`} class="block text-sm font-semibold text-gray-700 mb-1"
								>Recebido</label
							>
							<input
								type="number"
								step="0.01"
								min="0"
								max={item.quantityApproved}
								id={`received-${index}`}
								bind:value={item.quantityReceived}
								class="mt-1 w-full rounded-lg border border-gray-300 focus:border-green-500 focus:ring-2 focus:ring-green-400 shadow-sm px-4 py-2 transition"
								required
							/>
						</div>
					</div>
				{/each}
			</div>
		{/if}
	</div>

	<div class="space-y-4 border-t pt-5 mt-5">
		<div class="flex items-center">
			<input
				type="checkbox"
				id="comDivergencia"
				bind:checked={comDivergencia}
				disabled={hasQuantityDivergence}
				class="h-5 w-5 text-primary-600 border-gray-300 rounded focus:ring-primary-500 disabled:opacity-70 disabled:cursor-not-allowed"
			/>
			<label for="comDivergencia" class="ml-3 block text-md font-semibold text-gray-800">
				Recebido com Divergência?
			</label>
		</div>

		{#if hasQuantityDivergence}
			<p class="-mt-3 ml-8 text-sm text-orange-600 font-medium">
				(Marcado automaticamente por diferença de quantidade)
			</p>
		{/if}

		{#if comDivergencia}
			<div>
				<label for="observacaoEscola" class="block text-sm font-semibold text-gray-700 mb-1">
					Descreva a Divergência (Obrigatório)
				</label>
				<textarea
					id="observacaoEscola"
					rows="3"
					class="mt-1 w-full rounded-lg border border-gray-300 focus:border-red-500 focus:ring-2 focus:ring-red-400 shadow-sm px-4 py-2 transition"
					bind:value={observacaoEscola}
					placeholder="Ex: Veio 2kg de arroz a menos (recebi 8kg de 10kg aprovados)."
				/>
			</div>
		{/if}
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
			class="bg-green-600 hover:bg-green-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105"
			disabled={itemsParaConfirmar.length === 0}
		>
			Confirmar Recebimento
		</button>
	</div>
</form>