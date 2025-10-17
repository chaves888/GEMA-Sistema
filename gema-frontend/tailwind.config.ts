/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{html,js,svelte,ts}'],
  theme: {
    extend: {
      colors: {
        // Nova Paleta de Cores Baseada na Logo
        primary: { // Cor principal, podemos mapear para o azul da logo
          50: '#E3F2FD',
          100: '#BBDEFB',
          200: '#90CAF9',
          300: '#64B5F6',
          400: '#42A5F5',
          500: '#2196F3', // Azul padrão, mas podemos ajustar para o #1E88E5 se preferir
          600: '#1E88E5', // <-- Azul Principal da sua logo
          700: '#1976D2',
          800: '#1565C0',
          900: '#0D47A1',
        },
        accent: { // Uma cor de destaque, usando o verde claro
          50: '#F0F8EC',
          100: '#E0EFD8',
          200: '#C0DFB1',
          300: '#A0CF89',
          400: '#8BC34A', // <-- Verde Claro da sua logo
          500: '#7CB342',
          600: '#689F38',
          700: '#558B2F',
          800: '#436C27',
          900: '#33501E',
        },
        // Você também pode manter as cores padrão do Tailwind ou adicionar outras seções da logo
        // Ex: Podemos definir um 'gema-verde-escuro': '#4CAF50' se precisar de mais tons
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
  plugins: [],
};