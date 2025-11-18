import { writable } from 'svelte/store';
import { browser } from '$app/environment';

const initialTheme = browser
  ? localStorage.getItem('theme') || 
    (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
  : 'light';

export const theme = writable(initialTheme);

theme.subscribe((value) => {
  if (browser) {
    const root = document.documentElement;
    if (value === 'dark') {
      root.classList.add('dark');
    } else {
      root.classList.remove('dark');
    }
    localStorage.setItem('theme', value);
  }
});

export function toggleTheme() {
  theme.update((current) => (current === 'light' ? 'dark' : 'light'));
}