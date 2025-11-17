<script lang="ts">
  import * as api from '$lib/api';
  import { toast } from '$lib/toast';
  import { ArrowLeft, FileText, Download, Loader2, Calendar, FileSpreadsheet } from 'lucide-svelte';
  import * as XLSX from 'xlsx';

  // @ts-ignore
  import flatpickr from 'flatpickr';
  import 'flatpickr/dist/flatpickr.css';
  import { Portuguese } from 'flatpickr/dist/l10n/pt.js';
  import jsPDF from 'jspdf';
  import autoTable from 'jspdf-autotable';

  type RelatorioEntradaPrefeituraRow = {
    productId: string; productName: string; unit: string;
    quantidadeAdicionada: number; motivoObservacao: string | null; userName: string;
  };

  let startDate = '';
  let endDate = '';
  let flatpickrStartInstance: any = null;
  let flatpickrEndInstance: any = null;
  let reportData: RelatorioEntradaPrefeituraRow[] | null = null;
  let isLoading = false;

  const flatpickrOptions = { dateFormat: 'Y-m-d', locale: Portuguese, disableMobile: true };

  function initStartDate(node: HTMLInputElement) {
    flatpickrStartInstance = flatpickr(node, {
      ...flatpickrOptions,
      onChange: (selectedDates: Date[]) => {
        if (selectedDates[0] && flatpickrEndInstance) flatpickrEndInstance.set('minDate', selectedDates[0]);
      },
    });
  }
  function initEndDate(node: HTMLInputElement) {
    flatpickrEndInstance = flatpickr(node, flatpickrOptions);
  }

  async function handleGenerateReport() {
    if (!startDate || !endDate) { toast.error('Selecione as datas.'); return; }
    isLoading = true; reportData = null;
    try {
      const dto = { startDate, endDate };
      reportData = await api.post('relatorios/entradas-estoque-central', dto);
      if (reportData?.length === 0) toast.info('Nenhuma entrada encontrada.');
    } catch (e: any) { toast.error(e?.message || 'Erro ao gerar.'); } 
    finally { isLoading = false; }
  }

  // PDF e Excel (Funções mantidas, apenas ocultadas para brevidade, lógica igual)
  function getReportHeaders() { return [['Produto', 'Unid.', 'Qtd.', 'Obs.', 'Usuário']]; }
  function getReportBody() { 
    if (!reportData) return [];
    return reportData.map(row => [row.productName, row.unit, row.quantidadeAdicionada, row.motivoObservacao || 'Ajuste', row.userName]);
  }
  async function handleDownloadPDF() {
     if (!reportData) return;
     const doc = new jsPDF();
     autoTable(doc, { head: getReportHeaders(), body: getReportBody() });
     doc.save('relatorio_entradas.pdf');
  }
  async function handleDownloadExcel() {
    if (!reportData) return;
    const ws = XLSX.utils.aoa_to_sheet([...getReportHeaders(), ...getReportBody()]);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, 'Entradas');
    XLSX.writeFile(wb, 'relatorio_entradas.xlsx');
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-4 lg:p-6 space-y-6 animate-fadeIn">
  <div class="mb-2">
    <a href="/relatorios" class="inline-flex items-center gap-2 text-sm text-primary-600 hover:text-primary-800 font-semibold transition-all group">
      <ArrowLeft class="w-4 h-4 transition-transform group-hover:-translate-x-1" /> Voltar
    </a>
  </div>

  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border">
    <div>
      <h1 class="text-2xl lg:text-3xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Relatório de Entradas (Central)
      </h1>
      <p class="text-gray-600 mt-1 text-sm">Auditoria de entradas por ajuste manual ou importação.</p>
    </div>
  </div>

  <div class="bg-white/80 backdrop-blur-md p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col md:flex-row flex-wrap gap-4 items-end">
    <div class="flex-1 w-full md:min-w-[150px]">
      <label for="startDate" class="block text-sm font-medium text-gray-700">Data de Início</label>
      <div class="relative mt-1">
        <input id="startDate" type="text" placeholder="dd/mm/aaaa" bind:value={startDate} use:initStartDate class="block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-primary-500 sm:text-sm pr-10" />
        <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none"><Calendar class="w-5 h-5 text-gray-400" /></div>
      </div>
    </div>
    <div class="flex-1 w-full md:min-w-[150px]">
      <label for="endDate" class="block text-sm font-medium text-gray-700">Data de Fim</label>
      <div class="relative mt-1">
        <input id="endDate" type="text" placeholder="dd/mm/aaaa" bind:value={endDate} use:initEndDate class="block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-primary-500 sm:text-sm pr-10" />
        <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none"><Calendar class="w-5 h-5 text-gray-400" /></div>
      </div>
    </div>
    <button on:click={handleGenerateReport} disabled={isLoading} class="w-full md:w-auto flex items-center justify-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95 disabled:opacity-50">
      {#if isLoading} <Loader2 class="w-5 h-5 animate-spin" /> Gerando... {:else} <FileText class="w-5 h-5" /> Gerar Relatório {/if}
    </button>
  </div>

  {#if reportData}
    <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 overflow-hidden">
      <div class="p-4 border-b border-gray-200 bg-gray-50/50 flex flex-col sm:flex-row flex-wrap gap-3 justify-end">
        <button on:click={handleDownloadExcel} class="flex items-center justify-center gap-2 bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all text-sm w-full sm:w-auto">
          <FileSpreadsheet class="w-4 h-4" /> Baixar Excel
        </button>
        <button on:click={handleDownloadPDF} class="flex items-center justify-center gap-2 bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all text-sm w-full sm:w-auto">
          <Download class="w-4 h-4" /> Baixar PDF
        </button>
      </div>
      
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Produto</th>
              <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider">Unid.</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">Qtd. Adicionada</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Observação</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Usuário</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-100">
            {#each reportData as row}
              <tr class="hover:bg-gray-50/50 transition-colors">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800">{row.productName}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 text-center">{row.unit}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-green-600 font-bold text-right">{row.quantidadeAdicionada}</td>
                <td class="px-6 py-4 text-sm text-gray-500 max-w-xs truncate" title={row.motivoObservacao || ''}>{row.motivoObservacao || 'Ajuste Manual'}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{row.userName}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/if}
</div>

<style>
  /* Esconde o ícone nativo de calendário */
  :global(input[type="date"]::-webkit-inner-spin-button),
  :global(input[type="date"]::-webkit-calendar-picker-indicator),
  :global(input[type="time"]::-webkit-calendar-picker-indicator) {
      display: none;
      -webkit-appearance: none;
  }
  @keyframes fadeIn { from { opacity: 0; transform: scale(0.98); } to { opacity: 1; transform: scale(1); } }
  .animate-fadeIn { animation: fadeIn 0.25s ease-out; }
</style>