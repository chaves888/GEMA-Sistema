<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let cidade: { id?: string; name: string; state: string } = { name: '', state: '' };
  export let isEditing = false;

  const dispatch = createEventDispatcher();

  function handleSubmit() {
    cidade.state = cidade.state.toUpperCase();
    dispatch('save', cidade);
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <h2 class="text-3xl font-bold text-gray-800 border-b pb-4">
    {isEditing ? 'Editar Cidade' : 'Nova Cidade'}
  </h2>

  <div class="space-y-5">
    <div>
      <label for="name" class="block text-sm font-semibold text-gray-700 mb-1">Nome da Cidade</label>
      <input
        type="text"
        id="name"
        class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
        bind:value={cidade.name}
        required
      />
    </div>

    <div>
      <label for="state" class="block text-sm font-semibold text-gray-700 mb-1">Estado (UF)</label>
      <input
        type="text"
        id="state"
        class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
        placeholder="Ex: SP"
        maxlength="2"
        bind:value={cidade.state}
        required
      />
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