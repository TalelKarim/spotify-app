/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      colors: {
        spotify: {
          green: '#1DB954',
          black: '#121212',
          panel: '#181818',
          hover: '#242424',
          border: '#2A2A2A',
        },
      },
      boxShadow: {
        soft: '0 10px 30px rgba(0,0,0,0.25)',
      },
    },
  },
  plugins: [],
};
