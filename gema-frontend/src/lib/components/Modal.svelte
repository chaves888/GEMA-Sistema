<script lang="ts">
  import { createEventDispatcher } from 'svelte';

  export let show = false;
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

<svelte:window on:keydown={handleKeydown}/>

{#if show}
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div on:click={close} class="fixed inset-0 bg-black bg-opacity-50 z-40 flex justify-center items-center">
    
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <!-- svelte-ignore a11y-no-static-element-interactions -->
    <div on:click|stopPropagation class="bg-white rounded-lg shadow-xl p-6 w-full max-w-lg z-50">
      <slot /> </div>

  </div>
{/if}