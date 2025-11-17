<script lang="ts">
	import { onMount } from 'svelte';
	import * as api from '$lib/api';
	import { session } from '$lib/sessionStore';
	import { format, parseISO, eachDayOfInterval, getDay } from 'date-fns';
	import { ptBR } from 'date-fns/locale';
	import Modal from '$lib/components/Modal.svelte';
	import CardapioForm from '$lib/components/CardapioForm.svelte';
	import { CalendarPlus, Edit, Eye, Trash2, CalendarDays } from 'lucide-svelte';
	import { goto } from '$app/navigation';

	import { toast } from '$lib/toast';
	import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';

	type CardapioListItem = {
		id: string;
		name: string;
		startDate: string;
		endDate: string;
		status: 'rascunho' | 'publicado';
		createdBy: { name: string } | null;
	};

	let cardapios: CardapioListItem[] = [];
	let isLoading = true;
	let error: string | null = null;
	let isActionLoading = false;

	let showCreateModal = false;
	let newCardapioData = {
		startDate: new Date().toISOString().split('T')[0],
		endDate: new Date().toISOString().split('T')[0],
	};

	let showConfirmModal = false;
	let cardapioToDelete: CardapioListItem | null = null;
	let confirmMessage = '';

	$: if ($session) {
		loadCardapios();
	}

	async function loadCardapios() {
		isLoading = true;
		error = null;
		try {
			cardapios = await api.get('cardapios');
		} catch (e: any) {
			error = e?.message || 'Não foi possível carregar os cardápios.';
			console.error(e);
			
			// --- CORREÇÃO 2: Checa se 'error' não é nulo ---
			if (error) {
				toast.error(error);
			}
			// --- FIM DA CORREÇÃO 2 ---
		} finally {
			isLoading = false;
		}
	}

	function handleNovoCardapio() {
		const today = new Date().toISOString().split('T')[0];
		newCardapioData = { startDate: today, endDate: today };
		showCreateModal = true;
	}

	async function handleSaveNewCardapio(event: any) {
		const dataToSend = event.detail;
		const today = new Date().toISOString().split('T')[0];

		if (dataToSend.startDate < today) {
			toast.error('A data de início não pode ser anterior à data atual.');
			return;
		}
		if (dataToSend.endDate < dataToSend.startDate) {
			toast.error('A data de fim não pode ser anterior à data de início.');
			return;
		}

		try {
			const start = parseISO(dataToSend.startDate);
			const end = parseISO(dataToSend.endDate);
			const daysInInterval = eachDayOfInterval({ start, end });
			const weekdaysCount = daysInInterval.filter((date) => {
				const dayNum = getDay(date);
				return dayNum >= 1 && dayNum <= 5;
			}).length;

			if (weekdaysCount > 5) {
				toast.error(
					`Erro: O período selecionado contém ${weekdaysCount} dias úteis. Selecione no máximo 5.`
				);
				return;
			}
			if (weekdaysCount === 0) {
				toast.error('Erro: O período selecionado deve conter pelo menos 1 dia útil.');
				return;
			}
		} catch (e) {
			toast.error('Erro: Formato de data inválido.');
			return;
		}

		isActionLoading = true;
		try {
			const createdCardapio = await api.post('cardapios', dataToSend);
			showCreateModal = false;
			await goto(`/cardapios/${createdCardapio.id}`);
		} catch (e: any) {
			const errorMessage = e?.message || 'Erro ao criar o cardápio.';
			toast.error(errorMessage);
			console.error(e);
		} finally {
			isActionLoading = false;
		}
	}

	function handleViewEdit(id: string) {
		goto(`/cardapios/${id}`);
	}

	function openConfirmDeleteModal(cardapio: CardapioListItem) {
		if (isActionLoading) return;
		cardapioToDelete = cardapio;
		confirmMessage = `Tem certeza que deseja excluir o cardápio "${cardapio.name}"? Esta ação não pode ser desfeita.`;
		showConfirmModal = true;
	}

	async function handleConfirmDelete() {
		if (!cardapioToDelete || isActionLoading) return;
		const idToDelete = cardapioToDelete.id;
		showConfirmModal = false;
		isActionLoading = true;
		try {
			await api.del(`cardapios/${idToDelete}`);
			cardapios = cardapios.filter((c) => c.id !== idToDelete);
			toast.success('Cardápio excluído com sucesso.');
		} catch (e: any) {
			const errorMessage = e?.message || 'Falha ao excluir o cardápio.';
			toast.error(errorMessage);
			console.error(e);
		} finally {
			isActionLoading = false;
			cardapioToDelete = null;
		}
	}

	function onCancelDelete() {
		showConfirmModal = false;
		cardapioToDelete = null;
	}

	function formatLocalDate(dateString: string): string {
		if (!dateString) return 'N/A';
		try {
			const date = parseISO(dateString);
			return format(date, 'dd/MM/yyyy', { locale: ptBR });
		} catch (e) {
			console.error('Erro ao formatar data:', dateString, e);
			return 'Data Inválida';
		}
	}

	const diaMap: { [key: number]: string } = { 1: 'Seg', 2: 'Ter', 3: 'Qua', 4: 'Qui', 5: 'Sex' };
	function getWeekdays(startDate: string, endDate: string): string[] {
		try {
			const start = parseISO(startDate);
			const end = parseISO(endDate);
			const days = eachDayOfInterval({ start, end });
			
			return days
				.map((date) => getDay(date))
				.filter((dayNum) => dayNum >= 1 && dayNum <= 5)
				.map((dayNum) => diaMap[dayNum]);
		} catch (e) {
			return [];
		}
	}
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-4 lg:p-6 space-y-6 animate-fadeIn">
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border">
        <div>
            <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
                Cardápios Semanais
            </h1>
            {#if $session?.profile === 'nutricionista'}
                <p class="text-gray-600 mt-1 text-sm">Crie, gerencie e distribua os cardápios da escola.</p>
            {:else}
                <p class="text-gray-600 mt-1 text-sm">Consulte os cardápios disponíveis desta semana.</p>
            {/if}
        </div>
        {#if $session?.profile === 'nutricionista'}
            <button on:click={handleNovoCardapio} disabled={isActionLoading} class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95 disabled:opacity-50">
                <CalendarPlus class="w-5 h-5" /> Novo Cardápio
            </button>
        {/if}
    </div>

    {#if isLoading}
        <div class="flex justify-center items-center p-10"><p class="text-gray-500 text-lg animate-pulse">⏳ Carregando...</p></div>
    {:else if cardapios.length === 0}
        <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300">
            <p class="text-gray-600 font-semibold text-lg">Nenhum cardápio.</p>
            {#if $session?.profile === 'nutricionista'}
                <p class="text-sm text-gray-400 mt-2">Clique em “Novo Cardápio” para começar.</p>
            {/if}
        </div>
    {:else}
        <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-6">
            {#each cardapios as cardapio (cardapio.id)}
                {@const weekdays = getWeekdays(cardapio.startDate, cardapio.endDate)}
                <div class="bg-white rounded-2xl shadow-lg border border-gray-100 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex flex-col">
                    <div class="p-5 border-b border-gray-100">
                        <span class="inline-block mb-3 px-3 py-1 rounded-full text-xs font-bold shadow-sm {cardapio.status === 'publicado' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}">
                            {cardapio.status === 'publicado' ? 'Publicado' : 'Rascunho'}
                        </span>
                        <h3 class="text-2xl font-bold text-gray-800 truncate" title={cardapio.name}>{cardapio.name}</h3>
                        <p class="text-sm text-gray-500 mt-1">Criado por {cardapio.createdBy?.name || '(Usuário Excluído)'}</p>
                    </div>

                    <div class="p-5 flex-1">
                        <span class="text-xs font-semibold text-gray-400 uppercase tracking-wider flex items-center gap-2">
                            <CalendarDays class="w-4 h-4" /> Dias Inclusos
                        </span>
                        <div class="flex flex-wrap gap-2 mt-3">
                            {#if weekdays.length > 0}
                                {#each weekdays as dia}
                                    <span class="px-3 py-1 bg-primary-50 text-primary-700 text-sm font-semibold rounded-full">{dia}</span>
                                {/each}
                            {:else}
                                <span class="text-sm text-gray-400 italic">(Nenhum dia útil no período)</span>
                            {/if}
                        </div>
                    </div>

                    <div class="bg-gray-50 p-4 rounded-b-2xl border-t mt-auto flex justify-end items-center gap-3">
                        {#if $session?.profile === 'nutricionista'}
                            <button on:click={() => handleViewEdit(cardapio.id)} disabled={isActionLoading} class="action-btn text-primary-600 bg-primary-100 hover:bg-primary-200">
                                <Edit class="w-4 h-4" /> {cardapio.status === 'rascunho' ? 'Gerenciar' : 'Visualizar'}
                            </button>
                            <button on:click={() => openConfirmDeleteModal(cardapio)} disabled={isActionLoading} class="action-btn text-red-600 bg-red-100 hover:bg-red-200">
                                <Trash2 class="w-4 h-4" />
                            </button>
                        {:else}
                            <button on:click={() => handleViewEdit(cardapio.id)} disabled={isActionLoading} class="action-btn text-primary-600 bg-primary-100 hover:bg-primary-200">
                                <Eye class="w-4 h-4" /> Visualizar
                            </button>
                        {/if}
                    </div>
                </div>
            {/each}
        </div>
    {/if}
</div>

{#if showCreateModal}
	<Modal show={showCreateModal} on:close={() => (showCreateModal = false)} size="max-w-2xl">
		<CardapioForm
			bind:cardapio={newCardapioData}
			isEditing={false}
			on:save={handleSaveNewCardapio}
			on:cancel={() => (showCreateModal = false)}
		/>
	</Modal>
{/if}

<Modal show={showConfirmModal} on:close={onCancelDelete} size="max-w-md">
	<ConfirmDialog
		title="Excluir Cardápio"
		message={confirmMessage}
		confirmText="Sim, Excluir"
		on:confirm={handleConfirmDelete}
		on:cancel={onCancelDelete}
	/>
</Modal>

<style>
	@keyframes fadeIn {
		from {
			opacity: 0;
			transform: scale(0.98);
		}
		to {
			opacity: 1;
			transform: scale(1);
		}
	}
	.animate-fadeIn {
		animation: fadeIn 0.25s ease-out;
	}

	.action-btn {
		display: inline-flex;
		align-items: center;
		gap: 0.4rem;
		font-weight: 600;
		font-size: 0.875rem;
		padding: 0.5rem 0.75rem;
		border-radius: 9999px;
		transition: all 0.2s ease-in-out;
		/* 'disabled: opacity-50;' foi removido daqui */
	}

	/* --- CORREÇÃO 3: Adicionado seletor :disabled --- */
	.action-btn:disabled {
		opacity: 0.5;
	}
	/* --- FIM DA CORREÇÃO 3 --- */

	.action-btn:hover:not(:disabled) {
		transform: scale(1.05);
	}
	.action-btn:active:not(:disabled) {
		transform: scale(0.95);
	}
</style>