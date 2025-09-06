/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#1a1a1a',
        secondary: '#2d2d2d', 
        accent: '#22c55e',
        warning: '#f59e0b',
        error: '#ef4444',
        'text-primary': '#ffffff',
        'text-secondary': '#a1a1aa',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
      fontSize: {
        'base-mobile': '16px',
      },
    },
  },
  plugins: [],
}