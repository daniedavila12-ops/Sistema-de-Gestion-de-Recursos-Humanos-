import axios from 'axios'

export default defineNuxtPlugin((nuxtApp) => {
  const config = useRuntimeConfig()
  axios.defaults.baseURL = config.public.apiBase

  return {
    provide: {
      apiUrl: (path) => `${config.public.apiBase}${path}`
    }
  }
})
