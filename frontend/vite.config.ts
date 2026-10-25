import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    // Forward API calls to the FastAPI dev server
    proxy: {
      // DOUBT_API_PORT points the proxy at another backend (see .claude/launch.json)
      '/api': `http://127.0.0.1:${process.env.DOUBT_API_PORT ?? '8000'}`,
    },
  },
})
