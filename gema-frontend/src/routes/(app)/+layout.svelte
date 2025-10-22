<script lang="ts">
  // ... (Script setup, imports, onMount, handleLogout mantidos)
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { session, initializeSession } from '$lib/sessionStore';
  import { page } from '$app/stores';
  import GemaLogo from '$lib/assets/logo-gema.png'; 

  import {
    LayoutDashboard, Users, Building2, School, Package, Boxes, LogOut,
    ClipboardList, BookOpen
  } from 'lucide-svelte';

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

  // Otimização de Reatividade: Mantida
  $: pathname = $page.url.pathname;
  $: activeDashboard = pathname === '/dashboard';
  $: activeUsuarios = pathname.startsWith('/usuarios');
  $: activeCidades = pathname.startsWith('/cidades');
  $: activeEscolas = pathname.startsWith('/escolas');
  $: activeCardapios = pathname.startsWith('/cardapios');
  $: activeProdutos = pathname.startsWith('/produtos');
  $: activeEstoque = pathname.startsWith('/estoque');
  $: activeSolicitacoes = pathname.startsWith('/solicitacoes');

  const sidebarBg = 'bg-primary-800'; 
  const primaryText = 'text-primary-300';
  
  // ------------------------------------------
  // NOVO: Estilo Ativo Unificado
  // ------------------------------------------
  const activeStyle = 'bg-white text-primary-800 font-semibold shadow-md rounded-lg'; // Estilo do Cardápios
  const inactiveStyle = 'text-white hover:bg-primary-700 rounded-lg';

</script>

<div class="flex h-screen bg-gray-100 overflow-hidden">
  <aside class="w-64 {sidebarBg} text-white flex flex-col shadow-xl flex-shrink-0">
    <div class="h-20 flex items-center justify-start px-5 border-b border-primary-700 flex-shrink-0">
      <img src={GemaLogo} alt="Logo GEMA" class="h-14 w-auto" />
    </div>

    {#if $session}
      <nav class="flex-1 p-4 space-y-4 overflow-y-auto">

        <a href="/dashboard" class="flex items-center gap-3 p-2 transition-colors {activeDashboard ? activeStyle : inactiveStyle}">
          <LayoutDashboard class="w-5 h-5 flex-shrink-0" /> 
          <span>Dashboard</span>
        </a>

        {#if $session.profile === 'prefeitura'}
          <div class="pt-4">
            <h3 class="px-2 mb-2 text-xs font-semibold {primaryText} uppercase tracking-wider">Gerenciamento</h3>
            <div class="space-y-1">
              <a href="/usuarios" class="flex items-center gap-3 p-2 transition-colors {activeUsuarios ? activeStyle : inactiveStyle}">
                <Users class="w-5 h-5 flex-shrink-0" /> <span>Usuários</span>
              </a>
              <a href="/cidades" class="flex items-center gap-3 p-2 transition-colors {activeCidades ? activeStyle : inactiveStyle}">
                <Building2 class="w-5 h-5 flex-shrink-0" /> <span>Cidades</span>
              </a>
              <a href="/escolas" class="flex items-center gap-3 p-2 transition-colors {activeEscolas ? activeStyle : inactiveStyle}">
                <School class="w-5 h-5 flex-shrink-0" /> <span>Escolas</span>
              </a>
            </div>
          </div>
        {/if}

        <div class="pt-4">
          <h3 class="px-2 mb-2 text-xs font-semibold {primaryText} uppercase tracking-wider">Operações</h3>
          <div class="space-y-1">

            <a
              href="/cardapios"
              class="flex items-center gap-3 p-2 transition-colors
                     {activeCardapios ? activeStyle : inactiveStyle}"
            >
              <BookOpen class="w-5 h-5 flex-shrink-0" /> <span>Cardápios</span>
            </a>

            {#if $session.profile === 'prefeitura' || $session.profile === 'nutricionista' || $session.profile === 'escola'}
              <a href="/produtos" class="flex items-center gap-3 p-2 transition-colors {activeProdutos ? activeStyle : inactiveStyle}">
                <Package class="w-5 h-5 flex-shrink-0" /> <span>Produtos</span>
              </a>
            {/if}

            {#if $session.profile === 'prefeitura' || $session.profile === 'escola'}
              <a href="/estoque" class="flex items-center gap-3 p-2 transition-colors {activeEstoque ? activeStyle : inactiveStyle}">
                <Boxes class="w-5 h-5 flex-shrink-0" /> <span>Estoque</span>
              </a>
              <a href="/solicitacoes" class="flex items-center gap-3 p-2 transition-colors {activeSolicitacoes ? activeStyle : inactiveStyle}">
                <ClipboardList class="w-5 h-5 flex-shrink-0" /> <span>Solicitações</span>
              </a>
            {/if}

          </div>
        </div>
      </nav>

      <div class="p-4 border-t border-primary-700 mt-auto flex-shrink-0">
        <div class="mb-3 space-y-0.5">
          <p class="font-semibold text-sm truncate">{$session.email}</p>
          <p class="text-xs text-primary-400 capitalize">{$session.profile.replace('_', ' ')}</p>
          {#if ($session.profile === 'escola' || $session.profile === 'cozinheira') && $session.school}
            <div class="flex items-center gap-1 text-xs text-primary-200 pt-1">
              <School class="w-3 h-3 flex-shrink-0"/>
              <span class="truncate">{$session.school.name}</span>
            </div>
          {/if}
        </div>
        <button
          on:click={handleLogout}
          class="w-full flex items-center justify-center gap-2 bg-red-500 hover:bg-red-600 text-white font-semibold py-2 rounded-lg shadow transition"
        >
          <LogOut class="w-4 h-4 flex-shrink-0" /> Sair
        </button>
      </div>
    {/if}
  </aside>

  <div class="flex-1 flex flex-col overflow-hidden">
    <header class="h-16 bg-white shadow flex justify-between items-center px-6 flex-shrink-0">
      <h1 class="text-lg font-semibold text-gray-800 capitalize">
        {#if activeDashboard}Dashboard
        {:else if activeUsuarios}Usuários
        {:else if activeCidades}Cidades
        {:else if activeEscolas}Escolas
        {:else if activeProdutos}Produtos
        {:else if activeEstoque}Estoque
        {:else if activeSolicitacoes}Solicitações
        {:else if activeCardapios}Cardápios
        {:else}GEMA
        {/if}
      </h1>
    </header>

    <main class="flex-1 p-6 overflow-y-auto bg-gray-50">
      <slot />
    </main>
  </div>
</div>
