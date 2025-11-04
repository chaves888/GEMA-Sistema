<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  // --- ADICIONADO: 'eachDayOfInterval' e 'getDay' para a nova validação ---
  import { format, parseISO, eachDayOfInterval, getDay } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import Modal from '$lib/components/Modal.svelte';
  import CardapioForm from '$lib/components/CardapioForm.svelte';
  import { CalendarPlus, Edit, Eye, Trash2 } from 'lucide-svelte';
  import { goto } from '$app/navigation';

  import { toast } from '$lib/toast';
  import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';

  type CardapioListItem = {
    id: string;
    name: string;
    startDate: string;
    endDate: string;
    status: 'rascunho' | 'publicado';
    createdBy: { name: string };
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
    } catch (e) {
      error = 'Não foi possível carregar os cardápios.';
      console.error(e);
      toast.error(error);
    } finally {
      isLoading = false;
    }
  }

  function handleNovoCardapio() {
    const today = new Date().toISOString().split('T')[0];
    newCardapioData = { startDate: today, endDate: today };
    showCreateModal = true;
  }

  // --- FUNÇÃO ATUALIZADA COM TODAS AS VALIDAÇÕES ---
  async function handleSaveNewCardapio(event: any) {
    const dataToSend = event.detail;

    // Pega a data de hoje no formato YYYY-MM-DD (sem fuso horário)
    const today = new Date().toISOString().split('T')[0];

    // 1. Validação de data de início (igual ao backend)
    if (dataToSend.startDate < today) {
      toast.error('A data de início não pode ser anterior à data atual.');
      return; // Para a execução aqui
    }

    // 2. Validação de data de fim (igual ao backend)
    if (dataToSend.endDate < dataToSend.startDate) {
      toast.error('A data de fim não pode ser anterior à data de início.');
      return; // Para a execução aqui
    }

    // 3. Validação de 5 dias úteis (movida do CardapioForm)
    try {
      const start = parseISO(dataToSend.startDate);
      const end = parseISO(dataToSend.endDate);
      const daysInInterval = eachDayOfInterval({ start, end });
      const weekdaysCount = daysInInterval.filter((date) => {
        const dayNum = getDay(date);
        return dayNum >= 1 && dayNum <= 5; // Conta Segunda (1) a Sexta (5)
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
    // --- FIM DAS VALIDAÇÕES ---

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
      return format(date, 'dd/MM/yy', { locale: ptBR });
    } catch (e) {
      console.error('Erro ao formatar data:', dateString, e);
      return 'Data Inválida';
    }
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-6 space-y-6 animate-fadeIn">
  <div
    class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border"
  >
    <div>
      <h1
        class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent"
      >
        Cardápios Semanais
      </h1>
      {#if $session?.profile === 'nutricionista'}
        <p class="text-gray-600 mt-1 text-sm">Crie, gerencie e distribua os cardápios da escola.</p>
      {:else}
        <p class="text-gray-600 mt-1 text-sm">Consulte os cardápios disponíveis desta semana.</p>
      {/if}
    </div>
    {#if $session?.profile === 'nutricionista'}
      <button
        on:click={handleNovoCardapio}
        disabled={isActionLoading}
        class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95 disabled:opacity-50"
      >
        <CalendarPlus class="w-5 h-5" /> Novo Cardápio
      </button>
    {/if}
  </div>

  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando...</p>
    </div>
  {:else if error && cardapios.length === 0}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">
      {error}
    </div>
  {:else if cardapios.length === 0}
    <div
      class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300"
    >
      <p class="text-gray-600 font-semibold text-lg">Nenhum cardápio.</p>
      {#if $session?.profile === 'nutricionista'}
        <p class="text-sm text-gray-400 mt-2">Clique em “Novo Cardápio” para começar.</p>
      {:else}
        <p class="text-sm text-gray-400 mt-2">Aguardando envio.</p>
      {/if}
    </div>
  {:else}
    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-8">
      {#each cardapios as cardapio (cardapio.id)}
        <div
          class="bg-white rounded-2xl shadow-md border border-gray-100 hover:shadow-xl hover:-translate-y-1 transition-all duration-200 overflow-hidden flex flex-col"
        >
          <div class="p-6 flex-1">
            <span
              class="inline-block mb-2 px-2.5 py-0.5 rounded-full text-xs font-semibold shadow-sm {cardapio.status ===
              'publicado'
                ? 'bg-green-100 text-green-800 border border-green-300'
                : 'bg-yellow-100 text-yellow-800 border border-yellow-300'}"
            >
              {cardapio.status === 'publicado' ? 'Publicado' : 'Rascunho'}
            </span>
            <h3 class="font-bold text-lg text-gray-800 truncate">{cardapio.name}</h3>
            <p class="text-xs text-gray-400 mt-3">
              👩‍🍳 Criado por {cardapio.createdBy?.name || 'N/A'}
            </p>
          </div>
          <div
            class="bg-gray-50 p-4 text-right rounded-b-2xl border-t mt-auto flex justify-end items-center gap-4"
          >
            {#if $session?.profile === 'nutricionista'}
              <button
                on:click={() => handleViewEdit(cardapio.id)}
                disabled={isActionLoading}
                class="inline-flex items-center gap-1.5 text-primary-600 hover:text-primary-700 font-semibold text-sm transition-colors disabled:opacity-50"
              >
                <Edit class="w-4 h-4" />
                {cardapio.status === 'rascunho' ? 'Gerenciar' : 'Visualizar'}
              </button>

              <button
                on:click={() => openConfirmDeleteModal(cardapio)}
                disabled={isActionLoading}
                class="inline-flex items-center gap-1.5 text-red-500 hover:text-red-700 font-semibold text-sm transition-colors disabled:opacity-50"
              >
                <Trash2 class="w-4 h-4" />
                Excluir
              </button>
            {:else}
              <button
                on:click={() => handleViewEdit(cardapio.id)}
                disabled={isActionLoading}
                class="inline-flex items-center gap-1.5 text-gray-600 hover:text-gray-800 font-semibold text-sm transition-colors disabled:opacity-50"
              >
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
</style>