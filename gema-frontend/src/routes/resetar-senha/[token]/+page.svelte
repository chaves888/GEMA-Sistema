<script lang="ts">
  import { goto } from '$app/navigation';
  import GemaLogo from '$lib/assets/logo-gema.png';
  import type { PageData } from './$types';

  export let data: PageData;
  // Pega o token da URL
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
        // Redireciona para o login após 3 segundos
        setTimeout(() => {
          goto('/');
        }, 3000);
      } else {
        // Ex: "Token inválido ou expirado."
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
    class="w-full max-w-md rounded-2xl bg-white/10 backdrop-blur-lg p-8 shadow-2xl border border-white/20 text-white animate-fade-in"
  >
    <div class="text-center space-y-2">
      <img src={GemaLogo} alt="Logo GEMA" class="mx-auto h-28 w-auto mb-0 drop-shadow-md" />
      <h2 class="text-2xl font-bold">Crie sua Nova Senha</h2>
    </div>

    <form class="space-y-6 mt-8" on:submit|preventDefault={handleSubmit}>
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
                      {/if}
          {loading ? 'Salvando...' : 'Salvar Nova Senha'}
        </button>
      </div>
    </form>
  </div>
</main>