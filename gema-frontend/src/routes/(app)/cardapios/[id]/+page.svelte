<script lang="ts">
  import { page } from '$app/stores';
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import type { Cardapio, Refeicao } from '$lib/types';
  import { session } from '$lib/sessionStore';
  import { format, parseISO, eachDayOfInterval, getDay } from 'date-fns'; // Importa funções de data
  import { ptBR } from 'date-fns/locale';
  import { PlusCircle, Edit, Trash2, ArrowLeft } from 'lucide-svelte';

  // Mapeia o número do dia (Date.getDay()) para nossa string de DiaSemana
  const diaSemanaMap: { [key: number]: string } = {
    1: 'segunda',
    2: 'terca',
    3: 'quarta',
    4: 'quinta',
    5: 'sexta',
  };
  // Ordem de exibição
  const DIAS_SEMANA_ORDEM = ['segunda', 'terca', 'quarta', 'quinta', 'sexta'];

  let cardapio: Cardapio | null = null;
  let isLoading = true;
  let error: string | null = null;
  
  // Nossas variáveis dinâmicas
  let diasDaSemanaDoCardapio: string[] = []; // Ex: ['quarta']
  let refeicoesGrid: Record<string, Record<string, Refeicao | null>> = {};

  onMount(async () => {
    const id = $page.params.id;
    try {
      cardapio = await api.get(`cardapios/${id}`);
      
      if (cardapio) {
        // Popula as variáveis dinâmicas
        diasDaSemanaDoCardapio = getDiasDaSemanaNoIntervalo(cardapio.startDate, cardapio.endDate);
        organizeRefeicoes(cardapio.refeicoes);
      } else {
        throw new Error('Cardápio não encontrado.');
      }
    } catch (e: any) {
      error = e.message || 'Não foi possível carregar o cardápio.';
      console.error(e);
    } finally {
      isLoading = false;
    }
  });

  // --- NOVA FUNÇÃO AUXILIAR ---
  function getDiasDaSemanaNoIntervalo(start: string, end: string): string[] {
      const startDate = parseISO(start);
      const endDate = parseISO(end);
      const diasNoIntervalo = eachDayOfInterval({ start: startDate, end: endDate });

      const diasUteis = diasNoIntervalo
        .map(date => getDay(date)) // Pega o número do dia (0=Dom, 1=Seg, ..., 6=Sab)
        .filter(dayNumber => dayNumber >= 1 && dayNumber <= 5) // Filtra apenas dias úteis
        .map(dayNumber => diaSemanaMap[dayNumber]); // Mapeia para nossas strings ('segunda', 'terca'...)

      // Remove duplicados e mantém a ordem
      return DIAS_SEMANA_ORDEM.filter(dia => diasUteis.includes(dia));
  }

  function organizeRefeicoes(refeicoes: Refeicao[] = []) {
    const grid: Record<string, Record<string, Refeicao | null>> = {};
    for (const dia of diasDaSemanaDoCardapio) { // Usa a lista dinâmica
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
    } catch (e) { return 'Data Inválida'; }
  }

  // --- Placeholders ---
  function handleAddRefeicao(dia: string, tipo: string) { console.log('Abrir modal para ADICIONAR refeição:', dia, tipo); }
  function handleEditRefeicao(refeicao: Refeicao) { console.log('Abrir modal para EDITAR refeição:', refeicao.id); }
  function handleDeleteRefeicao(refeicao: Refeicao) { if (confirm(`...`)) { console.log('Chamar API para DELETAR refeição:', refeicao.id); } }
</script>

