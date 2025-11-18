<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { X } from 'lucide-svelte';
  import { fade, scale } from 'svelte/transition';

  export let show = false;
  export let size: string = 'max-w-2xl';
  export let showCloseButton: boolean = true;

  const dispatch = createEventDispatcher();

  function close() { dispatch('close'); }

  function handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape') close();
  }
</script>

<svelte:window on:keydown={handleKeydown} />

{#if show}
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div
    on:click={close}
    class="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 sm:p-6 overflow-hidden"
    transition:fade={{ duration: 150 }}
  >
    <div
      on:click|stopPropagation
      class="bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 rounded-2xl shadow-2xl w-full {size} relative flex flex-col max-h-[90vh] transition-colors duration-300"
      transition:scale={{ duration: 150, start: 0.95 }}
    >
      {#if showCloseButton}
        <button
          type="button"
          on:click={close}
          class="absolute top-4 right-4 text-gray-400 hover:text-gray-600 dark:text-gray-500 dark:hover:text-gray-300 transition-colors z-10"
          aria-label="Fechar modal"
        >
          <X class="w-6 h-6" />
        </button>
      {/if}
      
      <div class="p-6 sm:p-8 overflow-y-auto custom-scrollbar">
        <slot />
      </div>
    </div>
  </div>
{/if}