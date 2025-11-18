<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  // @ts-ignore
  import flatpickr from 'flatpickr';
  import 'flatpickr/dist/flatpickr.css';
  import { Portuguese } from 'flatpickr/dist/l10n/pt.js';

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
    dispatch('save', { startDate: cardapio.startDate, endDate: cardapio.endDate });
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="flex flex-col h-full">
  <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-6">
    <h2 class="text-2xl lg:text-3xl font-bold text-gray-800 dark:text-white">
      {isEditing ? 'Editar Datas do Cardápio' : 'Novo Cardápio Semanal'}
    </h2>
  </div>

  <div class="space-y-6 flex-1">
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div>
        <label for="startDate" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Data de Início</label>
        <input
          id="startDate"
          type="text"
          class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm placeholder-gray-400 dark:placeholder-gray-400"
          use:flatpickr={flatpickrOptions}
          bind:value={cardapio.startDate}
          required
        />
      </div>

      <div>
        <label for="endDate" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Data de Fim</label>
        <input
          id="endDate"
          type="text"
          class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm placeholder-gray-400 dark:placeholder-gray-400"
          use:flatpickr={{ ...flatpickrOptions, minDate: cardapio.startDate }}
          bind:value={cardapio.endDate}
          required
        />
      </div>
    </div>
  </div>

  <div class="mt-10 flex flex-col-reverse sm:flex-row justify-end gap-3 sm:gap-4 border-t border-gray-200 dark:border-gray-700 pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="w-full sm:w-auto px-5 py-2.5 rounded-xl border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition shadow-sm"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold transition transform hover:scale-105 shadow-md"
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