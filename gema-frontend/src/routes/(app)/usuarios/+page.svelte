<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import UserForm from '$lib/components/UserForm.svelte';
  import { session } from '$lib/sessionStore';
  import { toast } from '$lib/toast';
  import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';
  import { ShieldOff, ShieldCheck, Search } from 'lucide-svelte';

  type User = {
    id: string;
    name: string;
    email: string;
    profile: string;
    isActive: boolean;
    school?: { id: string; name: string };
  };

  let users: User[] = [];
  let isLoading = true;
  let isActionLoading = false;
  let error: string | null = null;

  let filterSearch = '';
  let filterProfile = '';
  let filterStatus = 'true';

  $: filteredUsers = users.filter((user) => {
    const statusMatch = filterStatus === 'all' || user.isActive === (filterStatus === 'true');
    const profileMatch = filterProfile === '' || user.profile === filterProfile;
    const searchTerm = filterSearch.toLowerCase();
    const searchMatch =
      filterSearch === '' ||
      user.name.toLowerCase().includes(searchTerm) ||
      user.email.toLowerCase().includes(searchTerm) ||
      (user.school?.name || '').toLowerCase().includes(searchTerm);

    return statusMatch && profileMatch && searchMatch;
  });

  let showModal = false;
  let isEditing = false;
  let currentUser: any = {};

  let showConfirmModal = false;
  let confirmTitle = '';
  let confirmMessage = '';
  let confirmButtonText = '';
  let confirmAction: (() => Promise<void>) | null = null;

  onMount(async () => {
    try {
      users = await api.get('users');
    } catch (e: any) {
      error = e?.message || 'Não foi possível carregar os usuários.';
      console.error(e);
    } finally {
      isLoading = false;
    }
  });

  function openAddModal() {
    isEditing = false;
    currentUser = { name: '', email: '', password: '', profile: 'cozinheira', schoolId: undefined };
    showModal = true;
  }

  function openEditModal(user: User) {
    isEditing = true;
    currentUser = { ...user, password: '', schoolId: user.school?.id };
    showModal = true;
  }

  async function handleSave(event: any) {
    const userToSave = event.detail;
    isActionLoading = true;

    const trimmedName = userToSave.name ? userToSave.name.trim() : '';
    if (trimmedName === '') {
      toast.error('O nome do usuário não pode estar vazio.');
      isActionLoading = false;
      return;
    }
    userToSave.name = trimmedName;

    if (isEditing && !userToSave.password) {
      delete userToSave.password;
    }

    try {
      if (isEditing) {
        const updatedUser = await api.patch(`users/${userToSave.id}`, userToSave);
        users = users.map((u) => (u.id === updatedUser.id ? updatedUser : u));
        toast.success('Usuário atualizado com sucesso!');
      } else {
        const newUser = await api.post('users', userToSave);
        users = [...users, newUser];
        toast.success('Usuário criado com sucesso!');
      }
      showModal = false;
    } catch (e: any) {
      const errorMessage = e?.message || 'Erro ao salvar o usuário.';
      toast.error(errorMessage);
      console.error(e);
    } finally {
      isActionLoading = false;
    }
  }

  async function handleActivateUser(user: User) {
    isActionLoading = true;
    try {
      const updatedUser = await api.patch(`users/${user.id}/activate`, {});
      users = users.map((u) => (u.id === updatedUser.id ? updatedUser : u));
      toast.success(`Usuário "${user.name}" ativado.`);
    } catch (e: any) {
      toast.error(e?.message || 'Erro ao ativar usuário.');
    } finally {
      isActionLoading = false;
    }
  }

  async function handleDeactivateUser(user: User) {
    isActionLoading = true;
    try {
      const updatedUser = await api.patch(`users/${user.id}/deactivate`, {});
      users = users.map((u) => (u.id === updatedUser.id ? updatedUser : u));
      toast.info(`Usuário "${user.name}" desativado.`);
    } catch (e: any) {
      toast.error(e?.message || 'Erro ao desativar usuário.');
    } finally {
      isActionLoading = false;
    }
  }

  async function handleDeleteUser(user: User) {
    isActionLoading = true;
    try {
      await api.del(`users/${user.id}`);
      users = users.filter((u) => u.id !== user.id);
      toast.success(`Usuário "${user.name}" excluído.`);
    } catch (e: any) {
      toast.error(e?.message || 'Falha ao excluir o usuário.');
    } finally {
      isActionLoading = false;
    }
  }

  function openConfirmModal(user: User, action: 'delete' | 'activate' | 'deactivate') {
    if (user.id === $session.id) {
      toast.error('Você não pode alterar seu próprio usuário.');
      return;
    }
    if (isActionLoading) return;

    if (action === 'delete') {
      confirmTitle = 'Excluir Usuário';
      confirmMessage = `Tem certeza que deseja excluir o usuário "${user.name}"? Esta ação é irreversível.`;
      confirmButtonText = 'Sim, Excluir';
      confirmAction = () => handleDeleteUser(user);
    } else if (action === 'activate') {
      confirmTitle = 'Ativar Usuário';
      confirmMessage = `Tem certeza que deseja ativar o usuário "${user.name}"? Ele poderá fazer login novamente.`;
      confirmButtonText = 'Sim, Ativar';
      confirmAction = () => handleActivateUser(user);
    } else if (action === 'deactivate') {
      confirmTitle = 'Desativar Usuário';
      confirmMessage = `Tem certeza que deseja desativar o usuário "${user.name}"? Ele não poderá mais fazer login.`;
      confirmButtonText = 'Sim, Desativar';
      confirmAction = () => handleDeactivateUser(user);
    }
    showConfirmModal = true;
  }

  async function handleConfirm() {
    if (confirmAction) {
      await confirmAction();
    }
    cancelConfirmModal();
  }

  function cancelConfirmModal() {
    showConfirmModal = false;
    confirmTitle = '';
    confirmMessage = '';
    confirmButtonText = '';
    confirmAction = null;
  }
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4 lg:p-6 space-y-6 animate-fadeIn transition-colors duration-300">
  
  <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 dark:bg-gray-800/70 backdrop-blur-md p-5 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700">
    <div>
      <h1 class="text-2xl lg:text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent">
        Gerenciamento de Usuários
      </h1>
      <p class="text-gray-600 dark:text-gray-300 mt-1 text-sm">Crie, edite e gerencie os acessos ao sistema.</p>
    </div>

    <button
      on:click={openAddModal}
      disabled={isActionLoading}
      class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95 disabled:opacity-50"
    >
      + Novo Usuário
    </button>
  </div>

  <div class="bg-white/80 dark:bg-gray-800/80 backdrop-blur-md p-4 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 flex flex-col md:flex-row flex-wrap gap-4">
    <div class="flex-1 w-full md:min-w-[200px]">
      <label for="filterSearch" class="block text-sm font-medium text-gray-700 dark:text-gray-300">Buscar (Nome, Email, Escola)</label>
      <div class="relative mt-1">
        <input
          type="text"
          id="filterSearch"
          bind:value={filterSearch}
          placeholder="Digite para buscar..."
          class="block w-full py-2 px-3 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm pl-10 bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-gray-400"
        />
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Search class="w-5 h-5 text-gray-400 dark:text-gray-500" />
        </div>
      </div>
    </div>
    
    <div class="flex-1 w-full md:min-w-[150px]">
      <label for="filterProfile" class="block text-sm font-medium text-gray-700 dark:text-gray-300"> Perfil </label>
      <select
        id="filterProfile"
        bind:value={filterProfile}
        class="mt-1 block w-full py-2 px-3 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
      >
        <option value="">Todos os Perfis</option>
        <option value="prefeitura">Prefeitura</option>
        <option value="escola">Escola</option>
        <option value="nutricionista">Nutricionista</option>
        <option value="cozinheira">Cozinheira</option>
      </select>
    </div>

    <div class="flex-1 w-full md:min-w-[150px]">
      <label for="filterStatus" class="block text-sm font-medium text-gray-700 dark:text-gray-300"> Status </label>
      <select
        id="filterStatus"
        bind:value={filterStatus}
        class="mt-1 block w-full py-2 px-3 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-900 dark:text-white rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm"
      >
        <option value="true">Ativos</option>
        <option value="false">Inativos</option>
        <option value="all">Todos</option>
      </select>
    </div>
  </div>

  {#if isLoading}
    <div class="flex justify-center items-center p-10">
      <p class="text-gray-500 dark:text-gray-400 text-lg animate-pulse">⏳ Carregando usuários...</p>
    </div>
  {:else if error}
    <div class="bg-red-100 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm font-medium dark:bg-red-900/20 dark:border-red-800 dark:text-red-400">
      {error}
    </div>
  {:else if filteredUsers.length === 0}
    <div class="text-center p-10 bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-dashed border-gray-300 dark:border-gray-700">
      <p class="text-gray-600 dark:text-gray-300 font-semibold text-lg">Nenhum usuário encontrado.</p>
    </div>
  {:else}
    <div class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 dark:border-gray-700 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-700 dark:to-gray-800">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Nome</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Email</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Perfil</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Escola</th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Status</th>
              <th scope="col" class="px-6 py-3 text-right text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wider">Ações</th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-100 dark:divide-gray-700">
            {#each filteredUsers as user (user.id)}
              <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors duration-150">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800 dark:text-gray-200">{user.name}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400">{user.email}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400 capitalize">{user.profile.replace('_', ' ')}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 dark:text-gray-400">{user.school?.name || 'N/A'}</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm">
                  {#if user.isActive}
                    <span class="px-2.5 py-0.5 inline-flex text-xs font-semibold rounded-full bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">Ativo</span>
                  {:else}
                    <span class="px-2.5 py-0.5 inline-flex text-xs font-semibold rounded-full bg-gray-100 text-gray-600 dark:bg-gray-700 dark:text-gray-300">Inativo</span>
                  {/if}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-3">
                  <button
                    on:click={() => openEditModal(user)}
                    class="text-primary-600 dark:text-primary-400 hover:text-primary-800 dark:hover:text-primary-300 font-semibold transition-colors disabled:opacity-50"
                    disabled={isActionLoading}
                  >
                    Editar
                  </button>
                  {#if user.isActive}
                    <button
                      on:click={() => openConfirmModal(user, 'deactivate')}
                      class="text-yellow-600 dark:text-yellow-500 hover:text-yellow-800 dark:hover:text-yellow-300 font-semibold transition-colors disabled:opacity-50"
                      disabled={isActionLoading || user.id === $session.id}
                    >
                      Desativar
                    </button>
                  {:else}
                    <button
                      on:click={() => openConfirmModal(user, 'activate')}
                      class="text-green-600 dark:text-green-400 hover:text-green-800 dark:hover:text-green-300 font-semibold transition-colors disabled:opacity-50"
                      disabled={isActionLoading || user.id === $session.id}
                    >
                      Ativar
                    </button>
                  {/if}
                  <button
                    on:click={() => openConfirmModal(user, 'delete')}
                    class="text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300 font-semibold transition-colors disabled:opacity-50"
                    disabled={isActionLoading || user.id === $session.id}
                  >
                    Excluir
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>
  {/if}
</div>

<Modal show={showModal} on:close={() => (showModal = false)} size="max-w-lg">
  <UserForm
    bind:user={currentUser}
    {isEditing}
    on:save={handleSave}
    on:cancel={() => (showModal = false)}
  />
</Modal>

<Modal show={showConfirmModal} on:close={cancelConfirmModal} size="max-w-md">
  <ConfirmDialog
    title={confirmTitle}
    message={confirmMessage}
    confirmText={confirmButtonText}
    on:confirm={handleConfirm}
    on:cancel={cancelConfirmModal}
  />
</Modal>

<style>
  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: scale(0.98);
    }
    to {
      opacity: 1;
      transform: scale(1);
    }
  }

  .animate-fadeIn {
    animation: fadeIn 0.25s ease-out;
  }

  th:first-child {
    border-top-left-radius: 1rem;
  }

  th:last-child {
    border-top-right-radius: 1rem;
  }
</style>