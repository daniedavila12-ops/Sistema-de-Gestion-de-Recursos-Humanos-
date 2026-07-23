<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <AppSidebar />

    <main class="flex-1 md:ml-64 p-4 md:p-8 overflow-y-auto transition-all duration-300 w-full overflow-x-hidden">
      <header class="mb-10 flex justify-between items-center bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div class="flex items-center gap-4">
          <button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
          </button>
          <div>
            <h1 class="text-2xl md:text-3xl font-black text-slate-800 tracking-tight uppercase">Panel Principal</h1>
            <p class="text-slate-500 mt-1 text-sm md:text-base font-medium italic">📅 {{ fechaActual }}</p>
          </div>
        </div>
        <div class="flex items-center gap-6">
          <NotificationBell v-if="isDashboardAdmin || allowedDashboard.includes('Campanita de Notificaciones')" />
          <div class="relative">
            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-6 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors">
              <div v-if="fotoUsuario" class="h-10 w-10 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-slate-100">
                <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
              </div>
              <div v-else class="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-lg ring-2 ring-slate-100 uppercase">
                {{ nombreUsuario.charAt(0) }}
              </div>
              <div class="flex flex-col">
                <span class="text-[10px] text-slate-400 font-black uppercase tracking-widest">Usuario Activo</span>
                <span class="text-base font-black text-slate-900 leading-tight">{{ nombreUsuario }}</span>
              </div>
            </div>

            <!-- Dropdown Menu -->
            <div v-if="dropdownPerfilAbierto" class="absolute right-0 mt-2 w-64 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50 animate-in slide-in-from-top-2 duration-200">
              <div class="p-5 border-b border-slate-100 bg-slate-50 flex items-center gap-4">
                <div v-if="fotoUsuario" class="h-12 w-12 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-white shadow-sm shrink-0">
                  <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-12 w-12 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-xl ring-2 ring-white shadow-sm shrink-0 uppercase">
                  {{ nombreUsuario.charAt(0) }}
                </div>
                <div>
                  <p class="font-black text-slate-800 text-sm leading-tight">{{ nombreUsuario }}</p>
                  <p class="text-[10px] font-bold text-blue-500 uppercase tracking-widest mt-0.5">{{ rolNombre }}</p>
                </div>
              </div>
              <div class="p-2 space-y-1">
                <button @click="abrirModalPerfil(); dropdownPerfilAbierto = false" class="w-full text-left flex items-center gap-3 p-3 hover:bg-slate-50 rounded-xl transition-colors group">
                  <span class="text-lg group-hover:scale-110 transition-transform">👤</span>
                  <span class="text-sm font-bold text-slate-700">Mi Perfil de Usuario</span>
                </button>
                <button @click="logout" class="w-full text-left flex items-center gap-3 p-3 hover:bg-red-50 rounded-xl transition-colors group">
                  <span class="text-lg group-hover:scale-110 transition-transform">🚪</span>
                  <span class="text-sm font-bold text-red-600">Cerrar Sesión</span>
                </button>
              </div>
            </div>
            <!-- Overlay invisible para cerrar el dropdown si se hace click fuera -->
            <div v-if="dropdownPerfilAbierto" @click="dropdownPerfilAbierto = false" class="fixed inset-0 z-40"></div>
          </div>
        </div>
      </header>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4 mb-6">
        <div
          v-for="(stat, index) in tarjetas" :key="index" 
          @click="handleStatClick(stat.link)"
          :class="[stat.color, stat.hoverGlow, stat.link ? 'cursor-pointer hover:-translate-y-1 hover:shadow-lg active:scale-[0.98]' : 'hover:shadow-md']" 
          class="relative overflow-hidden p-4 rounded-2xl shadow-sm transition-all duration-300 block group ring-2 ring-white/50 ring-offset-2">
          <!-- Icono de fondo grande -->
          <div class="absolute right-0 top-0 -mt-2 -mr-2 text-white/20 transition-transform group-hover:scale-110">
            <span class="text-5xl opacity-50">{{ stat.icon }}</span>
          </div>
          <div class="relative z-10 flex flex-col h-full justify-between">
            <div class="flex justify-between items-start">
              <h3 class="text-white/90 uppercase text-[9px] font-extrabold tracking-widest">{{ stat.label }}</h3>
              <span class="text-sm p-1.5 rounded-xl backdrop-blur-sm shadow-sm" :class="stat.bgIcon">{{ stat.icon }}</span>
            </div>
            <div class="mt-2">
              <p class="text-2xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ stat.valor }}</p>
              <p class="text-[9px] text-white/80 font-bold mt-1" v-if="stat.sub">{{ stat.sub }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Dashboard Lists -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <!-- Cumpleañeros -->
        <div v-if="dashboardLists.cumpleaneros !== null" id="cumpleaneros" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col h-[400px] scroll-mt-24">
          <div class="flex justify-between items-center mb-4 shrink-0">
            <h2 class="text-lg font-black text-slate-800 uppercase tracking-tight flex items-center gap-2"><span class="text-2xl">🎂</span> Cumpleañeros</h2>
            <select v-model="mesCumpleaneros" @change="fetchCumpleaneros" class="p-2 text-xs bg-slate-50 border rounded-xl outline-none focus:border-blue-500 font-bold text-slate-600 cursor-pointer">
              <option :value="1">Enero</option>
              <option :value="2">Febrero</option>
              <option :value="3">Marzo</option>
              <option :value="4">Abril</option>
              <option :value="5">Mayo</option>
              <option :value="6">Junio</option>
              <option :value="7">Julio</option>
              <option :value="8">Agosto</option>
              <option :value="9">Septiembre</option>
              <option :value="10">Octubre</option>
              <option :value="11">Noviembre</option>
              <option :value="12">Diciembre</option>
            </select>
          </div>
          <div v-if="dashboardLists.cumpleaneros && dashboardLists.cumpleaneros.length" class="space-y-3 overflow-y-auto pr-2 flex-1 scrollbar-thin">
            <NuxtLink v-for="emp in dashboardLists.cumpleaneros" :key="'cump-'+emp.id" :to="`/empleados/${emp.id}`" class="flex items-center gap-4 p-3 bg-slate-50 rounded-xl hover:bg-slate-100 hover:shadow-sm cursor-pointer transition-all active:scale-[0.98]">
              <div class="relative shrink-0">
                <div v-if="emp.foto" class="h-10 w-10 rounded-full overflow-hidden" :class="{'ring-2 ring-pink-500 ring-offset-2': calcularDiasRestantesTexto(emp.fecha_nacimiento) === '¡Hoy!'}"><img :src="`${$config.public.apiBase}${emp.foto}`" class="w-full h-full object-cover"/></div>
                <div v-else class="h-10 w-10 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center uppercase" :class="{'ring-2 ring-pink-500 ring-offset-2 bg-pink-100 text-pink-600': calcularDiasRestantesTexto(emp.fecha_nacimiento) === '¡Hoy!'}">{{ emp.nombre.charAt(0) }}</div>
                <div v-if="calcularDiasRestantesTexto(emp.fecha_nacimiento) === '¡Hoy!'" class="absolute -bottom-1 -right-3 bg-pink-500 text-white text-[9px] font-black px-1.5 py-0.5 rounded-full shadow-sm border border-white z-10 whitespace-nowrap animate-bounce">
                  🎉 ¡HOY!
                </div>
              </div>
              <div class="flex-1">
                <p class="font-bold text-sm text-slate-800">{{ emp.nombre }} {{ emp.apellido }}</p>
                <div class="flex items-center gap-2 mt-0.5">
                  <p class="text-xs text-slate-500">{{ new Date(emp.fecha_nacimiento).toLocaleDateString('es-HN', { day: 'numeric', month: 'long', timeZone: 'UTC' }) }}</p>
                  <span class="text-[10px] font-black px-2 py-0.5 rounded-md" :class="calcularDiasRestantesTexto(emp.fecha_nacimiento).includes('Pasó') ? 'text-slate-500 bg-slate-100' : 'text-pink-500 bg-pink-100'">{{ calcularDiasRestantesTexto(emp.fecha_nacimiento) }}</span>
                </div>
              </div>
            </NuxtLink>
          </div>
          <div v-else class="flex-1 flex items-center justify-center">
            <p class="text-sm text-slate-400 italic">No hay cumpleañeros este mes</p>
          </div>
        </div>

        <!-- Contratos por Vencer -->
        <div id="vencimientos" v-if="dashboardLists.vencimientos !== null" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col h-[400px]">
          <div class="flex justify-between items-center mb-4 shrink-0">
            <h2 class="text-lg font-black text-slate-800 uppercase tracking-tight flex items-center gap-2"><span class="text-2xl">📄</span> Contratos por Vencer</h2>
            <select v-model="mesVencimiento" @change="fetchVencimientos" class="p-2 text-xs bg-slate-50 border rounded-xl outline-none focus:border-blue-500 font-bold text-slate-600 cursor-pointer">
              <option value="proximos">Próximos 30 días</option>
              <option value="todos">Todos</option>
              <option :value="1">Enero</option>
              <option :value="2">Febrero</option>
              <option :value="3">Marzo</option>
              <option :value="4">Abril</option>
              <option :value="5">Mayo</option>
              <option :value="6">Junio</option>
              <option :value="7">Julio</option>
              <option :value="8">Agosto</option>
              <option :value="9">Septiembre</option>
              <option :value="10">Octubre</option>
              <option :value="11">Noviembre</option>
              <option :value="12">Diciembre</option>
            </select>
          </div>
          <div v-if="dashboardLists.vencimientos && dashboardLists.vencimientos.length" class="space-y-3 overflow-y-auto pr-2 flex-1 scrollbar-thin">
            <NuxtLink v-for="emp in dashboardLists.vencimientos" :key="'venc-'+emp.id" :to="`/empleados/${emp.empleado_id}`" class="flex items-center gap-4 p-3 bg-red-50 rounded-xl border border-red-100 hover:bg-red-100 hover:shadow-sm cursor-pointer transition-all active:scale-[0.98]">
              <div class="relative shrink-0">
                <div v-if="emp.foto" class="h-10 w-10 rounded-full overflow-hidden"><img :src="`${$config.public.apiBase}${emp.foto}`" class="w-full h-full object-cover"/></div>
                <div v-else class="h-10 w-10 rounded-full bg-red-200 text-red-600 font-bold flex items-center justify-center uppercase">{{ emp.nombre.charAt(0) }}</div>
              </div>
              <div class="flex-1">
                <p class="font-bold text-sm text-slate-800">{{ emp.nombre }} {{ emp.apellido }}</p>
                <div class="flex items-center gap-2 mt-0.5">
                  <p class="text-xs text-red-500 font-medium">Vence: {{ new Date(emp.fechaFinal).toLocaleDateString('es-HN', { timeZone: 'UTC' }) }} <span class="text-slate-400 text-[10px] ml-1 uppercase">({{ emp.tipoContrato }})</span></p>
                  <span class="text-[10px] font-black text-red-600 bg-red-200 px-2 py-0.5 rounded-md">{{ calcularDiasRestantesContratoTexto(emp.fechaFinal) }}</span>
                </div>
              </div>
            </NuxtLink>
          </div>
          <div v-else class="flex-1 flex items-center justify-center">
            <p class="text-sm text-slate-400 italic">No hay contratos por vencer pronto</p>
          </div>
        </div>
        
        <!-- Empleados Activos -->
        <div v-if="dashboardLists.activos !== null" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col h-[400px]">
          <div class="flex justify-between items-center mb-4 shrink-0">
            <h2 class="text-lg font-black text-slate-800 uppercase tracking-tight flex items-center gap-2"><span class="text-2xl">🟢</span> Empleados Activos</h2>
            <span v-if="dashboardLists.activos" class="bg-emerald-100 text-emerald-700 px-3 py-1 rounded-xl text-xs font-black">{{ dashboardLists.activos.length }}</span>
          </div>
          <div v-if="dashboardLists.activos && dashboardLists.activos.length" class="space-y-3 overflow-y-auto pr-2 flex-1 scrollbar-thin">
            <NuxtLink v-for="emp in dashboardLists.activos" :key="'act-'+emp.id" :to="`/empleados/${emp.id}`" class="flex items-center gap-4 p-3 bg-slate-50 rounded-xl hover:bg-slate-100 hover:shadow-sm cursor-pointer transition-all active:scale-[0.98]">
              <div v-if="emp.foto" class="h-10 w-10 rounded-full overflow-hidden shrink-0"><img :src="`${$config.public.apiBase}${emp.foto}`" class="w-full h-full object-cover"/></div>
              <div v-else class="h-10 w-10 rounded-full bg-emerald-100 text-emerald-600 font-bold flex items-center justify-center shrink-0 uppercase">{{ emp.nombre.charAt(0) }}</div>
              <div class="flex-1">
                <p class="font-bold text-sm text-slate-800">{{ emp.nombre }} {{ emp.apellido }}</p>
                <p class="text-[10px] uppercase tracking-wider text-slate-400 font-bold">{{ emp.codigo_empleado || 'Sin código' }}</p>
              </div>
            </NuxtLink>
          </div>
          <div v-else class="flex-1 flex items-center justify-center">
            <p class="text-sm text-slate-400 italic">No hay empleados activos</p>
          </div>
        </div>
        
        <!-- Empleados Inactivos -->
        <div v-if="dashboardLists.inactivos !== null" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 flex flex-col h-[400px]">
          <div class="flex justify-between items-center mb-4 shrink-0">
            <h2 class="text-lg font-black text-slate-800 uppercase tracking-tight flex items-center gap-2"><span class="text-2xl">🔴</span> Empleados Inactivos</h2>
            <span v-if="dashboardLists.inactivos" class="bg-red-100 text-red-700 px-3 py-1 rounded-xl text-xs font-black">{{ dashboardLists.inactivos.length }}</span>
          </div>
          <div v-if="dashboardLists.inactivos && dashboardLists.inactivos.length" class="space-y-3 overflow-y-auto pr-2 flex-1 scrollbar-thin">
            <NuxtLink v-for="emp in dashboardLists.inactivos" :key="'inact-'+emp.id" :to="`/empleados/${emp.id}`" class="flex items-center gap-4 p-3 bg-slate-50 rounded-xl opacity-75 hover:bg-slate-100 hover:opacity-100 hover:shadow-sm cursor-pointer transition-all active:scale-[0.98]">
              <div v-if="emp.foto" class="h-10 w-10 rounded-full overflow-hidden shrink-0 grayscale"><img :src="`${$config.public.apiBase}${emp.foto}`" class="w-full h-full object-cover"/></div>
              <div v-else class="h-10 w-10 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center shrink-0 uppercase">{{ emp.nombre.charAt(0) }}</div>
              <div class="flex-1">
                <p class="font-bold text-sm text-slate-600">{{ emp.nombre }} {{ emp.apellido }}</p>
                <p class="text-[10px] uppercase tracking-wider text-slate-400 font-bold">{{ emp.codigo_empleado || 'Sin código' }}</p>
              </div>
            </NuxtLink>
          </div>
          <div v-else class="flex-1 flex items-center justify-center">
            <p class="text-sm text-slate-400 italic">No hay empleados inactivos</p>
          </div>
        </div>
      </div>


      <div v-if="modalAbiertoPerfil" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex justify-center items-center p-4">
        <div class="bg-white w-full max-w-md overflow-hidden rounded-3xl shadow-2xl animate-in fade-in zoom-in duration-200">
          <div class="p-6 border-b bg-white flex justify-between items-center">
            <h2 class="text-2xl font-black text-slate-800 uppercase tracking-tight">👤 Perfil de Usuario</h2>
            <button @click="cerrarModalPerfil" class="text-slate-400 hover:text-red-500 transition text-2xl">&times;</button>
          </div>

          <form @submit.prevent="cambiarPassword" class="p-8 space-y-6">
            <div class="mb-6 flex flex-col items-center">
              <div class="relative group cursor-pointer" @click="triggerFileInputPerfil">
                <div v-if="fotoUsuario" class="h-20 w-20 rounded-full flex items-center justify-center overflow-hidden ring-4 ring-slate-100 shadow-lg mb-4">
                  <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-20 w-20 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-3xl ring-4 ring-slate-100 uppercase mb-4 shadow-lg">
                  {{ nombreUsuario.charAt(0) }}
                </div>
                <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity rounded-full bg-black/50 mb-4">
                  <span class="text-white text-[10px] font-bold px-2 py-1 text-center">Cambiar<br>Foto</span>
                </div>
                <input type="file" ref="fileInputPerfil" class="hidden" accept="image/*" @change="uploadFotoPerfil" />
              </div>
              <h3 class="text-xl font-black text-slate-900">{{ nombreUsuario }}</h3>
              <p class="text-xs font-bold text-slate-400 uppercase tracking-widest mt-1">{{ rolNombre }}</p>
            </div>

            <div>
              <h3 class="text-[10px] font-black text-blue-500 uppercase tracking-widest mb-4 border-b pb-2">Seguridad - Cambiar Contraseña</h3>
              <div class="space-y-4">
                <div>
                  <label class="block text-[10px] font-bold text-slate-400 uppercase mb-1">Contraseña Actual</label>
                  <input v-model="formPassword.actual" type="password" required class="w-full p-3 bg-slate-50 border rounded-xl outline-none focus:border-blue-500">
                </div>
                <div>
                  <label class="block text-[10px] font-bold text-slate-400 uppercase mb-1">Nueva Contraseña</label>
                  <input v-model="formPassword.nueva" type="password" required class="w-full p-3 bg-slate-50 border rounded-xl outline-none focus:border-blue-500">
                </div>
                <div>
                  <label class="block text-[10px] font-bold text-slate-400 uppercase mb-1">Confirmar Contraseña</label>
                  <input v-model="formPassword.confirmar" type="password" required class="w-full p-3 bg-slate-50 border rounded-xl outline-none focus:border-blue-500">
                </div>
              </div>
            </div>

            <div class="flex justify-end gap-3 pt-4 border-t">
              <button type="button" @click="cerrarModalPerfil" class="px-6 py-3 text-slate-400 font-bold uppercase text-xs">Cancelar</button>
              <button type="submit" :disabled="loadingPassword" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-black uppercase text-xs shadow-lg shadow-blue-200">
                {{ loadingPassword ? 'Actualizando...' : 'Actualizar' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import axios from 'axios'
import { useSidebar } from '@/composables/useSidebar'
const { toggleMobileMenu } = useSidebar()

const menuAbierto = ref(false)
const nombreUsuario = ref('')
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const departamentos = ref([])
const stats = ref({ total: 0, tickets: 0, cumpleaneros: 0, vencimientos: 0 })
const dashboardLists = ref({ cumpleaneros: [], vencimientos: [], activos: [], inactivos: [] })
const allowedDashboard = ref([])
const isDashboardAdmin = ref(false)
const fechaActual = ref(new Date().toLocaleDateString('es-HN', { day: 'numeric', month: 'long', year: 'numeric' }))

// Lógica Modal Perfil
const modalAbiertoPerfil = ref(false)
const loadingPassword = ref(false)
const formPassword = ref({ actual: '', nueva: '', confirmar: '' })

const dropdownPerfilAbierto = ref(false)

const fotoUsuario = ref(null)
const fileInputPerfil = ref(null)

const triggerFileInputPerfil = () => {
  fileInputPerfil.value.click()
}

const uploadFotoPerfil = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  const formData = new FormData()
  formData.append('foto', file)

  try {
    const id = localStorage.getItem('usuarioID')
    const res = await axios.post(`/api/auth/${id}/foto`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    
    fotoUsuario.value = res.data.fotoUrl
    localStorage.setItem('usuarioFoto', res.data.fotoUrl)
    alert('✅ ' + res.data.mensaje)
  } catch (err) {
    console.error("Error al subir la foto:", err)
    alert('❌ Error al subir la foto')
  }
}

const abrirModalPerfil = () => { modalAbiertoPerfil.value = true }
const cerrarModalPerfil = () => { 
  modalAbiertoPerfil.value = false
  formPassword.value = { actual: '', nueva: '', confirmar: '' } 
}

const cambiarPassword = async () => {
  if (formPassword.value.nueva !== formPassword.value.confirmar) {
    alert('❌ Las contraseñas nuevas no coinciden')
    return
  }
  try {
    loadingPassword.value = true
    const userId = localStorage.getItem('usuarioID')
    const res = await axios.post('/api/auth/cambiar-password', {
      id: userId,
      actual: formPassword.value.actual,
      nueva: formPassword.value.nueva
    })
    alert('✅ ' + (res.data.mensaje || 'Contraseña actualizada correctamente'))
    cerrarModalPerfil()
  } catch (error) {
    alert('❌ ' + (error.response?.data?.mensaje || 'Error al actualizar contraseña'))
  } finally {
    loadingPassword.value = false
  }
}



const tarjetas = computed(() => {
  let list = [
    { label: 'Total Empleados', valor: stats.value.total, icon: '👥', color: 'bg-gradient-to-br from-blue-500 to-blue-600 ring-offset-blue-50', bgIcon: 'bg-white/20 text-white', hoverGlow: 'shadow-blue-500/30', sub: `Activos: ${dashboardLists.value.activos?.length || 0}`, link: '/empleados' },
    { label: 'Tickets Ptes.', valor: stats.value.tickets, icon: '🎫', color: 'bg-gradient-to-br from-orange-400 to-orange-500 ring-offset-orange-50', bgIcon: 'bg-white/20 text-white', hoverGlow: 'shadow-orange-500/30', sub: 'Soporte IT', link: '/tickets' },
    { label: 'Incidentes Ptes.', valor: stats.value.incidencias, icon: '⚠️', color: 'bg-gradient-to-br from-red-400 to-red-500 ring-offset-red-50', bgIcon: 'bg-white/20 text-white', hoverGlow: 'shadow-red-500/30', sub: 'Requieren atención', link: '/reportes-incidencia' },
    { label: 'Cumpleañeros', valor: stats.value.cumpleaneros, icon: '🎂', color: 'bg-gradient-to-br from-fuchsia-400 to-fuchsia-500 ring-offset-fuchsia-50', bgIcon: 'bg-white/20 text-white', hoverGlow: 'shadow-fuchsia-500/30', sub: 'Este mes', link: '#cumpleaneros' },
    { label: 'Vencimientos', valor: stats.value.vencimientos, icon: '📄', color: 'bg-gradient-to-br from-indigo-500 to-indigo-600 ring-offset-indigo-50', bgIcon: 'bg-white/20 text-white', hoverGlow: 'shadow-indigo-500/30', sub: 'Próximos 30 días', link: '#vencimientos' },
  ];

  if (!isDashboardAdmin.value) {
    if (!allowedDashboard.value.includes('Total Empleados')) list = list.filter(t => t.label !== 'Total Empleados');
    if (!allowedDashboard.value.includes('Tickets Pendientes')) list = list.filter(t => t.label !== 'Tickets Ptes.');
    if (!allowedDashboard.value.includes('Incidentes Pendientes')) list = list.filter(t => t.label !== 'Incidentes Ptes.');
    if (!allowedDashboard.value.includes('Cumpleañeros')) list = list.filter(t => t.label !== 'Cumpleañeros');
    if (!allowedDashboard.value.includes('Vencimientos')) list = list.filter(t => t.label !== 'Vencimientos');
  }

  return list;
})

const handleStatClick = async (link) => {
  if (!link) return
  if (link === '#vencimientos') {
    mesVencimiento.value = 'todos'
    await fetchVencimientos()
  }
  if (link.startsWith('#')) {
    const el = document.querySelector(link)
    if (el) {
      el.scrollIntoView({ behavior: 'smooth' })
    }
  } else {
    navigateTo(link)
  }
}

const mesCumpleaneros = ref(new Date().getMonth() + 1)
const mesVencimiento = ref('proximos')

const calcularDiasRestantesContratoTexto = (fechaFinal) => {
  if (!fechaFinal) return '';
  const hoy = new Date();
  const todayDate = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate());
  const final = new Date(fechaFinal);
  const finalDate = new Date(final.getUTCFullYear(), final.getUTCMonth(), final.getUTCDate());
  
  const diffTime = finalDate.getTime() - todayDate.getTime();
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  
  if (diffDays < 0) return 'Vencido';
  if (diffDays === 0) return 'Vence hoy';
  if (diffDays === 1) return 'Falta 1 día';
  return `Faltan ${diffDays} días`;
}

const calcularDiasRestantesTexto = (fechaNacimiento) => {
  if (!fechaNacimiento) return '';
  const hoy = new Date();
  const todayDate = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate());
  const nacimiento = new Date(fechaNacimiento);
  const mes = nacimiento.getUTCMonth();
  const dia = nacimiento.getUTCDate();
  
  const cumpleEsteAnio = new Date(hoy.getFullYear(), mes, dia);
  
  const diffTime = cumpleEsteAnio.getTime() - todayDate.getTime();
  const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));
  
  if (diffDays === 0) return '¡Hoy!';
  if (diffDays < 0) {
    const diasPasados = Math.abs(diffDays);
    if (diasPasados === 1) return 'Pasó hace 1 día';
    return `Pasó hace ${diasPasados} días`;
  }
  
  if (diffDays === 1) return 'Falta 1 día';
  return `Faltan ${diffDays} días`;
}

