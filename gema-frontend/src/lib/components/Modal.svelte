<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { X } from 'lucide-svelte';
  import { fade, scale } from 'svelte/transition';

  export let show = false;
  /**
   * Define o tamanho máximo do modal.
   * Ex: 'max-w-lg', 'max-w-xl', 'max-w-2xl', 'max-w-3xl', 'max-w-4xl'
   */
  export let size: string = 'max-w-2xl'; // Um padrão versátil
  export let showCloseButton: boolean = true; // Controla a exibição do botão 'X'

  const dispatch = createEventDispatcher();

  function close() {
    dispatch('close');
  }

  // Permite fechar o modal com a tecla Escape
  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      close();
    }
  }
</script>

<svelte:window on:keydown={handleKeydown} />

{#if show}
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <div
    on:click={close}
    class="fixed inset-0 bg-black bg-opacity-40 backdrop-blur-sm z-40 flex items-center justify-center p-4 overflow-y-auto"
    transition:fade={{ duration: 150 }}
  >
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div
      on:click|stopPropagation
      class="bg-white rounded-2xl shadow-2xl w-full {size} z-50 p-8 relative"
      transition:scale={{ duration: 150, start: 0.95 }}
    >
      {#if showCloseButton}
        <button
          type="button"
          on:click={close}
          class="absolute top-5 right-5 text-gray-400 hover:text-gray-600 transition-colors"
          aria-label="Fechar modal"
        >
          <X class="w-7 h-7" />
        </button>
      {/if}
      
      <slot />
    </div>
  </div>
{/if}