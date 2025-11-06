<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  // --- Ajustar tipo Cardapio para incluir holidayWeekdays ---
  import type { Cardapio as CardapioType, Refeicao } from '$lib/types';
  import { session } from '$lib/sessionStore';
  // --- Importar mais helpers de data ---
  import { format, parseISO, eachDayOfInterval, getDay, addDays } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  // --- Importar mais ícones ---
  import { PlusCircle, Edit, Trash2, ArrowLeft, Send, CalendarOff } from 'lucide-svelte';
  import Modal from '$lib/components/Modal.svelte';
  import RefeicaoForm from '$lib/components/RefeicaoForm.svelte';

  // --- Imports Adicionados ---
  import { toast } from '$lib/toast';
  import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';
  // --- Fim dos Imports ---

  // --- Ajustar tipo Cardapio para incluir holidayWeekdays ---
  type Cardapio = CardapioType & { holidayWeekdays?: string[] };

  const diaSemanaMap: { [key: number]: string } = {
    1: 'segunda',
    2: 'terça',
    3: 'quarta',
    4: 'quinta',
    5: 'sexta',
  };
  const DIAS_SEMANA_ORDEM = ['segunda', 'terça', 'quarta', 'quinta', 'sexta'];

  let cardapio: Cardapio | null = null;
  let isLoading = true;
  let isActionLoading = false; // Para ações gerais (publicar)
  let isHolidayLoading: Record<string, boolean> = {}; // Loading por dia para feriado
  let isRefeicaoActionLoading: Record<string, boolean> = {}; // Loading por refeição (excluir)
  let error: string | null = null;

  // --- Mapa para guardar a data específica de cada dia da semana ---
  let diaSemanaParaData: Record<string, Date> = {};

  let diasDaSemanaDoCardapio: string[] = [];
  let refeicoesGrid: Record<string, Record<string, Refeicao | null>> = {};

  // --- Estado dos Modais ---
  let showRefeicaoModal = false;
  let modalData: {
    diaSemana: 'segunda' | 'terça' | 'quarta' | 'quinta' | 'sexta';
    tipo: 'manha' | 'tarde';
    refeicao: Refeicao | null;
  } | null = null;

  // --- ADICIONADO: Estado para o Modal de Confirmação GENÉRICO ---
  let showConfirmModal = false;
  let confirmTitle = '';
  let confirmMessage = '';
  let confirmButtonText = 'Confirmar';
  // Esta ação guarda a função que deve ser executada ao confirmar
  let confirmAction: () => Promise<void> | void = () => {};
  // --- FIM DA ADIÇÃO ---

  // --- Lógica reativa para verificar se pode publicar ---
  let canPublish = false;
  $: if (cardapio && cardapio.status === 'rascunho') {
    canPublish = diasDaSemanaDoCardapio.every((dia) => {
      if (cardapio?.holidayWeekdays?.includes(dia)) return true;
      return !!refeicoesGrid[dia]?.manha && !!refeicoesGrid[dia]?.tarde;
    });
  } else {
    canPublish = false;
  }
  // --- FIM LÓGICA REATIVA ---

  onMount(async () => {
    await loadCardapio();
  });

  async function loadCardapio() {
    isLoading = true;
    error = null;
    const id = $page.params.id;
    try {
      cardapio = await api.get(`cardapios/${id}`);
      if (cardapio) {
        setupDatesAndMeals(cardapio);
      } else {
        throw new Error('Cardápio não encontrado.');
      }
    } catch (e: any) {
      error = e.message || 'Não foi possível carregar o cardápio.';
      console.error(e);
      // Aqui o toast não é necessário, pois a UI exibe o 'error'
    } finally {
      isLoading = false;
    }
  }

  // --- Calcula datas específicas e organiza grid ---
  function setupDatesAndMeals(currentCardapio: Cardapio) {
    const start = parseISO(currentCardapio.startDate);
    const end = parseISO(currentCardapio.endDate);
    const tempDiaSemanaParaData: Record<string, Date> = {};
    const tempDiasDaSemanaDoCardapio: string[] = [];

    if (end < start) {
      diasDaSemanaDoCardapio = [];
      diaSemanaParaData = {};
      organizeRefeicoes([], []);
      return;
    }

    const days = eachDayOfInterval({ start, end });
    days.forEach((date) => {
      const dayNum = getDay(date);
      if (dayNum >= 1 && dayNum <= 5) {
        const diaStr = diaSemanaMap[dayNum];
        if (!tempDiaSemanaParaData[diaStr]) {
          tempDiaSemanaParaData[diaStr] = date;
          tempDiasDaSemanaDoCardapio.push(diaStr);
        }
      }
    });

    tempDiasDaSemanaDoCardapio.sort(
      (a, b) => DIAS_SEMANA_ORDEM.indexOf(a) - DIAS_SEMANA_ORDEM.indexOf(b)
    );
    diasDaSemanaDoCardapio = tempDiasDaSemanaDoCardapio;
    diaSemanaParaData = tempDiaSemanaParaData;
    organizeRefeicoes(currentCardapio.refeicoes || [], diasDaSemanaDoCardapio);
  }

  // Função organizeRefeicoes atualizada para receber os dias
  function organizeRefeicoes(refeicoes: Refeicao[] = [], diasAtuais: string[]) {
    const grid: Record<string, Record<string, Refeicao | null>> = {};
    for (const dia of diasAtuais) {
      grid[dia] = {};
      grid[dia]['manha'] = refeicoes.find((r) => r.diaSemana === dia && r.tipo === 'manha') || null;
      grid[dia]['tarde'] = refeicoes.find((r) => r.diaSemana === dia && r.tipo === 'tarde') || null;
    }
    refeicoesGrid = grid;
  }

  function formatLocalDate(dateString: string): string {
    if (!dateString) return 'N/A';
    try {
      const date = parseISO(dateString);
      return format(date, 'dd/MM/yyyy', { locale: ptBR });
    } catch (e) {
      return 'Data Inválida';
    }
  }

  // --- ADICIONADO: Funções para o Modal de Confirmação GENÉRICO ---
  function openConfirmModal(
    title: string,
    message: string,
    action: () => Promise<void> | void,
    buttonText: string = 'Confirmar'
  ) {
    confirmTitle = title;
    confirmMessage = message;
    confirmAction = action;
    confirmButtonText = buttonText;
    showConfirmModal = true;
  }

  async function handleConfirm() {
    await confirmAction(); // Executa a ação armazenada
    handleCancel(); // Fecha e limpa o modal
  }

  function handleCancel() {
    showConfirmModal = false;
    confirmTitle = '';
    confirmMessage = '';
    confirmButtonText = 'Confirmar';
    confirmAction = () => {};
  }
  // --- FIM DA ADIÇÃO ---

  // --- AÇÕES DA NUTRICIONISTA ---
  function handleAddRefeicao(dia: string, tipo: string) {
    if (
      !$session ||
      $session.profile !== 'nutricionista' ||
      cardapio?.status === 'publicado' ||
      cardapio?.holidayWeekdays?.includes(dia)
    )
      return;
    modalData = { diaSemana: dia as any, tipo: tipo as any, refeicao: null };
    showRefeicaoModal = true;
  }
  function handleEditRefeicao(refeicao: Refeicao) {
    if (
      !$session ||
      $session.profile !== 'nutricionista' ||
      cardapio?.status === 'publicado' ||
      cardapio?.holidayWeekdays?.includes(refeicao.diaSemana)
    )
      return;
    modalData = { diaSemana: refeicao.diaSemana, tipo: refeicao.tipo, refeicao: refeicao };
    showRefeicaoModal = true;
  }
  function onRefeicaoSaved(event: any) {
    const savedRefeicao: Refeicao = event.detail;
    refeicoesGrid[savedRefeicao.diaSemana][savedRefeicao.tipo] = savedRefeicao;
    refeicoesGrid = { ...refeicoesGrid };
    if (cardapio) {
      const index = cardapio.refeicoes.findIndex(
        (r) => r.diaSemana === savedRefeicao.diaSemana && r.tipo === savedRefeicao.tipo
      );
      if (index > -1) {
        cardapio.refeicoes[index] = savedRefeicao;
      } else {
        cardapio.refeicoes.push(savedRefeicao);
      }
      cardapio.refeicoes = [...cardapio.refeicoes];
    }
    showRefeicaoModal = false;
    modalData = null;
    toast.success('Refeição salva com sucesso!'); // Toast de sucesso
  }

  async function handleDeleteRefeicao(refeicao: Refeicao) {
    const refeicaoId = refeicao.id;
    if (
      !$session ||
      $session.profile !== 'nutricionista' ||
      cardapio?.status === 'publicado' ||
      isActionLoading ||
      isRefeicaoActionLoading[refeicaoId] ||
      cardapio?.holidayWeekdays?.includes(refeicao.diaSemana)
    )
      return;

    // --- ALTERADO: 'confirm' removido, lógica movida para 'action' ---
    const deleteAction = async () => {
      isRefeicaoActionLoading = { ...isRefeicaoActionLoading, [refeicaoId]: true };
      try {
        await api.del(`cardapios/refeicoes/${refeicao.id}`);
        refeicoesGrid[refeicao.diaSemana][refeicao.tipo] = null;
        refeicoesGrid = { ...refeicoesGrid };
        if (cardapio) {
          cardapio.refeicoes = cardapio.refeicoes.filter((r) => r.id !== refeicao.id);
        }
        toast.success('Refeição removida com sucesso.'); // <-- TROCA
      } catch (e: any) {
        toast.error(e?.message || 'Erro ao remover a refeição.'); // <-- TROCA
        console.error(e);
      } finally {
        isRefeicaoActionLoading = { ...isRefeicaoActionLoading, [refeicaoId]: false };
      }
    };

    openConfirmModal(
      'Remover Refeição',
      `Tem certeza que deseja remover a refeição "${refeicao.description}" de ${refeicao.diaSemana} (${refeicao.tipo})?`,
      deleteAction,
      'Sim, Remover'
    );
    // --- FIM DA ALTERAÇÃO ---
  }

  async function handleToggleHoliday(dia: string) {
    if (!cardapio || cardapio.status === 'publicado' || isActionLoading || isHolidayLoading[dia])
      return;
    
    const currentlyIsHoliday = cardapio.holidayWeekdays?.includes(dia);
    const actionText = currentlyIsHoliday ? 'desmarcar como feriado' : 'marcar como FERIADO';
    const cardapioId = cardapio.id;

    // --- ALTERADO: 'confirm' removido, lógica movida para 'action' ---
    const toggleAction = async () => {
      isHolidayLoading = { ...isHolidayLoading, [dia]: true };
      try {
        const updatedCardapio = await api.patch(`cardapios/${cardapioId}/holiday`, {
          diaSemana: dia,
          isHoliday: !currentlyIsHoliday,
        });
        if (cardapio) {
          cardapio.holidayWeekdays = updatedCardapio.holidayWeekdays;
          cardapio = { ...cardapio };
        }
        toast.success(`Dia ${currentlyIsHoliday ? 'desmarcado' : 'marcado'} como feriado.`); // <-- TROCA
      } catch (e: any) {
        toast.error(e?.message || `Erro ao ${actionText}.`); // <-- TROCA
        console.error(e);
      } finally {
        isHolidayLoading = { ...isHolidayLoading, [dia]: false };
      }
    };

    openConfirmModal(
      'Alterar Feriado',
      `Tem certeza que deseja ${actionText} para ${dia}?`,
      toggleAction,
      currentlyIsHoliday ? 'Sim, Desmarcar' : 'Sim, Marcar'
    );
    // --- FIM DA ALTERAÇÃO ---
  }

  async function handlePublish() {
    if (!cardapio || isActionLoading || cardapio.status === 'publicado' || !canPublish) return;

    const cardapioId = cardapio.id;

    // --- ALTERADO: 'confirm' removido, lógica movida para 'action' ---
    const publishAction = async () => {
      isActionLoading = true;
      try {
        const publishedCardapio = await api.patch(`cardapios/${cardapioId}/publish`, {});
        if (cardapio) {
          cardapio.status = publishedCardapio.status;
          cardapio = { ...cardapio };
        }
        toast.success('Cardápio publicado com sucesso!'); // <-- TROCA
      } catch (e: any) {
        toast.error(e?.message || 'Erro ao publicar o cardápio.'); // <-- TROCA
        console.error(e);
      } finally {
        isActionLoading = false;
      }
    };

    openConfirmModal(
      'Publicar Cardápio',
      'Tem certeza que deseja PUBLICAR este cardápio? Após a publicação, ele não poderá mais ser editado e os feriados não poderão ser alterados.',
      publishAction,
      'Sim, Publicar'
    );
    // --- FIM DA ALTERAÇÃO ---
  }

  $: gridColsClass =
    diasDaSemanaDoCardapio.length >= 5
      ? 'lg:grid-cols-5'
      : diasDaSemanaDoCardapio.length === 4
        ? 'lg:grid-cols-4'
        : 'lg:grid-cols-3';
