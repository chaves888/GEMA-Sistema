<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    import { AlertTriangle } from 'lucide-svelte';

    export let title: string = 'Confirmar Ação';
    export let message: string = 'Você tem certeza que deseja continuar?';
    export let confirmText: string = 'Confirmar';
    export let cancelText: string = 'Cancelar';

    // Define se o botão de confirmação deve ser vermelho (destrutivo)
    export let isDestructive: boolean = true;

    const dispatch = createEventDispatcher();
</script>

<div class="flex flex-col">
    <div class="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
        <AlertTriangle class="h-6 w-6 text-red-600" aria-hidden="true" />
    </div>
    <div class="mt-3 text-center sm:mt-5">
        <h3 class="text-xl md:text-2xl font-bold leading-6 text-gray-900" id="modal-title">
            {title}
        </h3>
        <div class="mt-2">
            <p class="text-sm text-gray-500">
                {message}
            </p>
        </div>
    </div>
</div>

<div class="mt-6 grid grid-cols-1 sm:grid-cols-2 gap-3">
    <button
        type="button"
        class="inline-flex w-full justify-center rounded-lg border border-gray-300 bg-white px-4 py-2.5 text-base font-semibold text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2 order-2 sm:order-1"
        on:click={() => dispatch('cancel')}
    >
        {cancelText}
    </button>

    <button
        type="button"
        class="inline-flex w-full justify-center rounded-lg px-4 py-2.5 text-base font-semibold text-white shadow-sm transition-all focus:outline-none focus:ring-2 focus:ring-offset-2 order-1 sm:order-2"
        class:bg-red-600={isDestructive}
        class:hover:bg-red-700={isDestructive}
        class:focus:ring-red-500={isDestructive}
        class:bg-primary-600={!isDestructive}
        class:hover:bg-primary-700={!isDestructive}
        class:focus:ring-primary-500={!isDestructive}
        on:click={() => dispatch('confirm')}
    >
        {confirmText}
    </button>
</div>