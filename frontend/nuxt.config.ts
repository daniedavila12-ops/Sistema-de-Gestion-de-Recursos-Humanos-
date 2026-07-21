// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: ['@nuxtjs/tailwindcss'],
  devtools: { enabled: true },
  runtimeConfig: {
    public: {
      apiBase: (process.env.API_URL as string) || 'http://localhost:3007'
    }
  },
  // Agregamos esto para cambiar el puerto:
  devServer: {
    port: 3001
  }
})