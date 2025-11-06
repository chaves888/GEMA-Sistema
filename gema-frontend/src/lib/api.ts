// src/lib/api.ts
import { goto } from '$app/navigation';

const BASE_URL = 'http://localhost:3000';

async function send({ method, path, data }: { method: string; path: string; data?: any }) {
	const token = localStorage.getItem('gema_token');

	if (!token && path !== 'auth/login') {
		await goto('/');
		throw new Error('Token não encontrado');
	}

	const headers: Record<string, string> = {};

	if (token) {
		headers['Authorization'] = `Bearer ${token}`;
	}

	const opts: RequestInit = {
		method,
		headers,
	};

	if (data) {
		if (data instanceof FormData) {
			opts.body = data;
		} else {
			headers['Content-Type'] = 'application/json';
			opts.body = JSON.stringify(data);
		}
	}

	const response = await fetch(`${BASE_URL}/${path}`, opts);

	if (!response.ok) {
		if (response.status === 401) {
			localStorage.removeItem('gema_token');
			await goto('/');
		}

		// --- INÍCIO DA CORREÇÃO ---
		let errorData;
		try {
			// 1. Tenta ler o corpo do erro (que o NestJS envia como JSON)
			errorData = await response.json();
		} catch (parseError) {
			// 2. Se o corpo não for JSON (ex: 500 HTML, 503 proxy, etc.)
			console.error('Falha ao ler o JSON do erro:', parseError);
			// Lança um erro genérico baseado no status
			throw new Error(`Erro ${response.status}: ${response.statusText}`);
		}

		// 3. Lança o objeto de erro COMPLETO do NestJS
		// (ex: { statusCode: 409, message: "Estoque insuficiente...", error: "Conflict" })
		throw errorData;
		// --- FIM DA CORREÇÃO ---
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