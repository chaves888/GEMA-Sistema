<!-- src/lib/components/EscolaForm.svelte -->
<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';

  type Cidade = { id: string; name: string; state: string; };

  export let escola: { id?: string; name: string; address: string; cityId: string; } = { name: '', address: '', cityId: '' };
  export let isEditing = false;
  
  let cidades: Cidade[] = [];
  const dispatch = createEventDispatcher();

  onMount(async () => {
    cidades = await api.get('cidades');
    if (!isEditing && cidades.length > 0) {
      escola.cityId = cidades[0].id;
    }
  });

  function handleSubmit() {
    dispatch('save', escola);
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <h2 class="text-2xl font-bold mb-6">
    {isEditing ? 'Editar Escola' : 'Adicionar Nova Escola'}
  </h2>

  <div class="space-y-4">
    <div>
      <label for="name" class="block text-sm font-medium text-gray-700">Nome da Escola</label>
      <input type="text" id="name" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={escola.name} required>
    </div>

    <div>
      <label for="address" class="block text-sm font-medium text-gray-700">Endereço (Opcional)</label>
      <input type="text" id="address" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={escola.address}>
    </div>
    
    <div>
      <label for="city" class="block text-sm font-medium text-gray-700">Cidade</label>
      <select id="city" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={escola.cityId} required>
        {#if cidades.length === 0}
          <option disabled value="">Carregando cidades...</option>
        {:else}
          {#each cidades as cidade (cidade.id)}
            <option value={cidade.id}>{cidade.name} - {cidade.state}</option>
          {/each}
        {/if}
      </select>
    </div>
  </div>

  <div class="mt-8 flex justify-end space-x-3">
    <button type="button" on:click={() => dispatch('cancel')} class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded hover:bg-gray-300">
      Cancelar
    </button>
    <button type="submit" class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded">
      Salvar
    </button>
  </div>
</form>
