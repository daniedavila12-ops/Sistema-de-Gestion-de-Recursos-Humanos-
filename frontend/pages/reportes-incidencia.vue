<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <!-- SIDEBAR DINÁMICO -->
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
          <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Reportes de Incidencia</h1>
          <p class="text-slate-500 mt-1 font-medium italic">Gestiona faltas, incidentes y reportes del personal</p>
        </div>
        <div class="flex items-center gap-6">
          
          <button v-if="permisosModulo.puedeCrear" @click="abrirModalNuevo" class="bg-red-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-red-700 transition-all shadow-lg shadow-red-200">
            + Nuevo Reporte
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
            <div v-if="dropdownPerfilAbierto" @click="dropdownPerfilAbierto = false" class="fixed inset-0 z-40"></div>
          </div>
        </div>
      </header>

      <div class="flex gap-8 items-start">
        <!-- Sidebar del Módulo -->
        <ReportesSidebar :counts="sidebarCounts" :activeFilter="filtroActivo" :reportesList="unfilteredReportesForCounts" @filter-changed="aplicarFiltro" @categorias-actualizadas="actualizarCategorias" class="shrink-0 rounded-3xl shadow-sm border border-slate-100 overflow-hidden" style="height: auto;" />

        <div class="flex-1 grid grid-cols-1 gap-8">
          <!-- TABLA DE REPORTES -->
          <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
            <div class="p-6 border-b border-slate-100 bg-slate-50/50 flex flex-col gap-4">
              <div class="flex justify-between items-center">
                <h2 class="text-xl font-black text-slate-800 uppercase tracking-tight">Historial de Reportes</h2>
                <button @click="fetchReportes" class="text-slate-400 hover:text-red-500 transition-colors" title="Actualizar">
                  🔄
                </button>
              </div>
              
              <!-- Barra de Herramientas -->
              <div class="flex flex-wrap gap-4 items-center justify-between bg-white p-3 rounded-xl border border-slate-200">
                <!-- Búsqueda -->
                <div class="flex-1 min-w-[250px] relative">
                  <span class="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400">🔍</span>
                  <input v-model="searchTrm" type="text" placeholder="Buscador Reportes de Incidencia..." 
                    class="w-full pl-10 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-lg outline-none focus:border-red-500 text-sm font-medium text-slate-700 transition-colors">
                </div>
                
                <div class="flex gap-4 items-center flex-wrap">
                  <!-- Filtro por Prioridad -->
                  <div class="flex items-center gap-2">
                    <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Filtro:</span>
                    <select v-model="priorityFilter" class="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 outline-none focus:border-red-500 text-sm font-medium text-slate-700 transition-colors cursor-pointer">
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
                    <select v-model="sortOption" class="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 outline-none focus:border-red-500 text-sm font-medium text-slate-700 transition-colors cursor-pointer">
                      <option value="reciente">Primero más reciente</option>
                      <option value="antiguo">Primero Antiguo</option>
                      <option value="prioridad">Prioridad (de Alta a Baja)</option>
                      <option value="actualizado">Actualizado recientemente</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>
            
            <div v-if="reportesPaginados.length === 0" class="p-8 text-center text-slate-500 font-medium">
              No se encontraron reportes con los filtros actuales.
            </div>
            <div class="flex flex-col gap-4 p-6 bg-slate-50/50" v-else>
              <!-- Cards Integradas -->
              <div v-for="reporte in reportesPaginados" :key="reporte.id" class="bg-white rounded-2xl p-4 shadow-sm hover:shadow-md transition-shadow flex flex-col gap-3 border border-slate-100">
                <div class="flex items-center justify-between">
                  <div class="flex items-center gap-3">
                    <span class="font-bold text-slate-700 text-sm">#INC-{{ String(reporte.id).padStart(3, '0') }}</span>
                    <span :class="['px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-widest', prioridadClass(reporte.prioridad)]">
                      {{ reporte.prioridad || 'Media' }}
                    </span>
                    <span :class="['px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-widest', claseEstado(reporte.estado)]">
                      {{ reporte.estado || 'Pendiente' }}
                    </span>
                  </div>
                  <div class="h-8 w-8 rounded-full overflow-hidden border border-slate-200 shrink-0" :title="`Asignado a: ${reporte.asignado_usuario_nombre || 'Nadie'}`">
                    <img v-if="reporte.asignado_usuario_foto" :src="`http://localhost:3007${reporte.asignado_usuario_foto}`" class="w-full h-full object-cover" />
                    <div v-else class="w-full h-full bg-slate-200 flex items-center justify-center text-slate-500 font-bold text-xs uppercase">
                      {{ (reporte.asignado_usuario_nombre || '?').charAt(0) }}
                    </div>
                  </div>
                </div>

                <div>
                  <h3 class="text-slate-800 font-semibold text-base leading-tight cursor-pointer hover:text-red-600 transition-colors" @click="verDetalle(reporte.id)">
                    {{ reporte.tema || 'Sin tema' }}
                  </h3>
                  <p class="text-slate-500 text-sm mt-1 line-clamp-2 truncate">Reportado a: {{ reporte.empleado_nombre || 'Desconocido' }} {{ reporte.empleado_apellido || '' }} - {{ reporte.descripcion }}</p>
                </div>

                <div class="flex items-center gap-4 text-xs text-slate-400 font-medium mt-1">
                  <div class="flex items-center gap-1">
                    <div class="h-4 w-4 rounded-full overflow-hidden bg-slate-200 flex items-center justify-center shrink-0 border border-slate-300">
                      <span class="text-[8px] text-slate-600 font-bold uppercase">{{ (reporte.jefe_reporta || '?').charAt(0) }}</span>
                    </div>
                    <span>{{ reporte.jefe_reporta || 'Usuario' }}</span>
                  </div>
                  <div class="flex items-center gap-1">
                    <span>📁</span>
                    <span>{{ reporte.categoria || 'General' }}</span>
                  </div>
                  <div class="flex items-center gap-1">
                    <span>⏱️</span>
                    <span>{{ formatearFecha(reporte.fecha_creacion) }}</span>
                  </div>
                  <div class="flex items-center gap-1">
                    <span>💬</span>
                    <span>{{ reporte.respuestas_count || 0 }}</span>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Paginación -->
            <div class="flex justify-between items-center p-6 bg-white border-t border-slate-100 rounded-b-3xl" v-if="totalPaginas > 1">
              <span class="text-sm font-medium text-slate-500">Mostrando página {{ paginaActual }} de {{ totalPaginas }} ({{ misReportes.length }} reportes)</span>
              <div class="flex items-center gap-2">
                <button @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1" class="px-3 py-1 rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 transition-colors text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed">Anterior</button>
                
                <button v-for="pag in totalPaginas" :key="pag" @click="cambiarPagina(pag)"
                  :class="['px-3 py-1 rounded-lg shadow-sm text-sm font-bold transition-all', pag === paginaActual ? 'bg-red-600 text-white shadow-red-200' : 'border border-slate-200 text-slate-500 hover:bg-slate-50']">
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

    <!-- Modal Nuevo Reporte -->
    <div v-if="mostrarModal" class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 overflow-y-auto">
      <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 w-full max-w-md my-8">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-red-50 rounded-t-3xl">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">Nuevo Reporte</h3>
          </div>
          <button @click="cerrarModal" class="text-slate-400 hover:text-red-500 transition-colors">
            ❌
          </button>
        </header>

        <div class="p-8">
          <form @submit.prevent="crearReporte" class="space-y-5">
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Número de Identidad (Reportado)</label>
              <input v-model="nuevoReporte.identidad" type="text" placeholder="Ej: 0801-1990-12345" required
                class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-red-500 text-slate-700 font-medium transition-colors">
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Categoría</label>
                <select v-model="nuevoReporte.categoria" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-red-500 text-slate-700 font-medium transition-colors">
                  <option v-for="cat in categoriasActivas" :key="cat.id" :value="cat.nombre">{{ cat.nombre }}</option>
                </select>
              </div>
              <div>
                <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Prioridad</label>
                <select v-model="nuevoReporte.prioridad" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-red-500 text-slate-700 font-medium transition-colors">
                  <option value="Baja">Baja</option>
                  <option value="Media">Media</option>
                  <option value="Alta">Alta</option>
                  <option value="Urgente">Urgente</option>
                </select>
              </div>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Tema / Asunto</label>
              <input v-model="nuevoReporte.tema" type="text" placeholder="Breve resumen de la incidencia" required
                class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-red-500 text-slate-700 font-medium transition-colors">
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Descripción Detallada</label>
              <textarea v-model="nuevoReporte.descripcion" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-red-500 text-slate-700 transition-colors" rows="4" placeholder="Detalla la incidencia aquí..." required></textarea>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase mb-2">Evidencia (Opcional)</label>
              <input type="file" ref="fileInputRef" @change="handleFileUpload"
                class="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-red-500 text-slate-700 text-sm transition-colors cursor-pointer">
            </div>
            
            <div class="flex justify-end gap-3 pt-4 border-t border-slate-100 mt-6">
              <button type="button" @click="cerrarModal" class="px-6 py-3 text-slate-400 font-bold uppercase text-xs">Cancelar</button>
              <button type="submit" :disabled="loading" class="px-8 py-3 bg-red-600 text-white rounded-xl font-black uppercase text-xs shadow-lg shadow-red-200 hover:bg-red-700 transition-all disabled:opacity-50">
                {{ loading ? 'Enviando...' : 'Crear Reporte' }}
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
import jsPDF from 'jspdf'
import 'jspdf-autotable'

