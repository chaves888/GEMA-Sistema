<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import CidadeForm from '$lib/components/CidadeForm.svelte';
  import { toast } from '$lib/toast';
  import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';
  import { Search } from 'lucide-svelte';

  type CidadeApiResponse = {
    id: string;
    name: string;
    state: string;
    cep: string;
    bairro?: string | null;
  };
  type CidadeFormData = {
    id?: string;
    name: string;
    state: string;
    cep: string;
    bairro?: string | null;
  };

  let cidades: CidadeApiResponse[] = [];
  let isLoading = true;
  let error: string | null = null;
  let showModal = false;
  let isEditing = false;
  let currentCidade: CidadeFormData = { name: '', state: '', cep: '', bairro: '' };

  let searchTerm = '';

  $: filteredCidades = cidades.filter((cidade) => {
    const term = searchTerm.toLowerCase().trim();
    if (term === '') return true;

    return (
      cidade.name.toLowerCase().includes(term) ||
      (cidade.bairro || '').toLowerCase().includes(term) ||
      cidade.cep.toLowerCase().includes(term)
    );
  });

  let showConfirmModal = false;
  let cidadeToDelete: CidadeApiResponse | null = null;
  let confirmMessage = '';

  onMount(async () => {
    try {
      cidades = await api.get('cidades');
    } catch (e: any) {
      error = e?.message || 'Não foi possível carregar as cidades.';
      console.error(e);
      if (error) {
        toast.error(error);
      }
    } finally {
      isLoading = false;
    }
  });

  function openAddModal() {
    isEditing = false;
    currentCidade = { name: '', state: '', cep: '', bairro: '' };
    showModal = true;
  }

  function openEditModal(cidade: CidadeApiResponse) {
    isEditing = true;
    currentCidade = {
      id: cidade.id,
      name: cidade.name,
      state: cidade.state,
      cep: cidade.cep || '',
      bairro: cidade.bairro || ''
    };
    showModal = true;
  }

  async function handleSave(event: any) {
    const cidadeToSave = event.detail;
    const trimmedName = cidadeToSave.name ? cidadeToSave.name.trim() : '';
    if (trimmedName === '') {
      toast.error('O nome da cidade não pode estar vazio.');
      return;
    }
    cidadeToSave.name = trimmedName;

    try {
      if (isEditing) {
        const updatedCidade = await api.patch(`cidades/${cidadeToSave.id}`, cidadeToSave);
        cidades = cidades.map((c) => (c.id === updatedCidade.id ? updatedCidade : c));
        toast.success('Cidade atualizada com sucesso!');
      } else {
        const newCidade = await api.post('cidades', cidadeToSave);
        cidades = [...cidades, newCidade];
        cidades.sort((a, b) => a.name.localeCompare(b.name));
        toast.success('Cidade criada com sucesso!');
      }
      showModal = false;
    } catch (e: any) {
      const errorMessage = e?.message || 'Erro ao salvar a cidade.';
      toast.error(errorMessage);
      console.error(e);
    }
  }

  function openConfirmDeleteModal(cidade: CidadeApiResponse) {
    cidadeToDelete = cidade;
    confirmMessage = `Tem certeza que deseja excluir a cidade "${cidade.name}"?`;
    showConfirmModal = true;
  }

  async function handleConfirmDelete() {
    if (!cidadeToDelete) return;
    const idToDelete = cidadeToDelete.id;
    showConfirmModal = false;
    cidadeToDelete = null;

    try {
      await api.del(`cidades/${idToDelete}`);
      cidades = cidades.filter((c) => c.id !== idToDelete);
      toast.success('Cidade excluída com sucesso!');
    } catch (e: any) {
      const errorMessage = e?.message || 'Falha ao excluir a cidade.';
      toast.error(errorMessage);
      console.error(e);
    }
  }

  function onCancelDelete() {
    showConfirmModal = false;
    cidadeToDelete = null;
  }

  function formatCep(cep: string | null | undefined): string {
    if (!cep) return '—';
    const cleaned = cep.replace(/\D/g, '');
    if (cleaned.length === 8) {
      return `${cleaned.slice(0, 5)}-${cleaned.slice(5)}`;
    }
    return cep;
  }
