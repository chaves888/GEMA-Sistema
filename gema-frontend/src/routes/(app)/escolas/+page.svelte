<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import EscolaForm from '$lib/components/EscolaForm.svelte';

  // 1. IMPORTAR TOAST, CONFIRMDIALOG E ÍCONE DE BUSCA
  import { toast } from '$lib/toast';
  import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';
  import { Search } from 'lucide-svelte';

  // --- ATUALIZAR TIPO Escola (e Cidade aninhada) ---
  type Escola = {
    id: string;
    name: string;
    address: string | null;
    numero: string | null; // <-- ADICIONADO
    city: {
      id: string;
      name: string;
      state: string;
      cep: string;
      bairro?: string | null;
    };
  };
  // --- FIM ATUALIZAÇÃO ---

  let escolas: Escola[] = [];
  let isLoading = true;
  let error: string | null = null;

  // --- 2. ADICIONAR ESTADO PARA O FILTRO ---
  let searchTerm = '';

  // --- 3. ADICIONAR LISTA FILTRADA REATIVA ---
  $: filteredEscolas = escolas.filter((escola) => {
    const term = searchTerm.toLowerCase().trim();
    if (term === '') return true;
    
    // Busca no nome da escola ou no nome da cidade
    return (
      escola.name.toLowerCase().includes(term) ||
      escola.city.name.toLowerCase().includes(term)
    );
  });
  
  // --- FIM DAS ADIÇÕES DE FILTRO ---

  let showModal = false;
  let isEditing = false;
  // Tipo para o formulário (não muda)
  let currentEscola: {
    id?: string;
    name: string;
    address: string;
    numero?: string | null; // <-- ADICIONADO
    cityId: string;
  } = { name: '', address: '', numero: '', cityId: '' };

  // 2. ADICIONAR ESTADO PARA O MODAL DE CONFIRMAÇÃO
  let showConfirmModal = false;
  let escolaToDelete: Escola | null = null;
  let confirmMessage = '';

  onMount(async () => {
    try {
      // A API /escolas (com eager: true) já deve incluir o objeto 'city' completo
      escolas = await api.get('escolas');
    } catch (e: any) {
      error = e?.message || 'Não foi possível carregar as escolas.';
      console.error(e);
      // 3. ADICIONAR TOAST DE ERRO NO CARREGAMENTO
      toast.error(error ?? 'Ocorreu um erro desconhecido.');
    } finally {
      isLoading = false;
    }
  });

  function openAddModal() {
    isEditing = false;
    currentEscola = { name: '', address: '', numero: '', cityId: '' };
    showModal = true;
  }

  function openEditModal(escola: Escola) {
    isEditing = true;
    currentEscola = {
      id: escola.id,
      name: escola.name,
      address: escola.address || '',
      numero: escola.numero || '', // <-- ADICIONADO
      cityId: escola.city.id
    };
    showModal = true;
  }

  async function handleSave(event: any) {
    const escolaToSave = event.detail;

    // Validação de nomeazio (igual fizemos em outros)
    const trimmedName = escolaToSave.name ? escolaToSave.name.trim() : '';
    if (trimmedName === '') {
      toast.error('O nome da escola não pode estar vazio ou conter apenas espaços.');
      return;
    }
    escolaToSave.name = trimmedName;

    try {
      if (isEditing) {
        const updatedEscola = await api.patch(`escolas/${escolaToSave.id}`, escolaToSave);
        // Atualiza a lista local com os dados retornados (que incluirão a cidade atualizada)
        escolas = escolas.map((e) => (e.id === updatedEscola.id ? updatedEscola : e));
        // 4. SUBSTITUIR ALERT POR TOAST
        toast.success('Escola atualizada com sucesso!');
      } else {
        const newEscola = await api.post('escolas', escolaToSave);
        escolas = [...escolas, newEscola];
        escolas.sort((a, b) => a.name.localeCompare(b.name)); // Ordena
        // 4. SUBSTITUIR ALERT POR TOAST
        toast.success('Escola criada com sucesso!');
      }
      showModal = false;
    } catch (e: any) {
      // 4. SUBSTITUIR ALERT POR TOAST
      const errorMessage = e?.message || 'Erro ao salvar a escola.';
      toast.error(errorMessage);
      console.error(e);
    }
  }

  // 5. FUNÇÃO PARA ABRIR O MODAL DE CONFIRMAÇÃO
  function openConfirmDeleteModal(escola: Escola) {
    escolaToDelete = escola;
    confirmMessage = `Tem certeza que deseja excluir a escola "${escola.name}"?`;
    showConfirmModal = true;
  }

  // 6. FUNÇÃO QUE EXECUTA A EXCLUSÃO
  async function handleConfirmDelete() {
    if (!escolaToDelete) return;

    const idToDelete = escolaToDelete.id;

    // Fecha o modal e limpa o estado
    showConfirmModal = false;
    escolaToDelete = null;

    try {
      await api.del(`escolas/${idToDelete}`);
      escolas = escolas.filter((e) => e.id !== idToDelete);
      // 4. SUBSTITUIR ALERT POR TOAST
      toast.success('Escola excluída com sucesso!');
    } catch (e: any) {
      // 4. SUBSTITUIR ALERT POR TOAST
      const errorMessage = e?.message || 'Falha ao excluir a escola.';
      toast.error(errorMessage);
      console.error(e);
    }
  }

  // 7. FUNÇÃO PARA CANCELAR A EXCLUSÃO
  function onCancelDelete() {
    showConfirmModal = false;
    escolaToDelete = null;
  }

  // Função de formatar CEP (copiada de cidades/+page.svelte)
  function formatCep(cep: string | null | undefined): string {
    if (!cep) return '—';
    const cleaned = cep.replace(/\D/g, '');
    if (cleaned.length === 8) {
      return `${cleaned.slice(0, 5)}-${cleaned.slice(5)}`;
    }
    return cep;
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-4 lg:p-6 space-y-6 animate-fadeIn">
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border">
    <div>
      <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Gerenciamento de Escolas
      </h1>
      <p class="text-gray-600 mt-1 text-sm">Adicione, edite e remova escolas cadastradas no sistema.</p>
    </div>
    <button on:click={openAddModal} class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95">
      + Nova Escola
    </button>
  </div>

  <div class="bg-white/80 backdrop-blur-md p-4 rounded-xl shadow-sm border border-gray-100 flex flex-col md:flex-row flex-wrap gap-4">
    <div class="flex-1 min-w-[250px]">
      <label for="searchTerm" class="block text-sm font-medium text-gray-700">Buscar (Nome da Escola, Cidade)</label>
      <div class="relative mt-1">
        <input type="text" id="searchTerm" bind:value={searchTerm} placeholder="Digite o nome da escola ou cidade..." class="block w-full py-2 px-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pl-10" />
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Search class="w-5 h-5 text-gray-400" />
        </div>
      </div>
    </div>
  </div>

  {#if isLoading}
    <div class="flex justify-center items-center p-10"><p class="text-gray-500 text-lg animate-pulse">⏳ Carregando escolas...</p></div>
  {:else if filteredEscolas.length === 0}
    <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300"><p class="text-gray-600 font-semibold text-lg">Nenhum resultado.</p></div>
  {:else}
    <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gradient-to-r from-gray-50 to-gray-100">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Nome</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Endereço</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">N°</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Cidade</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Bairro</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">CEP</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">Ações</th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-100">
            {#each filteredEscolas as escola (escola.id)}
              <tr class="hover:bg-primary-50/40 transition-all duration-150">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800">{escola.name}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{escola.address || '—'}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{escola.numero || '—'}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{escola.city.name} - {escola.city.state}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{escola.city.bairro || '—'}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{formatCep(escola.city.cep)}</td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4">
                  <button on:click={() => openEditModal(escola)} class="text-primary-600 hover:text-primary-800 font-semibold transition-colors">Editar</button>
                  <button on:click={() => openConfirmDeleteModal(escola)} class="text-red-600 hover:text-red-800 font-semibold transition-colors">Excluir</button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/if}
</div>

<Modal show={showModal} on:close={() => (showModal = false)} size="max-w-2xl">
  <EscolaForm
    bind:escola={currentEscola}
    {isEditing}
    on:save={handleSave}
    on:cancel={() => (showModal = false)}
  />
</Modal>

<Modal show={showConfirmModal} on:close={onCancelDelete} size="max-w-md">
  <ConfirmDialog
    title="Excluir Escola"
    message={confirmMessage}
    confirmText="Sim, Excluir"
    on:confirm={handleConfirmDelete}
    on:cancel={onCancelDelete}
  />
</Modal>
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
  th:first-child {
    border-top-left-radius: 1rem;
  }
  th:last-child {
    border-top-right-radius: 1rem;
  }
</style>