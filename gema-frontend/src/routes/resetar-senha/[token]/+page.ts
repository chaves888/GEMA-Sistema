import type { PageLoad } from './$types';

// Esta função 'load' roda antes da página ser renderizada.
// O SvelteKit garante que 'params' aqui terá o tipo { token: string }
export const load: PageLoad = ({ params }) => {
    return {
        token: params.token
    };
};