/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        // Green Tones
        green: {
          primary: 'var(--color-green-primary)',
          dark: 'var(--color-green-dark)',
          light: 'var(--color-green-light)',
          deep: 'var(--color-green-deep)',
          muted: 'var(--color-green-muted)',
        },
        // Pink Tones
        pink: {
          lightest: 'var(--color-pink-lightest)',
          light: 'var(--color-pink-light)',
          accent: 'var(--color-pink-accent)',
          border: 'var(--color-pink-border)',
        },
        // Neutral Colors
        white: 'var(--color-white)',
        black: 'var(--color-black)',
        // System Colors
        error: 'var(--color-error)',
      },
    },
  },
  plugins: [],
  darkMode: 'class', // Enable dark mode with class strategy
}

