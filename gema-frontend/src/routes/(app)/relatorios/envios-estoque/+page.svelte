<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import { toast } from '$lib/toast';
  // --- 1. IMPORTAR ÍCONE E BIBLIOTECA XLSX ---
  import { ArrowLeft, FileText, Download, Loader2, Calendar, FileSpreadsheet } from 'lucide-svelte';
  import * as XLSX from 'xlsx';
  
  import { format, parseISO } from 'date-fns';
  import { ptBR } from 'date-fns/locale';

  // @ts-ignore
  import flatpickr from 'flatpickr';
  // ... (outros imports)
  import jsPDF from 'jspdf';
  import autoTable from 'jspdf-autotable';
    import { Portuguese } from 'flatpickr/dist/l10n/pt';

  // ... (type RelatorioEnvioRow) ...
  type RelatorioEnvioRow = {
    dataEnvio: string; // Vem como string ISO
    escolaName: string;
    productName: string;
    unit: string;
    quantidadeEnviada: number;
    solicitacaoId: string;
  };

  // ... (variáveis de estado) ...
  let startDate = '';
  let endDate = '';
  let flatpickrStartInstance: any = null;
  let flatpickrEndInstance: any = null;
  let reportData: RelatorioEnvioRow[] | null = null;
  let isLoading = false;

  // ... (initStartDate, initEndDate, handleGenerateReport) ...
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
      reportData = await api.post('relatorios/envios-estoque-central', dto);
      if (reportData?.length === 0) {
        toast.info('Nenhum envio encontrado para o período selecionado.');
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
    return [['Escola', 'Produto', 'Unidade', 'Qtd. Total Enviada']];
  }
  function getReportBody() {
    if (!reportData) return [];
    return reportData.map((row) => [
      row.escolaName,
      row.productName,
      row.unit,
      row.quantidadeEnviada,
    ]);
  }
  // --- FIM DA PREPARAÇÃO ---

  async function handleDownloadPDF() {
    if (!reportData) return;
    try {
      const doc = new jsPDF();
      doc.setFontSize(16);
      doc.text('Relatório de Envios do Estoque Central', 14, 20);
      doc.setFontSize(10);
      doc.text(`Período: ${startDate} a ${endDate}`, 14, 26);

      autoTable(doc, {
        head: getReportHeaders(), // <-- Usar helper
        body: getReportBody(), // <-- Usar helper
        startY: 30,
        theme: 'grid',
        headStyles: { fillColor: [13, 71, 161] },
      });

      doc.save(`relatorio_envios_estoque_${startDate}_a_${endDate}.pdf`);
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
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Envios');
      
      worksheet['!cols'] = [
        { wch: 40 }, // Escola
        { wch: 30 }, // Produto
        { wch: 10 }, // Unidade
        { wch: 20 }  // Qtd. Total Enviada
      ];

      XLSX.writeFile(workbook, `relatorio_envios_estoque_${startDate}_a_${endDate}.xlsx`);
    } catch (e) {
      console.error('Erro ao gerar Excel:', e);
      toast.error('Falha ao gerar o Excel.');
    }
  }
  // --- FIM DA NOVA FUNÇÃO ---

  // ... (formatLocalDate)
  function formatLocalDate(dateString: string) {
      try {
        return format(parseISO(dateString), 'dd/MM/yyyy HH:mm', { locale: ptBR });
      } catch (e) {
        return dateString;
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
        Relatório de Envios do Estoque Central
      </h1>
      <p class="text-gray-600 mt-1 text-sm">
        Auditoria de produtos enviados pela Prefeitura (baseado no log de movimentações).
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
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Escola (Destino)</th
              >
              <th
                class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Produto</th
              >
              <th
                class="px-6 py-3 text-center text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Unid.</th
              >
              <th
                class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider"
                >Qtd. Total Enviada</th
              >
              </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-100">
            {#each reportData as row (`${row.escolaName}-${row.productName}`)}
              <tr class="hover:bg-gray-50/50 transition-colors duration-150">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800">
                  {row.escolaName}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                  {row.productName}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 text-center">
                  {row.unit}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-800 font-bold text-right">
                  {row.quantidadeEnviada}
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
  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: scale(0.98);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }
  .animate-fadeIn {
    animation: fadeIn 0.25s ease-out;
  }
</style>