const router = useRouter()

// Variables de sesión y layout
const nombreUsuario = ref('')
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const fotoUsuario = ref(null)
const usuarioActualId = ref(null)
const menuUsuario = ref([])
const dropdownPerfilAbierto = ref(false)
const modalAbiertoPerfil = ref(false)

const formPassword = ref({ actual: '', nueva: '', confirmar: '' })
const loadingPassword = ref(false)
const fileInputPerfil = ref(null)

const permisosModulo = ref({ puedeVer: 1, puedeCrear: 1, puedeEditar: 1, puedeEliminar: 1 })

const triggerFileInputPerfil = () => { fileInputPerfil.value.click() }
const uploadFotoPerfil = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const formData = new FormData()
  formData.append('foto', file)
  try {
    const res = await axios.post(`http://localhost:3007/api/auth/${usuarioActualId.value}/foto`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    fotoUsuario.value = res.data.fotoUrl
    localStorage.setItem('usuarioFoto', res.data.fotoUrl)
    alert('✅ ' + res.data.mensaje)
  } catch (err) {
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
    const res = await axios.put(`http://localhost:3007/api/auth/${usuarioActualId.value}/password`, {
      actual: formPassword.value.actual,
      nueva: formPassword.value.nueva
    })
    alert('✅ ' + res.data.mensaje)
    cerrarModalPerfil()
  } catch (err) {
    alert('❌ ' + (err.response?.data?.error || 'Error al cambiar contraseña'))
  } finally {
    loadingPassword.value = false
  }
}