<div class="space-y-6 animate-fadeIn">
  
  <div class="mb-2">
    <a href="/cardapios" class="inline-flex items-center gap-2 text-sm text-primary-600 hover:text-primary-800 font-semibold transition-colors group">
      <ArrowLeft class="w-4 h-4 transition-transform group-hover:-translate-x-1"/>
      Voltar para todos os cardápios
    </a>
  </div>

  {#if isLoading}
    <div class="text-center p-10"><p class="text-gray-500">⏳ Carregando cardápio...</p></div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg">{error}</div>
  
  {:else if cardapio} 
    <div class="bg-white p-6 rounded-lg shadow-md border-l-4 border-primary-600">
      <h1 class="text-3xl font-bold text-gray-900">{cardapio.name}</h1>
      <p class="text-gray-500 mt-1">
        Período: 
        <span class="font-semibold">{formatLocalDate(cardapio.startDate)}</span>
        a
        <span class="font-semibold">{formatLocalDate(cardapio.endDate)}</span>
      </p>
      <p class="text-sm text-gray-400 mt-2">Criado por: {cardapio.createdBy?.name || 'N/A'}</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-{diasDaSemanaDoCardapio.length} gap-5">
      
      {#each diasDaSemanaDoCardapio as dia (dia)}
        <div class="bg-white rounded-lg shadow-md border overflow-hidden flex flex-col">
          <div class="bg-gray-50 p-3 border-b text-center">
            <h2 class="text-lg font-semibold text-gray-700 capitalize">{dia}</h2>
          </div>
          
          <div class="flex flex-col h-full divide-y">
            <div class="flex-1 p-4 space-y-2">
              <h4 class="font-semibold text-primary-700">Manhã (10h)</h4>
              {#if refeicoesGrid[dia] && refeicoesGrid[dia]['manha']}
                {@const refeicao = refeicoesGrid[dia]['manha']}
                <div class="text-sm text-gray-600">
                  <p class="font-medium italic">"{refeicao.description || 'Sem descrição'}"</p>
                  <ul class="list-disc list-inside mt-2 text-xs space-y-0.5">
                    {#each refeicao.items as item}
                      <li>{item.product.name} ({item.quantityPerStudent} {item.product.unit})</li>
                    {/each}
                  </ul>
                  {#if $session?.profile === 'nutricionista'}
                    <div class="flex gap-2 mt-3 pt-2 border-t">
                      <button on:click={() => handleEditRefeicao(refeicao)} class="text-xs text-primary-600 hover:underline">Editar</button>
                      <button on:click={() => handleDeleteRefeicao(refeicao)} class="text-xs text-red-500 hover:underline">Remover</button>
                    </div>
                  {/if}
                </div>
              {:else if $session?.profile === 'nutricionista'}
                <button 
                  on:click={() => handleAddRefeicao(dia, 'manha')}
                  class="w-full flex items-center justify-center gap-2 text-sm text-gray-500 hover:bg-gray-100 p-3 rounded-md border-2 border-dashed transition"
                >
                  <PlusCircle class="w-4 h-4"/> Adicionar Refeição
                </button>
              {:else}
                 <p class="text-sm text-gray-400 italic">(Sem refeição cadastrada)</p>
              {/if}
            </div>
            
            <div class="flex-1 p-4 space-y-2">
              <h4 class="font-semibold text-primary-700">Tarde (15h)</h4>
               {#if refeicoesGrid[dia] && refeicoesGrid[dia]['tarde']}
                {@const refeicao = refeicoesGrid[dia]['tarde']}
                <div class="text-sm text-gray-600">
                  <p class="font-medium italic">"{refeicao.description || 'Sem descrição'}"</p>
                  <ul class="list-disc list-inside mt-2 text-xs space-y-0.5">
                    {#each refeicao.items as item}
                      <li>{item.product.name} ({item.quantityPerStudent} {item.product.unit})</li>
                    {/each}
                  </ul>
                  {#if $session?.profile === 'nutricionista'}
                    <div class="flex gap-2 mt-3 pt-2 border-t">
                      <button on:click={() => handleEditRefeicao(refeicao)} class="text-xs text-primary-600 hover:underline">Editar</button>
                      <button on:click={() => handleDeleteRefeicao(refeicao)} class="text-xs text-red-500 hover:underline">Remover</button>
                    </div>
                  {/if}
                </div>
              {:else if $session?.profile === 'nutricionista'}
                <button 
                  on:click={() => handleAddRefeicao(dia, 'tarde')}
                  class="w-full flex items-center justify-center gap-2 text-sm text-gray-500 hover:bg-gray-100 p-3 rounded-md border-2 border-dashed transition"
                >
                  <PlusCircle class="w-4 h-4"/> Adicionar Refeição
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
        <p class="text-gray-500 font-medium">Cardápio não encontrado ou dados corrompidos.</p>
     </div>
  {/if}
</div>