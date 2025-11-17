<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { Boxes, ClipboardList, ArchiveX, Warehouse, Truck, PackagePlus } from 'lucide-svelte';

  let snapshotData: {
    totalSolicitacoes: number;
    totalItensEnviados: number;
    totalPerdasPrefeitura: number;
    totalPerdasEscolas: number;
  } | null = null;
  let isLoadingSnapshot = true;

  onMount(async () => {
    try {
      snapshotData = await api.get('relatorios/snapshot');
    } catch (e) {
      console.error('Erro ao carregar snapshot:', e);
    } finally {
      isLoadingSnapshot = false;
    }
  });
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-4 lg:p-6 space-y-6 animate-fadeIn">
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border">
    <div>
      <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Relatórios do Sistema
      </h1>
      <p class="text-gray-600 mt-1 text-sm">Visão geral e relatórios detalhados do sistema.</p>
    </div>
  </div>

  <div class="pt-2">
    <h2 class="text-xl lg:text-2xl font-bold text-gray-800 mb-4">Visão Geral (Todos os Períodos)</h2>

    {#if isLoadingSnapshot}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6">
        {#each { length: 4 } as _}
          <div class="bg-white rounded-2xl shadow-lg border border-gray-100 p-6 flex items-center gap-5 animate-pulse">
            <div class="flex-shrink-0 bg-gray-200 p-3 rounded-full w-14 h-14" />
            <div>
              <div class="h-4 bg-gray-200 rounded w-32 mb-2" />
              <div class="h-8 bg-gray-300 rounded w-20" />
            </div>
          </div>
        {/each}
      </div>
    {:else if snapshotData}
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6">
        <div class="bg-white rounded-2xl shadow-lg border border-gray-100 p-6 flex items-center gap-5 hover:shadow-xl transition-shadow">
          <div class="flex-shrink-0 bg-primary-100 text-primary-600 p-4 rounded-full">
            <ClipboardList class="w-6 h-6" />
          </div>
          <div>
            <p class="text-sm font-medium text-gray-500">Total de Solicitações</p>
            <p class="text-2xl lg:text-3xl font-bold text-gray-900">{snapshotData.totalSolicitacoes}</p>
          </div>
        </div>
        <div class="bg-white rounded-2xl shadow-lg border border-gray-100 p-6 flex items-center gap-5 hover:shadow-xl transition-shadow">
          <div class="flex-shrink-0 bg-green-100 text-green-600 p-4 rounded-full">
            <Truck class="w-6 h-6" />
          </div>
          <div>
            <p class="text-sm font-medium text-gray-500">Itens Enviados (Central)</p>
            <p class="text-2xl lg:text-3xl font-bold text-gray-900">{snapshotData.totalItensEnviados}</p>
          </div>
        </div>
        <div class="bg-white rounded-2xl shadow-lg border border-gray-100 p-6 flex items-center gap-5 hover:shadow-xl transition-shadow">
          <div class="flex-shrink-0 bg-yellow-100 text-yellow-700 p-4 rounded-full">
            <Warehouse class="w-6 h-6" />
          </div>
          <div>
            <p class="text-sm font-medium text-gray-500">Saidas (Estoque Central)</p>
            <p class="text-2xl lg:text-3xl font-bold text-gray-900">{snapshotData.totalPerdasPrefeitura}</p>
          </div>
        </div>
        <div class="bg-white rounded-2xl shadow-lg border border-gray-100 p-6 flex items-center gap-5 hover:shadow-xl transition-shadow">
          <div class="flex-shrink-0 bg-red-100 text-red-600 p-4 rounded-full">
            <ArchiveX class="w-6 h-6" />
          </div>
          <div>
            <p class="text-sm font-medium text-gray-500">Saidas (Estoque Escolas)</p>
            <p class="text-2xl lg:text-3xl font-bold text-gray-900">{snapshotData.totalPerdasEscolas}</p>
          </div>
        </div>
      </div>
    {/if}
  </div>

  <div class="mt-8 pt-6 border-t border-gray-200">
    <h2 class="text-xl lg:text-2xl font-bold text-gray-800 mb-4">Relatórios Detalhados</h2>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 lg:gap-6">
      <a href="/relatorios/solicitacoes-por-escola" class="report-card">
        <div class="report-card-icon bg-primary-100 text-primary-600">
          <ClipboardList class="w-6 h-6" />
        </div>
        <div>
          <h2 class="report-card-title">Solicitações por Escola</h2>
          <p class="report-card-description">Consolidado de pedidos e taxa de atendimento por escola.</p>
        </div>
      </a>

      <a href="/relatorios/envios-estoque" class="report-card">
        <div class="report-card-icon bg-green-100 text-green-600">
          <Boxes class="w-6 h-6" />
        </div>
        <div>
          <h2 class="report-card-title">Envios (Estoque Central)</h2>
          <p class="report-card-description">Auditoria de saídas do estoque central para as escolas.</p>
        </div>
      </a>

      <a href="/relatorios/ajustes-prefeitura" class="report-card">
        <div class="report-card-icon bg-yellow-100 text-yellow-700">
          <Warehouse class="w-6 h-6" />
        </div>
        <div>
          <h2 class="report-card-title">Saidas (Estoque Central)</h2>
          <p class="report-card-description">Auditoria de perdas e ajustes manuais no estoque central.</p>
        </div>
      </a>

      <a href="/relatorios/ajustes-escolas" class="report-card">
        <div class="report-card-icon bg-red-100 text-red-600">
          <ArchiveX class="w-6 h-6" />
        </div>
        <div>
          <h2 class="report-card-title">Saidas (Estoque Escolas)</h2>
          <p class="report-card-description">Monitora perdas e ajustes manuais reportados pelas escolas.</p>
        </div>
      </a>

      <a href="/relatorios/entradas-prefeitura" class="report-card">
        <div class="report-card-icon bg-cyan-100 text-cyan-600">
          <PackagePlus class="w-6 h-6" />
        </div>
        <div>
          <h2 class="report-card-title">Entradas (Estoque Central)</h2>
          <p class="report-card-description">Auditoria de entradas por ajuste manual ou importação.</p>
        </div>
      </a>
    </div>
  </div>
</div>

<style>
  @keyframes fadeIn {
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
  }
  .animate-fadeIn { animation: fadeIn 0.25s ease-out; }

  .report-card {
    background-color: white;
    border-radius: 1rem;
    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
    border: 1px solid #e5e7eb;
    padding: 1.5rem;
    display: flex;
    align-items: flex-start;
    gap: 1.25rem;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .report-card:hover {
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    transform: translateY(-0.25rem);
  }
  .report-card-icon { flex-shrink: 0; padding: 0.75rem; border-radius: 9999px; }
  .report-card-title { font-size: 1.125rem; font-weight: 700; color: #1f2937; }
  .report-card-description { font-size: 0.875rem; color: #4b5563; margin-top: 0.25rem; }
</style>