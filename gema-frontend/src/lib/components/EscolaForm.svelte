<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';

  type Cidade = { id: string; name: string; state: string };

  export let escola: { id?: string; name: string; address: string; cityId: string } = {
    name: '',
    address: '',
    cityId: '',
  };
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

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <h2 class="text-3xl font-bold text-gray-800 border-b pb-4">
    {isEditing ? 'Editar Escola' : 'Nova Escola'}
  </h2>

  <div class="space-y-5">
    <div>
      <label for="name" class="block text-sm font-semibold text-gray-700 mb-1">Nome da Escola</label>
      <input
        type="text"
        id="name"
        class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
        bind:value={escola.name}
        required
      />
    </div>

    <div>
      <label for="address" class="block text-sm font-semibold text-gray-700 mb-1">Endereço (Opcional)</label>
      <input
        type="text"
        id="address"
        class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
        bind:value={escola.address}
      />
    </div>

    <div>
      <label for="city" class="block text-sm font-semibold text-gray-700 mb-1">Cidade</label>
      <select
        id="city"
        class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition bg-white"
        bind:value={escola.cityId}
        required
      >
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

  <div class="mt-8 flex justify-end space-x-4 border-t pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105"
    >
      Salvar
    </button>
  </div>
</form>