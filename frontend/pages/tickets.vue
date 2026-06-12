<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <!-- SIDEBAR DINÁMICO (Copia de index.vue) -->
    <aside class="w-64 bg-slate-800 text-white flex flex-col shadow-xl fixed h-full z-10">
      <div class="p-6 text-2xl font-bold border-b border-slate-700 tracking-tight text-blue-400 uppercase">
        RRHH Innova
      </div>
      
      <nav class="flex-1 p-4 space-y-1 overflow-y-auto">
        <div v-for="(item, index) in menuUsuario" :key="item.ruta || index">
          <div v-if="item.esCabecera" class="text-[10px] font-black text-slate-500 uppercase tracking-widest mt-6 mb-2 px-3">
            {{ item.nombre }}
          </div>
          <NuxtLink v-else :to="item.ruta" 
            class="flex items-center gap-3 p-3 rounded-xl hover:bg-slate-700 transition-all duration-200 group"
            active-class="bg-blue-600 shadow-lg">
            <span class="text-xl group-hover:scale-110 transition-transform">{{ item.icono }}</span>
            <span class="text-sm font-medium">{{ item.nombre }}</span>
          </NuxtLink>
        </div>
      </nav>

      <div class="p-4 border-t border-slate-700 bg-slate-900/50">
        <div class="mb-4 px-2 flex flex-col">
          <span class="text-[9px] font-black text-slate-500 uppercase tracking-widest">Nivel de Acceso</span>
          <span class="text-xs font-bold text-blue-400">{{ rolNombre }}</span>
        </div>
        <button @click="logout" class="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-red-500/10 hover:text-red-400 transition-all font-bold text-xs uppercase tracking-widest">
          <span>🚪</span> Cerrar Sesión
        </button>
      </div>
    </aside>

    <!-- CONTENIDO PRINCIPAL -->
    <main class="flex-1 ml-64 p-8 overflow-y-auto">
      <header class="mb-10 flex justify-between items-center bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div>
          <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Módulo de Tickets</h1>
          <p class="text-slate-500 mt-1 font-medium italic">Gestiona tus solicitudes y requerimientos</p>
        </div>
        <div class="flex items-center gap-6">
          <button @click="abrirModalNuevo" class="bg-blue-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-blue-700 transition-all shadow-lg shadow-blue-200">
            + Nueva Solicitud
          </button>
          
          <div class="relative w-full md:w-auto flex justify-end">
            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-6 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors no-print">
              <div v-if="fotoUsuario" class="h-10 w-10 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-slate-100">
                <img :src="`http://localhost:3007${fotoUsuario}`" class="w-full h-full object-cover" />
              </div>
              <div v-else class="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-lg ring-2 ring-slate-100 uppercase">
                {{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}
              </div>
              <div class="flex flex-col text-left">
                <span class="text-[10px] text-slate-400 font-black uppercase tracking-widest">Usuario Activo</span>
                <span class="text-base font-black text-slate-900 leading-tight">{{ nombreUsuario || 'Cargando...' }}</span>
              </div>
            </div>

            <!-- Dropdown Menu -->
            <div v-if="dropdownPerfilAbierto" class="absolute right-0 mt-14 w-64 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50 animate-in slide-in-from-top-2 duration-200 no-print">
              <div class="p-5 border-b border-slate-100 bg-slate-50 flex items-center gap-4">
                <div v-if="fotoUsuario" class="h-12 w-12 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-white shadow-sm shrink-0">
                  <img :src="`http://localhost:3007${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-12 w-12 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-xl ring-2 ring-white shadow-sm shrink-0 uppercase">
                  {{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}
                </div>
                <div>
                  <p class="font-black text-slate-800 text-sm leading-tight">{{ nombreUsuario || 'Cargando...' }}</p>
                  <p class="text-[10px] font-bold text-blue-500 uppercase tracking-widest mt-0.5">{{ rolNombre || 'Cargando...' }}</p>
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

      <div class="flex gap-8 items-start">
        <!-- Sidebar del Módulo -->
        <TicketsSidebar :counts="sidebarCounts" :activeFilter="filtroActivo" :ticketsList="unfilteredTicketsForCounts" @filter-changed="aplicarFiltro" @categorias-actualizadas="actualizarCategorias" class="shrink-0 rounded-3xl shadow-sm border border-slate-100 overflow-hidden" style="height: auto;" />

        <div class="flex-1 grid grid-cols-1 gap-8">
          <!-- TABLA DE TICKETS -->
        <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
          <div class="p-6 border-b border-slate-100 bg-slate-50/50 flex flex-col gap-4">
            <div class="flex justify-between items-center">
              <h2 class="text-xl font-black text-slate-800 uppercase tracking-tight">Historial de Tickets</h2>
              <button @click="fetchTickets" class="text-slate-400 hover:text-blue-500 transition-colors" title="Actualizar">
                🔄
              </button>
            </div>
            
            <!-- Barra de Herramientas: Búsqueda, Filtro y Orden -->
            <div class="flex flex-wrap gap-4 items-center justify-between bg-white p-3 rounded-xl border border-slate-200">
              <!-- Búsqueda -->
              <div class="flex-1 min-w-[250px] relative">
                <span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">🔍</span>
                <input v-model="searchTrm" type="text" placeholder="Buscador Tickets de Registro..." 
                  class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg outline-none focus:border-blue-500 text-sm font-medium text-slate-700 transition-colors">
              </div>
              
              <div class="flex gap-4 items-center flex-wrap">
                <!-- Filtro por Prioridad -->
                <div class="flex items-center gap-2">
                  <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Filtro:</span>
                  <select v-model="priorityFilter" class="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 outline-none focus:border-blue-500 text-sm font-medium text-slate-700 transition-colors cursor-pointer">
                    <option value="todas">Todas las prioridades</option>
                    <option value="Urgente">URGENTE</option>
                    <option value="Alta">ALTO</option>
                    <option value="Media">MEDIO</option>
                    <option value="Baja">BAJO</option>
                  </select>
                </div>

                <!-- Ordenar por -->
                <div class="flex items-center gap-2">
                  <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Ordenar:</span>
                  <select v-model="sortOption" class="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 outline-none focus:border-blue-500 text-sm font-medium text-slate-700 transition-colors cursor-pointer">
                    <option value="reciente">Primero más reciente</option>
                    <option value="antiguo">Primero Antiguo</option>
                    <option value="prioridad">Prioridad (de Alta a Baja)</option>
                    <option value="actualizado">Actualizado recientemente</option>
                  </select>
                </div>
              </div>
            </div>
          </div>
          
          <div v-if="ticketsPaginados.length === 0" class="p-8 text-center text-slate-500 font-medium">
            No se encontraron tickets con los filtros actuales.
          </div>
          <div class="flex flex-col gap-4 p-6 bg-slate-50/50" v-else>
            <TicketCard v-for="ticket in ticketsPaginados" :key="ticket.id" :ticket="ticket" @ver-detalle="verDetalle" />
          </div>
          
          <!-- Paginación -->
          <div class="flex justify-between items-center p-6 bg-white border-t border-slate-100 rounded-b-3xl" v-if="totalPaginas > 1">
            <span class="text-sm font-medium text-slate-500">Mostrando página {{ paginaActual }} de {{ totalPaginas }} ({{ misTickets.length }} tickets)</span>
            <div class="flex items-center gap-2">
              <button @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1" class="px-3 py-1 rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 transition-colors text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed">Anterior</button>
              
              <button v-for="pag in totalPaginas" :key="pag" @click="cambiarPagina(pag)"
                :class="['px-3 py-1 rounded-lg shadow-sm text-sm font-bold transition-all', pag === paginaActual ? 'bg-purple-600 text-white shadow-purple-200' : 'border border-slate-200 text-slate-500 hover:bg-slate-50']">
                {{ pag }}
              </button>

              <button @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas" class="px-3 py-1 rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 transition-colors text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed">Siguiente</button>
            </div>
          </div>
        </div>
      </div>
      </div>

    <!-- Modal Perfil -->
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
                <img :src="`http://localhost:3007${fotoUsuario}`" class="w-full h-full object-cover" />
              </div>
              <div v-else class="h-20 w-20 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-3xl ring-4 ring-slate-100 uppercase mb-4 shadow-lg">
                {{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}
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

    <!-- Modal Nueva Solicitud -->
    <div v-if="mostrarModal" class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 overflow-y-auto">
      <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 w-full max-w-md my-8">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50 rounded-t-3xl">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">Nueva Solicitud</h3>
          </div>
          <button @click="cerrarModal" class="text-slate-400 hover:text-red-500 transition-colors">
            ❌
          </button>
        </header>

        <div class="p-8">
          <form @submit.prevent="crearTicket" class="space-y-5">
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Número de Identidad</label>
              <input v-model="nuevoTicket.identidad" type="text" placeholder="Ej: 0801-1990-12345" required
                class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-blue-500 text-slate-700 font-medium transition-colors">
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Tipo de Solicitud</label>
                <select v-model="nuevoTicket.tipo" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-blue-500 text-slate-700 font-medium transition-colors">
                  <option v-for="cat in categoriasActivas" :key="cat.id" :value="cat.nombre">{{ cat.nombre }}</option>
                </select>
              </div>
              <div>
                <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Prioridad</label>
                <select v-model="nuevoTicket.prioridad" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-blue-500 text-slate-700 font-medium transition-colors">
                  <option value="Baja">Baja</option>
                  <option value="Media">Media</option>
                  <option value="Alta">Alta</option>
                  <option value="Urgente">Urgente</option>
                </select>
              </div>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Tema / Asunto</label>
              <input v-model="nuevoTicket.tema" type="text" placeholder="Breve resumen" required
                class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-blue-500 text-slate-700 font-medium transition-colors">
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Descripción</label>
              <textarea v-model="nuevoTicket.descripcion" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-blue-500 text-slate-700 transition-colors" rows="4" placeholder="Detalla tu solicitud aquí..." required></textarea>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Subir Archivo (Opcional)</label>
              <input type="file" ref="fileInputRef" @change="handleFileUpload"
                class="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-blue-500 text-slate-700 text-sm transition-colors cursor-pointer">
            </div>
            
            <div class="flex justify-end gap-3 pt-4 border-t border-slate-100 mt-6">
              <button type="button" @click="cerrarModal" class="px-6 py-3 text-slate-400 font-bold uppercase text-xs">Cancelar</button>
              <button type="submit" :disabled="loading" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-black uppercase text-xs shadow-lg shadow-blue-200 hover:bg-blue-700 transition-all disabled:opacity-50">
                {{ loading ? 'Enviando...' : 'Enviar Solicitud' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import TicketCard from '~/components/TicketCard.vue'

const router = useRouter()

// Variables de sesión y layout
const nombreUsuario = ref('')
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const fotoUsuario = ref(null)
const menuUsuario = ref([])

// Variables del módulo
const mostrarModal = ref(false)
const loading = ref(false)
const misTickets = ref([])
const todosLosTickets = ref([])
const sidebarCounts = ref({
  todas: 0,
  misEntradas: 0,
  asignado: 0,
  sinAsignacion: 0,
  abierto: 0,
  enProgreso: 0,
  pendiente: 0,
  resuelto: 0,
  cerrado: 0
})

// Variables de Paginación
const paginaActual = ref(1)
const ticketsPorPagina = ref(8)

const ticketsPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * ticketsPorPagina.value
  return misTickets.value.slice(inicio, inicio + ticketsPorPagina.value)
})

const totalPaginas = computed(() => Math.ceil(misTickets.value.length / ticketsPorPagina.value) || 1)

const cambiarPagina = (pag) => {
  if (pag >= 1 && pag <= totalPaginas.value) {
    paginaActual.value = pag
  }
}

const nuevoTicket = ref({
  usuario_id: null,
  identidad: '',
  tipo: 'Vacaciones',
  prioridad: 'Media',
  tema: '',
  descripcion: ''
})
const archivoTicket = ref(null)
const fileInputRef = ref(null)

const filtroActivo = ref('todas')
const searchTrm = ref('')
const sortOption = ref('reciente')
const priorityFilter = ref('todas')
const unfilteredTicketsForCounts = ref([])

const categoriasActivas = ref([])

const actualizarCategorias = (categorias) => {
  categoriasActivas.value = categorias.filter(c => c.activa)
  if (categoriasActivas.value.length > 0 && !categoriasActivas.value.find(c => c.nombre === nuevoTicket.value.tipo)) {
    nuevoTicket.value.tipo = categoriasActivas.value[0].nombre
  }
}

watch([searchTrm, sortOption, priorityFilter], () => {
  filtrarTickets()
})

const aplicarFiltro = (filtro) => {
  filtroActivo.value = filtro
  filtrarTickets()
}

const filtrarTickets = () => {
  let data = todosLosTickets.value
  
  const uid = nuevoTicket.value.usuario_id
  
  if (rolID.value != 1) {
    data = data.filter(t => t.asignado_usuario_id == uid)
  }

  // 1. Filtro de Sidebar
  if (filtroActivo.value === 'todas') {
    // se mantiene la data
  } else if (filtroActivo.value === 'misEntradas') {
    data = data.filter(t => t.usuario_id == uid)
  } else if (filtroActivo.value === 'asignado') {
    data = data.filter(t => t.asignado_usuario_id == uid)
  } else if (filtroActivo.value === 'sinAsignacion') {
    data = data.filter(t => !t.asignado_usuario_id && !t.asignado_empleado_id)
  } else if (filtroActivo.value.startsWith('estado-')) {
    const estado = filtroActivo.value.substring(7)
    if (estado === 'Pendiente') {
      data = data.filter(t => !t.estado || t.estado === 'Pendiente')
    } else {
      data = data.filter(t => t.estado === estado)
    }
  } else if (filtroActivo.value.startsWith('categoria-')) {
    const categoria = filtroActivo.value.substring(10)
    data = data.filter(t => t.tipo === categoria || t.Categoria === categoria)
  }

  // 2. Filtro de Prioridad
  if (priorityFilter.value !== 'todas') {
    data = data.filter(t => (t.prioridad || 'Media').toUpperCase() === priorityFilter.value.toUpperCase())
  }

  // 3. Filtro de Búsqueda
  if (searchTrm.value) {
    const term = searchTrm.value.toLowerCase()
    data = data.filter(t => 
      (t.tema || '').toLowerCase().includes(term) ||
      (t.descripcion || '').toLowerCase().includes(term) ||
      (t.empleado_nombre || '').toLowerCase().includes(term) ||
      (t.empleado_apellido || '').toLowerCase().includes(term) ||
      (t.identidad || '').toLowerCase().includes(term) ||
      (t.tipo || '').toLowerCase().includes(term)
    )
  }

  // 4. Ordenamiento
  data = data.sort((a, b) => {
    if (sortOption.value === 'reciente') {
      return new Date(b.fecha_creacion) - new Date(a.fecha_creacion)
    } else if (sortOption.value === 'antiguo') {
      return new Date(a.fecha_creacion) - new Date(b.fecha_creacion)
    } else if (sortOption.value === 'prioridad') {
       const pWeights = { 'URGENTE': 4, 'ALTA': 3, 'MEDIA': 2, 'BAJA': 1 }
       const pA = pWeights[(a.prioridad || 'Media').toUpperCase()] || 0
       const pB = pWeights[(b.prioridad || 'Media').toUpperCase()] || 0
       return pB - pA
    } else if (sortOption.value === 'actualizado') {
       const dA = new Date(a.updated_at || a.fecha_creacion)
       const dB = new Date(b.updated_at || b.fecha_creacion)
       return dB - dA
    }
    return 0
  })

  misTickets.value = data
  paginaActual.value = 1
}

const handleFileUpload = (event) => {
  archivoTicket.value = event.target.files[0]
}

const abrirModalNuevo = () => {
  if (!nuevoTicket.value.tipo && categoriasActivas.value.length > 0) {
    nuevoTicket.value.tipo = categoriasActivas.value[0].nombre
  }
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
  nuevoTicket.value.identidad = ''
  nuevoTicket.value.descripcion = ''
  nuevoTicket.value.tipo = categoriasActivas.value.length > 0 ? categoriasActivas.value[0].nombre : ''
  nuevoTicket.value.tema = ''
  nuevoTicket.value.prioridad = 'Media'
  archivoTicket.value = null
  if (fileInputRef.value) fileInputRef.value.value = ''
}

const verDetalle = (id) => {
  router.push({ path: '/TicketDetail', query: { id } })
}

const fetchTickets = async () => {
  try {
    const response = await axios.get('http://localhost:3007/api/tickets/lista')
    const data = response.data
    todosLosTickets.value = data

    const uid = nuevoTicket.value.usuario_id;
    let countsData = data;
    if (rolID.value != 1) {
      countsData = data.filter(t => t.asignado_usuario_id == uid);
    }
    
    unfilteredTicketsForCounts.value = countsData

    sidebarCounts.value = {
      todas: countsData.length,
      misEntradas: countsData.filter(t => t.usuario_id == uid).length,
      asignado: countsData.filter(t => t.asignado_usuario_id == uid).length,
      sinAsignacion: countsData.filter(t => !t.asignado_usuario_id && !t.asignado_empleado_id).length,
      abierto: countsData.filter(t => t.estado === 'Abierto').length,
      enProgreso: countsData.filter(t => t.estado === 'En Progreso').length,
      pendiente: countsData.filter(t => (!t.estado || t.estado === 'Pendiente')).length,
      resuelto: countsData.filter(t => t.estado === 'Resuelto').length,
      cerrado: countsData.filter(t => t.estado === 'Cerrado').length
    }

    filtrarTickets()
  } catch (error) { 
    console.error("Error al cargar tickets:", error) 
  }
}

const crearTicket = async () => {
  if (!nuevoTicket.value.descripcion.trim() || !nuevoTicket.value.tema.trim()) {
    alert("Por favor ingrese un tema y una descripción.")
    return
  }
  
  try {
    loading.value = true
    
    const formData = new FormData()
    formData.append('usuario_id', nuevoTicket.value.usuario_id || '')
    formData.append('identidad', nuevoTicket.value.identidad)
    formData.append('tipo', nuevoTicket.value.tipo)
    formData.append('prioridad', nuevoTicket.value.prioridad)
    formData.append('tema', nuevoTicket.value.tema)
    formData.append('descripcion', nuevoTicket.value.descripcion)
    
    if (archivoTicket.value) {
      formData.append('archivo', archivoTicket.value)
    }

    await axios.post('http://localhost:3007/api/tickets/crear', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    
    cerrarModal()
    await fetchTickets()
    alert("✅ Ticket enviado con éxito")
  } catch (error) { 
    console.error(error)
    alert("❌ Error al enviar el ticket") 
  } finally {
    loading.value = false
  }
}

const claseEstado = (estado) => {
  const e = estado || 'Pendiente'
  if (e === 'Abierto') return 'bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-blue-200'
  if (e === 'En Progreso') return 'bg-purple-100 text-purple-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-purple-200'
  if (e === 'Pendiente') return 'bg-yellow-100 text-yellow-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-yellow-200'
  if (e === 'Resuelto') return 'bg-green-100 text-green-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-green-200'
  if (e === 'Cerrado') return 'bg-gray-100 text-gray-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-gray-200'
  return 'bg-slate-100 text-slate-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-slate-200'
}

const clasePrioridad = (prioridad) => {
  const p = prioridad || 'Media'
  if (p === 'Urgente') return 'text-red-700 font-black'
  if (p === 'Alta') return 'text-red-600 font-bold'
  if (p === 'Baja') return 'text-green-600 font-bold'
  return 'text-yellow-600 font-bold'
}

const formatearFecha = (fechaStr) => {
  if (!fechaStr) return '-'
  return new Date(fechaStr).toLocaleDateString('es-HN', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

onMounted(async () => {
  // Inicializar variables de sesión
  const uId = localStorage.getItem('usuarioID')
  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Invitado'
  rolID.value = localStorage.getItem('usuarioRol') || 3
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null
  
  nuevoTicket.value.usuario_id = uId

  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }
  
  try {
    // Cargar menú dinámico
    const m = await axios.get(`http://localhost:3007/api/menu/${rolID.value}`)
    menuUsuario.value = m.data
  } catch(e) {
    console.error("Error al cargar menú", e)
  }

  // Cargar tickets
  await fetchTickets()
})

const logout = () => { 
  localStorage.clear()
  navigateTo('/login') 
}
</script>