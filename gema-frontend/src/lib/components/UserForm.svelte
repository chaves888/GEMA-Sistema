<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';

  type School = { id: string; name: string; };

  export let user: { 
    id?: string; 
    name: string; 
    email: string; 
    password?: string; 
    profile: string;
    schoolId?: string;
  } = { 
    name: '', 
    email: '', 
    password: '', 
    profile: 'cozinheira',
    schoolId: undefined
  };
  export let isEditing = false;

  let schools: School[] = [];
  const dispatch = createEventDispatcher();

  onMount(async () => {
    try {
      schools = await api.get('escolas');
    } catch (e) {
      console.error("Falha ao carregar escolas", e);
    }
  });

  function handleSubmit() {
    if (user.profile !== 'escola' && user.profile !== 'cozinheira') {
      user.schoolId = undefined;
    }
    dispatch('save', user);
  }
</script>

<form 
  on:submit|preventDefault={handleSubmit} 
  class="bg-white rounded-2xl shadow-lg p-8 w-full max-w-lg mx-auto border border-gray-100"
>
  <h2 class="text-2xl font-bold text-gray-800 mb-8 flex items-center justify-center">
    {isEditing ? 'Editar Usuário' : 'Adicionar Novo Usuário'}
  </h2>

  <div class="space-y-5">
    <div>
      <label for="name" class="block text-sm font-semibold text-gray-700 mb-1">Nome</label>
      <input
        id="name"
        type="text"
        bind:value={user.name}
        required
        class="w-full px-4 py-2 rounded-xl border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
        placeholder="Digite o nome completo"
      />
    </div>

    <div>
      <label for="email" class="block text-sm font-semibold text-gray-700 mb-1">Email</label>
      <input
        id="email"
        type="email"
        bind:value={user.email}
        required
        class="w-full px-4 py-2 rounded-xl border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
        placeholder="exemplo@email.com"
      />
    </div>

    <div>
      <label for="password" class="block text-sm font-semibold text-gray-700 mb-1">
        Senha {isEditing ? '(Deixe em branco para não alterar)' : ''}
      </label>
      <input
        id="password"
        type="password"
        bind:value={user.password}
        required={!isEditing}
        class="w-full px-4 py-2 rounded-xl border border-gray-300 focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
        placeholder={isEditing ? "••••••••" : "Digite uma senha segura"}
      />
    </div>

    <div>
      <label for="profile" class="block text-sm font-semibold text-gray-700 mb-1">Perfil</label>
      <select
        id="profile"
        bind:value={user.profile}
        required
        class="w-full px-4 py-2 rounded-xl border border-gray-300 bg-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
      >
        <option value="prefeitura">Gestor da Prefeitura</option>
        <option value="escola">Gestor da Escola</option>
        <option value="nutricionista">Nutricionista</option>
        <option value="cozinheira">Cozinheira</option>
      </select>
    </div>

    {#if user.profile === 'escola' || user.profile === 'cozinheira'}
      <div>
        <label for="school" class="block text-sm font-semibold text-gray-700 mb-1">Escola</label>
        <select
          id="school"
          bind:value={user.schoolId}
          required
          class="w-full px-4 py-2 rounded-xl border border-gray-300 bg-white focus:border-primary-500 focus:ring-2 focus:ring-primary-300 transition-all shadow-sm"
        >
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
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="px-5 py-2 rounded-xl border border-gray-300 text-gray-700 font-semibold bg-gray-100 hover:bg-gray-200 hover:shadow transition-all"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="px-5 py-2 rounded-xl bg-primary-600 text-white font-semibold hover:bg-primary-700 hover:shadow-md transition-all"
    >
      Salvar
    </button>
  </div>
</form>
