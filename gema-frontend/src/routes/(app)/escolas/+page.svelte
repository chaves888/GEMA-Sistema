<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import EscolaForm from '$lib/components/EscolaForm.svelte';

  type Escola = {
    id: string;
    name: string;
    address: string;
    city: {
      id: string;
      name: string;
      state: string;
    }
  };
  
  let escolas: Escola[] = [];
  let isLoading = true;
  let error: string | null = null;

  let showModal = false;
  let isEditing = false;
  let currentEscola: any = {};

  onMount(async () => {
    try {
      escolas = await api.get('escolas');
    } catch (e) {
      error = 'Não foi possível carregar as escolas.';
      console.error(e);
    } finally {
      isLoading = false;
    }
  });

  function openAddModal() {
    isEditing = false;
    currentEscola = { name: '', address: '', cityId: '' };
    showModal = true;
  }

  function openEditModal(escola: Escola) {
    isEditing = true;
    currentEscola = { 
      id: escola.id,
      name: escola.name,
      address: escola.address,
      cityId: escola.city.id
    }; 
    showModal = true;
  }

  async function handleSave(event: any) {
    const escolaToSave = event.detail;
    try {
      if (isEditing) {
        const updatedEscola = await api.patch(`escolas/${escolaToSave.id}`, escolaToSave);
        escolas = escolas.map(e => e.id === updatedEscola.id ? updatedEscola : e);
      } else {
        const newEscola = await api.post('escolas', escolaToSave);
        escolas = [...escolas, newEscola];
      }
      showModal = false;
    } catch (e) {
      alert('Erro ao salvar a escola.');
      console.error(e);
    }
  }
  
  async function deleteEscola(escolaId: string, escolaName: string) {
    if (!confirm(`Tem certeza que deseja excluir a escola "${escolaName}"?`)) {
      return;
    }
    try {
      await api.del(`escolas/${escolaId}`);
      escolas = escolas.filter(e => e.id !== escolaId);
    } catch (e: any) {
      if (e && e.message) {
        alert(`Erro: ${e.message}`);
      } else {
        alert('Falha ao excluir a escola.');
      }
      console.error(e);
    }
  }
</script>

<!-- 🌆 CONTAINER GERAL -->
<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 py-10 px-6 space-y-8 animate-fadeIn">

  <!-- 🔹 CABEÇALHO -->
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-6 rounded-xl shadow-sm border border-gray-100">
    <div>
      <h1 class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Gerenciamento de Escolas
      </h1>
      <p class="text-gray-600 mt-1 text-sm">Adicione, edite e remova escolas cadastradas no sistema.</p>
    </div>

    <button 
      on:click={openAddModal}
      class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95"
    >
      <span class="text-lg">＋</span> Nova Escola
    </button>
  </div>

  <!-- 🔸 CONTEÚDO -->
  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 text-lg animate-pulse">⏳ Carregando escolas...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">{error}</div>
  {:else if escolas.length === 0}
    <div class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300">
      <p class="text-gray-600 font-semibold text-lg">Nenhuma escola encontrada.</p>
      <p class="text-sm text-gray-400 mt-2">Clique em “Nova Escola” para adicionar a primeira.</p>
    </div>
  {:else}
    <div class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gradient-to-r from-gray-50 to-gray-100">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Nome</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Endereço</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider">Cidade</th>
            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider">Ações</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-100">
          {#each escolas as escola (escola.id)}
            <tr class="hover:bg-primary-50/40 transition-all duration-150">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800">{escola.name}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{escola.address || '—'}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{escola.city.name} - {escola.city.state}</td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4">
                <button 
                  on:click={() => openEditModal(escola)} 
                  class="text-primary-600 hover:text-primary-800 font-semibold transition-colors">
                  Editar
                </button>
                <button 
                  on:click={() => deleteEscola(escola.id, escola.name)} 
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

<!-- 🔹 MODAL -->
<Modal show={showModal} on:close={() => showModal = false}>
  <EscolaForm
    bind:escola={currentEscola}
    {isEditing}
    on:save={handleSave}
    on:cancel={() => showModal = false}
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

  th:first-child {
    border-top-left-radius: 1rem;
  }

  th:last-child {
    border-top-right-radius: 1rem;
  }
</style>
