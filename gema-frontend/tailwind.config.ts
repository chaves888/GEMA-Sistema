/** @type {import('tailwindcss').Config} */
module.exports = {
  // 1. Removemos a linha da flowbite-svelte daqui
  content: ['./src/**/*.{html,js,svelte,ts}'], 
  theme: {
    extend: {
      colors: {
        // Sua paleta de cores (continua perfeita)
        primary: { 50: '#E3F2FD', 100: '#BBDEFB', 200: '#90CAF9', 300: '#64B5F6', 400: '#42A5F5', 500: '#2196F3', 600: '#1E88E5', 700: '#1976D2', 800: '#1565C0', 900: '#0D47A1' },
        accent: { 50: '#F0F8EC', 100: '#E0EFD8', 200: '#C0DFB1', 300: '#A0CF89', 400: '#8BC34A', 500: '#7CB342', 600: '#689F38', 700: '#558B2F', 800: '#436C27', 900: '#33501E' }
      },
      keyframes: {
        'fade-in': {
          '0%': { opacity: '0', transform: 'translateY(-10px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
      animation: {
        'fade-in': 'fade-in 0.5s ease-out forwards',
      },
    },
  },
  // 2. Removemos o plugin da flowbite daqui
  plugins: [], 
};