import { error } from '@sveltejs/kit';

export function load() {
    // Isso força o Svelte a renderizar a tela de erro (app/+error.svelte)
    // dentro do layout do app (app/+layout.svelte)
    throw error(404, 'Página não encontrada');
}