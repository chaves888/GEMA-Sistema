<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { session } from '$lib/sessionStore';
  import { format, parseISO, getDay } from 'date-fns';
  import { ptBR } from 'date-fns/locale';
  import { AlertTriangle, ListChecks, FileText, ChefHat, Users, Building2 } from 'lucide-svelte';
  import StatusBar from '$lib/components/StatusBar.svelte';
  import type { Refeicao } from '$lib/types';

  let dashboardData: any = null;
  let isLoading = true;
  let error: string | null = null;

  let refeicaoManhaHoje: Refeicao | null | undefined = undefined;
  let refeicaoTardeHoje: Refeicao | null | undefined = undefined;
  let diaSemanaHoje: string | null = null;

  const dayNumToStringMap: { [key: number]: string } = { 1: 'segunda', 2: 'terca', 3: 'quarta', 4: 'quinta', 5: 'sexta' };

  $: if ($session) loadDashboardData();

  async function loadDashboardData() {
    isLoading = true;
    error = null;
    refeicaoManhaHoje = undefined;
    refeicaoTardeHoje = undefined;
    diaSemanaHoje = null;

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

<!-- HERO HEADER -->
<div class="hero border-b border-gray-200 pb-4 mb-6">
  {#if $session.profile === 'prefeitura'}
    <h1 class="text-blue-600 text-2xl font-bold">Dashboard da Prefeitura</h1>
    <p class="text-gray-500 mt-1 text-sm">Visão geral do sistema municipal</p>
  {:else if $session.profile === 'escola'}
    <h1 class="text-blue-600 text-2xl font-bold">Dashboard da Escola</h1>
    <p class="text-gray-500 mt-1 text-sm">{$session.school?.name}</p>
  {:else if $session.profile === 'nutricionista'}
    <h1 class="text-blue-600 text-2xl font-bold">Dashboard da Nutricionista</h1>
    <p class="text-gray-500 mt-1 text-sm">Gerencie cardápios e rascunhos</p>
  {:else if $session.profile === 'cozinheira'}
    <h1 class="text-blue-600 text-2xl font-bold">🍽️ Bom dia, Cozinheira!</h1>
    <p class="text-gray-500 mt-1 text-sm">Escola: {$session.school?.name}</p> 
  {/if}
</div>

<!-- MAIN CONTENT -->
<div class="dashboard-container animate-fadeIn">

  {#if isLoading}
    <div class="flex justify-center items-center h-64">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm font-medium">{error}</div>
  {:else if dashboardData && $session}

    <!-- PREFEITURA -->
    {#if $session.profile === 'prefeitura'}
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-6 mb-10">
    <div class="card">
      <Users class="icon" />
      <h2>{dashboardData.stats?.users || 0}</h2>
      <p>Usuários</p>
    </div>
    <div class="card">
      <Building2 class="icon" />
      <h2>{dashboardData.stats?.schools || 0}</h2>
      <p>Escolas</p>
    </div>
    <div class="card">
      <ListChecks class="icon text-yellow-500" />
      <h2>{dashboardData.stats?.pendingSolicitacoes || 0}</h2>
      <p>Solicitações Pendentes</p>
    </div>
  </div>

  <!-- PAINEL ESTOQUE CENTRAL -->
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
                {item.quantity} / min: {item.product.minStock}
              </span>
            </div>
            <StatusBar percentage={item.percentage} status={item.status} />
          </li>
        {/each}
      </ul>
      <a href="/estoque" class="link">Ver Estoque Central</a>
    </div>
  {/if}

  <!-- PAINEL ESTOQUES DAS ESCOLAS -->
  {#if dashboardData.schoolStocks?.length > 0}
    <div class="panel">
      <div class="panel-header">
        <Building2 class="w-5 h-5 text-primary-600" />
        <h3>🏫 Estoque das Escolas</h3>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-4">
        {#each dashboardData.schoolStocks as schoolStock}
          <div class="panel bg-gray-50 p-4 rounded-xl border border-gray-200 shadow-inner">
            <h4 class="font-semibold text-gray-800 mb-3">{schoolStock.schoolName}</h4>
            {#if schoolStock.criticalItems.length > 0}
              <ul class="space-y-3">
                {#each schoolStock.criticalItems as item}
                  <li class="text-sm">
                    <div class="flex justify-between items-center mb-1">
                      <span>{item.product.name}</span>
                      <span class="{item.status === 'Crítico' ? 'text-red-600' : 'text-yellow-600'} font-semibold">
                        {item.quantity} {item.product.unit}
                      </span>
                    </div>
                    <StatusBar percentage={item.percentage} status={item.status} />
                  </li>
                {/each}
              </ul>
            {:else}
              <p class="text-sm text-gray-500 italic">Nenhum item crítico/médio.</p>
            {/if}
          </div>
        {/each}
      </div>
    </div>
  {:else}
    <p class="text-sm text-gray-500 italic">Nenhuma escola cadastrada.</p>
  {/if}

{/if}

    <!-- ESCOLA -->
    {#if $session.profile === 'escola'}
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {#if dashboardData.criticalStock?.length > 0}
          <div class="panel">
            <div class="panel-header">
              <AlertTriangle class="w-5 h-5 text-amber-500" />
              <h3>Estoque Crítico / Médio</h3>
            </div>
            <ul class="space-y-4">
              {#each dashboardData.criticalStock as item}
                <li>
                  <div class="flex justify-between text-sm font-medium">
                    <span>{item.product.name} ({item.product.unit})</span>
                    <span class="{item.status === 'Crítico' ? 'text-red-600' : 'text-yellow-600'}">
                      {item.quantity} / min: {item.product.minStock}
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

    <!-- NUTRICIONISTA -->
    {#if $session.profile === 'nutricionista'}
      <div class="panel">
        <div class="panel-header">
          <FileText class="w-5 h-5 text-yellow-600" />
          <h3>Cardápios em Rascunho</h3>
        </div>
        {#if dashboardData.draftCardapios?.length > 0}
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
        {:else}
          <p class="text-sm text-gray-500 italic">Nenhum rascunho.</p>
        {/if}
      </div>
    {/if}

    <!-- COZINHEIRA -->
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

<style>
  /* ======== HERO ======== */
  .hero {
    background: linear-gradient(to right, #f9fafb, #f1f5f9);
    padding: 2.5rem 2rem;
    border-radius: 1rem;
    margin-bottom: 2rem;
    text-align: left;
    box-shadow: inset 0 -1px 0 rgba(0, 0, 0, 0.05);
  }
  .hero h1 {
    
    font-size: 2rem;
    font-weight: 700;
    color: #2089e6;
  }
  .hero p {
    font-size: 1rem;
    color: #6b7280;
    margin-top: .25rem;
  }

  /* ======== MAIN ======== */
  .dashboard-container {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }

  /* ======== CARDS ======== */
  .card {
    background: white;
    border: 1px solid #e5e7eb;
    border-radius: 1rem;
    padding: 1.75rem;
    text-align: center;
    box-shadow: 0 2px 6px rgba(0,0,0,0.04);
    transition: all 0.2s ease-in-out;
  }
  .card:hover {
    transform: translateY(-3px);
    box-shadow: 0 4px 10px rgba(0,0,0,0.06);
  }
  .card h2 {
    font-size: 2rem;
    font-weight: 700;
    color: #1e293b;
  }
  .card p {
    color: #6b7280;
    margin-top: 0.25rem;
  }
  .card .icon {
    margin: 0 auto 0.75rem auto;
    color: #64748b;
    width: 28px;
    height: 28px;
  }

  /* ======== PANEL ======== */
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

  /* ======== MEAL ======== */
  .meal {
    background: #f9fafb;
    border: 1px solid #e5e7eb;
    border-radius: .75rem;
    padding: .75rem;
  }

  /* ======== LINKS ======== */
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

  /* ======== ANIMATION ======== */
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
  .animate-fadeIn {
    animation: fadeIn 0.4s ease-out forwards;
  }
</style>
