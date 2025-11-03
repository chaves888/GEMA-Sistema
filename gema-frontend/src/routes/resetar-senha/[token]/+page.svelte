<script lang="ts">
  import { goto } from '$app/navigation';
  import GemaLogo from '$lib/assets/logo-gema.png';
  import type { PageData } from './$types';

  export let data: PageData;
  const token = data.token;

  let password = '';
  let passwordConfirm = '';
  let errorMessage: string | null = null;
  let successMessage: string | null = null;
  let loading = false;

  async function handleSubmit() {
    if (password !== passwordConfirm) {
      errorMessage = 'As senhas não coincidem.';
      return;
    }

    if (password.length < 6) {
      errorMessage = 'A senha deve ter no mínimo 6 caracteres.';
      return;
    }

    loading = true;
    errorMessage = null;
    successMessage = null;

    try {
      const response = await fetch('http://localhost:3000/auth/reset-password', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token, password }),
      });

      const data = await response.json();

      if (response.ok) {
        successMessage = 'Senha redefinida com sucesso! Redirecionando para o login...';
        setTimeout(() => {
          goto('/');
        }, 3000);
      } else {
        errorMessage = data.message || 'Ocorreu um erro ao redefinir a senha.';
      }
    } catch (error) {
      console.error('Erro de conexão:', error);
      errorMessage = 'Não foi possível conectar ao servidor.';
    } finally {
      loading = false;
    }
  }
</script>

<main
  class="flex min-h-screen items-center justify-center bg-gradient-to-br from-primary-600 via-primary-700 to-primary-900 p-6"
>
  <div
    class="w-full max-w-sm rounded-xl bg-white/10 backdrop-blur-lg p-6 shadow-2xl border border-white/20 text-white animate-fade-in"
  >
    <div class="text-center space-y-2">
      <img src={GemaLogo} alt="Logo GEMA" class="mx-auto h-24 w-auto mb-0 drop-shadow-md" />
      <h2 class="text-2xl font-bold">Crie sua Nova Senha</h2>
      <p class="text-sm text-primary-100">Insira e confirme sua nova senha para continuar</p>
    </div>

    <form class="space-y-4 mt-6" on:submit|preventDefault={handleSubmit}>
      <div>
        <input
          id="password"
          type="password"
          placeholder="Nova senha (mín. 6 caracteres)"
          required
          class="block w-full rounded-lg border border-white/30 bg-white/10 px-4 py-3 text-white placeholder-primary-100 focus:outline-none focus:ring-2 focus:ring-accent-400 focus:border-transparent transition"
          bind:value={password}
        />
      </div>

      <div>
        <input
          id="passwordConfirm"
          type="password"
          placeholder="Confirme a nova senha"
          required
          class="block w-full rounded-lg border border-white/30 bg-white/10 px-4 py-3 text-white placeholder-primary-100 focus:outline-none focus:ring-2 focus:ring-accent-400 focus:border-transparent transition"
          bind:value={passwordConfirm}
        />
      </div>

      {#if errorMessage}
        <div class="flex items-center text-red-300 text-sm font-medium bg-red-900/20 border border-red-500/30 rounded-lg px-3 py-2">
          <svg class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01M5.938 19h12.124c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L4.206 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          {errorMessage}
        </div>
      {/if}

      {#if successMessage}
        <div class="flex items-center text-green-300 text-sm font-medium bg-green-900/20 border border-green-500/30 rounded-lg px-3 py-2">
          {successMessage}
        </div>
      {/if}

      <div>
        <button
          type="submit"
          class="group relative flex w-full justify-center rounded-lg bg-accent-500 py-3 px-4 text-sm font-semibold text-white hover:bg-accent-400 focus:outline-none focus:ring-2 focus:ring-accent-300 focus:ring-offset-2 focus:ring-offset-primary-800 transition disabled:opacity-60 disabled:cursor-not-allowed"
          disabled={loading || !!successMessage}
        >
          {#if loading}
            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
            </svg>
          {/if}
          {loading ? 'Salvando...' : 'Salvar Nova Senha'}
        </button>
      </div>
    </form>
  </div>
</main>
