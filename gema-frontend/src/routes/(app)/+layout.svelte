<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { session, initializeSession } from '$lib/sessionStore';
  import { page } from '$app/stores';
  import GemaLogo from '$lib/assets/logo-gema.png';

  // Ícones Lucide
  import { LayoutDashboard, Users, Building2, School, Package, Boxes, LogOut } from 'lucide-svelte';

  onMount(() => {
    initializeSession();
    const token = localStorage.getItem('gema_token');
    if (!token) goto('/');
  });

  function handleLogout() {
    localStorage.removeItem('gema_token');
    session.set(null);
    goto('/');
  }
</script>

<div class="flex h-screen bg-gray-100">
  <!-- Sidebar -->
  <aside class="w-64 bg-gradient-to-b from-primary-700 via-primary-800 to-primary-900 text-white flex flex-col shadow-xl">
    <!-- Logo -->
    <div class="h-20 flex items-center justify-start px-5 border-b border-primary-600">
      <img src={GemaLogo} alt="Logo GEMA" class="h-14 w-auto" />
    </div>

    {#if $session}
      <!-- Navegação -->
      <nav class="flex-1 p-4 space-y-4 overflow-y-auto">
        <!-- Dashboard -->
        <a
          href="/dashboard"
          class="flex items-center gap-3 p-2 rounded-lg transition-colors
                 {$page.url.pathname === '/dashboard'
                   ? 'bg-primary-600 font-semibold shadow-inner border-l-4 border-white'
                   : 'hover:bg-primary-600'}"
        >
          <LayoutDashboard class="w-5 h-5" /> <span>Dashboard</span>
        </a>

        <!-- Gerenciamento -->
        {#if $session.profile === 'prefeitura'}
          <div>
            <h3 class="px-2 text-xs font-semibold text-primary-300 uppercase tracking-wider">Gerenciamento</h3>
            <div class="space-y-1 mt-2">
              <a
                href="/usuarios"
                class="flex items-center gap-3 p-2 rounded-lg transition-colors
                       {$page.url.pathname.startsWith('/usuarios')
                         ? 'bg-primary-600 font-semibold shadow-inner border-l-4 border-white'
                         : 'hover:bg-primary-600'}"
              >
                <Users class="w-5 h-5" /> <span>Usuários</span>
              </a>

              <a
                href="/cidades"
                class="flex items-center gap-3 p-2 rounded-lg transition-colors
                       {$page.url.pathname.startsWith('/cidades')
                         ? 'bg-primary-600 font-semibold shadow-inner border-l-4 border-white'
                         : 'hover:bg-primary-600'}"
              >
                <Building2 class="w-5 h-5" /> <span>Cidades</span>
              </a>

              <a
                href="/escolas"
                class="flex items-center gap-3 p-2 rounded-lg transition-colors
                       {$page.url.pathname.startsWith('/escolas')
                         ? 'bg-primary-600 font-semibold shadow-inner border-l-4 border-white'
                         : 'hover:bg-primary-600'}"
              >
                <School class="w-5 h-5" /> <span>Escolas</span>
              </a>
            </div>
          </div>
        {/if}

        <!-- Operações -->
        <div>
          <h3 class="px-2 text-xs font-semibold text-primary-300 uppercase tracking-wider">Operações</h3>
          <div class="space-y-1 mt-2">
            {#if $session.profile === 'prefeitura' || $session.profile === 'nutricionista' || $session.profile === 'escola'}
              <a
                href="/produtos"
                class="flex items-center gap-3 p-2 rounded-lg transition-colors
                       {$page.url.pathname.startsWith('/produtos')
                         ? 'bg-primary-600 font-semibold shadow-inner border-l-4 border-white'
                         : 'hover:bg-primary-600'}"
              >
                <Package class="w-5 h-5" /> <span>Produtos</span>
              </a>
            {/if}

            {#if $session.profile === 'prefeitura' || $session.profile === 'escola'}
              <a
                href="/estoque"
                class="flex items-center gap-3 p-2 rounded-lg transition-colors
                       {$page.url.pathname.startsWith('/estoque')
                         ? 'bg-primary-600 font-semibold shadow-inner border-l-4 border-white'
                         : 'hover:bg-primary-600'}"
              >
                <Boxes class="w-5 h-5" /> <span>Estoque</span>
              </a>
            {/if}
          </div>
        </div>
      </nav>

      <!-- Rodapé Sidebar -->
      <div class="p-4 border-t border-primary-700">
        <div class="mb-3">
          <p class="font-semibold text-sm">{$session.email}</p>
          <p class="text-xs text-primary-300 capitalize">{$session.profile.replace('_', ' ')}</p>
        </div>

        <button
          on:click={handleLogout}
          class="w-full flex items-center justify-center gap-2 bg-red-500 hover:bg-red-600 text-white font-semibold py-2 rounded-lg shadow transition"
        >
          <LogOut class="w-4 h-4" /> Sair
        </button>
      </div>
    {/if}
  </aside>

  <!-- Conteúdo Principal -->
  <div class="flex-1 flex flex-col">
    <header class="h-16 bg-white shadow flex justify-between items-center px-6">
      <h1 class="text-lg font-semibold text-gray-800 capitalize">
        {#if $page.url.pathname === '/dashboard'}Dashboard{/if}
        {#if $page.url.pathname.startsWith('/usuarios')}Usuários{/if}
        {#if $page.url.pathname.startsWith('/cidades')}Cidades{/if}
        {#if $page.url.pathname.startsWith('/escolas')}Escolas{/if}
        {#if $page.url.pathname.startsWith('/produtos')}Produtos{/if}
        {#if $page.url.pathname.startsWith('/estoque')}Estoque{/if}
      </h1>
    </header>

    <main class="flex-1 p-6 overflow-y-auto bg-gray-50">
      <slot />
    </main>
  </div>
</div>
