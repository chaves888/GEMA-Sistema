<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import CidadeForm from '$lib/components/CidadeForm.svelte';

  type Cidade = { id: string; name: string; state: string; };
  
  let cidades: Cidade[] = [];
  let isLoading = true;
  let error: string | null = null;

  let showModal = false;
  let isEditing = false;
  let currentCidade: any = {};

  onMount(async () => {
    try {
      cidades = await api.get('cidades');
    } catch (e) {
      error = 'Não foi possível carregar as cidades.';
      console.error(e);
    } finally {
      isLoading = false;
    }
  });

  function openAddModal() {
    isEditing = false;
    currentCidade = { name: '', state: '' };
    showModal = true;
  }

  function openEditModal(cidade: Cidade) {
    isEditing = true;
    currentCidade = { ...cidade }; 
    showModal = true;
  }

  async function handleSave(event: any) {
    const cidadeToSave = event.detail;
    try {
      if (isEditing) {
        const updatedCidade = await api.patch(`cidades/${cidadeToSave.id}`, cidadeToSave);
        cidades = cidades.map(c => c.id === updatedCidade.id ? updatedCidade : c);
      } else {
        const newCidade = await api.post('cidades', cidadeToSave);
        cidades = [...cidades, newCidade];
      }
      showModal = false;
    } catch (e) {
      alert('Erro ao salvar a cidade.');
      console.error(e);
    }
  }
  
  async function deleteCidade(cidadeId: string, cidadeName: string) {
    if (!confirm(`Tem certeza que deseja excluir a cidade "${cidadeName}"?`)) return;
    try {
      await api.del(`cidades/${cidadeId}`);
      cidades = cidades.filter(c => c.id !== cidadeId);
    } catch (e: any) {
      if (e && e.message) alert(`Erro: ${e.message}`);
      else alert('Falha ao excluir a cidade.');
      console.error(e);
    }
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 py-10 px-6 space-y-8 animate-fadeIn">

  <!-- 🔹 Cabeçalho -->
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-6 rounded-xl shadow-sm border border-gray-100">
    <div>
      <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Gerenciamento de Cidades
      </h1>
      <p class="text-gray-600 mt-1 text-sm">Adicione, edite e remova cidades cadastradas no sistema.</p>
    </div>

    <button 
      on:click={openAddModal}
      class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95"
    >
      + Nova Cidade
    </button>
  </div>

  <!-- 🔸 Conteúdo -->
  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando cidades...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">{error}</div>
  {:else if cidades.length === 0}
    <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300">
      <p class="text-gray-600 font-semibold text-lg">Nenhuma cidade encontrada.</p>
      <p class="text-sm text-gray-400 mt-2">Clique em “Nova Cidade” para adicionar a primeira.</p>
    </div>
  {:else}
    <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gradient-to-r from-gray-50 to-gray-100">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Nome</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Estado (UF)</th>
            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">Ações</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-100">
          {#each cidades as cidade (cidade.id)}
            <tr class="hover:bg-gray-50 transition-colors duration-150">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800">{cidade.name}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 uppercase">{cidade.state}</td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4">
                <button 
                  on:click={() => openEditModal(cidade)} 
                  class="text-primary-600 hover:text-primary-800 font-semibold transition-colors">
                  Editar
                </button>
                <button 
                  on:click={() => deleteCidade(cidade.id, cidade.name)} 
                  class="text-red-600 hover:text-red-800 font-semibold transition-colors">
                  Excluir
                </button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<Modal show={showModal} on:close={() => showModal = false}>
  <CidadeForm bind:cidade={currentCidade} {isEditing} on:save={handleSave} on:cancel={() => showModal = false} />
</Modal>

<style>
  @keyframes fadeIn {
    from { opacity: 0; transform: scale(0.98); }
    to { opacity: 1; transform: scale(1); }
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
