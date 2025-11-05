<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  // <-- MUDANÇA: Importa a nova store e a api -->
  import { session, initializeSession, pendingSolicitacoesCount } from '$lib/sessionStore';
  import * as api from '$lib/api'; 
  // <-- FIM DA MUDANÇA -->
  import { page } from '$app/stores';
  import GemaLogo from '$lib/assets/logo-gema.png'; 
  import Notifications from '$lib/components/Notifications.svelte';
  import { browser } from '$app/environment';
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
    window.location.href = '/';
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

  // --- NOVO: Carregar contagem de pendentes ---
  let initialCountLoaded = false;
  $: if ($session?.profile === 'prefeitura' && !initialCountLoaded && browser) {
    async function loadPendingCount() {
      try {
        const data = await api.get('solicitacoes/pendentes/count');
        pendingSolicitacoesCount.set(data.count);
        initialCountLoaded = true; // Marca como carregado
      } catch (e) {
        console.error('Erro ao carregar contagem de pendentes:', e);
      }
    }
    loadPendingCount();
  }
  // --- FIM ---
</script>

<div class="flex h-screen bg-gray-100 overflow-hidden">
  <aside class="w-64 {sidebarBg} text-white flex flex-col shadow-xl flex-shrink-0">
    <div class="h-20 flex items-center justify-start px-5 border-b border-primary-700 flex-shrink-0">
      <img src={GemaLogo} alt="Logo GEMA" class="h-14 w-auto" />
    </div>

    {#if $session}
      <nav class="flex-1 p-4 space-y-2 overflow-y-auto">

        <a href="/dashboard" class="flex items-center gap-3 p-2 transition-colors {activeDashboard ? activeStyle : inactiveStyle}">
          <LayoutDashboard class="w-5 h-5 flex-shrink-0" /> 
          <span>Dashboard</span>
        </a>

        {#if $session.profile === 'prefeitura'}
          <a href="/usuarios" class="flex items-center gap-3 p-2 transition-colors {activeUsuarios ? activeStyle : inactiveStyle}">
            <Users class="w-5 h-5 flex-shrink-0" /> <span>Usuários</span>
          </a>
          <a href="/cidades" class="flex items-center gap-3 p-2 transition-colors {activeCidades ? activeStyle : inactiveStyle}">
            <Building2 class="w-5 h-5 flex-shrink-0" /> <span>Cidades</span>
          </a>
          <a href="/escolas" class="flex items-center gap-3 p-2 transition-colors {activeEscolas ? activeStyle : inactiveStyle}">
            <School class="w-5 h-5 flex-shrink-0" /> <span>Escolas</span>
          </a>
        {/if}

        <a href="/cardapios" class="flex items-center gap-3 p-2 transition-colors {activeCardapios ? activeStyle : inactiveStyle}">
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

          <a
            href="/solicitacoes"
            class="relative flex items-center justify-between p-2 transition-colors {activeSolicitacoes ? activeStyle : inactiveStyle}"
          >
            <div class="flex items-center gap-3">
              <ClipboardList class="w-5 h-5 flex-shrink-0" /> 
              <span>Solicitações</span>
            </div>
            {#if $session.profile === 'prefeitura' && $pendingSolicitacoesCount > 0}
              <span
                class="flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-xs font-bold text-white shadow"
              >
                {$pendingSolicitacoesCount}
              </span>
            {/if}
          </a>
          {/if}

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
    <main class="flex-1 p-6 overflow-y-auto bg-gray-50">
      <slot />
    </main>
  </div>
  <Notifications />
</div>