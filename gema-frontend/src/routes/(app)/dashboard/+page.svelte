<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import { format, parseISO, getDay } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import {
    AlertTriangle,
    ListChecks,
    FileText,
    ChefHat,
    Users,
    School,
    BookOpen,
    PackageCheck,
    AlertCircle,
  } from 'lucide-svelte';
  import StatusBar from '$lib/components/StatusBar.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import type { Refeicao } from '$lib/types';

  let dashboardData: any = null;
  let isLoading = true;
  let error: string | null = null;
  let dataLoaded = false;

  let refeicaoManhaHoje: Refeicao | null | undefined = undefined;
  let refeicaoTardeHoje: Refeicao | null | undefined = undefined;
  let diaSemanaHoje: string | null = null;
  const dayNumToStringMap: { [key: number]: string } = {
    1: 'segunda', 2: 'terça', 3: 'quarta', 4: 'quinta', 5: 'sexta',
  };

  type EstoqueItem = {
    quantity: number;
    status: 'Crítico' | 'Médio' | 'Bom' | 'N/A';
    percentage: number;
    minStock: number;
    product: { id: string; name: string; unit: string };
  };
  let stockMap = new Map<string, EstoqueItem>();

  let escolaCriticalCount = 0;
  let escolaPendingCount = 0;
  let escolaAwaitingReceiptCount = 0;
  let nutriDraftCount = 0;
  let nutriPublishedCount = 0;
  let escolaPublishedCardapiosCount = 0;

  let showSchoolStockModal = false;
  let selectedSchoolStock: any = null;

  function openSchoolStockModal(schoolStock: any) {
    selectedSchoolStock = schoolStock;
    showSchoolStockModal = true;
  }

  function closeSchoolStockModal() {
    showSchoolStockModal = false;
    selectedSchoolStock = null;
  }
  
  $: if ($session && !dataLoaded) {
      dataLoaded = true;
      loadDashboardData();
  }

  async function loadDashboardData() {
    isLoading = true;
    error = null;
    refeicaoManhaHoje = undefined;
    refeicaoTardeHoje = undefined;
    diaSemanaHoje = null;
    stockMap.clear();

    try {
      dashboardData = await api.get('dashboard');

      if ($session?.profile === 'cozinheira') {
        if (dashboardData.escolaEstoque) {
          stockMap = new Map(
            dashboardData.escolaEstoque.map((item: EstoqueItem) => [item.product.id, item])
          );
        }
        if (dashboardData?.currentCardapio?.refeicoes) {
          const todayNum = getDay(new Date());
          diaSemanaHoje = dayNumToStringMap[todayNum];
          if (diaSemanaHoje) {
            refeicaoManhaHoje = dashboardData.currentCardapio.refeicoes.find(
              (r: Refeicao) => r.diaSemana === diaSemanaHoje && r.tipo === 'manha'
            );
            refeicaoTardeHoje = dashboardData.currentCardapio.refeicoes.find(
              (r: Refeicao) => r.diaSemana === diaSemanaHoje && r.tipo === 'tarde'
            );
          }
        }
      }

      if ($session?.profile === 'escola') {
        escolaCriticalCount = dashboardData.stats?.criticalStock || 0;
        escolaPendingCount = dashboardData.stats?.pendingSolicitacoes || 0;
        escolaPublishedCardapiosCount = dashboardData.stats?.publishedCardapios || 0;
        escolaAwaitingReceiptCount = dashboardData.stats?.awaitingReceipt || 0;
      }
      if ($session?.profile === 'nutricionista') {
        nutriDraftCount = dashboardData.stats?.draftCardapios || 0;
        nutriPublishedCount = dashboardData.stats?.publishedCardapios || 0;
      }
    } catch (e: any) {
      error = e?.message || 'Erro ao carregar os dados do dashboard.';
      console.error('Erro dashboard:', e);
    } finally {
      isLoading = false;
    }
  }

  // --- HELPERS COM DARK MODE ---
  function getStatusClass(status: string): string {
    switch (status) {
      case 'pendente': return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900/30 dark:text-yellow-300';
      case 'aprovado': return 'bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300';
      case 'aprovado_parcialmente': return 'bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300';
      case 'negado': return 'bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300';
      case 'recebido_com_divergencia': return 'bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-300';
      case 'recebido': return 'bg-gray-200 text-gray-800 font-medium dark:bg-gray-700 dark:text-gray-300';
      default: return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300';
    }
  }
  function formatStatus(status: string): string {
    return status.replace('_', ' ').replace(/\b\w/g, (l) => l.toUpperCase());
  }
  function formatLocalDate(dateString: string | undefined | null): string {
    if (!dateString) return 'N/A';
    try {
      const date = parseISO(dateString);
      return format(date, 'dd/MM/yyyy', { locale: ptBR });
    } catch {
      return 'Data Inválida';
    }
  }
  function getStockStatusClass(status: string | undefined): string {
    if (status === 'Crítico') return 'text-red-500 font-bold dark:text-red-400';
    if (status === 'Médio') return 'text-yellow-500 font-semibold dark:text-yellow-400';
    return 'text-gray-500 dark:text-gray-400'; 
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4 lg:p-6 space-y-6 animate-fadeIn transition-colors duration-300">
  {#if $session}
    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 dark:bg-gray-800/70 backdrop-blur-md p-5 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
      <div>
          {#if $session.profile === 'prefeitura'}
              <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">Dashboard da Prefeitura</h1>
              <p class="text-gray-600 dark:text-gray-300 mt-1 text-sm">Visão geral do sistema municipal</p>
          {:else if $session.profile === 'escola'}
              <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent flex items-center gap-2">Dashboard: {$session.school?.name || ''}</h1>
              <p class="text-gray-600 dark:text-gray-300 mt-1 text-sm">Visão geral do seu estoque e solicitações</p>
          {:else if $session.profile === 'nutricionista'}
              <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">Dashboard da Nutricionista</h1>
              <p class="text-gray-600 dark:text-gray-300 mt-1 text-sm">Gerencie cardápios e rascunhos</p>
          {:else if $session.profile === 'cozinheira'}
              <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">Bom dia, Cozinheira!</h1>
              <p class="text-gray-600 dark:text-gray-300 mt-1 text-sm">Escola: {$session.school?.name}</p>
          {/if}
      </div>
    </div>
  {/if}
  
  <div class="dashboard-container animate-fadeIn">
    {#if isLoading}
      <div class="flex justify-center items-center h-64">
        <p class="text-gray-500 dark:text-gray-400 text-lg animate-pulse">⏳ Carregando...</p>
      </div>
    {:else if error}
      <div class="bg-red-100 dark:bg-red-900/20 border border-red-200 dark:border-red-800 text-red-700 dark:text-red-400 px-4 py-3 rounded-lg text-sm font-medium">
        {error}
      </div>
    {:else if dashboardData && $session}
      {#if $session.profile === 'prefeitura'}
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-10">
          <a href="/usuarios" class="stat-card card-blue">
            <div class="icon-wrapper"><Users size={32} /></div>
            <div class="text-content">
              <h2>{dashboardData.stats?.users || 0}</h2>
              <p>Usuários Cadastrados</p>
            </div>
          </a>
          
          <a href="/escolas" class="stat-card card-purple">
            <div class="icon-wrapper"><School size={32} /></div>
            <div class="text-content">
              <h2>{dashboardData.stats?.schools || 0}</h2>
              <p>Escolas Atendidas</p>
            </div>
          </a>
          <a href="/solicitacoes?status=pendente" class="stat-card card-yellow">
            <div class="icon-wrapper"><ListChecks size={32} /></div>
            <div class="text-content">
              <h2>{dashboardData.stats?.pendingSolicitacoes || 0}</h2>
              <p>Solicitações Pendentes</p>
            </div>
          </a>
          <a href="/cardapios" class="stat-card card-green">
            <div class="icon-wrapper"><BookOpen size={32} /></div>
            <div class="text-content">
              <h2>{dashboardData.stats?.publishedCardapios || 0}</h2>
              <p>Cardápios Publicados</p>
            </div>
          </a>
        </div>

        {#if dashboardData.criticalStockPrefeitura?.length > 0}
            <div class="panel mb-8">
                <div class="panel-header">
                    <AlertTriangle class="w-5 h-5 text-red-500 dark:text-red-400" />
                    <h3>Estoque Central Crítico/Médio</h3>
                </div>
                <ul class="space-y-4">
                    {#each dashboardData.criticalStockPrefeitura as item}
                        <li>
                            <div class="flex justify-between text-sm font-medium">
                                <span class="text-gray-900 dark:text-gray-100">{item.product.name} ({item.product.unit})</span>
                                <span class="{item.status === 'Crítico' ? 'text-red-600 dark:text-red-400' : 'text-yellow-600 dark:text-yellow-400'}">
                                    {item.quantity} / min: {item.minStock}
                                </span>
                            </div>
                            <StatusBar percentage={item.percentage} status={item.status} />
                        </li>
                    {/each}
                </ul>
                <a href="/estoque" class="btn-link btn-secondary">Ver Estoque Central</a>
            </div>
        {/if}

        {#if dashboardData.schoolStocks?.length > 0}
            <div class="panel">
                <div class="panel-header">
                    <School class="w-5 h-5 text-primary-600 dark:text-primary-400" />
                    <h3>Estoque das Escolas (Crítico e Médio)</h3>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5 mt-4">
                    {#each dashboardData.schoolStocks as schoolStock (schoolStock.schoolId)}
                        <button type="button" class="school-stat-card {schoolStock.criticalItemsCount > 0 ? 'is-critical' : ''}" on:click={() => openSchoolStockModal(schoolStock)}>
                            <div class="school-card-header">
                                <h4 class="font-semibold text-gray-800 dark:text-gray-200 text-left">{schoolStock.schoolName}</h4>
                                <span class="text-xs text-gray-500 dark:text-gray-400 block text-left">{schoolStock.city}</span>
                            </div>
                            <div class="school-card-body">
                                <span class="count {schoolStock.criticalItemsCount > 0 ? 'text-red-600 dark:text-red-400' : 'text-green-600 dark:text-green-400'}">
                                    {schoolStock.criticalItemsCount}
                                </span>
                                <span class="label text-gray-500 dark:text-gray-400">
                                    {schoolStock.criticalItemsCount === 1 ? 'Item crítico/médio' : 'Itens críticos/médios'}
                                </span>
                            </div>
                        </button>
                    {/each}
                </div>
            </div>
        {:else}
             <p class="text-sm text-gray-500 dark:text-gray-400 italic">Nenhuma escola cadastrada.</p>
        {/if}
      {/if}

      {#if $session.profile === 'escola'}
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6 mb-10">
              <a href="/estoque" class="stat-card card-red">
                  <div class="icon-wrapper"><AlertTriangle size={32} /></div>
                  <div class="text-content">
                      <h2>{escolaCriticalCount}</h2>
                      <p>Itens Críticos / Médios</p>
                  </div>
              </a>
              <a href="/solicitacoes?status=pendente" class="stat-card card-yellow">
                  <div class="icon-wrapper"><ListChecks size={32} /></div>
                  <div class="text-content">
                      <h2>{escolaPendingCount}</h2>
                      <p>Solicitações Pendentes</p>
                  </div>
              </a>
              <a href="/solicitacoes?status=aprovado" class="stat-card card-blue">
                  <div class="icon-wrapper"><PackageCheck size={32} /></div>
                  <div class="text-content">
                      <h2>{escolaAwaitingReceiptCount}</h2>
                      <p>Aguardando Recebimento</p>
                  </div>
              </a>
              <a href="/cardapios" class="stat-card card-green">
                  <div class="icon-wrapper"><BookOpen size={32} /></div>
                  <div class="text-content">
                      <h2>{escolaPublishedCardapiosCount}</h2>
                      <p>Cardápios Publicados</p>
                  </div>
              </a>
          </div>
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {#if dashboardData.criticalStock?.length > 0}
                  <div class="panel">
                      <div class="panel-header">
                          <AlertTriangle class="w-5 h-5 text-amber-500 dark:text-amber-400" />
                          <h3>Detalhes do Estoque Crítico</h3>
                      </div>
                      <ul class="space-y-4">
                          {#each dashboardData.criticalStock as item}
                              <li>
                                  <div class="flex justify-between text-sm font-medium">
                                      <span class="text-gray-900 dark:text-gray-100">{item.product.name} ({item.product.unit})</span>
                                      <span class="{item.status === 'Crítico' ? 'text-red-600 dark:text-red-400' : 'text-yellow-600 dark:text-yellow-400'} font-semibold">
                                          {item.quantity} / min: {item.minStock}
                                      </span>
                                  </div>
                                  <StatusBar percentage={item.percentage} status={item.status} />
                              </li>
                          {/each}
                      </ul>
                      <a href="/solicitacoes" class="btn-link btn-primary">Fazer Solicitação</a>
                  </div>
              {/if}
              <div class="panel">
                  <div class="panel-header">
                      <ListChecks class="w-5 h-5 text-primary-600 dark:text-primary-400" />
                      <h3>Últimas Solicitações</h3>
                  </div>
                  {#if dashboardData.recentSolicitacoes?.length > 0}
                      <ul class="space-y-3">
                          {#each dashboardData.recentSolicitacoes as s}
                              <li class="flex justify-between text-sm border-b border-gray-100 dark:border-gray-700 pb-2 last:border-b-0">
                                  <span class="text-gray-500 dark:text-gray-400">{format(parseISO(s.createdAt), 'dd/MM/yy HH:mm')}</span>
                                  <span class="px-2 py-0.5 rounded-full text-xs font-semibold {getStatusClass(s.status)}">{formatStatus(s.status)}</span>
                              </li>
                          {/each}
                      </ul>
                  {:else}
                      <p class="text-sm text-gray-500 dark:text-gray-400 italic mt-2">Nenhuma recente.</p>
                  {/if}
                  <a href="/solicitacoes" class="btn-link btn-secondary">Ver todas</a>
              </div>
          </div>
      {/if}

      {#if $session.profile === 'nutricionista'}
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 lg:gap-6 mb-10">
              <a href="/cardapios?status=rascunho" class="stat-card card-yellow">
                  <div class="icon-wrapper"><FileText size={32} /></div>
                  <div class="text-content">
                      <h2>{nutriDraftCount}</h2>
                      <p>Cardápios em Rascunho</p>
                  </div>
              </a>
              <a href="/cardapios" class="stat-card card-green">
                  <div class="icon-wrapper"><BookOpen size={32} /></div>
                  <div class="text-content">
                      <h2>{nutriPublishedCount}</h2>
                      <p>Cardápios Publicados</p>
                  </div>
              </a>
          </div>
      {/if}

      {#if $session.profile === 'cozinheira'}
          <div class="panel">
              <div class="panel-header">
                  <ChefHat class="w-5 h-5 text-primary-600 dark:text-primary-400" />
                  <h3>Refeições de Hoje ({format(new Date(), 'dd/MM/yyyy')})</h3>
              </div>

              {#if diaSemanaHoje && (refeicaoManhaHoje || refeicaoTardeHoje)}
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div class="meal-card">
                          <h4 class="meal-header morning">☀️ Manhã</h4>
                          {#if refeicaoManhaHoje}
                              <p class="meal-description">“{refeicaoManhaHoje.description}”</p>
                              <hr class="my-3 border-gray-200 dark:border-gray-700" />
                              <span class="ingredient-title">Ingredientes:</span>
                              <ul class="ingredient-list">
                                  {#each refeicaoManhaHoje.products as item (item.id)}
                                      {@const stockInfo = stockMap.get(item.id)}
                                      <li class="ingredient-item">
                                          <span class="text-gray-700 dark:text-gray-300">{item?.name || '(Produto Excluído)'}</span>
                                          {#if stockInfo && (stockInfo.status === 'Crítico' || stockInfo.status === 'Médio')}
                                              <span class="stock-warning {getStockStatusClass(stockInfo.status)}" title="Estoque: {stockInfo.quantity} / {stockInfo.minStock}">
                                                  <AlertCircle class="w-4 h-4" />
                                                  {stockInfo.status}
                                              </span>
                                          {/if}
                                      </li>
                                  {/each}
                              </ul>
                          {:else}
                              <p class="meal-empty dark:text-gray-400">(Sem refeição cadastrada)</p>
                          {/if}
                      </div>

                      <div class="meal-card">
                          <h4 class="meal-header afternoon">🌇 Tarde</h4>
                          {#if refeicaoTardeHoje}
                              <p class="meal-description">“{refeicaoTardeHoje.description}”</p>
                              <hr class="my-3 border-gray-200 dark:border-gray-700" />
                              <span class="ingredient-title">Ingredientes:</span>
                              <ul class="ingredient-list">
                                  {#each refeicaoTardeHoje.products as item (item.id)}
                                      {@const stockInfo = stockMap.get(item.id)}
                                      <li class="ingredient-item">
                                          <span class="text-gray-700 dark:text-gray-300">{item?.name || '(Produto Excluído)'}</span>
                                          {#if stockInfo && (stockInfo.status === 'Crítico' || stockInfo.status === 'Médio')}
                                              <span class="stock-warning {getStockStatusClass(stockInfo.status)}" title="Estoque: {stockInfo.quantity} / {stockInfo.minStock}">
                                                  <AlertCircle class="w-4 h-4" />
                                                  {stockInfo.status}
                                              </span>
                                          {/if}
                                      </li>
                                  {/each}
                              </ul>
                          {:else}
                              <p class="meal-empty dark:text-gray-400">(Sem refeição cadastrada)</p>
                          {/if}
                      </div>
                  </div>
              {:else}
                  <p class="text-sm text-gray-500 dark:text-gray-400 italic text-center py-4">
                      (Nenhum cardápio publicado para hoje)
                  </p>
              {/if}
          </div>
      {/if}
{/if}
  </div>
</div>

{#if showSchoolStockModal && selectedSchoolStock}
    <Modal show={showSchoolStockModal} on:close={closeSchoolStockModal} size="max-w-3xl">
        <div class="space-y-6">
            <div class="border-b border-gray-200 dark:border-gray-700 pb-4">
                <h2 class="text-2xl lg:text-3xl font-bold text-gray-800 dark:text-white">Estoque Crítico/Médio</h2>
                <p class="text-sm text-gray-600 dark:text-gray-400 mt-2">
                    Escola: <span class="font-semibold dark:text-gray-200">{selectedSchoolStock.schoolName}</span>
                    <span class="text-gray-400 mx-1">|</span>
                    <span class="text-gray-600 dark:text-gray-400">{selectedSchoolStock.city}</span>
                </p>
            </div>
            {#if selectedSchoolStock.criticalItems.length > 0}
                <ul class="space-y-4 max-h-96 overflow-y-auto pr-2">
                    {#each selectedSchoolStock.criticalItems as item}
                        <li>
                            <div class="flex justify-between text-sm font-medium">
                                <span class="text-gray-900 dark:text-gray-100">{item.product.name} ({item.product.unit})</span>
                                <span class="{item.status === 'Crítico' ? 'text-red-600 dark:text-red-400' : 'text-yellow-600 dark:text-yellow-400'} font-semibold">
                                    {item.quantity} / min: {item.minStock}
                                </span>
                            </div>
                            <StatusBar percentage={item.percentage} status={item.status} />
                        </li>
                    {/each}
                </ul>
            {:else}
                <p class="text-sm text-gray-500 dark:text-gray-400 italic text-center py-4">
                    Nenhum item crítico ou médio para esta escola.
                </p>
            {/if}
            <div class="mt-8 flex justify-end border-t border-gray-200 dark:border-gray-700 pt-6">
                <button type="button" on:click={closeSchoolStockModal} class="bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-200 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition shadow-sm">
                    Fechar
                </button>
            </div>
        </div>
    </Modal>
{/if}

<style>
    .dashboard-container {
        display: flex;
        flex-direction: column;
        gap: 2rem;
    }
    
    /* Estilos dos Cards de Estatísticas */
    .stat-card {
        display: flex; align-items: center; gap: 1.5rem; padding: 1.5rem; border-radius: 1rem;
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05); color: white; transition: all 0.2s ease-in-out;
    }
    .stat-card:hover { transform: translateY(-4px); box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08); }
    .stat-card .icon-wrapper { flex-shrink: 0; display: grid; place-items: center; width: 4rem; height: 4rem; border-radius: 9999px; background-color: rgba(255, 255, 255, 0.2); }
    .stat-card .text-content h2 { font-size: 2.25rem; font-weight: 800; line-height: 1.1; }
    .stat-card .text-content p { font-size: 0.875rem; font-weight: 500; opacity: 0.9; margin-top: 0.25rem; }
    
    /* Cores dos Cards (Não mudam no Dark Mode, pois já são coloridos) */
    .card-blue { background-image: linear-gradient(to right, #3b82f6, #2563eb); }
    .card-green { background-image: linear-gradient(to right, #22c55e, #16a34a); }
    .card-yellow { background-image: linear-gradient(to right, #f59e0b, #d97706); }
    .card-red { background-image: linear-gradient(to right, #ef4444, #dc2626); }
    .card-purple { background-image: linear-gradient(to right, #8b5cf6, #7c3aed); }
    
    /* --- ESTILOS CUSTOMIZADOS COM SUPORTE A DARK MODE --- */

    /* Painel */
    .panel {
        background: white; border: 1px solid #e5e7eb; border-radius: 1rem; padding: 1.5rem;
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04); transition: all 0.2s;
    }
    /* Dark Mode para Painel */
    :global(.dark) .panel {
        background-color: #1f2937; /* gray-800 */
        border-color: #374151; /* gray-700 */
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.5);
    }

    .panel-header {
        display: flex; align-items: center; gap: 0.5rem; font-weight: 600; color: #1f2937; margin-bottom: 1rem;
    }
    :global(.dark) .panel-header {
        color: #f3f4f6; /* gray-100 */
    }

    /* Cards de Escola */
    .school-stat-card {
        background: white; border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 1rem; 
        box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04); transition: all 0.2s ease-in-out;
    }
    :global(.dark) .school-stat-card {
        background-color: #1f2937;
        border-color: #374151;
    }

    .school-stat-card:hover { transform: translateY(-3px); box-shadow: 0 4px 12px rgba(0, 0, 0, 0.07); border-color: #cacfd7; }
    
    .school-stat-card.is-critical { border-left-width: 4px; border-left-color: #ef4444; }
    .school-stat-card.is-critical:hover { border-color: #ef4444; }

    /* Links e Botões Secundários */
    .btn-link {
        display: inline-block; margin-top: 1rem; padding: 0.5rem 1.25rem; border-radius: 9999px;
        font-size: 0.875rem; font-weight: 600; text-align: center; text-decoration: none;
        transition: all 0.2s ease-in-out; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }
    .btn-primary { background-color: #dc2626; color: white; }
    .btn-primary:hover { background-color: #f50404; }
    
    .btn-secondary { background-color: #f3f4f6; color: #374151; border: 1px solid #e5e7eb; }
    .btn-secondary:hover { background-color: #e5e7eb; border-color: #d1d5db; }
    
    :global(.dark) .btn-secondary {
        background-color: #374151; /* gray-700 */
        color: #e5e7eb; /* gray-200 */
        border-color: #4b5563; /* gray-600 */
    }
    :global(.dark) .btn-secondary:hover {
        background-color: #4b5563;
    }

    /* Cards de Refeição (Cozinheira) */
    .meal-card {
        background: linear-gradient(to bottom, white, #f9fafb);
        border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 1.25rem; box-shadow: 0 2px 4px rgba(0,0,0,0.04);
    }
    :global(.dark) .meal-card {
        background: linear-gradient(to bottom, #1f2937, #111827); /* gray-800 to gray-900 */
        border-color: #374151;
    }

    .meal-description { font-size: 1.125rem; font-style: italic; color: #1f2937; }
    :global(.dark) .meal-description { color: #f3f4f6; }

    .ingredient-title { font-size: 0.75rem; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.05em; display: block; margin-top: 1rem; }
    :global(.dark) .ingredient-title { color: #9ca3af; }

    .ingredient-list { margin-top: 0.75rem; display: flex; flex-direction: column; gap: 0.5rem; }
    .ingredient-item { display: flex; justify-content: space-between; align-items: center; font-size: 0.875rem; color: #374151; padding-bottom: 0.5rem; border-bottom: 1px dashed #e5e7eb; }
    :global(.dark) .ingredient-item { border-bottom-color: #4b5563; } /* gray-600 */
    
    .stock-warning { display: inline-flex; align-items: center; gap: 0.25rem; font-size: 0.75rem; padding: 0.125rem 0.5rem; border-radius: 9999px; background-color: white; border: 1px solid currentColor; }
    :global(.dark) .stock-warning { background-color: #1f2937; }

    .meal-empty { font-size: 0.875rem; color: #6b7280; font-style: italic; text-align: center; padding-top: 1rem; padding-bottom: 1rem; }
    :global(.dark) .meal-empty { color: #9ca3af; }

    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
    .animate-fadeIn { animation: fadeIn 0.4s ease-out forwards; }
</style>