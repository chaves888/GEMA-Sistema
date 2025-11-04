<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  // @ts-ignore
  import flatpickr from 'flatpickr';
  import 'flatpickr/dist/flatpickr.css';
  import { Portuguese } from 'flatpickr/dist/l10n/pt.js';
  // --- REMOVIDO: 'date-fns' não é mais necessário aqui ---

  export let cardapio = {
    startDate: new Date().toISOString().split('T')[0],
    endDate: new Date().toISOString().split('T')[0],
  };
  export let isEditing = false;
  const dispatch = createEventDispatcher();

  const flatpickrOptions = {
    dateFormat: 'Y-m-d',
    disable: [(date: Date) => date.getDay() === 0 || date.getDay() === 6],
    locale: Portuguese,
    minDate: 'today',
  };

  function handleSubmit() {
    // --- LÓGICA DE VALIDAÇÃO REMOVIDA ---
    // A página pai agora é responsável por validar
    dispatch('save', { startDate: cardapio.startDate, endDate: cardapio.endDate });
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <h2 class="text-3xl font-bold mb-6 text-gray-800 border-b pb-4">
    {isEditing ? 'Editar Datas do Cardápio' : 'Novo Cardápio Semanal'}
  </h2>
  <div class="space-y-6">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div>
        <label for="startDate" class="block text-sm font-semibold text-gray-700 mb-1"
          >Data de Início</label
        >
        <input
          id="startDate"
          type="text"
          class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
          use:flatpickr={flatpickrOptions}
          bind:value={cardapio.startDate}
          required
        />
      </div>
      <div>
        <label for="endDate" class="block text-sm font-semibold text-gray-700 mb-1"
          >Data de Fim</label
        >
        <input
          id="endDate"
          type="text"
          class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
          use:flatpickr={{ ...flatpickrOptions, minDate: cardapio.startDate }}
          bind:value={cardapio.endDate}
          required
        />
      </div>
    </div>
  </div>
  <div class="mt-10 flex justify-end space-x-4 border-t pt-6">
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
      {isEditing ? 'Salvar Datas' : 'Criar Cardápio'}
    </button>
  </div>
</form>

<style>
  :global(.flatpickr-calendar) {
    z-index: 1050 !important;
  }
</style>