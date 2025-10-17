<!-- src/routes/(app)/cidades/+page.svelte -->
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
    if (!confirm(`Tem certeza que deseja excluir a cidade "${cidadeName}"?`)) {
      return;
    }
    try {
      await api.del(`cidades/${cidadeId}`);
      cidades = cidades.filter(c => c.id !== cidadeId);
    } catch (e: any) {
      if (e && e.message) { alert(`Erro: ${e.message}`); }
      else { alert('Falha ao excluir a cidade.'); }
      console.error(e);
    }
  }
</script>

<div class="space-y-6 p-6">
  <div class="flex justify-between items-center">
    <h1 class="text-3xl font-extrabold text-gray-800">Gerenciamento de Cidades</h1>
    <button on:click={openAddModal} class="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 text-white font-semibold py-2 px-5 rounded-lg shadow-md transition-all duration-200">
      + Adicionar Cidade
    </button>
  </div>

  {#if isLoading}
    <p class="text-gray-500">Carregando cidades...</p>
  {:else if error}
    <p class="text-red-500 font-semibold">{error}</p>
  {:else}
    <div class="overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200 rounded-lg shadow-md overflow-hidden">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Nome</th>
            <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">Estado (UF)</th>
            <th class="px-6 py-3 text-right text-xs font-semibold text-gray-500 uppercase tracking-wider">Ações</th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          {#each cidades as cidade (cidade.id)}
            <tr class="hover:bg-gray-50 transition-colors">
              <td class="px-6 py-4 whitespace-nowrap font-medium text-gray-700">{cidade.name}</td>
              <td class="px-6 py-4 whitespace-nowrap text-gray-600">{cidade.state}</td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-2">
                <button on:click={() => openEditModal(cidade)} class="text-blue-600 hover:text-blue-800 font-semibold transition-colors">Editar</button>
                <button on:click={() => deleteCidade(cidade.id, cidade.name)} class="text-red-600 hover:text-red-800 font-semibold transition-colors">Excluir</button>
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