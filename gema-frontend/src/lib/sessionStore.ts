import { writable } from 'svelte/store';
import { browser } from '$app/environment';
import { jwtDecode } from 'jwt-decode';

export const session = writable<any>(null);

export function initializeSession() {
  if (browser) {
    const token = localStorage.getItem('gema_token');
    if (token) {
      try {
        const decodedToken: any = jwtDecode(token);
        // ADICIONA A PROPRIEDADE 'school' AQUI
        session.set({
          id: decodedToken.sub,
          email: decodedToken.email,
          profile: decodedToken.profile,
          school: decodedToken.school // <-- ADICIONADO
        });
      } catch (e) {
        localStorage.removeItem('gema_token');
        session.set(null);
      }
    } else {
      session.set(null); // Garante que a sessão seja nula se não houver token
    }
  }
}