// src/lib/toast.ts
import { writable } from 'svelte/store';

// Define os tipos de notificação que teremos
export type ToastType = 'success' | 'error' | 'info';

export interface Toast {
	id: number;
	message: string;
	type: ToastType;
	timeout: number;
}

const { subscribe, update } = writable<Toast[]>([]);

function addToast(message: string, type: ToastType, timeout: number = 4000) {
	// Cria um ID aleatório
	const id = Math.floor(Math.random() * 10000);

	// Adiciona a nova notificação à lista
	update((toasts) => [...toasts, { id, message, type, timeout }]);

	// Configura um timer para remover a notificação automaticamente
	if (timeout > 0) {
		setTimeout(() => {
			removeToast(id);
		}, timeout);
	}
}

function removeToast(id: number) {
	update((toasts) => toasts.filter((t) => t.id !== id));
}

export const toast = {
	subscribe,
	// Funções fáceis de usar
	success: (message: string, timeout: number = 3000) =>
		addToast(message, 'success', timeout),
	error: (message: string, timeout: number = 5000) =>
		addToast(message, 'error', timeout), // Erros duram um pouco mais
	info: (message: string, timeout: number = 3000) => addToast(message, 'info', timeout),
	remove: removeToast
};