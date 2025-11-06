<script lang="ts">
	import { createEventDispatcher } from 'svelte';
	import { toast } from '$lib/toast';
	import { fade } from 'svelte/transition'; // Importar animação

	// Propriedades recebidas (item de estoque)
	export let item: {
		product: { id: string; name: string; unit: string };
		quantity: number; // Esta é a quantidade ATUAL
	};

	// --- ESTADO LOCAL ATUALIZADO ---
	const currentQuantity = item.quantity; // Guarda a quantidade original
	let newQuantity = item.quantity; // O valor do input
	let motivoCategoria = ''; // O <select>
	let motivoObservacao = ''; // O <textarea>
	// --- FIM DA ATUALIZAÇÃO ---

	const dispatch = createEventDispatcher();

	// Reatividade: verifica se é uma redução
	$: isReduction = newQuantity < currentQuantity;

	// Limpa a observação se a categoria mudar e não for 'outro'
	$: if (motivoCategoria !== 'outro') {
		motivoObservacao = '';
	}

	function handleSubmit() {
		// --- VALIDAÇÃO ATUALIZADA ---
		if (isReduction) {
			if (!motivoCategoria) {
				toast.error('Selecione um motivo para a redução.');
				return; // Para a execução
			}
			if (motivoCategoria === 'outro' && (!motivoObservacao || motivoObservacao.trim() === '')) {
				toast.error('A observação é obrigatória para o motivo "Outro".');
				return;
			}
		}
		// --- FIM DA VALIDAÇÃO ---

		// Envia o DTO atualizado para o backend
		dispatch('save', {
			productId: item.product.id,
			newQuantity: newQuantity,
			motivoCategoria: motivoCategoria || undefined,
			motivoObservacao: motivoObservacao.trim() || undefined,
		});
	}
</script>

<form on:submit|preventDefault={handleSubmit}>
	<div class="border-b pb-4 mb-6">
		<h2 class="text-2xl font-bold text-gray-800">Ajustar Estoque</h2>
		<p class="text-gray-600 mt-1">
			Produto: <span class="font-semibold">{item.product.name} ({item.product.unit})</span>
		</p>
		<p class="text-sm text-gray-500 mt-1">
			Quantidade Atual: <span class="font-bold">{currentQuantity}</span>
		</p>
	</div>

	<div class="space-y-5">
		<div>
			<label for="quantity" class="block text-sm font-semibold text-gray-700 mb-1"
				>Nova Quantidade</label
			>
			<input
				type="number"
				id="quantity"
				required
				step="0.01"
				min="0"
				bind:value={newQuantity}
				class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
			/>
		</div>

		{#if isReduction}
			<div class="space-y-4 rounded-md border border-red-200 bg-red-50 p-4" transition:fade>
				<div>
					<label for="motivoCategoria" class="block text-sm font-semibold text-red-700 mb-1"
						>Motivo da Redução (Obrigatório)</label
					>
					<select
						id="motivoCategoria"
						bind:value={motivoCategoria}
						required
						class="w-full px-4 py-2 rounded-lg border border-gray-300 bg-white focus:border-red-500 focus:ring-2 focus:ring-red-300 transition-all shadow-sm"
					>
						<option value="" disabled>Selecione um motivo...</option>
						<option value="perda">Perda / Avaria</option>
						<option value="uso_interno">Uso Interno</option>
						<option value="vencimento">Vencimento</option>
						<option value="ajuste">Ajuste de contagem</option>
						<option value="outro">Outro</option>
					</select>
				</div>

				{#if motivoCategoria === 'outro'}
					<div transition:fade>
						<label
							for="motivoObservacao"
							class="block text-sm font-semibold text-red-700 mb-1"
						>
							Observação (Obrigatório)
						</label>
						<textarea
							id="motivoObservacao"
							rows="3"
							bind:value={motivoObservacao}
							placeholder="Descreva o motivo da redução..."
							class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:border-red-500 focus:ring-2 focus:ring-red-300 transition-all shadow-sm"
							required
						/>
					</div>
				{/if}
			</div>
		{/if}
		</div>

	<div class="mt-8 flex justify-end space-x-3 border-t pt-6">
		<button
			type="button"
			on:click={() => dispatch('cancel')}
			class="px-5 py-2 rounded-xl border border-gray-300 text-gray-700 font-semibold bg-gray-100 hover:bg-gray-200 transition-all"
		>
			Cancelar
		</button>
		<button
			type="submit"
			class="px-5 py-2 rounded-xl bg-primary-600 text-white font-semibold hover:bg-primary-700 transition-all shadow-sm"
		>
			Salvar Ajuste
		</button>
	</div>
</form>