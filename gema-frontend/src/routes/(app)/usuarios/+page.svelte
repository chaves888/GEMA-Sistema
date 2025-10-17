<script lang="ts">
  import { onMount } from 'svelte';
  import * as api from '$lib/api';
  import Modal from '$lib/components/Modal.svelte';
  import UserForm from '$lib/components/UserForm.svelte';
  import { session } from '$lib/sessionStore';

  type User = { 
    id: string; 
    name: string; 
    email: string; 
    profile: string;
    school?: { id: string, name: string }; // A escola é opcional
  };
  
  let users: User[] = [];
  let isLoading = true;
  let error: string | null = null;

  let showModal = false;
  let isEditing = false;
  // currentUser armazena os dados para o formulário
  let currentUser: any = {};

  onMount(async () => {
    try { 
      users = await api.get('users'); 
    } catch (e) { 
      error = 'Não foi possível carregar os usuários.'; 
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
    // Prepara os dados para o formulário, incluindo o schoolId se existir
    currentUser = { ...user, password: '', schoolId: user.school?.id }; 
    showModal = true;
  }

  async function handleSave(event: any) {
    const userToSave = event.detail;
    
    // Remove o campo de senha se estiver vazio durante a edição
    if (isEditing && !userToSave.password) {
      delete userToSave.password;
    }

    try {
      if (isEditing) {
        const updatedUser = await api.patch(`users/${userToSave.id}`, userToSave);
        // Atualiza o usuário na lista da tela
        users = users.map(u => u.id === updatedUser.id ? updatedUser : u);
      } else {
        const newUser = await api.post('users', userToSave);
        // Adiciona o novo usuário à lista
        users = [...users, newUser];
      }
      showModal = false; // Fecha o modal
    } catch (e: any) {
      // Exibe a mensagem de erro específica vinda do backend (ex: email duplicado)
      if (e && e.message) {
        alert(`Erro: ${e.message}`);
      } else {
        alert('Erro ao salvar o usuário.');
      }
      console.error(e);
    }
  }
  
  async function deleteUser(userId: string, userName: string) {
    if (!confirm(`Tem certeza que deseja excluir o usuário "${userName}"?`)) {
      return;
    }
    try {
      await api.del(`users/${userId}`);
      // Remove o usuário da lista na tela
      users = users.filter(user => user.id !== userId);
    } catch (e: any) {
      if (e && e.message) {
        alert(`Erro: ${e.message}`);
      } else {
        alert('Falha ao excluir o usuário.');
      }
      console.error(e);
    }
  }
</script>

<div class="space-y-6">
  <div class="flex justify-between items-center">
    <h1 class="text-3xl font-bold text-gray-800">Gerenciamento de Usuários</h1>
    <button on:click={openAddModal} class="bg-primary-600 hover:bg-primary-700 text-white font-bold py-2 px-4 rounded-lg shadow-md transition-transform hover:scale-105">
      + Adicionar Usuário
    </button>
  </div>

  {#if isLoading}
    <p class="text-gray-500">Carregando usuários...</p>
  {:else if error}
    <p class="text-red-500">{error}</p>
  {:else}
    <div class="bg-white shadow-md rounded-lg overflow-x-auto">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nome</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Perfil</th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Escola</th> 
            <th scope="col" class="relative px-6 py-3"><span class="sr-only">Ações</span></th>
          </tr>
        </thead>
        <tbody class="bg-white divide-y divide-gray-200">
          {#each users as user (user.id)}
            <tr>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{user.name}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{user.email}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 capitalize">{user.profile.replace('_', ' ')}</td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{user.school?.name || 'N/A'}</td>
              <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4">
                <button on:click={() => openEditModal(user)} class="text-primary-600 hover:text-primary-900">Editar</button>
                <button on:click={() => deleteUser(user.id, user.name)} class="text-red-600 hover:text-red-900">Excluir</button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
    </div>
  {/if}
</div>

<Modal show={showModal} on:close={() => showModal = false}>
  <UserForm bind:user={currentUser} {isEditing} on:save={handleSave} on:cancel={() => showModal = false} />
</Modal>

