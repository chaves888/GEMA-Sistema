<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import type { Cardapio, Refeicao } from '$lib/types';
  import { session } from '$lib/sessionStore';
  import { format, parseISO, eachDayOfInterval, getDay } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import { PlusCircle, Edit, Trash2, ArrowLeft, Send } from 'lucide-svelte';
  import Modal from '$lib/components/Modal.svelte';
  import RefeicaoForm from '$lib/components/RefeicaoForm.svelte';

  const diaSemanaMap: { [key: number]: string } = {
    1: 'segunda',
    2: 'terca',
    3: 'quarta',
    4: 'quinta',
    5: 'sexta',
  };
  const DIAS_SEMANA_ORDEM = ['segunda', 'terca', 'quarta', 'quinta', 'sexta'];

  let cardapio: Cardapio | null = null;
  let isLoading = true;
  let isActionLoading = false;
  let error: string | null = null;

  let diasDaSemanaDoCardapio: string[] = [];
  let refeicoesGrid: Record<string, Record<string, Refeicao | null>> = {};

  // --- Estado dos Modais ---
  let showRefeicaoModal = false;
  let modalData: {
    diaSemana: 'segunda' | 'terca' | 'quarta' | 'quinta' | 'sexta';
    tipo: 'manha' | 'tarde';
    refeicao: Refeicao | null;
  } | null = null;
  // --- Fim Estado Modais ---

  onMount(async () => {
    await loadCardapio();
  });

  async function loadCardapio() {
    isLoading = true;
    const id = $page.params.id;
    try {
      cardapio = await api.get(`cardapios/${id}`);
      if (cardapio) {
        diasDaSemanaDoCardapio = getDiasDaSemanaNoIntervalo(cardapio.startDate, cardapio.endDate);
        organizeRefeicoes(cardapio.refeicoes || []);
      } else {
        throw new Error('Cardápio não encontrado.');
      }
    } catch (e: any) {
      error = e.message || 'Não foi possível carregar o cardápio.';
      console.error(e);
    } finally {
      isLoading = false;
    }
  }

  function getDiasDaSemanaNoIntervalo(start: string, end: string): string[] {
    const startDate = parseISO(start);
    const endDate = parseISO(end);

    if (endDate < startDate) return [];

    const diasNoIntervalo = eachDayOfInterval({ start: startDate, end: endDate });

    const diasUteis = diasNoIntervalo
      .map(date => getDay(date))
      .filter(dayNumber => dayNumber >= 1 && dayNumber <= 5)
      .map(dayNumber => diaSemanaMap[dayNumber]);

    return DIAS_SEMANA_ORDEM.filter(dia => diasUteis.includes(dia));
  }

  function organizeRefeicoes(refeicoes: Refeicao[] = []) {
    const grid: Record<string, Record<string, Refeicao | null>> = {};
    for (const dia of diasDaSemanaDoCardapio) {
      grid[dia] = {};
      grid[dia]['manha'] = refeicoes.find(r => r.diaSemana === dia && r.tipo === 'manha') || null;
      grid[dia]['tarde'] = refeicoes.find(r => r.diaSemana === dia && r.tipo === 'tarde') || null;
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

  // --- AÇÕES DA NUTRICIONISTA ---

  function handleAddRefeicao(dia: string, tipo: string) {
    if (!$session || $session.profile !== 'nutricionista' || cardapio?.status === 'publicado') return;

    modalData = {
      diaSemana: dia as any,
      tipo: tipo as any,
      refeicao: null,
    };
    showRefeicaoModal = true;
  }

  function handleEditRefeicao(refeicao: Refeicao) {
    if (!$session || $session.profile !== 'nutricionista' || cardapio?.status === 'publicado') return;

    modalData = {
      diaSemana: refeicao.diaSemana,
      tipo: refeicao.tipo,
      refeicao: refeicao,
    };
    showRefeicaoModal = true;
  }

  function onRefeicaoSaved(event: any) {
    const savedRefeicao: Refeicao = event.detail;

    refeicoesGrid[savedRefeicao.diaSemana][savedRefeicao.tipo] = savedRefeicao;
    refeicoesGrid = { ...refeicoesGrid };

    if (cardapio) {
      const index = cardapio.refeicoes.findIndex(r => r.id === savedRefeicao.id);
      if (index > -1) {
        cardapio.refeicoes[index] = savedRefeicao;
      } else {
        cardapio.refeicoes.push(savedRefeicao);
      }
      cardapio.refeicoes = [...cardapio.refeicoes];
    }

    showRefeicaoModal = false;
    modalData = null;
  }

  async function handleDeleteRefeicao(refeicao: Refeicao) {
    if (!$session || $session.profile !== 'nutricionista' || cardapio?.status === 'publicado' || isActionLoading) return;

    if (!confirm(`Tem certeza que deseja remover a refeição "${refeicao.description}" de ${refeicao.diaSemana} (${refeicao.tipo})?`)) {
      return;
    }

    isActionLoading = true;
    try {
      await api.del(`cardapios/refeicoes/${refeicao.id}`);

      refeicoesGrid[refeicao.diaSemana][refeicao.tipo] = null;
      refeicoesGrid = { ...refeicoesGrid };

      if (cardapio) {
        cardapio.refeicoes = cardapio.refeicoes.filter(r => r.id !== refeicao.id);
      }
    } catch (e: any) {
      alert(e?.message || 'Erro ao remover a refeição.');
      console.error(e);
    } finally {
      isActionLoading = false;
    }
  }

  async function handlePublish() {
    if (!cardapio || isActionLoading || cardapio.status === 'publicado') return;
    if (!confirm('Tem certeza que deseja PUBLICAR este cardápio? Após a publicação, ele não poderá mais ser editado ou excluído.')) {
      return;
    }

    isActionLoading = true;
    try {
      const publishedCardapio = await api.patch(`cardapios/${cardapio.id}/publish`, {});
      cardapio.status = publishedCardapio.status;
      alert('Cardápio publicado com sucesso!');
    } catch (e: any) {
      alert(e?.message || 'Erro ao publicar o cardápio.');
      console.error(e);
    } finally {
      isActionLoading = false;
    }
  }

  $: gridColsClass =
    diasDaSemanaDoCardapio.length > 3 ? `lg:grid-cols-${diasDaSemanaDoCardapio.length}` : `lg:grid-cols-3`;
</script>

<div class="space-y-6 animate-fadeIn">
  <div class="mb-2">
    <a href="/cardapios" class="inline-flex items-center gap-2 text-sm text-primary-600 hover:text-primary-800 font-semibold transition-all group">
      <ArrowLeft class="w-4 h-4 transition-transform group-hover:-translate-x-1" />
      Voltar para todos os cardápios
    </a>
  </div>

  {#if isLoading}
    <div class="text-center py-10"><p class="text-gray-500 text-lg font-medium">⏳ Carregando cardápio...</p></div>
  {:else if error}
    <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm font-medium">{error}</div>
  {:else if cardapio}
    <div class="flex flex-col md:flex-row justify-between items-start gap-4 bg-gradient-to-r from-primary-50 to-white p-6 rounded-xl shadow-md border border-gray-100">
      <div class="space-y-2">
        <h1 class="text-3xl font-bold text-gray-900 tracking-tight">{cardapio.name}</h1>
        <p class="text-gray-500">
          <span class="font-semibold text-gray-700">Período:</span>
          {formatLocalDate(cardapio.startDate)} – {formatLocalDate(cardapio.endDate)}
        </p>
        <p class="text-sm text-gray-400">Criado por: <span class="font-medium text-gray-600">{cardapio.createdBy?.name || 'N/A'}</span></p>

        <span
          class="inline-block px-3 py-1 rounded-full text-xs font-semibold shadow-sm {cardapio.status === 'publicado'
            ? 'bg-green-100 text-green-800 border border-green-300'
            : 'bg-yellow-100 text-yellow-800 border border-yellow-300'}"
        >
          {cardapio.status === 'publicado' ? 'Publicado' : 'Rascunho'}
        </span>
      </div>

      {#if $session?.profile === 'nutricionista' && cardapio.status === 'rascunho'}
        <button
          on:click={handlePublish}
          disabled={isActionLoading}
          class="flex items-center gap-2 bg-green-600 hover:bg-green-700 active:scale-95 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all disabled:opacity-50"
        >
          <Send class="w-5 h-5" />
          Publicar Cardápio
        </button>
      {/if}
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 {gridColsClass} gap-6 mt-4">
      {#each diasDaSemanaDoCardapio as dia (dia)}
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm hover:shadow-lg hover:scale-[1.01] transition-all overflow-hidden flex flex-col">
          <div class="bg-gradient-to-r from-primary-600/10 to-primary-50 p-3 border-b text-center">
            <h2 class="text-lg font-semibold text-primary-700 capitalize tracking-wide">{dia}</h2>
          </div>

          <div class="flex flex-col divide-y">
            <div class="flex-1 p-5 space-y-3">
              <h4 class="font-semibold text-primary-700 flex items-center gap-1">☀️ Manhã (10h)</h4>

              {#if refeicoesGrid[dia]?.manha}
                {@const refeicao = refeicoesGrid[dia]['manha']}
                <div class="text-sm text-gray-700 bg-gray-50 rounded-lg p-3 shadow-inner border border-gray-100">
                  <p class="font-medium italic text-gray-800 mb-1">“{refeicao.description}”</p>
                  <ul class="list-disc list-inside text-xs text-gray-600 space-y-1">
                    {#each refeicao.products as item (item.id)}
                      <li>{item.name}</li>
                    {/each}
                  </ul>

                  {#if $session?.profile === 'nutricionista' && cardapio.status === 'rascunho'}
                    <div class="flex gap-3 mt-3 pt-2 border-t border-gray-200">
                      <button on:click={() => handleEditRefeicao(refeicao)} class="text-xs text-primary-600 hover:underline font-medium disabled:opacity-50">Editar</button>
                      <button on:click={() => handleDeleteRefeicao(refeicao)} class="text-xs text-red-500 hover:underline font-medium disabled:opacity-50">Remover</button>
                    </div>
                  {/if}
                </div>
              {:else if $session?.profile === 'nutricionista' && cardapio.status === 'rascunho'}
                <button
                  on:click={() => handleAddRefeicao(dia, 'manha')}
                  disabled={isActionLoading}
                  class="w-full flex items-center justify-center gap-2 text-sm text-gray-500 hover:bg-primary-50 border-2 border-dashed border-primary-200 rounded-lg py-3 transition disabled:opacity-50"
                >
                  <PlusCircle class="w-4 h-4 text-primary-500" /> Adicionar Refeição
                </button>
              {:else}
                <p class="text-sm text-gray-400 italic">(Sem refeição cadastrada)</p>
              {/if}
            </div>

            <div class="flex-1 p-5 space-y-3">
              <h4 class="font-semibold text-primary-700 flex items-center gap-1">🌇 Tarde (15h)</h4>

              {#if refeicoesGrid[dia]?.tarde}
                {@const refeicao = refeicoesGrid[dia]['tarde']}
                <div class="text-sm text-gray-700 bg-gray-50 rounded-lg p-3 shadow-inner border border-gray-100">
                  <p class="font-medium italic text-gray-800 mb-1">“{refeicao.description}”</p>
                  <ul class="list-disc list-inside text-xs text-gray-600 space-y-1">
                    {#each refeicao.products as item (item.id)}
                      <li>{item.name}</li>
                    {/each}
                  </ul>

                  {#if $session?.profile === 'nutricionista' && cardapio.status === 'rascunho'}
                    <div class="flex gap-3 mt-3 pt-2 border-t border-gray-200">
                      <button on:click={() => handleEditRefeicao(refeicao)} class="text-xs text-primary-600 hover:underline font-medium disabled:opacity-50">Editar</button>
                      <button on:click={() => handleDeleteRefeicao(refeicao)} class="text-xs text-red-500 hover:underline font-medium disabled:opacity-50">Remover</button>
                    </div>
                  {/if}
                </div>
              {:else if $session?.profile === 'nutricionista' && cardapio.status === 'rascunho'}
                <button
                  on:click={() => handleAddRefeicao(dia, 'tarde')}
                  disabled={isActionLoading}
                  class="w-full flex items-center justify-center gap-2 text-sm text-gray-500 hover:bg-primary-50 border-2 border-dashed border-primary-200 rounded-lg py-3 transition disabled:opacity-50"
                >
                  <PlusCircle class="w-4 h-4 text-primary-500" /> Adicionar Refeição
                </button>
              {:else}
                <p class="text-sm text-gray-400 italic">(Sem refeição cadastrada)</p>
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
  <Modal show={showRefeicaoModal} on:close={() => (showRefeicaoModal = false)} size="max-w-2xl" showCloseButton={false}>
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