<script lang="ts">
  import * as api from '$lib/api';
  import { toast } from '$lib/toast';
  import { ArrowLeft, FileText, Download, Loader2, Calendar, FileSpreadsheet } from 'lucide-svelte';
  import * as XLSX from 'xlsx';
  import { onMount } from 'svelte';

  // @ts-ignore
  import flatpickr from 'flatpickr';
  import 'flatpickr/dist/flatpickr.css';
  import { Portuguese } from 'flatpickr/dist/l10n/pt.js';

  import jsPDF from 'jspdf';
  import autoTable from 'jspdf-autotable';

  type RelatorioAjustePrefeituraRow = {
    productId: string;
    productName: string;
    unit: string;
    motivoCategoria: string;
    motivoObservacao: string | null;
    quantidadeTotal: number;
  };

  let startDate = '';
  let endDate = '';
  let flatpickrStartInstance: any = null;
  let flatpickrEndInstance: any = null;
  let reportData: RelatorioAjustePrefeituraRow[] | null = null;
  let isLoading = false;

  const flatpickrOptions = {
    dateFormat: 'Y-m-d',
    locale: Portuguese,
    disableMobile: true
  };

  function initStartDate(node: HTMLInputElement) {
    flatpickrStartInstance = flatpickr(node, {
      ...flatpickrOptions,
      onChange: (selectedDates: Date[]) => {
        if (selectedDates[0] && flatpickrEndInstance) {
          flatpickrEndInstance.set('minDate', selectedDates[0]);
        }
      },
    });
  }

  function initEndDate(node: HTMLInputElement) {
    flatpickrEndInstance = flatpickr(node, flatpickrOptions);
  }

  async function handleGenerateReport() {
    if (!startDate || !endDate) {
      toast.error('Por favor, selecione a data de início e a data de fim.');
      return;
    }
    if (new Date(endDate) < new Date(startDate)) {
      toast.error('A data de fim não pode ser anterior à data de início.');
      return;
    }
    isLoading = true;
    reportData = null;
    try {
      const dto = { startDate, endDate };
      reportData = await api.post('relatorios/ajustes-perdas-prefeitura', dto);
      if (reportData?.length === 0) {
        toast.info('Nenhum ajuste ou perda encontrado no período.');
      }
    } catch (e: any) {
      toast.error(e?.message || 'Erro ao gerar o relatório.');
      console.error(e);
    } finally {
      isLoading = false;
    }
  }

  function formatMotivo(motivo: string): string {
    switch (motivo) {
      case 'perda': return 'Perda / Avaria';
      case 'vencimento': return 'Vencimento';
      case 'uso_interno': return 'Uso Interno';
      case 'ajuste': return 'Ajuste de Contagem';
      case 'outro': return 'Outro';
      default: return motivo;
    }
  }

  function getMotivoClass(motivo: string): string {
    switch (motivo) {
      case 'perda':
      case 'vencimento':
        return 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300';
      case 'uso_interno':
      case 'outro':
        return 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-300';
      case 'ajuste':
        return 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300';
      default:
        return 'bg-gray-100 text-gray-700 dark:bg-gray-700/50 dark:text-gray-300';
    }
  }

  function getReportHeaders() {
    return [['Produto', 'Unid.', 'Motivo', 'Qtd.', 'Descrição']];
  }

  function getReportBody() {
    if (!reportData) return [];
    return reportData.map((row) => [
      row.productName,
      row.unit,
      formatMotivo(row.motivoCategoria),
      row.quantidadeTotal,
      row.motivoObservacao || '-',
    ]);
  }

  async function handleDownloadPDF() {
    if (!reportData) return;
    try {
      const doc = new jsPDF();
      doc.setFontSize(16);
      doc.text('Relatório de Ajustes e Perdas (Estoque Central)', 14, 20);
      doc.setFontSize(10);
      doc.text(`Período: ${startDate} a ${endDate}`, 14, 26);

      autoTable(doc, {
        head: getReportHeaders(),
        body: getReportBody(),
        startY: 30,
        theme: 'grid',
        headStyles: { fillColor: [13, 71, 161] },
      });

      doc.save(`relatorio_ajustes_perdas_central_${startDate}_a_${endDate}.pdf`);
    } catch (e) {
      console.error('Erro ao gerar PDF:', e);
      toast.error('Falha ao gerar o PDF.');
    }
  }

  async function handleDownloadExcel() {
    if (!reportData) return;
    try {
      const data = [
        ...getReportHeaders(),
        ...getReportBody()
      ];
      
      const worksheet = XLSX.utils.aoa_to_sheet(data);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Ajustes_Central');
      
      worksheet['!cols'] = [
        { wch: 30 },
        { wch: 10 },
        { wch: 20 },
        { wch: 10 },
        { wch: 50 }
      ];

      XLSX.writeFile(workbook, `relatorio_ajustes_perdas_central_${startDate}_a_${endDate}.xlsx`);
    } catch (e) {
      console.error('Erro ao gerar Excel:', e);
      toast.error('Falha ao gerar o Excel.');
    }
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4 lg:p-6 space-y-6 animate-fadeIn transition-colors duration-300">
  <div class="mb-2">
    <a
      href="/relatorios"
      class="inline-flex items-center gap-2 text-sm text-primary-600 hover:text-primary-800 dark:text-primary-400 dark:hover:text-primary-300 font-semibold transition-all group"
    >
      <ArrowLeft class="w-4 h-4 transition-transform group-hover:-translate-x-1" />
      Voltar para Relatórios
    </a>
  </div>
  
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 dark:bg-gray-800/70 backdrop-blur-md p-5 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
    <div>
      <h1 class="text-2xl lg:text-3xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Relatório de Ajustes e Perdas (Estoque Central)
      </h1>
      <p class="text-gray-600 dark:text-gray-300 mt-1 text-sm">
        Auditoria de perdas, vencimentos e outros ajustes de saída manuais da Prefeitura.
      </p>
    </div>
  </div>

  <div class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-md p-4 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 flex flex-col md:flex-row flex-wrap gap-4 items-end">
    <div class="flex-1 w-full md:min-w-[150px]">
      <label for="startDate" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Data de Início</label>
      <div class="relative mt-1">
        <input
          id="startDate"
          type="text"
          placeholder="dd/mm/aaaa"
          bind:value={startDate}
          use:initStartDate
          class="block w-full py-2 px-3 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pr-10 bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-400"
        />
        <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
          <Calendar class="w-5 h-5 text-gray-400 dark:text-gray-500" />
        </div>
      </div>
    </div>
    <div class="flex-1 w-full md:min-w-[150px]">
      <label for="endDate" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Data de Fim</label>
      <div class="relative mt-1">
        <input
          id="endDate"
          type="text"
          placeholder="dd/mm/aaaa"
          bind:value={endDate}
          use:initEndDate
          class="block w-full py-2 px-3 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pr-10 bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-400"
        />
        <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
          <Calendar class="w-5 h-5 text-gray-400 dark:text-gray-500" />
        </div>
      </div>
    </div>
    <button
      on:click={handleGenerateReport}
      disabled={isLoading}
      class="w-full md:w-auto flex items-center justify-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95 disabled:opacity-50"
    >
      {#if isLoading}
        <Loader2 class="w-5 h-5 animate-spin" />
        Gerando...
      {:else}
        <FileText class="w-5 h-5" />
        Gerar Relatório
      {/if}
    </button>
  </div>

  {#if reportData}
    <div class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 dark:border-gray-700 overflow-hidden">
      <div class="p-4 border-b border-gray-200 dark:border-gray-700 bg-gray-50/50 dark:bg-gray-700/30 flex flex-col sm:flex-row flex-wrap gap-3 justify-end">
        <button
          on:click={handleDownloadExcel}
          class="flex items-center justify-center gap-2 bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all text-sm w-full sm:w-auto"
        >
          <FileSpreadsheet class="w-4 h-4" /> Baixar Excel
        </button>
        <button
          on:click={handleDownloadPDF}
          class="flex items-center justify-center gap-2 bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all text-sm w-full sm:w-auto"
        >
          <Download class="w-4 h-4" /> Baixar PDF
        </button>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Produto</th>
              <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Unid.</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Motivo</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Qtd. Total</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Descrição (Observação)</th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-100 dark:divide-gray-700">
            {#each reportData as row (`${row.productId}-${row.motivoCategoria}-${row.motivoObservacao}`)}
              <tr class="hover:bg-gray-50/50 dark:hover:bg-gray-700/50 transition-colors duration-150">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800 dark:text-gray-200">
                  {row.productName}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400 text-center">
                  {row.unit}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm">
                  <span class="px-2 py-0.5 rounded-full text-xs font-semibold {getMotivoClass(row.motivoCategoria)}">
                    {formatMotivo(row.motivoCategoria)}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-red-600 dark:text-red-400 font-bold text-right">
                  {row.quantidadeTotal}
                </td>
                <td class="px-6 py-4 text-sm text-gray-500 dark:text-gray-400 max-w-xs truncate" title={row.motivoObservacao || ''}>
                  {row.motivoObservacao || '—'}
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/if}
</div>

<style>
  /* Esconde o ícone nativo de calendário do navegador */
  :global(input[type="date"]::-webkit-inner-spin-button),
  :global(input[type="date"]::-webkit-calendar-picker-indicator),
  :global(input[type="time"]::-webkit-calendar-picker-indicator) {
      display: none;
      -webkit-appearance: none;
  }
  
  @keyframes fadeIn {
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
  }
  .animate-fadeIn {
    animation: fadeIn 0.25s ease-out;
  }
</style>