<script lang="ts">
	import { page } from '$app/stores';
	import { ServerCrash, AlertTriangle, ArrowLeft } from 'lucide-svelte';
	import GemaLogo from '$lib/assets/logo-gema.png';

	// Pega o status (404, 500, etc.) e a mensagem do erro
	$: statusCode = $page.status;
	$: message = $page.error?.message;

	let title = 'Opa! Algo deu errado';
	let description = 'Ocorreu um erro inesperado.';

	// Personaliza a mensagem com base no erro
	if (statusCode === 404) {
		title = 'Página não encontrada';
		description = 'O endereço que você tentou acessar não existe ou foi movido.';
	} else if (statusCode === 500) {
		title = 'Erro Interno do Servidor';
		description =
			'Nosso sistema encontrou um problema. A equipe técnica já foi notificada. Tente novamente mais tarde.';
	} else if (message && message.toLowerCase().includes('failed to fetch')) {
		// Este é o erro de "internet caiu" ou "backend offline"
		title = 'Não foi possível conectar';
		description =
			'Não conseguimos nos conectar ao servidor. Verifique sua conexão com a internet ou tente novamente mais tarde.';
	} else if (message) {
		// Pega a mensagem de erro específica (ex: "Estoque insuficiente...")
		description = message;
	}
</script>

<div
	class="flex min-h-full flex-col items-center justify-center bg-gray-50 p-6 text-center animate-fadeIn"
>
	<div class="max-w-md w-full">
		<div
			class="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-red-100 shadow-lg"
		>
			{#if statusCode === 404}
				<AlertTriangle class="h-12 w-12 text-red-500" />
			{:else}
				<ServerCrash class="h-12 w-12 text-red-500" />
			{/if}
		</div>

		<div class="mt-6">
			<p class="text-lg font-semibold text-red-600">Erro {statusCode}</p>
			<h1 class="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">
				{title}
			</h1>
			<p class="mt-4 text-base text-gray-500">
				{description}
			</p>
		</div>
		<img src={GemaLogo} alt="Logo GEMA" class="mx-auto h-12 w-auto mt-12 opacity-30" />
	</div>
</div>

<style>
	@keyframes fadeIn {
		from {
			opacity: 0;
			transform: scale(0.95);
		}
		to {
			opacity: 1;
			transform: scale(1);
		}
	}
	.animate-fadeIn {
		animation: fadeIn 0.3s ease-out forwards;
	}
</style>