<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  
  // 1. Importa a biblioteca flatpickr
  import flatpickr from "flatpickr";
  
  // 2. Importa o CSS do calendário
  import "flatpickr/dist/flatpickr.css";
  
  // 3. --- MUDANÇA AQUI: Importa o pacote de idioma Português ---
  import { Portuguese } from "flatpickr/dist/l10n/pt.js";

  export let cardapio: {
    id?: string;
    name: string;
    startDate: string;
    endDate: string;
  } = {
    name: '',
    startDate: new Date().toISOString().split('T')[0],
    endDate: new Date().toISOString().split('T')[0]
  };
  
  export let isEditing = false;
  
  const dispatch = createEventDispatcher();

  // 4. --- MUDANÇA AQUI: Adiciona a opção 'locale' ---
  const flatpickrOptions = {
    dateFormat: "Y-m-d", // Formato YYYY-MM-DD
    disable: [
      (date: Date) => {
        // Retorna 'true' para Sábado (6) ou Domingo (0)
        return (date.getDay() === 0 || date.getDay() === 6);
      }
    ],
    locale: Portuguese, // Define o idioma do calendário
  };

  function handleSubmit() {
    if (new Date(cardapio.endDate) < new Date(cardapio.startDate)) {
        alert('Erro: A data de fim não pode ser anterior à data de início.');
        return;
    }
    dispatch('save', cardapio);
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="space-y-6">
  <h2 class="text-2xl font-bold mb-6 text-gray-800">
    {isEditing ? 'Editar Cardápio Semanal' : 'Novo Cardápio Semanal'}
  </h2>

  <div class="space-y-4">
    <div>
      <label for="name" class="block text-sm font-medium text-gray-700">Nome do Cardápio</label>
      <input 
        type="text" 
        id="name" 
        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" 
        bind:value={cardapio.name} 
        placeholder="Ex: Cardápio Semana 42 (21 a 25/10)"
        required
      >
    </div>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <label for="startDate" class="block text-sm font-medium text-gray-700">Data de Início</label>
        <input
          id="startDate"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
          use:flatpickr={flatpickrOptions}
          bind:value={cardapio.startDate}
          required
        />
      </div>
      <div>
        <label for="endDate" class="block text-sm font-medium text-gray-700">Data de Fim</label>
         <input
          id="endDate"
          class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
          use:flatpickr={flatpickrOptions}
          bind:value={cardapio.endDate}
          required
        />
      </div>
    </div>
  </div>

  <div class="mt-8 flex justify-end space-x-3 border-t pt-6">
    <button type="button" on:click={() => dispatch('cancel')} class="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded-lg hover:bg-gray-300 transition">
      Cancelar
    </button>
    <button type="submit" class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded-lg shadow-md transition">
      {isEditing ? 'Salvar Alterações' : 'Criar Cardápio'}
    </button>
  </div>
</form>

<style>
  :global(.flatpickr-calendar) {
    z-index: 100 !important;
  }
</style>