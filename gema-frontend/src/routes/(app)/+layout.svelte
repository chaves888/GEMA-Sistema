<script lang="ts">
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import { session, initializeSession, pendingSolicitacoesCount } from '$lib/sessionStore';
    import * as api from '$lib/api';
    import { page } from '$app/stores';
    import GemaLogo from '$lib/assets/logo-gema.png';
    import Notifications from '$lib/components/Notifications.svelte';
    import { browser } from '$app/environment';
    import { theme, toggleTheme } from '$lib/themeStore';
    import {
        LayoutDashboard, Users, Building2, School, Package, Boxes,
        LogOut, ClipboardList, BookOpen, FileText, User as UserIcon,
        Menu, X, Sun, Moon
    } from 'lucide-svelte';

    let isMobileMenuOpen = false;
    
    // Como estamos dentro de (app), podemos assumir que deve ter token.
    // Se não tiver, o onMount joga pro login.
    let hasToken = browser && !!localStorage.getItem('gema_token');

    onMount(async () => {
        if (hasToken) {
            await initializeSession();
        } else {
            goto('/');
        }
    });

    function handleLogout() {
        localStorage.removeItem('gema_token');
        session.set(null);
        window.location.href = '/';
    }

    function getInitials(name: string | undefined): string {
        if (!name) return 'US';
        const parts = name.trim().split(' ');
        if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
        return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    $: { if ($page.url.pathname) isMobileMenuOpen = false; }

    $: pathname = $page.url.pathname;
    $: activeDashboard = pathname === '/dashboard';
    $: activeUsuarios = pathname.startsWith('/usuarios');
    $: activeCidades = pathname.startsWith('/cidades');
    $: activeEscolas = pathname.startsWith('/escolas');
    $: activeCardapios = pathname.startsWith('/cardapios');
    $: activeProdutos = pathname.startsWith('/produtos');
    $: activeEstoque = pathname.startsWith('/estoque');
    $: activeSolicitacoes = pathname.startsWith('/solicitacoes');
    $: activeRelatorios = pathname.startsWith('/relatorios');

    const activeStyle = 'bg-white/10 text-white font-semibold shadow-sm rounded-lg border-l-4 border-accent-500';
    const inactiveStyle = 'text-gray-300 hover:bg-white/5 hover:text-white rounded-lg transition-all';

    let initialCountLoaded = false;
    $: if (($session?.profile === 'prefeitura') && !initialCountLoaded && browser) {
        loadPendingCount();
    }

    async function loadPendingCount() {
        try {
            const data = await api.get('solicitacoes/pendentes/count');
            pendingSolicitacoesCount.set(data.count);
            initialCountLoaded = true; 
        } catch (e) {
            console.error('Erro contagem:', e);
        }
    }
</script>

<div class="flex h-screen bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-gray-100 overflow-hidden font-sans relative transition-colors duration-300">
    
    <!-- Sidebar sempre renderiza aqui, pois estamos na área protegida -->
    {#if isMobileMenuOpen}
        <!-- svelte-ignore a11y-click-events-have-key-events -->
        <!-- svelte-ignore a11y-no-static-element-interactions -->
        <div class="fixed inset-0 bg-black/50 z-30 lg:hidden" on:click={() => isMobileMenuOpen = false}></div>
    {/if}

    <aside 
        class="fixed lg:static inset-y-0 left-0 z-40 w-72 text-white flex flex-col shadow-2xl transition-transform duration-300 ease-in-out lg:transform-none {isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full'}"
        style="background-color: #0D47A1;" 
    >
        <div class="h-20 lg:h-24 flex items-center justify-between px-4 lg:justify-center border-b border-white/10 flex-shrink-0 bg-primary-950/30">
            <img src={GemaLogo} alt="Logo GEMA" class="h-12 lg:h-16 w-auto drop-shadow-md" />
            <button class="lg:hidden text-white" on:click={() => isMobileMenuOpen = false}>
                <X class="w-6 h-6" />
            </button>
        </div>

        <nav class="flex-1 px-3 py-4 space-y-1.5 overflow-y-auto custom-scrollbar">
            <p class="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 mt-2">Principal</p>
            
            <a href="/dashboard" class="flex items-center gap-3 px-3 py-2.5 text-sm {activeDashboard ? activeStyle : inactiveStyle}">
                <LayoutDashboard class="w-5 h-5" /> <span>Dashboard</span>
            </a>

            {#if $session?.profile === 'prefeitura'}
                <p class="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 mt-6">Cadastros</p>
                <a href="/usuarios" class="flex items-center gap-3 px-3 py-2.5 text-sm {activeUsuarios ? activeStyle : inactiveStyle}">
                    <Users class="w-5 h-5" /> <span>Usuários</span>
                </a>
                <a href="/cidades" class="flex items-center gap-3 px-3 py-2.5 text-sm {activeCidades ? activeStyle : inactiveStyle}">
                    <Building2 class="w-5 h-5" /> <span>Cidades</span>
                </a>
                <a href="/escolas" class="flex items-center gap-3 px-3 py-2.5 text-sm {activeEscolas ? activeStyle : inactiveStyle}">
                    <School class="w-5 h-5" /> <span>Escolas</span>
                </a>
            {/if}

            <p class="px-3 text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 mt-6">Gestão</p>
            
            <a href="/cardapios" class="flex items-center gap-3 px-3 py-2.5 text-sm {activeCardapios ? activeStyle : inactiveStyle}">
                <BookOpen class="w-5 h-5" /> <span>Cardápios</span>
            </a>

            {#if $session?.profile === 'prefeitura' || $session?.profile === 'nutricionista' || $session?.profile === 'escola'}
                <a href="/produtos" class="flex items-center gap-3 px-3 py-2.5 text-sm {activeProdutos ? activeStyle : inactiveStyle}">
                    <Package class="w-5 h-5" /> <span>Produtos</span>
                </a>
            {/if}

            {#if $session?.profile === 'prefeitura' || $session?.profile === 'escola' || $session?.profile === 'cozinheira'}
                <a href="/estoque" class="flex items-center gap-3 px-3 py-2.5 text-sm {activeEstoque ? activeStyle : inactiveStyle}">
                    <Boxes class="w-5 h-5" /> <span>Estoque</span>
                </a>
            {/if}

            {#if $session?.profile === 'prefeitura' || $session?.profile === 'escola'}
                <a href="/solicitacoes" class="relative flex items-center justify-between px-3 py-2.5 text-sm {activeSolicitacoes ? activeStyle : inactiveStyle}">
                    <div class="flex items-center gap-3">
                        <ClipboardList class="w-5 h-5" /> <span>Solicitações</span>
                    </div>
                    {#if $session?.profile === 'prefeitura' && $pendingSolicitacoesCount > 0}
                        <span class="flex h-5 min-w-[1.25rem] px-1.5 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white shadow-sm ring-2 ring-primary-900">
                            {$pendingSolicitacoesCount}
                        </span>
                    {/if}
                </a>
            {/if}

            {#if $session?.profile === 'prefeitura'}
                <a href="/relatorios" class="flex items-center gap-3 px-3 py-2.5 text-sm {activeRelatorios ? activeStyle : inactiveStyle}">
                    <FileText class="w-5 h-5" /> <span>Relatórios</span>
                </a>
            {/if}
        </nav>

        <div class="border-t border-white/10 bg-black/20">
            <div class="px-4 pt-4 pb-3">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-3 overflow-hidden">
                        <div class="h-10 w-10 rounded-full bg-accent-500 flex items-center justify-center text-white font-bold text-base shadow-lg ring-2 ring-white/10 flex-shrink-0">
                            {getInitials($session?.name)}
                        </div>
                        <div class="flex-1 min-w-0">
                            <p class="text-sm font-bold text-white truncate leading-tight">
                                {$session?.name || 'Usuário'}
                            </p>
                            <p class="text-xs text-gray-400 truncate">
                                {$session?.email || ''}
                            </p>
                        </div>
                    </div>
                    <button on:click={toggleTheme} class="ml-2 p-2 rounded-full hover:bg-white/10 text-gray-300 hover:text-white">
                        {#if $theme === 'dark'} <Sun class="w-5 h-5" /> {:else} <Moon class="w-5 h-5" /> {/if}
                    </button>
                </div>
                {#if ($session?.profile === 'escola' || $session?.profile === 'cozinheira') && $session?.school}
                    <div class="mt-2 flex items-center gap-2 text-xs text-gray-300 bg-white/5 p-1.5 rounded-md">
                        <School class="w-3 h-3 text-accent-400 flex-shrink-0" />
                        <span class="truncate font-medium">{$session.school.name}</span>
                    </div>
                {/if}
            </div>
            <div class="px-4 pb-4">
                <button on:click={handleLogout} class="w-full flex items-center justify-center gap-2 bg-red-600/90 hover:bg-red-600 text-white font-medium py-2.5 rounded-lg shadow-md text-sm">
                    <LogOut class="w-4 h-4" /> Sair do Sistema
                </button>
            </div>
        </div>
    </aside>

    <div class="flex-1 flex flex-col overflow-hidden w-full">
        <header class="lg:hidden h-16 bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 flex items-center px-4 justify-between flex-shrink-0 transition-colors duration-300">
            <button class="text-gray-600 dark:text-gray-200" on:click={() => isMobileMenuOpen = true}>
                <Menu class="w-6 h-6" />
            </button>
            <span class="font-bold text-primary-800 dark:text-primary-400 text-lg">GEMA</span>
            <div class="w-6"></div>
        </header>

        <main class="flex-1 p-4 lg:p-6 overflow-y-auto bg-gray-50 dark:bg-gray-900 scroll-smooth transition-colors duration-300">
            <slot />
        </main>
    </div>
    <Notifications />
</div>

<style>
    .custom-scrollbar::-webkit-scrollbar { width: 4px; }
    .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
    .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(255, 255, 255, 0.1); border-radius: 2px; }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover { background: rgba(255, 255, 255, 0.2); } 
</style>