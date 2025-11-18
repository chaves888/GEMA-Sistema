<script lang="ts">
  import { toast } from '$lib/toast';
  import { CheckCircle, AlertCircle, Info, X } from 'lucide-svelte'; // Adicionei Info caso use toasts informativos
  import { fly } from 'svelte/transition';
</script>

<div class="fixed bottom-4 right-4 z-[100] flex flex-col gap-3">
  {#each $toast as notification (notification.id)}
    <div
      in:fly={{ y: 20, duration: 300 }} 
      out:fly={{ x: 100, duration: 200 }}
      class="flex items-center w-full max-w-sm p-4 rounded-lg shadow-xl border transition-colors duration-300
             bg-white dark:bg-gray-800 
             text-gray-700 dark:text-gray-200
             dark:border-gray-700"
      role="alert"
      class:border-green-300={notification.type === 'success'}
      class:dark:border-green-800={notification.type === 'success'}
      
      class:border-red-300={notification.type === 'error'}
      class:dark:border-red-800={notification.type === 'error'}
      
      class:border-blue-300={notification.type === 'info'}
      class:dark:border-blue-800={notification.type === 'info'}
    >
      
      <!-- Ícone de Sucesso -->
      {#if notification.type === 'success'}
        <div
          class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 rounded-lg
                 text-green-600 dark:text-green-400 
                 bg-green-100 dark:bg-green-900/30"
        >
          <CheckCircle class="w-5 h-5" />
        </div>
      
      <!-- Ícone de Erro -->
      {:else if notification.type === 'error'}
        <div
          class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 rounded-lg
                 text-red-600 dark:text-red-400 
                 bg-red-100 dark:bg-red-900/30"
        >
          <AlertCircle class="w-5 h-5" />
        </div>
      
      <!-- Ícone de Info (Fallback) -->
      {:else}
        <div
            class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 rounded-lg
                   text-blue-600 dark:text-blue-400 
                   bg-blue-100 dark:bg-blue-900/30"
        >
            <Info class="w-5 h-5" />
        </div>
      {/if}

      <div class="ml-3 text-sm font-medium break-words">{notification.message}</div>

      <button
        type="button"
        class="ml-auto -mx-1.5 -my-1.5 rounded-lg p-1.5 inline-flex h-8 w-8 transition-colors
               bg-white dark:bg-gray-800 
               text-gray-400 dark:text-gray-500 
               hover:text-gray-900 dark:hover:text-white 
               hover:bg-gray-100 dark:hover:bg-gray-700 
               focus:ring-2 focus:ring-gray-300 dark:focus:ring-gray-600"
        aria-label="Close"
        on:click={() => toast.remove(notification.id)}
      >
        <X class="w-5 h-5" />
      </button>
    </div>
  {/each}
</div>