</script>

<div class="space-y-6 animate-fadeIn pb-10">
  <div class="mb-2">
    <a
      href="/cardapios"
      class="inline-flex items-center gap-2 text-sm text-primary-600 hover:text-primary-800 font-semibold transition-all group"
    >
      <ArrowLeft class="w-4 h-4 transition-transform group-hover:-translate-x-1" /> Voltar
    </a>
  </div>

  {#if isLoading}
    <div class="text-center py-10">
      <p class="text-gray-500 text-lg font-medium">⏳ Carregando...</p>
    </div>
  {:else if error}
    <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm font-medium">
      {error}
    </div>
  {:else if cardapio}
    <div
      class="flex flex-col md:flex-row justify-between items-start gap-4 bg-gradient-to-r from-primary-50 to-white p-6 rounded-xl shadow-md border border-gray-100"
    >
      <div class="space-y-2">
        <h1 class="text-3xl font-bold text-gray-900 tracking-tight">{cardapio.name}</h1>
        <p class="text-sm text-gray-400">
          Criado por: <span class="font-medium text-gray-600">{cardapio.createdBy?.name || '(Usuário Excluído)'}</span>
        </p>
        <span
          class="inline-block px-3 py-1 rounded-full text-xs font-semibold shadow-sm {cardapio.status ===
          'publicado'
            ? 'bg-green-100 text-green-800 border border-green-300'
            : 'bg-yellow-100 text-yellow-800 border border-yellow-300'}"
        >
          {cardapio.status === 'publicado' ? 'Publicado' : 'Rascunho'}
        </span>
      </div>
      {#if $session?.profile === 'nutricionista' && cardapio.status === 'rascunho'}
        <button
          on:click={handlePublish}
          disabled={isActionLoading || !canPublish}
          class="flex items-center gap-2 bg-green-600 hover:bg-green-700 active:scale-95 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          title={!canPublish
            ? 'Preencha todas as refeições (manhã e tarde) dos dias úteis não feriados para poder publicar.'
            : 'Publicar cardápio'}
        >
          <Send class="w-5 h-5" /> Publicar
        </button>
      {/if}
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 {gridColsClass} gap-6 mt-4">
      {#each diasDaSemanaDoCardapio as dia (dia)}
        {@const isHoliday = cardapio?.holidayWeekdays?.includes(dia)}
        {@const specificDate = diaSemanaParaData[dia]}
        <div
          class="bg-white rounded-xl border border-gray-100 shadow-sm hover:shadow-lg hover:scale-[1.01] transition-all overflow-hidden flex flex-col {isHoliday
            ? 'bg-gray-100 opacity-70'
            : ''}"
        >
          <div
            class="bg-gradient-to-r from-primary-600/10 to-primary-50 p-3 border-b text-center relative min-h-[70px] flex flex-col justify-center"
          >
            <h2 class="text-lg font-semibold text-primary-700 capitalize tracking-wide">
              {dia}{specificDate ? ` - ${format(specificDate, 'dd/MM')}` : ''}
            </h2>
            {#if isHoliday}
              <span
                class="absolute top-2 right-2 text-xs bg-gray-500 text-white px-2 py-0.5 rounded font-semibold shadow-sm"
                >FERIADO</span
              >
            {/if}
            {#if $session?.profile === 'nutricionista' && cardapio?.status === 'rascunho'}
              <button
                on:click={() => handleToggleHoliday(dia)}
                disabled={isActionLoading || isHolidayLoading[dia]}
                class="absolute top-2 left-2 p-1 rounded-full hover:bg-white/50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-primary-400"
                title={isHoliday ? 'Desmarcar como feriado' : 'Marcar como feriado'}
              >
                {#if isHolidayLoading[dia]}
                  <svg
                    class="animate-spin h-5 w-5 text-primary-600"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <circle
                      class="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      stroke-width="4"
                    ></circle>
                    <path
                      class="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                    ></path>
                  </svg>
                {:else}
                  <CalendarOff
                    class="w-5 h-5 {isHoliday
                      ? 'text-red-600'
                      : 'text-gray-400 hover:text-gray-600'}"
                  />
                {/if}
              </button>
            {/if}
          </div>

          <div class="flex flex-col divide-y flex-1">
            <div class="p-5 space-y-3 min-h-[150px] flex flex-col">
              <h4 class="font-semibold text-primary-700 flex items-center gap-1">☀️ Manhã</h4>
              {#if refeicoesGrid[dia]?.manha && !isHoliday}
                {@const refeicao = refeicoesGrid[dia]['manha']}
                <div
                  class="text-sm text-gray-700 bg-gray-50 rounded-lg p-3 shadow-inner border border-gray-100 flex-1"
                >
                  <p class="text-base font-medium italic text-gray-800 mb-1">
                    “{refeicao.description}”
                  </p>
                  <ul class="list-disc list-inside text-sm text-gray-600 space-y-1">
                    {#each refeicao.products as item (item.id)}
                      <li>{item?.name || '(Produto Excluído)' }</li>
                    {/each}
                  </ul>
                  {#if $session?.profile === 'nutricionista' && cardapio?.status === 'rascunho'}
                    <div class="flex gap-3 mt-3 pt-2 border-t border-gray-200">
                      <button
                        on:click={() => handleEditRefeicao(refeicao)}
                        class="text-xs text-primary-600 hover:underline font-medium disabled:opacity-50"
                        disabled={isHoliday || isRefeicaoActionLoading[refeicao.id]}>Editar</button
                      >
                      <button
                        on:click={() => handleDeleteRefeicao(refeicao)}
                        class="text-xs text-red-500 hover:underline font-medium disabled:opacity-50"
                        disabled={isHoliday || isRefeicaoActionLoading[refeicao.id]}
                      >
                        {#if isRefeicaoActionLoading[refeicao.id]}...{:else}Remover{/if}
                      </button>
                    </div>
                  {/if}
                </div>
              {:else if $session?.profile === 'nutricionista' && cardapio?.status === 'rascunho' && !isHoliday}
                <button
                  on:click={() => handleAddRefeicao(dia, 'manha')}
                  disabled={isActionLoading || isHoliday}
                  class="w-full flex-1 flex items-center justify-center gap-2 text-sm text-gray-500 hover:bg-primary-50 border-2 border-dashed border-primary-200 rounded-lg py-3 transition disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <PlusCircle class="w-4 h-4 text-primary-500" /> Adicionar
                </button>
              {:else if !isHoliday}
                <p class="text-sm text-gray-400 italic flex-1 flex items-center justify-center">
                  (Sem refeição)
                </p>
              {:else}
                <p class="text-sm text-gray-400 italic flex-1 flex items-center justify-center">
                  (Feriado)
                </p>
              {/if}
            </div>
            <div class="p-5 space-y-3 min-h-[150px] flex flex-col">
              <h4 class="font-semibold text-primary-700 flex items-center gap-1">🌇 Tarde (15h)</h4>
              {#if refeicoesGrid[dia]?.tarde && !isHoliday}
                {@const refeicao = refeicoesGrid[dia]['tarde']}
                <div
                  class="text-sm text-gray-700 bg-gray-50 rounded-lg p-3 shadow-inner border border-gray-100 flex-1"
                >
                  <p class="text-base font-medium italic text-gray-800 mb-1">
                    “{refeicao.description}”
                  </p>
                  <ul class="list-disc list-inside text-sm text-gray-600 space-y-1">
                    {#each refeicao.products as item (item.id)}
                      <li>{item?.name || '(Produto Excluído)' }</li>
                    {/each}
                  </ul>
                  {#if $session?.profile === 'nutricionista' && cardapio?.status === 'rascunho'}
                    <div class="flex gap-3 mt-3 pt-2 border-t border-gray-200">
                      <button
                        on:click={() => handleEditRefeicao(refeicao)}
                        class="text-xs text-primary-600 hover:underline font-medium disabled:opacity-50"
                        disabled={isHoliday || isRefeicaoActionLoading[refeicao.id]}>Editar</button
                      >
                      <button
                        on:click={() => handleDeleteRefeicao(refeicao)}
                        class="text-xs text-red-500 hover:underline font-medium disabled:opacity-50"
                        disabled={isHoliday || isRefeicaoActionLoading[refeicao.id]}
                      >
                        {#if isRefeicaoActionLoading[refeicao.id]}...{:else}Remover{/if}
                      </button>
                    </div>
                  {/if}
                </div>
              {:else if $session?.profile === 'nutricionista' && cardapio?.status === 'rascunho' && !isHoliday}
                <button
                  on:click={() => handleAddRefeicao(dia, 'tarde')}
                  disabled={isActionLoading || isHoliday}
                  class="w-full flex-1 flex items-center justify-center gap-2 text-sm text-gray-500 hover:bg-primary-50 border-2 border-dashed border-primary-200 rounded-lg py-3 transition disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  <PlusCircle class="w-4 h-4 text-primary-500" /> Adicionar
                </button>
              {:else if !isHoliday}
                <p class="text-sm text-gray-400 italic flex-1 flex items-center justify-center">
                  (Sem refeição)
                </p>
              {:else}
                <p class="text-sm text-gray-400 italic flex-1 flex items-center justify-center">
                  (Feriado)
                </p>
              {/if}
            </div>
          </div>
        </div>
      {/each}
    </div>
  {:else}
    <div class="text-center p-10 bg-white rounded-lg shadow-sm border">
      <p class="text-gray-500 font-medium">Cardápio não encontrado.</p>
    </div>
  {/if}
</div>

{#if showRefeicaoModal && modalData && cardapio}
  <Modal
    show={showRefeicaoModal}
    on:close={() => (showRefeicaoModal = false)}
    size="max-w-2xl"
    showCloseButton={true}
  >
    <RefeicaoForm
      cardapioId={cardapio.id}
      diaSemana={modalData.diaSemana}
      tipo={modalData.tipo}
      refeicao={modalData.refeicao}
      on:save={onRefeicaoSaved}
      on:cancel={() => (showRefeicaoModal = false)}
    />
  </Modal>
{/if}

<Modal show={showConfirmModal} on:close={handleCancel} size="max-w-md">
  <ConfirmDialog
    title={confirmTitle}
    message={confirmMessage}
    confirmText={confirmButtonText}
    on:confirm={handleConfirm}
    on:cancel={handleCancel}
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