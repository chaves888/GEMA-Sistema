<script lang="ts">
	import { onMount } from 'svelte';
	import * as api from '$lib/api';
	import Modal from '$lib/components/Modal.svelte';
	import UserForm from '$lib/components/UserForm.svelte';
	import { session } from '$lib/sessionStore';

	// 1. IMPORTAR O TOAST E O DIÁLOGO DE CONFIRMAÇÃO
	import { toast } from '$lib/toast';
	import ConfirmDialog from '$lib/components/ConfirmDialog.svelte';

	type User = {
		id: string;
		name: string;
		email: string;
		profile: string;
		school?: { id: string; name: string };
	};

	let users: User[] = [];
	let isLoading = true;
	let error: string | null = null;

	let showModal = false;
	let isEditing = false;
	let currentUser: any = {};

	// 2. ESTADO PARA O MODAL DE CONFIRMAÇÃO
	let showConfirmModal = false;
	let userToDelete: User | null = null;
	let confirmMessage = '';

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
		
		// Validação de nome vazio (igual fizemos em produtos)
		const trimmedName = userToSave.name ? userToSave.name.trim() : '';
		if (trimmedName === '') {
			toast.error('O nome do usuário não pode estar vazio ou conter apenas espaços.');
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
				// 3. SUBSTITUIR ALERT POR TOAST
				toast.success('Usuário atualizado com sucesso!');
			} else {
				const newUser = await api.post('users', userToSave);
				users = [...users, newUser];
				// 3. SUBSTITUIR ALERT POR TOAST
				toast.success('Usuário criado com sucesso!');
			}
			showModal = false;
		} catch (e: any) {
			// 3. SUBSTITUIR ALERT POR TOAST
			const errorMessage = e?.message || 'Erro ao salvar o usuário.';
			toast.error(errorMessage);
			console.error(e);
		}
	}

	// 4. FUNÇÃO PARA ABRIR O DIÁLOGO DE CONFIRMAÇÃO
	function openConfirmDeleteModal(user: User) {
		// Não podemos deixar o usuário se auto-excluir
		if (user.id === $session.id) {
			toast.error('Você não pode excluir o seu próprio usuário.');
			return;
		}
		
		userToDelete = user;
		confirmMessage = `Tem certeza que deseja excluir o usuário "${user.name}"?`;
		showConfirmModal = true;
	}

	// 5. FUNÇÃO CHAMADA PELO MODAL PARA EXECUTAR A EXCLUSÃO
	async function handleConfirmDelete() {
		if (!userToDelete) return;
		
		const idToDelete = userToDelete.id;

		// Fecha o modal e limpa o estado
		showConfirmModal = false;
		userToDelete = null;

		try {
			await api.del(`users/${idToDelete}`);
			users = users.filter((user) => user.id !== idToDelete);
			// 3. SUBSTITUIR ALERT POR TOAST
			toast.success('Usuário excluído com sucesso!');
		} catch (e: any) {
			// 3. SUBSTITUIR ALERT POR TOAST
			const errorMessage = e?.message || 'Falha ao excluir o usuário.';
			toast.error(errorMessage);
			console.error(e);
		}
	}

	// 6. FUNÇÃO PARA CANCELAR A EXCLUSÃO
	function onCancelDelete() {
		showConfirmModal = false;
		userToDelete = null;
	}
</script>

<div class="min-h-screen bg-gradient-to-b from-gray-50 to-gray-100 p-6 space-y-6 animate-fadeIn">
	<div
		class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white/70 backdrop-blur-md p-5 rounded-xl shadow-sm border"
	>
		<div>
			<h1
				class="text-4xl font-extrabold bg-gradient-to-r from-primary-600 to-primary-400 bg-clip-text text-transparent"
			>
				Gerenciamento de Usuários
			</h1>
			<p class="text-gray-600 mt-1 text-sm">Crie, edite e gerencie os acessos ao sistema.</p>
		</div>

		<button
			on:click={openAddModal}
			class="flex items-center gap-2 bg-gradient-to-r from-primary-600 to-primary-500 hover:from-primary-500 hover:to-primary-400 text-white font-semibold py-2.5 px-6 rounded-lg shadow-lg transition-all transform hover:scale-[1.04] active:scale-95"
		>
			+ Novo Usuário
		</button>
	</div>

	{#if isLoading}
		<div class="flex justify-center items-center p-10">
			<p class="text-gray-500 text-lg animate-pulse">⏳ Carregando usuários...</p>
		</div>
	{:else if error}
		<div class="bg-red-100 text-red-700 p-4 rounded-lg shadow-sm text-center font-medium">
			{error}
		</div>
	{:else if users.length === 0}
		<div
			class="text-center p-10 bg-white rounded-xl shadow-sm border border-dashed border-gray-300"
		>
			<p class="text-gray-600 font-semibold text-lg">Nenhum usuário encontrado.</p>
			<p class="text-sm text-gray-400 mt-2">Clique em “Novo Usuário” para adicionar o primeiro.</p>
		</div>
	{:else}
		<div
			class="bg-white/90 backdrop-blur-md rounded-2xl shadow-md border border-gray-100 overflow-hidden"
		>
			<table class="min-w-full divide-y divide-gray-200">
				<thead class="bg-gradient-to-r from-gray-50 to-gray-100">
					<tr>
						<th
							scope="col"
							class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
							>Nome</th
						>
						<th
							scope="col"
							class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
							>Email</th
						>
						<th
							scope="col"
							class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
							>Perfil</th
						>
						<th
							scope="col"
							class="px-6 py-3 text-left text-xs font-semibold text-gray-600 uppercase tracking-wider"
							>Escola</th
						>
						<th
							scope="col"
							class="px-6 py-3 text-right text-xs font-semibold text-gray-600 uppercase tracking-wider"
							>Ações</th
						>
					</tr>
				</thead>
				<tbody class="bg-white divide-y divide-gray-100">
					{#each users as user (user.id)}
						<tr class="hover:bg-gray-50 transition-colors duration-150">
							<td class="px-6 py-4 whitespace-nowrap text-sm font-semibold text-gray-800"
								>{user.name}</td
							>
							<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{user.email}</td>
							<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600 capitalize"
								>{user.profile.replace('_', ' ')}</td
							>
							<td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600"
								>{user.school?.name || 'N/A'}</td
							>
							<td
								class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium space-x-4"
							>
								<button
									on:click={() => openEditModal(user)}
									class="text-primary-600 hover:text-primary-800 font-semibold transition-colors"
								>
									Editar
								</button>
								<button
									on:click={() => openConfirmDeleteModal(user)}
									class="text-red-600 hover:text-red-800 font-semibold transition-colors disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:text-red-600"
									disabled={user.id === $session.id}
									title={user.id === $session.id ? 'Você não pode excluir a si mesmo' : ''}
								>
									Excluir
								</button>
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
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

<Modal show={showConfirmModal} on:close={onCancelDelete} size="max-w-md">
	<ConfirmDialog
		title="Excluir Usuário"
		message={confirmMessage}
		confirmText="Sim, Excluir"
		on:confirm={handleConfirmDelete}
		on:cancel={onCancelDelete}
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