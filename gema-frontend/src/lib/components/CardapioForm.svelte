<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import flatpickr from "flatpickr";
  import "flatpickr/dist/flatpickr.css";
  import { Portuguese } from "flatpickr/dist/l10n/pt.js";

  export let cardapio = {
    name: '',
    startDate: new Date().toISOString().split('T')[0],
    endDate: new Date().toISOString().split('T')[0]
  };

  export let isEditing = false;
  const dispatch = createEventDispatcher();

  const flatpickrOptions = {
    dateFormat: "Y-m-d",
    disable: [(date: Date) => date.getDay() === 0 || date.getDay() === 6],
    locale: Portuguese
  };

  function handleSubmit() {
    if (new Date(cardapio.endDate) < new Date(cardapio.startDate)) {
      alert('Erro: A data de fim não pode ser anterior à data de início.');
      return;
    }
    dispatch('save', cardapio);
  }
</script>

<!-- === FUNDO ESCURO DO MODAL === -->
<div class="fixed inset-0 bg-black bg-opacity-40 backdrop-blur-sm flex items-center justify-center z-50">
  <!-- === CONTEÚDO DO MODAL === -->
  <form on:submit|preventDefault={handleSubmit}
    class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl p-8 transform transition-all animate-fadeIn scale-100">

    <h2 class="text-3xl font-bold mb-6 text-gray-800 text-center border-b pb-4">
      {isEditing ? 'Editar Cardápio Semanal' : 'Novo Cardápio Semanal'}
    </h2>

    <div class="space-y-6">
      <div>
        <label for="name" class="block text-sm font-semibold text-gray-700 mb-1">Nome do Cardápio</label>
        <input 
          type="text"
          id="name"
          class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
          bind:value={cardapio.name}
          placeholder="Ex: Cardápio Semana 42 (21 a 25/10)"
          required
        >
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label for="startDate" class="block text-sm font-semibold text-gray-700 mb-1">Data de Início</label>
          <input
            id="startDate"
            class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
            use:flatpickr={flatpickrOptions}
            bind:value={cardapio.startDate}
            required
          />
        </div>
        <div>
          <label for="endDate" class="block text-sm font-semibold text-gray-700 mb-1">Data de Fim</label>
          <input
            id="endDate"
            class="mt-1 w-full rounded-lg border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-400 shadow-sm px-4 py-2 transition"
            use:flatpickr={flatpickrOptions}
            bind:value={cardapio.endDate}
            required
          />
        </div>
      </div>
    </div>

    <div class="mt-10 flex justify-end space-x-4 border-t pt-6">
      <button type="button"
        on:click={() => dispatch('cancel')}
        class="bg-gray-100 text-gray-700 font-semibold py-2.5 px-6 rounded-lg hover:bg-gray-200 transition shadow-sm">
        Cancelar
      </button>

      <button type="submit"
        class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2.5 px-6 rounded-lg shadow-md transition transform hover:scale-105">
        {isEditing ? 'Salvar Alterações' : 'Criar Cardápio'}
      </button>
    </div>
  </form>
</div>

<style>
  :global(.flatpickr-calendar) {
    z-index: 1000 !important;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
  }

  .animate-fadeIn {
    animation: fadeIn 0.25s ease-out;
  }
</style>
