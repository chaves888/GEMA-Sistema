// src/lib/api.ts
import { goto } from '$app/navigation';

const BASE_URL = 'http://localhost:3000';

async function send({ method, path, data }: { method: string, path: string, data?: any }) {
    const token = localStorage.getItem('gema_token');

    if (!token && path !== 'auth/login') {
        await goto('/');
        throw new Error('Token não encontrado');
    }

    // --- MUDANÇA AQUI ---
    // 1. Criamos o objeto de headers com o tipo explícito
    const headers: Record<string, string> = {
        'Content-Type': 'application/json'
    };
    
    // 2. Adicionamos a autorização se o token existir
    if (token) {
        headers['Authorization'] = `Bearer ${token}`;
    }
    // --- FIM DA MUDANÇA ---

    const opts: RequestInit = {
        method,
        headers, // 3. Usamos o objeto de headers já pronto
    };

    if (data) {
        opts.body = JSON.stringify(data);
    }

    const response = await fetch(`${BASE_URL}/${path}`, opts);

    if (!response.ok) {
      if (response.status === 401) {
        localStorage.removeItem('gema_token');
        await goto('/');
      }
      throw await response.json();
    }
    
    if (response.status === 204) {
      return null;
    }

    return response.json();
}


export function get(path: string) {
    return send({ method: 'GET', path });
}

export function post(path: string, data: any) {
    return send({ method: 'POST', path, data });
}

export function patch(path: string, data: any) {
    return send({ method: 'PATCH', path, data });
}

export function del(path: string) {
    return send({ method: 'DELETE', path });
}