// Variables del Módulo Reportes
const mostrarModal = ref(false)
const loading = ref(false)
const misReportes = ref([])
const todosLosReportes = ref([])

const unfilteredReportesForCounts = ref([])

const categoriasActivas = ref([])

const actualizarCategorias = (categorias) => {
  categoriasActivas.value = categorias.filter(c => c.activa)
  if (categoriasActivas.value.length > 0 && !categoriasActivas.value.find(c => c.nombre === nuevoReporte.value.categoria)) {
    nuevoReporte.value.categoria = categoriasActivas.value[0].nombre
  }
}

const sidebarCounts = ref({
  todas: 0,
  misEntradas: 0,
  asignado: 0,
  sinAsignacion: 0,
  pendiente: 0,
  enProceso: 0,
  resuelto: 0,
  cancelado: 0
})

const paginaActual = ref(1)
const ticketsPorPagina = ref(8)

const reportesPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * ticketsPorPagina.value
  return misReportes.value.slice(inicio, inicio + ticketsPorPagina.value)
})

const totalPaginas = computed(() => Math.ceil(misReportes.value.length / ticketsPorPagina.value) || 1)

const cambiarPagina = (pag) => {
  if (pag >= 1 && pag <= totalPaginas.value) {
    paginaActual.value = pag
  }
}

const nuevoReporte = ref({
  identidad: '',
  categoria: '',
  prioridad: 'Media',
  tema: '',
  descripcion: ''
})
const archivoReporte = ref(null)
const fileInputRef = ref(null)

const filtroActivo = ref('todas')
const searchTrm = ref('')
const sortOption = ref('reciente')
const priorityFilter = ref('todas')

watch([searchTrm, sortOption, priorityFilter], () => {
  filtrarReportes()
})

const aplicarFiltro = (filtro) => {
  filtroActivo.value = filtro
  filtrarReportes()
}

const obtenerConteoCategoria = (cat) => {
  let data = todosLosReportes.value
  if (rolID.value != 1 && rolID.value != 2) {
    data = data.filter(r => r.jefe_reporta === nombreUsuario.value || r.asignado_usuario_id == usuarioActualId.value)
  }
  return data.filter(r => r.categoria === cat).length
}

