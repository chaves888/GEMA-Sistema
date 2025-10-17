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

<div class="space-y-4">
  <div class="flex justify-between items-center">
    <h1 class="text-3xl font-bold text-gray-800">Gerenciamento de Escolas</h1>
    <button on:click={openAddModal} class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded">
      + Adicionar Escola
    </button>
  </div>

  {#if isLoading}
    <p>Carregando escolas...</p>
  {:else if error}
    <p class="text-red-500">{error}</p>
  {:else}
    <div class="bg-white shadow-md rounded-lg overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nome da Escola</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Endereço</th>
            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Cidade</th>
            <th class="relative px-6 py-3"><span class="sr-only">Ações</span></th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          {#each escolas as escola (escola.id)}
            <tr>
              <td class="px-6 py-4 whitespace-nowrap font-medium text-gray-900">{escola.name}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{escola.address || 'N/A'}</td>
              <td class="px-6 py-4 whitespace-nowrap">{escola.city.name} - {escola.city.state}</td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                <button on:click={() => openEditModal(escola)} class="text-primary-600 hover:text-primary-900">Editar</button>
                <button on:click={() => deleteEscola(escola.id, escola.name)} class="text-red-600 hover:text-red-900">Excluir</button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<Modal show={showModal} on:close={() => showModal = false}>
  <EscolaForm
    bind:escola={currentEscola}
    {isEditing}
    on:save={handleSave}
    on:cancel={() => showModal = false}
  />
</Modal>