</script>

<!-- Adicionado: dark:from-gray-900 dark:to-gray-800 e transition-colors -->
<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4 lg:p-6 space-y-6 animate-fadeIn transition-colors duration-300">
  
  <!-- Cabeçalho -->
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 dark:bg-gray-800/70 backdrop-blur-md p-5 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
    <div>
      <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Gerenciamento de Cidades
      </h1>
      <p class="text-gray-600 dark:text-gray-300 mt-1 text-sm">Adicione, edite e remova cidades cadastradas no sistema.</p>
    </div>
    <button on:click={openAddModal} class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95">
      + Nova Cidade
    </button>
  </div>

  <!-- Filtros -->
  <div class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-md p-4 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 flex flex-col md:flex-row flex-wrap gap-4">
    <div class="flex-1 min-w-[250px]">
      <label for="searchTerm" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Buscar (Nome, Bairro, CEP)</label>
      <div class="relative mt-1">
        <input
          type="text"
          id="searchTerm"
          bind:value={searchTerm}
          placeholder="Digite o nome, bairro ou CEP..."
          class="block w-full py-2 px-3 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pl-10 bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-400"
        />
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Search class="w-5 h-5 text-gray-400 dark:text-gray-500" />
        </div>
      </div>
    </div>
  </div>

  <!-- Tabela -->
  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 dark:text-gray-400 text-lg animate-pulse">⏳ Carregando cidades...</p>
    </div>
  {:else if error && cidades.length === 0}
    <div class="bg-red-100 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm font-medium dark:bg-red-900/20 dark:border-red-800 dark:text-red-400">
      {error}
    </div>
  {:else if cidades.length === 0}
    <div class="text-center p-10 bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-dashed border-gray-300 dark:border-gray-700">
      <p class="text-gray-600 dark:text-gray-300 font-semibold text-lg">Nenhuma cidade encontrada.</p>
      <p class="text-sm text-gray-400 dark:text-gray-500 mt-2">Clique em “Nova Cidade” para adicionar a primeira.</p>
    </div>
  {:else if filteredCidades.length === 0}
    <div class="text-center p-10 bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-dashed border-gray-300 dark:border-gray-700">
      <p class="text-gray-600 dark:text-gray-300 font-semibold text-lg">Nenhum resultado encontrado.</p>
      <p class="text-sm text-gray-400 dark:text-gray-500 mt-2">Tente ajustar o filtro de busca.</p>
    </div>
  {:else}
    <div class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 dark:border-gray-700 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-700 dark:to-gray-800">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Nome</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Bairro</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">CEP</th>
              <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">UF</th>
              <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Ações</th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-100 dark:divide-gray-700">
            {#each filteredCidades as cidade (cidade.id)}
              <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors duration-150">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800 dark:text-gray-200">{cidade.name}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400">{cidade.bairro || '—'}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400">{formatCep(cidade.cep)}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400 uppercase">{cidade.state}</td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4">
                  <button on:click={() => openEditModal(cidade)} class="text-primary-600 dark:text-primary-400 hover:text-primary-800 dark:hover:text-primary-300 font-semibold transition-colors">Editar</button>
                  <button on:click={() => openConfirmDeleteModal(cidade)} class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300 font-semibold transition-colors">Excluir</button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/if}
</div>

<Modal show={showModal} on:close={() => (showModal = false)} size="max-w-lg">
  <CidadeForm
    bind:cidade={currentCidade}
    {isEditing}
    on:save={handleSave}
    on:cancel={() => (showModal = false)}
  />
</Modal>

<Modal show={showConfirmModal} on:close={onCancelDelete} size="max-w-md">
  <ConfirmDialog
    title="Excluir Cidade"
    message={confirmMessage}
    confirmText="Sim, Excluir"
    on:confirm={handleConfirmDelete}
    on:cancel={onCancelDelete}
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
  th:first-child { border-top-left-radius: 1rem; }
  th:last-child { border-top-right-radius: 1rem; }
</style>