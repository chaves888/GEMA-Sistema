<script lang="ts">
    import { page } from '$app/stores';
    import { ServerCrash, AlertTriangle, ArrowLeft } from 'lucide-svelte';
    
    // Pega o status e mensagem
    $: statusCode = $page.status;
    $: message = $page.error?.message;

    let title = 'Opa! Algo deu errado';
    let description = 'Ocorreu um erro inesperado.';

    // Lógica de mensagens (igual a antes)
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
        <div class="mx-auto flex h-24 w-24 items-center justify-center rounded-full bg-red-100 dark:bg-red-900/30 shadow-lg mb-6">
            {#if statusCode === 404}
                <AlertTriangle class="h-12 w-12 text-red-600 dark:text-red-400" />
            {:else}
                <ServerCrash class="h-12 w-12 text-red-600 dark:text-red-400" />
            {/if}
        </div>

        <div class="space-y-3">
            <p class="text-lg font-bold text-red-600 dark:text-red-400 uppercase tracking-wider">
                Erro {statusCode}
            </p>
            <h1 class="text-4xl font-extrabold tracking-tight text-gray-900 dark:text-white sm:text-5xl">
                {title}
            </h1>
            <p class="text-base text-gray-600 dark:text-gray-300">
                {description}
            </p>
        </div>

        <div class="mt-10">
             <a 
                href="/" 
                class="inline-flex items-center gap-2 px-6 py-3 rounded-lg bg-primary-600 hover:bg-primary-700 text-white font-semibold shadow-md transition-transform hover:scale-105 active:scale-95"
             >
                <ArrowLeft class="w-5 h-5" />
                Voltar para o Início
             </a>
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