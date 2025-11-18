<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { toast } from '$lib/toast';
  import Modal from '$lib/components/Modal.svelte';
  import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';
  import { ArrowLeft, FileText, Download, Send, Loader2, Calendar, FileSpreadsheet } from 'lucide-svelte';
  import * as XLSX from 'xlsx';

  // @ts-ignore
  import flatpickr from 'flatpickr';
  import 'flatpickr/dist/flatpickr.css';
  import { Portuguese } from 'flatpickr/dist/l10n/pt.js';

  import jsPDF from 'jspdf';
  import autoTable from 'jspdf-autotable';

  type RelatorioRow = {
    escolaId: string;
    escolaName: string;
    totalSolicitacoes: number;
    totalItensSolicitados: number;
    totalItensAprovados: number;
    totalComDivergencia: number;
    taxaAtendimento: number;
  };

  let startDate = '';
  let endDate = '';
  let flatpickrStartInstance: any = null;
  let flatpickrEndInstance: any = null;

  let reportData: RelatorioRow[] | null = null;
  let isLoading = false;
  let isSendingEmail = false;
  let showConfirmModal = false;

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
      reportData = await api.post('relatorios/solicitacoes-por-escola', dto);
      if (reportData?.length === 0) {
        toast.info('Nenhum dado encontrado para o período selecionado.');
      }
    } catch (e: any) {
      toast.error(e?.message || 'Erro ao gerar o relatório.');
      console.error(e);
    } finally {
      isLoading = false;
    }
  }

  function getReportHeaders() {
    return [
      [
        'Escola',
        'Total Pedidos',
        'Itens Pedidos',
        'Itens Aprovados',
        '% Atend.',
        'Divergências',
      ],
    ];
  }

  function getReportBody() {
    if (!reportData) return [];
    return reportData.map((row) => [
      row.escolaName,
      row.totalSolicitacoes,
      row.totalItensSolicitados,
      row.totalItensAprovados,
      `${row.taxaAtendimento}%`,
      row.totalComDivergencia,
    ]);
  }

  async function handleDownloadPDF() {
    if (!reportData) return;
    try {
      const doc = new jsPDF();
      doc.setFontSize(16);
      doc.text('Relatório Consolidado de Solicitações por Escola', 14, 20);
      doc.setFontSize(10);
      doc.text(`Período: ${startDate} a ${endDate}`, 14, 26);

      autoTable(doc, {
        head: getReportHeaders(),
        body: getReportBody(),
        startY: 30,
        theme: 'grid',
        headStyles: { fillColor: [13, 71, 161] },
      });

      doc.save(`relatorio_solicitacoes_${startDate}_a_${endDate}.pdf`);
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
        ...getReportBody(),
      ];

      const worksheet = XLSX.utils.aoa_to_sheet(data);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Solicitações');

      worksheet['!cols'] = [
        { wch: 40 },
        { wch: 15 },
        { wch: 15 },
        { wch: 15 },
        { wch: 10 },
        { wch: 15 },
      ];

      XLSX.writeFile(workbook, `relatorio_solicitacoes_${startDate}_a_${endDate}.xlsx`);
    } catch (e) {
      console.error('Erro ao gerar Excel:', e);
      toast.error('Falha ao gerar o Excel.');
    }
  }

  async function handleConfirmEmailSend() {
    isSendingEmail = true;
    showConfirmModal = false;
    try {
      const dto = { startDate, endDate };
      const response = await api.post('relatorios/solicitacoes-por-escola/enviar-email', dto);
      toast.success(response.message || 'E-mail enviado com sucesso!');
    } catch (e: any) {
      toast.error(e?.message || 'Erro ao enviar o e-mail.');
      console.error(e);
    } finally {
      isSendingEmail = false;
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
        Relatório de Solicitações por Escola
      </h1>
      <p class="text-gray-600 dark:text-gray-300 mt-1 text-sm">
        Selecione um período para visualizar a performance dos pedidos.
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
        <button
          on:click={() => (showConfirmModal = true)}
          disabled={isSendingEmail}
          class="flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all text-sm w-full sm:w-auto"
        >
          {#if isSendingEmail}
            <Loader2 class="w-4 h-4 animate-spin" />
            Enviando...
          {:else}
            <Send class="w-4 h-4" />
            Enviar por E-mail
          {/if}
        </button>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Escola</th>
              <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Total Pedidos</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Itens Pedidos</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Itens Aprovados</th>
              <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">% Atendimento</th>
              <th class="px-6 py-3 text-center text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Pedidos c/ Divergência</th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-100 dark:divide-gray-700">
            {#each reportData as row (row.escolaId)}
              <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors duration-150">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800 dark:text-gray-200">
                  {row.escolaName}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400 text-center">
                  {row.totalSolicitacoes}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400 text-right">
                  {row.totalItensSolicitados}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400 text-right">
                  {row.totalItensAprovados}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-center">
                  {#if row.taxaAtendimento < 75}
                    <span class="text-red-600 dark:text-red-400">{row.taxaAtendimento}%</span>
                  {:else if row.taxaAtendimento < 90}
                    <span class="text-yellow-600 dark:text-yellow-400">{row.taxaAtendimento}%</span>
                  {:else}
                    <span class="text-green-600 dark:text-green-400">{row.taxaAtendimento}%</span>
                  {/if}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-center">
                  {#if row.totalComDivergencia > 0}
                    <span class="font-bold text-orange-600 dark:text-orange-400">{row.totalComDivergencia}</span>
                  {:else}
                    <span class="text-gray-500 dark:text-gray-500">{row.totalComDivergencia}</span>
                  {/if}
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/if}
</div>

<Modal show={showConfirmModal} on:close={() => (showConfirmModal = false)} size="max-w-md">
  <ConfirmDialog
    title="Enviar Relatório por E-mail"
    message="Tem certeza que deseja enviar este relatório por e-mail para você e para todos os Gestores de Escola ativos?"
    confirmText="Sim, Enviar"
    on:confirm={handleConfirmEmailSend}
    on:cancel={() => (showConfirmModal = false)}
  />
</Modal>

<style>
  /* Esconde o ícone nativo do navegador */
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