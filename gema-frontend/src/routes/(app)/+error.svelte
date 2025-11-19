<script lang="ts">
    import { page } from '$app/stores';
    import { ServerCrash, AlertTriangle, ArrowLeft } from 'lucide-svelte';
    
    // Pega o status e mensagem
    $: statusCode = $page.status;
    $: message = $page.error?.message;

    let title = 'Opa! Algo deu errado';
    let description = 'Ocorreu um erro inesperado.';

    // Lógica de mensagens
    $: if (statusCode === 404) {
        title = 'Página não encontrada';
        description = 'O endereço que você tentou acessar não existe ou foi movido.';
    } else if (statusCode === 500) {
        title = 'Erro Interno do Servidor';
        description = 'Nosso sistema encontrou um problema. Tente novamente mais tarde.';
    } else if (message) {
        description = message;
    }
</script>

<div class="flex h-full flex-col items-center justify-center p-6 text-center animate-fadeIn">
    <div class="max-w-md w-full py-12">
        <!-- Círculo do ícone: Muda de cor dinamicamente -->
        <div class="mx-auto flex h-24 w-24 items-center justify-center rounded-full shadow-lg mb-6 {statusCode === 404 ? 'bg-yellow-100 dark:bg-yellow-900/30' : 'bg-red-100 dark:bg-red-900/30'}">
            {#if statusCode === 404}
                <!-- Ícone Amarelo para 404 -->
                <AlertTriangle class="h-12 w-12 text-yellow-600 dark:text-yellow-400" />
            {:else}
                <!-- Ícone Vermelho para outros erros -->
                <ServerCrash class="h-12 w-12 text-red-600 dark:text-red-400" />
            {/if}
        </div>

        <div class="space-y-3">
            <p class="text-lg font-bold uppercase tracking-wider {statusCode === 404 ? 'text-yellow-600 dark:text-yellow-400' : 'text-red-600 dark:text-red-400'}">
                Erro {statusCode}
            </p>
            <h1 class="text-4xl font-extrabold tracking-tight text-gray-900 dark:text-white sm:text-5xl">
                {title}
            </h1>
            <p class="text-base text-gray-600 dark:text-gray-300">
                {description}
            </p>
        </div>
    </div>
</div>

<style>
    @keyframes fadeIn {
        from { opacity: 0; transform: scale(0.95); }
        to { opacity: 1; transform: scale(1); }
    }
    .animate-fadeIn {
        animation: fadeIn 0.3s ease-out forwards;
    }
</style>