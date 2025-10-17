// src/lib/sessionStore.ts
import { writable } from 'svelte/store';
import { browser } from '$app/environment';
import { jwtDecode } from 'jwt-decode'; // <-- MUDANÇA AQUI

export const session = writable<any>(null);

export function initializeSession() {
  if (browser) {
    const token = localStorage.getItem('gema_token');
    if (token) {
      try {
        const decodedToken: any = jwtDecode(token); // <-- MUDANÇA AQUI
        session.set({
          id: decodedToken.sub,
          email: decodedToken.email,
          profile: decodedToken.profile
        });
      } catch (e) {
        localStorage.removeItem('gema_token');
        session.set(null);
      }
    }
  }
}