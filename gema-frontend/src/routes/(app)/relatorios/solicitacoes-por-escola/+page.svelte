<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { toast } from '$lib/toast';
  import Modal from '$lib/components/Modal.svelte';
  import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';
  // --- 1. IMPORTAR ÍCONE E BIBLIOTECA XLSX ---
  import { ArrowLeft, FileText, Download, Send, Loader2, Calendar, FileSpreadsheet } from 'lucide-svelte';
  import * as XLSX from 'xlsx';

  // @ts-ignore (Ignora aviso de tipo do flatpickr)
  import flatpickr from 'flatpickr';
  // ... (outros imports)
  import jsPDF from 'jspdf';
  import autoTable from 'jspdf-autotable';
    import { Portuguese } from 'flatpickr/dist/l10n/pt';

  // ... (type RelatorioRow)
  type RelatorioRow = {
    escolaId: string;
    escolaName: string;
    totalSolicitacoes: number;
    totalItensSolicitados: number;
    totalItensAprovados: number;
    totalComDivergencia: number;
    taxaAtendimento: number;
  };

  // ... (variáveis de estado: startDate, endDate, reportData, etc.)
  let startDate = '';
  let endDate = '';
  let flatpickrStartInstance: any = null;
  let flatpickrEndInstance: any = null;

  let reportData: RelatorioRow[] | null = null;
  let isLoading = false;
  let isSendingEmail = false;

  // ... (initStartDate, initEndDate, handleGenerateReport)
  const flatpickrOptions = {
    dateFormat: 'Y-m-d',
    locale: Portuguese,
  };
  function initStartDate(node: HTMLInputElement) {
    flatpickrStartInstance = flatpickr(node, {
      ...flatpickrOptions,
      onChange: (selectedDates) => {
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

  // --- 2. PREPARAR DADOS (PARA PDF E EXCEL) ---
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
  // --- FIM DA PREPARAÇÃO ---

  async function handleDownloadPDF() {
    if (!reportData) return;
    try {
      const doc = new jsPDF();
      doc.setFontSize(16);
      doc.text('Relatório Consolidado de Solicitações por Escola', 14, 20);
      doc.setFontSize(10);
      doc.text(`Período: ${startDate} a ${endDate}`, 14, 26);

      autoTable(doc, {
        head: getReportHeaders(), // <-- Usar helper
        body: getReportBody(), // <-- Usar helper
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

  // --- 3. NOVA FUNÇÃO DE EXCEL ---
  async function handleDownloadExcel() {
    if (!reportData) return;
    try {
      const data = [
        ...getReportHeaders(), // Cabeçalhos
        ...getReportBody()    // Corpo
      ];
      
      const worksheet = XLSX.utils.aoa_to_sheet(data);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Solicitações');
      
      // Auto-ajusta a largura das colunas (opcional, mas recomendado)
      worksheet['!cols'] = [
        { wch: 40 }, // Escola
        { wch: 15 }, // Total Pedidos
        { wch: 15 }, // Itens Pedidos
        { wch: 15 }, // Itens Aprovados
        { wch: 10 }, // % Atend.
        { wch: 15 }  // Divergências
      ];

      XLSX.writeFile(workbook, `relatorio_solicitacoes_${startDate}_a_${endDate}.xlsx`);
    } catch (e) {
      console.error('Erro ao gerar Excel:', e);
      toast.error('Falha ao gerar o Excel.');
    }
  }
  // --- FIM DA NOVA FUNÇÃO ---

  // ... (handleConfirmEmailSend e showConfirmModal) ...
  let showConfirmModal = false;
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

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-6 space-y-6 animate-fadeIn">
  <div class="mb-2">
    <a
      href="/relatorios"
      class="inline-flex items-center gap-2 text-sm text-primary-600 hover:text-primary-800 font-semibold transition-all group"
    >
      <ArrowLeft class="w-4 h-4 transition-transform group-hover:-translate-x-1" />
      Voltar para Relatórios
    </a>
  </div>
  <div
    class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border"
  >
    <div>
      <h1
        class="text-3xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent"
      >
        Relatório de Solicitações por Escola
      </h1>
      <p class="text-gray-600 mt-1 text-sm">
        Selecione um período para visualizar a performance dos pedidos.
      </p>
    </div>
  </div>
  <div
    class="bg-white/80 backdrop-blur-md p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col md:flex-row flex-wrap gap-4 items-end"
  >
    <div class="flex-1 min-w-[150px]">
      <label for="startDate" class="block text-sm font-medium text-gray-700">Data de Início</label>
      <div class="relative mt-1">
        <input
          id="startDate"
          type="text"
          placeholder="YYYY-MM-DD"
          bind:value={startDate}
          use:initStartDate
          class="block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pr-10"
        />
        <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
          <Calendar class="w-5 h-5 text-gray-400" />
        </div>
      </div>
    </div>
    <div class="flex-1 min-w-[150px]">
      <label for="endDate" class="block text-sm font-medium text-gray-700">Data de Fim</label>
      <div class="relative mt-1">
        <input
          id="endDate"
          type="text"
          placeholder="YYYY-MM-DD"
          bind:value={endDate}
          use:initEndDate
          class="block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pr-10"
        />
        <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
          <Calendar class="w-5 h-5 text-gray-400" />
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
    <div
      class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 overflow-hidden"
    >
      <div class="p-4 border-b border-gray-200 bg-gray-50/50 flex flex-wrap gap-3 justify-end">
        <button
          on:click={handleDownloadExcel}
          class="flex items-center gap-2 bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all text-sm"
        >
          <FileSpreadsheet class="w-4 h-4" /> Baixar Excel
        </button>
        <button
          on:click={handleDownloadPDF}
          class="flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all text-sm"
        >
          <Download class="w-4 h-4" /> Baixar PDF
        </button>
        <button
          on:click={() => (showConfirmModal = true)}
          disabled={isSendingEmail}
          class="flex items-center justify-center gap-2 bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all text-sm w-44"
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
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Escola</th
              >
              <th
                class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Total Pedidos</th
              >
              <th
                class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Itens Pedidos</th
              >
              <th
                class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Itens Aprovados</th
              >
              <th
                class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >% Atendimento</th
              >
              <th
                class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Pedidos c/ Divergência</th
              >
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-100">
            {#each reportData as row (row.escolaId)}
              <tr class="hover:bg-gray-50/50 transition-colors duration-150">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800">
                  {row.escolaName}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 text-center">
                  {row.totalSolicitacoes}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 text-right">
                  {row.totalItensSolicitados}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 text-right">
                  {row.totalItensAprovados}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-center">
                  {#if row.taxaAtendimento < 75}
                    <span class="text-red-600">{row.taxaAtendimento}%</span>
                  {:else if row.taxaAtendimento < 90}
                    <span class="text-yellow-600">{row.taxaAtendimento}%</span>
                  {:else}
                    <span class="text-green-600">{row.taxaAtendimento}%</span>
                  {/if}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-center">
                  {#if row.totalComDivergencia > 0}
                    <span class="font-bold text-orange-600">{row.totalComDivergencia}</span>
                  {:else}
                    <span class="text-gray-500">{row.totalComDivergencia}</span>
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
  @keyframes fadeIn {
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
  }
  .animate-fadeIn {
    animation: fadeIn 0.25s ease-out;
  }
</style>