<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import { format, parseISO, getDay } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import { AlertTriangle, ListChecks, FileText, ChefHat, Users, School, BookOpen } from 'lucide-svelte';
  import StatusBar from '$lib/components/StatusBar.svelte';
  import Modal from '$lib/components/Modal.svelte';
  import type { Refeicao } from '$lib/types';

  let dashboardData: any = null;
  let isLoading = true;
  let error: string | null = null;

  // --- Stats para Cozinheira ---
  let refeicaoManhaHoje: Refeicao | null | undefined = undefined;
  let refeicaoTardeHoje: Refeicao | null | undefined = undefined;
  let diaSemanaHoje: string | null = null;
  const dayNumToStringMap: { [key: number]: string } = { 1: 'segunda', 2: 'terça', 3: 'quarta', 4: 'quinta', 5: 'sexta' };

  // --- Stats Derivadas ---
  let escolaCriticalCount = 0;
  let escolaPendingCount = 0;
  let nutriDraftCount = 0;
  let nutriPublishedCount = 0;
  let escolaPublishedCardapiosCount = 0; // <-- ADICIONADO

  // --- ESTADO PARA O NOVO MODAL ---
  let showSchoolStockModal = false;
  let selectedSchoolStock: any = null; // Armazena os dados da escola clicada
  
  function openSchoolStockModal(schoolStock: any) {
    selectedSchoolStock = schoolStock;
    showSchoolStockModal = true;
  }

  function closeSchoolStockModal() {
    showSchoolStockModal = false;
    selectedSchoolStock = null;
  }
  // --- FIM DO ESTADO DO MODAL ---

  $: if ($session) loadDashboardData();

  async function loadDashboardData() {
    isLoading = true;
    error = null;
    refeicaoManhaHoje = undefined;
    refeicaoTardeHoje = undefined;
    diaSemanaHoje = null;
    escolaCriticalCount = 0;
    escolaPendingCount = 0;
    nutriDraftCount = 0;
    nutriPublishedCount = 0;
    escolaPublishedCardapiosCount = 0; // <-- RESET

    try {
      dashboardData = await api.get('dashboard');

      if ($session?.profile === 'cozinheira' && dashboardData?.currentCardapio?.refeicoes) {
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

      // --- ATUALIZADO: Carrega stats da escola do backend ---
      if ($session?.profile === 'escola') {
          escolaCriticalCount = dashboardData.stats?.criticalStock || 0;
          escolaPendingCount = dashboardData.stats?.pendingSolicitacoes || 0;
          escolaPublishedCardapiosCount = dashboardData.stats?.publishedCardapios || 0; // <-- POPULADO
      }
      // --- ATUALIZADO: Carrega stats da nutri do backend ---
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

  function getStatusClass(status: string): string {
    switch (status) {
      case 'pendente': return 'bg-yellow-100 text-yellow-800';
      case 'aprovado': return 'bg-green-100 text-green-800';
      case 'aprovado_parcialmente': return 'bg-blue-100 text-blue-800';
      case 'negado': return 'bg-red-100 text-red-800';
      case 'recebido_com_divergencia': return 'bg-orange-100 text-orange-800';
      case 'recebido': return 'bg-gray-200 text-gray-800 font-medium';
      default: return 'bg-gray-100 text-gray-800';
    }
  }

  function formatStatus(status: string): string {
    return status.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase());
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
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-6 space-y-6 animate-fadeIn">

  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border">
    <div>
      {#if $session.profile === 'prefeitura'}
        <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
          Dashboard da Prefeitura
        </h1>
        <p class="text-gray-600 mt-1 text-sm">Visão geral do sistema municipal</p>
      {:else if $session.profile === 'escola'}
        <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent flex items-center gap-2"> Dashboard: {$session.school?.name || ''}</h1>
        <p class="text-gray-600 mt-1 text-sm">Visão geral do seu estoque e solicitações</p>
      {:else if $session.profile === 'nutricionista'}
        <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
          Dashboard da Nutricionista
        </h1>
        <p class="text-gray-600 mt-1 text-sm">Gerencie cardápios e rascunhos</p>
      {:else if $session.profile === 'cozinheira'}
        <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
          Bom dia, Cozinheira!
        </h1>
        <p class="text-gray-600 mt-1 text-sm">Escola: {$session.school?.name}</p>
      {/if}
    </div>
  </div>
    
<div class="dashboard-container animate-fadeIn">

  {#if isLoading}
    <div class="flex justify-center items-center h-64">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm font-medium">{error}</div>
  {:else if dashboardData && $session}

    {#if $session.profile === 'prefeitura'}
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
        <a href="/usuarios" class="stat-card card-blue">
          <div class="icon-wrapper"><Users size={32} /></div>
          <div class="text-content">
            <h2>{dashboardData.stats?.users || 0}</h2>
            <p>Usuários Cadastrados</p>
          </div>
        </a>
        <a href="/escolas" class="stat-card card-green">
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
            <AlertTriangle class="w-5 h-5 text-red-500" />
            <h3>Estoque Central Crítico/Médio</h3>
          </div>
          <ul class="space-y-4">
            {#each dashboardData.criticalStockPrefeitura as item}
              <li>
                <div class="flex justify-between text-sm font-medium">
                  <span>{item.product.name} ({item.product.unit})</span>
                  <span class="{item.status === 'Crítico' ? 'text-red-600' : 'text-yellow-600'}">
                    {item.quantity} / min: {item.minStock}
                  </span>
                </div>
                <StatusBar percentage={item.percentage} status={item.status} />
              </li>
            {/each}
          </ul>
          <a href="/estoque" class="link">Ver Estoque Central</a>
        </div>
      {/if}

      {#if dashboardData.schoolStocks?.length > 0}
        <div class="panel">
          <div class="panel-header">
            <School class="w-5 h-5 text-primary-600" />
            <h3>Estoque das Escolas (Crítico e Médio)</h3>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5 mt-4">
            {#each dashboardData.schoolStocks as schoolStock (schoolStock.schoolId)}
              <button
                type="button"
                class="school-stat-card {schoolStock.criticalItemsCount > 0 ? 'is-critical' : ''}"
                on:click={() => openSchoolStockModal(schoolStock)}
              >
                <div class="school-card-header">
                  <h4 class="font-semibold text-gray-800">{schoolStock.schoolName}</h4>
                  <span class="text-xs text-gray-500">{schoolStock.city}</span>
                </div>
                <div class="school-card-body">
                  <span class="count {schoolStock.criticalItemsCount > 0 ? 'text-red-600' : 'text-green-600'}">
                    {schoolStock.criticalItemsCount}
                  </span>
                  <span class="label">
                    {schoolStock.criticalItemsCount === 1 ? 'Item crítico/médio' : 'Itens críticos/médios'}
                  </span>
                </div>
              </button>
            {/each}
          </div>
        </div>
      {:else}
        <p class="text-sm text-gray-500 italic">Nenhuma escola cadastrada.</p>
      {/if}
    {/if}

    {#if $session.profile === 'escola'}
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-10">
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
              <AlertTriangle class="w-5 h-5 text-amber-500" />
              <h3>Detalhes do Estoque Crítico</h3>
            </div>
            <ul class="space-y-4">
              {#each dashboardData.criticalStock as item}
                <li>
                  <div class="flex justify-between text-sm font-medium">
                    <span>{item.product.name} ({item.product.unit})</span>
                    <span class="{item.status === 'Crítico' ? 'text-red-600' : 'text-yellow-600'} font-semibold"> 
                      {item.quantity} / min: {item.minStock} 
                    </span>
                  </div>
                  <StatusBar percentage={item.percentage} status={item.status} />
                </li>
              {/each}
            </ul>
            <a href="/estoque" class="link">Gerenciar Estoque</a>
          </div>
        {/if}
        <div class="panel">
          <div class="panel-header">
            <ListChecks class="w-5 h-5 text-primary-600" />
            <h3>Últimas Solicitações</h3>
          </div>
          {#if dashboardData.recentSolicitacoes?.length > 0}
            <ul class="space-y-3">
              {#each dashboardData.recentSolicitacoes as s}
                <li class="flex justify-between text-sm border-b border-gray-100 pb-2 last:border-b-0">
                  <span class="text-gray-500">{format(parseISO(s.createdAt), 'dd/MM/yy HH:mm')}</span>
                  <span class="px-2 py-0.5 rounded-full text-xs font-semibold {getStatusClass(s.status)}">{formatStatus(s.status)}</span>
                </li>
              {/each}
            </ul>
          {:else}
            <p class="text-sm text-gray-500 italic mt-2">Nenhuma recente.</p>
          {/if}
          <a href="/solicitacoes" class="link">Ver todas</a>
        </div>
      </div>
    {/if}

    {#if $session.profile === 'nutricionista'}
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 mb-10">
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
      {#if dashboardData.draftCardapios?.length > 0}
        <div class="panel">
          <div class="panel-header">
            <FileText class="w-5 h-5 text-yellow-600" />
            <h3>Detalhes dos Rascunhos</h3>
          </div>
          <ul class="space-y-3">
            {#each dashboardData.draftCardapios as c}
              <li class="flex justify-between text-sm border-b pb-2 last:border-b-0">
                <div>
                  <a href="/cardapios/{c.id}" class="font-medium text-primary-700 hover:underline">{c.name}</a>
                  <p class="text-xs text-gray-500">{formatLocalDate(c.startDate)} a {formatLocalDate(c.endDate)}</p>
                </div>
                <a href="/cardapios/{c.id}" class="link">Gerenciar</a>
              </li>
            {/each}
          </ul>
        </div>
      {:else}
         <p class="text-sm text-gray-500 italic">Nenhum cardápio em rascunho.</p>
      {/if}
    {/if}

    {#if $session.profile === 'cozinheira'}
      <div class="panel">
        <div class="panel-header">
          <ChefHat class="w-5 h-5 text-primary-600" />
          <h3>Refeições de Hoje</h3>
        </div>
        {#if diaSemanaHoje}
          <div class="space-y-6">
            <div>
              <h4 class="font-semibold text-primary-700 mb-2">☀️ Manhã</h4>
              {#if refeicaoManhaHoje}
                <div class="meal">
                  <p class="italic mb-1">“{refeicaoManhaHoje.description}”</p>
                  <ul class="list-disc list-inside text-xs text-gray-600 space-y-1">
                    {#each refeicaoManhaHoje.products as item (item.id)}<li>{item.name}</li>{/each}
                  </ul>
                </div>
              {:else}
                <p class="text-sm text-gray-500 italic">(Sem refeição cadastrada)</p>
              {/if}
            </div>
            <div>
              <h4 class="font-semibold text-primary-700 mb-2">🌇 Tarde</h4>
              {#if refeicaoTardeHoje}
                <div class="meal">
                  <p class="italic mb-1">“{refeicaoTardeHoje.description}”</p>
                  <ul class="list-disc list-inside text-xs text-gray-600 space-y-1">
                    {#each refeicaoTardeHoje.products as item (item.id)}<li>{item.name}</li>{/each}
                  </ul>
                </div>
              {:else}
                <p class="text-sm text-gray-500 italic">(Sem refeição cadastrada)</p>
              {/if}
            </div>
          </div>
        {:else}
          <p class="text-sm text-gray-500 italic">(Hoje não é um dia útil com cardápio)</p>
        {/if}
      </div>
    {/if}
  {/if}
</div>
</div>

{#if showSchoolStockModal && selectedSchoolStock}
  <Modal show={showSchoolStockModal} on:close={closeSchoolStockModal} size="max-w-3xl">
    <div class="space-y-6">
      <div class="border-b pb-4">
        <h2 class="text-3xl font-bold text-gray-800">Estoque Crítico/Médio</h2>
        <p class="text-sm text-gray-600 mt-2">
          Escola: <span class="font-semibold">{selectedSchoolStock.schoolName}</span>
          <span class="text-gray-400 mx-1">|</span>
          <span class="text-gray-600">{selectedSchoolStock.city}</span>
        </p>
      </div>

      {#if selectedSchoolStock.criticalItems.length > 0}
        <ul class="space-y-4 max-h-96 overflow-y-auto pr-2">
          {#each selectedSchoolStock.criticalItems as item (item.product.id)}
            <li>
              <div class="flex justify-between text-sm font-medium">
                <span>{item.product.name} ({item.product.unit})</span>
                <span class="{item.status === 'Crítico' ? 'text-red-600' : 'text-yellow-600'} font-semibold">
                  {item.quantity} / min: {item.minStock}
                </span>
              </div>
              <StatusBar percentage={item.percentage} status={item.status} />
            </li>
          {/each}
        </ul>
      {:else}
         <p class="text-sm text-gray-500 italic text-center py-4">Nenhum item crítico ou médio para esta escola.</p>
      {/if}

      <div class="mt-8 flex justify-end border-t pt-6">
        <button
          type="button"
          on:click={closeSchoolStockModal}
          class="bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm"
        >
          Fechar
        </button>
      </div>
    </div>
  </Modal>
{/if}

<style>
  /* ======== MAIN ======== */
  .dashboard-container {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }

  /* ======== STAT CARDS (Prefeitura, Escola, Nutri) ======== */
  .stat-card {
    display: flex;
    align-items: center;
    gap: 1.5rem;
    padding: 1.5rem;
    border-radius: 1rem;
    box-shadow: 0 4px 10px rgba(0,0,0,0.05);
    color: white;
    transition: all 0.2s ease-in-out;
  }
  .stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.08);
  }
  .stat-card .icon-wrapper {
    flex-shrink: 0;
    display: grid;
    place-items: center;
    width: 4rem; 
    height: 4rem;
    border-radius: 9999px;
    background-color: rgba(255, 255, 255, 0.2);
  }
  .stat-card .text-content h2 {
    font-size: 2.25rem;
    font-weight: 800;
    line-height: 1.1;
  }
  .stat-card .text-content p {
    font-size: 0.875rem;
    font-weight: 500;
    opacity: 0.9;
    margin-top: 0.25rem;
  }
  .card-blue { background-image: linear-gradient(to right, #3b82f6, #2563eb); }
  .card-green { background-image: linear-gradient(to right, #22c55e, #16a34a); }
  .card-yellow { background-image: linear-gradient(to right, #f59e0b, #d97706); }
  .card-red { background-image: linear-gradient(to right, #ef4444, #dc2626); }
  
  /* ======== NOVOS CARDS DE SUMÁRIO (Estoque Escolas) ======== */
  .school-stat-card {
    background: white;
    border: 1px solid #e5e7eb; /* Borda padrão */
    border-radius: 0.75rem; /* 12px */
    padding: 1rem; /* 16px */
    text-align: left;
    box-shadow: 0 2px 6px rgba(0,0,0,0.04);
    transition: all 0.2s ease-in-out;
  }
  .school-stat-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.07);
    border-color: #cacfd7;
  }
  /* Borda de alerta vermelha */
  .school-stat-card.is-critical {
    border-left-width: 4px;
    border-left-color: #ef4444; /* red-500 */
  }
  .school-stat-card.is-critical:hover {
     border-color: #ef4444;
  }
  .school-card-header {
    border-bottom: 1px solid #f3f4f6; /* gray-100 */
    padding-bottom: 0.5rem;
    margin-bottom: 0.75rem;
  }
  .school-card-body {
    display: flex;
    align-items: baseline;
    gap: 0.5rem;
  }
  .school-card-body .count {
    font-size: 2rem; /* 32px */
    font-weight: 700;
    line-height: 1;
  }
  .school-card-body .label {
    font-size: 0.875rem; /* 14px */
    color: #6b7280; /* gray-500 */
    font-weight: 500;
  }
  /* --- FIM DOS NOVOS ESTILOS --- */
  
  /* ======== PAINEL GENÉRICO (Mantido) ======== */
  .panel {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 1rem;
    padding: 1.5rem;
    box-shadow: 0 2px 6px rgba(0,0,0,0.04);
    transition: all 0.2s;
  }
  .panel:hover {
    box-shadow: 0 4px 10px rgba(0,0,0,0.06);
  }
  .panel-header {
    display: flex;
    align-items: center;
    gap: .5rem;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 1rem;
  }

  /* ======== MEAL (Mantido) ======== */
  .meal {
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: .75rem;
    padding: .75rem;
  }

  /* ======== LINKS (Mantido) ======== */
  .link {
    display: inline-block;
    margin-top: 1rem;
    font-size: .875rem;
    color: #2563eb;
    font-weight: 500;
    transition: color 0.2s;
  }
  .link:hover {
    color: #1d4ed8;
    text-decoration: underline;
  }

  /* ======== ANIMATION (Mantido) ======== */
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .animate-fadeIn {
    animation: fadeIn 0.4s ease-out forwards;
  }
</style>