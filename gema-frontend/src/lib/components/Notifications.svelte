<script lang="ts">
	import { toast } from '$lib/toast';
	import { CheckCircle, AlertCircle, X } from 'lucide-svelte';
	import { fly } from 'svelte/transition';
</script>

<div class="fixed bottom-4 right-4 z-[100] flex flex-col gap-3">
	{#each $toast as notification (notification.id)}
		<div
			in:fly={{ y: -20, duration: 300 }}
			out:fly={{ x: 100, duration: 200 }}
			class="flex items-center w-full max-w-sm p-4 text-gray-700 bg-white rounded-lg shadow-xl border"
			role="alert"
			class:border-green-300={notification.type === 'success'}
			class:border-red-300={notification.type === 'error'}
			class:border-blue-300={notification.type === 'info'}
		>
			{#if notification.type === 'success'}
				<div
					class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-green-600 bg-green-100 rounded-lg"
				>
					<CheckCircle class="w-5 h-5" />
				</div>
			{:else if notification.type === 'error'}
				<div
					class="inline-flex items-center justify-center flex-shrink-0 w-8 h-8 text-red-600 bg-red-100 rounded-lg"
				>
					<AlertCircle class="w-5 h-5" />
				</div>
			{/if}

			<div class="ml-3 text-sm font-medium">{notification.message}</div>

			<button
				type="button"
				class="ml-auto -mx-1.5 -my-1.5 bg-white text-gray-400 hover:text-gray-900 rounded-lg focus:ring-2 focus:ring-gray-300 p-1.5 hover:bg-gray-100 inline-flex h-8 w-8"
				aria-label="Close"
				on:click={() => toast.remove(notification.id)}
			>
				<X class="w-5 h-5" />
			</button>
		</div>
	{/each}
</div>