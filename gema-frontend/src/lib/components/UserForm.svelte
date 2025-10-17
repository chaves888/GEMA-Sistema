<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';

  type School = { id: string; name: string; };

  // O componente recebe os dados do usuário
  export let user: { 
    id?: string; 
    name: string; 
    email: string; 
    password?: string; 
    profile: string;
    schoolId?: string; // <-- Novo campo para o ID da escola
  } = { 
    name: '', 
    email: '', 
    password: '', 
    profile: 'cozinheira',
    schoolId: undefined
  };
  export let isEditing = false;
  
  // Variável para guardar a lista de escolas
  let schools: School[] = [];
  const dispatch = createEventDispatcher();

  // onMount roda quando o componente é criado
  onMount(async () => {
    // Busca a lista de escolas para preencher o seletor
    try {
      schools = await api.get('escolas');
    } catch (e) {
      console.error("Falha ao carregar escolas", e);
    }
  });

  function handleSubmit() {
    // Se o perfil não for de escola ou cozinheira, garante que o schoolId não seja enviado
    if (user.profile !== 'escola' && user.profile !== 'cozinheira') {
      user.schoolId = undefined;
    }
    dispatch('save', user);
  }
</script>

<form on:submit|preventDefault={handleSubmit}>
  <h2 class="text-2xl font-bold mb-6">
    {isEditing ? 'Editar Usuário' : 'Adicionar Novo Usuário'}
  </h2>

  <div class="space-y-4">
    <div>
      <label for="name" class="block text-sm font-medium text-gray-700">Nome</label>
      <input type="text" id="name" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={user.name} required>
    </div>

    <div>
      <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
      <input type="email" id="email" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={user.email} required>
    </div>

    <div>
      <label for="password" class="block text-sm font-medium text-gray-700">
        Senha {isEditing ? '(Deixe em branco para não alterar)' : ''}
      </label>
      <input type="password" id="password" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={user.password} required={!isEditing}>
    </div>
    
    <div>
      <label for="profile" class="block text-sm font-medium text-gray-700">Perfil</label>
      <select id="profile" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={user.profile} required>
        <option value="prefeitura">Gestor da Prefeitura</option>
        <option value="escola">Gestor da Escola</option>
        <option value="nutricionista">Nutricionista</option>
        <option value="cozinheira">Cozinheira</option>
      </select>
    </div>

    {#if user.profile === 'escola' || user.profile === 'cozinheira'}
    <div>
      <label for="school" class="block text-sm font-medium text-gray-700">Escola</label>
      <select id="school" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" bind:value={user.schoolId} required>
        <option disabled value="">Selecione uma escola...</option>
        {#if schools.length === 0}
          <option disabled>Carregando escolas...</option>
        {:else}
          {#each schools as school (school.id)}
            <option value={school.id}>{school.name}</option>
          {/each}
        {/if}
      </select>
    </div>
    {/if}
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