const filtrarReportes = () => {
  let data = todosLosReportes.value

  if (rolID.value !== 1 && rolID.value !== 2) {
    data = data.filter(r => r.jefe_reporta === nombreUsuario.value || r.asignado_usuario_id === usuarioActualId.value)
  }

  if (filtroActivo.value === 'todas') {
    //
  } else if (filtroActivo.value === 'misEntradas') {
    data = data.filter(r => r.jefe_reporta === nombreUsuario.value)
  } else if (filtroActivo.value === 'asignado') {
    data = data.filter(r => r.asignado_usuario_id === usuarioActualId.value)
  } else if (filtroActivo.value === 'sinAsignacion') {
    data = data.filter(r => !r.asignado_usuario_id)
  } else if (filtroActivo.value.startsWith('estado-')) {
    const est = filtroActivo.value.substring(7)
    if (est === 'Pendiente') {
      data = data.filter(r => !r.estado || r.estado === 'Pendiente')
    } else if (est === 'Cancelado') {
      data = data.filter(r => r.estado === 'Cancelado' || r.estado === 'Desestimado')
    } else {
      data = data.filter(r => r.estado === est)
    }
  } else if (filtroActivo.value.startsWith('categoria-')) {
    const cat = filtroActivo.value.substring(10)
    data = data.filter(r => r.categoria === cat)
  }

  if (priorityFilter.value !== 'todas') {
    data = data.filter(r => (r.prioridad || 'Media').toUpperCase() === priorityFilter.value.toUpperCase())
  }

  if (searchTrm.value) {
    const term = searchTrm.value.toLowerCase()
    data = data.filter(r => 
      (r.tema || '').toLowerCase().includes(term) ||
      (r.descripcion || '').toLowerCase().includes(term) ||
      (r.empleado_nombre || '').toLowerCase().includes(term) ||
      (r.empleado_apellido || '').toLowerCase().includes(term) ||
      (r.identidad || '').toLowerCase().includes(term) ||
      (r.jefe_reporta || '').toLowerCase().includes(term)
    )
  }

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

  misReportes.value = data
  paginaActual.value = 1
}

const handleFileUpload = (event) => {
  archivoReporte.value = event.target.files[0]
}

const abrirModalNuevo = () => {
  if (!nuevoReporte.value.categoria && categoriasActivas.value.length > 0) {
    nuevoReporte.value.categoria = categoriasActivas.value[0].nombre
  }
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
  nuevoReporte.value = {
    identidad: '',
    categoria: categoriasActivas.value.length > 0 ? categoriasActivas.value[0].nombre : '',
    prioridad: 'Media',
    tema: '',
    descripcion: ''
  }
  archivoReporte.value = null
  if (fileInputRef.value) fileInputRef.value.value = ''
}

const verDetalle = (id) => {
  router.push({ path: '/TicketDetailReportesIncidencia', query: { id } })
}

const fetchReportes = async () => {
  try {
    const response = await axios.get('http://localhost:3007/api/reportes-incidencia/lista')
    const data = response.data
    todosLosReportes.value = data

    let countsData = data
    if (rolID.value !== 1 && rolID.value !== 2) {
      countsData = data.filter(r => r.jefe_reporta === nombreUsuario.value || r.asignado_usuario_id === usuarioActualId.value)
    }

    unfilteredReportesForCounts.value = countsData

    sidebarCounts.value = {
      todas: countsData.length,
      misEntradas: countsData.filter(r => r.jefe_reporta === nombreUsuario.value).length,
      asignado: countsData.filter(r => r.asignado_usuario_id === usuarioActualId.value).length,
      sinAsignacion: countsData.filter(r => !r.asignado_usuario_id).length,
      pendiente: countsData.filter(r => !r.estado || r.estado === 'Pendiente').length,
      enProceso: countsData.filter(r => r.estado === 'En Proceso').length,
      resuelto: countsData.filter(r => r.estado === 'Resuelto').length,
      cancelado: countsData.filter(r => r.estado === 'Cancelado' || r.estado === 'Desestimado').length
    }

    filtrarReportes()
  } catch (error) { 
    console.error("Error al cargar reportes:", error) 
  }
}

