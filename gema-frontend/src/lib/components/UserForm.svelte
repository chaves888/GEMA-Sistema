<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import * as api from '$lib/api';

  type School = { id: string; name: string };

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
    schoolId: undefined,
  };
  export let isEditing = false;

  let schools: School[] = [];
  const dispatch = createEventDispatcher();

  onMount(async () => {
    try {
      schools = await api.get('escolas');
    } catch (e) {
      console.error('Falha ao carregar escolas', e);
    }
  });

  function handleSubmit() {
    if (user.profile !== 'escola' && user.profile !== 'cozinheira') {
      user.schoolId = undefined;
    }
    dispatch('save', user);
  }
</script>

<form on:submit|preventDefault={handleSubmit} class="flex flex-col h-full">
  <!-- Cabeçalho -->
  <div class="border-b border-gray-200 dark:border-gray-700 pb-4 mb-6">
    <h2 class="text-2xl lg:text-3xl font-bold text-gray-800 dark:text-white">
      {isEditing ? 'Editar Usuário' : 'Novo Usuário'}
    </h2>
  </div>

  <!-- Campos -->
  <div class="space-y-5 flex-1 overflow-y-auto pr-1">
    <div>
      <label for="name" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Nome</label>
      <input
        id="name"
        type="text"
        bind:value={user.name}
        required
        class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 transition-all shadow-sm placeholder-gray-400 dark:placeholder-gray-400"
        placeholder="Digite o nome completo"
      />
    </div>

    <div>
      <label for="email" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Email</label>
      <input
        id="email"
        type="email"
        bind:value={user.email}
        required
        class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 transition-all shadow-sm placeholder-gray-400 dark:placeholder-gray-400"
        placeholder="exemplo@email.com"
      />
    </div>

    <div>
      <label for="password" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">
        Senha {isEditing ? '(Deixe em branco para não alterar)' : ''}
      </label>
      <input
        id="password"
        type="password"
        bind:value={user.password}
        required={!isEditing}
        class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 transition-all shadow-sm placeholder-gray-400 dark:placeholder-gray-400"
        placeholder={isEditing ? '••••••••' : 'Digite uma senha segura'}
      />
    </div>

    <div>
      <label for="profile" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Perfil</label>
      <select
        id="profile"
        bind:value={user.profile}
        required
        class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 transition-all shadow-sm"
      >
        <option value="prefeitura">Gestor da Prefeitura</option>
        <option value="escola">Gestor da Escola</option>
        <option value="nutricionista">Nutricionista</option>
        <option value="cozinheira">Cozinheira</option>
      </select>
    </div>

    {#if user.profile === 'escola' || user.profile === 'cozinheira'}
      <div>
        <label for="school" class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-1">Escola</label>
        <select
          id="school"
          bind:value={user.schoolId}
          required
          class="w-full px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:border-primary-500 focus:ring-2 focus:ring-primary-400 transition-all shadow-sm"
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

  <!-- Rodapé Botões -->
  <div class="mt-8 flex flex-col-reverse sm:flex-row justify-end gap-3 sm:gap-4 border-t border-gray-200 dark:border-gray-700 pt-6">
    <button
      type="button"
      on:click={() => dispatch('cancel')}
      class="w-full sm:w-auto px-5 py-2 rounded-xl border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-200 bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 transition-all"
    >
      Cancelar
    </button>
    <button
      type="submit"
      class="w-full sm:w-auto px-5 py-2 rounded-xl bg-primary-600 hover:bg-primary-700 text-white font-bold transition-all shadow-sm transform hover:scale-105"
    >
      Salvar
    </button>
  </div>
</form>