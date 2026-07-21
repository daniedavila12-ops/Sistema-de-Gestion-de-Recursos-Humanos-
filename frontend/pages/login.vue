<template>
  <div class="min-h-screen flex flex-col items-center justify-center bg-slate-900 p-4 font-sans">
    
    <div class="bg-white p-10 rounded-3xl shadow-2xl w-full max-w-md border border-white/10">
      <div class="text-center mb-8 flex flex-col items-center">
        <img :src="`${$config.public.apiBase}/uploads/Logo/Logo.png`" alt="Logo Innova" class="h-20 mb-4 object-contain" />
        <h2 class="text-2xl font-black text-slate-800 tracking-tighter uppercase">RRHH Innova</h2>
        <p class="text-slate-400 font-bold text-xs mt-1 tracking-widest uppercase opacity-70">Gestión de Talento Humano</p>
      </div>

      <form @submit.prevent="handleLogin" class="space-y-6">
        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Correo Institucional</label>
          <input v-model="email" type="email" required placeholder="admin@test.com"
            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200">
        </div>

        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Contraseña</label>
          <input v-model="password" type="password" required placeholder="••••••••"
            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200">
        </div>

        <button type="submit" :disabled="loading"
          class="w-full bg-blue-600 text-white py-4 rounded-2xl font-black text-sm uppercase tracking-widest hover:bg-blue-700 shadow-xl shadow-blue-500/20 active:scale-[0.98] transition-all disabled:bg-slate-300">
          {{ loading ? 'Verificando...' : 'Entrar al Sistema' }}
        </button>
      </form>

      <div v-if="errorMsg" class="mt-6 p-3 bg-red-50 rounded-xl border border-red-100">
        <p class="text-center text-red-600 text-xs font-bold uppercase tracking-tighter italic">
          ⚠️ {{ errorMsg }}
        </p>
      </div>
    </div>

    <div class="mt-12 w-full max-w-2xl">
      <p class="text-center text-slate-500 text-[10px] font-black uppercase tracking-[0.3em] mb-6 opacity-50">
        Servicios Externos
      </p>
      
      <div class="grid grid-cols-2 sm:grid-cols-5 gap-4">
        <NuxtLink to="/biblioteca" 
          class="flex flex-col items-center p-5 bg-slate-800/40 border border-white/5 rounded-3xl hover:bg-slate-800 hover:border-blue-500/50 transition-all group">
          <span class="text-3xl mb-3 group-hover:scale-110 transition-transform">📚</span>
          <span class="text-white text-[9px] font-black uppercase tracking-widest text-center opacity-70 group-hover:opacity-100">Biblioteca</span>
        </NuxtLink>

        <NuxtLink to="/tickets-soporte" 
          class="flex flex-col items-center p-5 bg-slate-800/40 border border-white/5 rounded-3xl hover:bg-slate-800 hover:border-yellow-500/50 transition-all group">
          <span class="text-3xl mb-3 group-hover:scale-110 transition-transform">🎫</span>
          <span class="text-white text-[9px] font-black uppercase tracking-widest text-center opacity-70 group-hover:opacity-100">Tickets</span>
        </NuxtLink>

        <NuxtLink to="/crear-reporte-incidencia" 
          class="flex flex-col items-center p-5 bg-slate-800/40 border border-white/5 rounded-3xl hover:bg-slate-800 hover:border-red-500/50 transition-all group">
          <span class="text-3xl mb-3 group-hover:scale-110 transition-transform">⚠️</span>
          <span class="text-white text-[9px] font-black uppercase tracking-widest text-center opacity-70 group-hover:opacity-100">Incidentes</span>
        </NuxtLink>

        <NuxtLink to="/reporte-sms" 
          class="flex flex-col items-center p-5 bg-slate-800/40 border border-white/5 rounded-3xl hover:bg-slate-800 hover:border-green-500/50 transition-all group">
          <span class="text-3xl mb-3 group-hover:scale-110 transition-transform">📩</span>
          <span class="text-white text-[9px] font-black uppercase tracking-widest text-center opacity-70 group-hover:opacity-100">Reporte SMS</span>
        </NuxtLink>

        <NuxtLink to="/reclutamiento" 
          class="flex flex-col items-center p-5 bg-slate-800/40 border border-white/5 rounded-3xl hover:bg-slate-800 hover:border-cyan-500/50 transition-all group">
          <span class="text-3xl mb-3 group-hover:scale-110 transition-transform">💼</span>
          <span class="text-white text-[9px] font-black uppercase tracking-widest text-center opacity-70 group-hover:opacity-100">Empleos</span>
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios'

const email = ref('')
const password = ref('')
const errorMsg = ref('')
const loading = ref(false)

const handleLogin = async () => {
  try {
    loading.value = true
    errorMsg.value = ''
    
    const res = await axios.post('/api/auth/login', {
      email: email.value,
      password: password.value
    })

    if (res.data && res.data.usuario) {
      localStorage.setItem('usuarioNombre', res.data.usuario.nombre)
      localStorage.setItem('usuarioID', res.data.usuario.id)
      localStorage.setItem('usuarioRol', res.data.usuario.rol)
      if (res.data.usuario.foto) {
        localStorage.setItem('usuarioFoto', res.data.usuario.foto)
      } else {
        localStorage.removeItem('usuarioFoto')
      }
      await navigateTo('/')
    }
  } catch (error) {
    if (!error.response) {
      errorMsg.value = 'Servidor fuera de línea'
    } else {
      errorMsg.value = error.response.data.mensaje || 'Error de acceso'
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.flex {
  animation: pageIn 0.6s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes pageIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>