const crearReporte = async () => {
  if (!nuevoReporte.value.descripcion.trim() || !nuevoReporte.value.tema.trim()) {
    alert("Por favor ingrese un tema y una descripción.")
    return
  }
  
  try {
    loading.value = true
    
    const formData = new FormData()
    formData.append('jefe_reporta', nombreUsuario.value)
    formData.append('identidad', nuevoReporte.value.identidad)
    formData.append('categoria', nuevoReporte.value.categoria)
    formData.append('prioridad', nuevoReporte.value.prioridad)
    formData.append('tema', nuevoReporte.value.tema)
    formData.append('descripcion', nuevoReporte.value.descripcion)
    
    if (archivoReporte.value) {
      formData.append('archivo', archivoReporte.value)
    }

    await axios.post('http://localhost:3007/api/reportes-incidencia/crear', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    
    cerrarModal()
    await fetchReportes()
    alert("✅ Reporte enviado con éxito")
  } catch (error) { 
    console.error(error)
    alert("❌ Error al enviar el reporte") 
  } finally {
    loading.value = false
  }
}

const claseEstado = (estado) => {
  const e = estado || 'Pendiente'
  if (e === 'En Proceso') return 'bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-blue-200'
  if (e === 'Pendiente') return 'bg-orange-100 text-orange-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-orange-200'
  if (e === 'Resuelto') return 'bg-green-100 text-green-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-green-200'
  if (e === 'Cancelado' || e === 'Desestimado') return 'bg-slate-100 text-slate-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-slate-200'
  return 'bg-slate-100 text-slate-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-slate-200'
}

const prioridadClass = (prioridad) => {
  const p = (prioridad || 'Media').toUpperCase()
  if (p === 'URGENTE') return 'text-red-700 font-black bg-red-50 border border-red-100'
  if (p === 'ALTA') return 'text-orange-600 font-bold bg-orange-50 border border-orange-100'
  if (p === 'BAJA') return 'text-green-600 font-bold bg-green-50 border border-green-100'
  return 'text-yellow-600 font-bold bg-yellow-50 border border-yellow-100' // Media
}

const formatearFecha = (fechaStr) => {
  if (!fechaStr) return '-'
  return new Date(fechaStr).toLocaleDateString('es-HN', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

const generarPDF = () => {
  const doc = new jsPDF('landscape')

  doc.setFontSize(22)
  doc.setTextColor(220, 38, 38) // red-600
  doc.text('Reportes de Incidencia', 14, 22)
  
  doc.setFontSize(10)
  doc.setTextColor(100, 116, 139) // slate-500
  doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 30)
  doc.text(`Filtro activo: ${filtroActivo.value.toUpperCase()}`, 14, 36)

  const headers = [['ID', 'Prioridad', 'Estado', 'Reportado A', 'Tema', 'Categoría', 'Fecha Creación']]
  const data = reportesPaginados.value.map(r => [
    `#INC-${String(r.id).padStart(3, '0')}`,
    (r.prioridad || 'Media').toUpperCase(),
    (r.estado || 'Pendiente').toUpperCase(),
    `${r.empleado_nombre || ''} ${r.empleado_apellido || ''}`.trim() || 'Desconocido',
    r.tema || 'Sin tema',
    r.categoria || 'General',
    formatearFecha(r.fecha_creacion)
  ])

  doc.autoTable({
    startY: 42,
    head: headers,
    body: data,
    theme: 'grid',
    headStyles: {
      fillColor: [220, 38, 38], // red-600
      textColor: [255, 255, 255],
      fontStyle: 'bold',
      halign: 'center'
    },
    bodyStyles: {
      halign: 'center'
    },
    columnStyles: {
      4: { halign: 'left' } // El tema alineado a la izquierda para mejor lectura
    },
    alternateRowStyles: {
      fillColor: [248, 250, 252] // slate-50
    }
  })

  doc.save('Historial_Reportes_Incidencia.pdf')
}

onMounted(async () => {
  const uId = localStorage.getItem('usuarioID');
  usuarioActualId.value = uId ? parseInt(uId, 10) : null;
  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Invitado'
  const rol = localStorage.getItem('usuarioRol');
  rolID.value = rol ? parseInt(rol, 10) : 3;
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null

  if (rolID.value === 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value === 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }
  
  try {
    const resPermisos = await axios.get(`http://localhost:3007/api/roles/${rolID.value}/permisos`)
    const moduloActual = resPermisos.data.find(p => p.modulo_nombre.toLowerCase().includes('reporte') || p.modulo_nombre.toLowerCase().includes('incidencia'))
    if (moduloActual) {
      permisosModulo.value = moduloActual
    }
  } catch (e) {
    console.error("Error al cargar permisos", e)
  }

  try {
    const m = await axios.get(`http://localhost:3007/api/menu/${rolID.value}`)
    menuUsuario.value = m.data
  } catch(e) {
    console.error("Error al cargar menú", e)
  }

  await fetchReportes()
})

const logout = () => { 
  localStorage.clear()
  navigateTo('/login') 
}
</script>