const fetchCumpleaneros = async () => {
  try {
    const listsRes = await axios.get(`/api/stats/dashboard-lists?mes=${mesCumpleaneros.value}`)
    // Actualizamos solo la lista de cumpleañeros
    dashboardLists.value.cumpleaneros = listsRes.data.cumpleaneros
  } catch (err) {
    console.error("Error cargando cumpleañeros", err)
  }
}

const fetchVencimientos = async () => {
  try {
    const listsRes = await axios.get(`/api/stats/dashboard-lists?mesVencimiento=${mesVencimiento.value}`)
    // Actualizamos solo la lista de vencimientos
    dashboardLists.value.vencimientos = listsRes.data.vencimientos
  } catch (err) {
    console.error("Error cargando vencimientos", err)
  }
}

onMounted(async () => {
  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Invitado'
  rolID.value = localStorage.getItem('usuarioRol') || 2
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null
  
  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }
  
  try {
    const p = await axios.get(`/api/dashboard-permisos/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    isDashboardAdmin.value = p.data === 'ALL'
    allowedDashboard.value = p.data === 'ALL' ? [] : (p.data || [])
  } catch (err) {
    console.error("Error cargando permisos", err)
  }

  try {
    const uId = localStorage.getItem('usuarioID') || '';
    const uNombre = localStorage.getItem('usuarioNombre') || '';
    const uRol = localStorage.getItem('usuarioRol') || '';
    const s = await axios.get(`/api/stats/resumen?usuario_id=${uId}&nombre=${encodeURIComponent(uNombre)}&rol_id=${uRol}`)
    stats.value = s.data
  } catch (err) {
    console.error("Error cargando estadisticas resumen", err)
  }
  try {
    const depRes = await axios.get('/api/departamentos/lista')
    departamentos.value = depRes.data
  } catch (err) {
    console.error("Error cargando departamentos", err)
  }

  try {
    const listsRes = await axios.get(`/api/stats/dashboard-lists?mes=${mesCumpleaneros.value}&mesVencimiento=${mesVencimiento.value}`)
    const dLists = listsRes.data
    
    // Asignar permisos a las listas del dashboard
    if (!isDashboardAdmin.value) {
      if (!allowedDashboard.value.includes('Cumpleañeros')) dLists.cumpleaneros = null
      if (!allowedDashboard.value.includes('Contratos por Vencer')) dLists.vencimientos = null
      if (!allowedDashboard.value.includes('Empleados Activos')) dLists.activos = null
      if (!allowedDashboard.value.includes('Empleados Inactivos')) dLists.inactivos = null
    }
    
    dashboardLists.value = dLists
  } catch (err) {
    console.error("Error cargando listas del dashboard", err)
  }

  // Socket.io for realtime dashboard stats update
  const { io } = await import('socket.io-client');
  const socket = io(useRuntimeConfig().public.apiBase);
  socket.on('nuevo_ticket', async () => {
    try {
      const uId = localStorage.getItem('usuarioID') || '';
      const uNombre = localStorage.getItem('usuarioNombre') || '';
      const uRol = localStorage.getItem('usuarioRol') || '';
      const s = await axios.get(`/api/stats/resumen?usuario_id=${uId}&nombre=${encodeURIComponent(uNombre)}&rol_id=${uRol}`);
      stats.value = s.data;
    } catch (err) {
      console.error("Error recargando estadisticas resumen (socket)", err);
    }
  });
})

const logout = () => { localStorage.clear(); navigateTo('/dashboard') }
</script>
