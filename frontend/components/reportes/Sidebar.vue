<template>
  <aside class="w-72 bg-white flex flex-col font-sans overflow-y-auto select-none" style="scrollbar-width: thin; scrollbar-color: #e2e8f0 transparent;">

    <!-- Vistas -->
    <div class="px-4 pt-5 pb-4">
      <h3 class="text-[10px] font-extrabold text-slate-400 uppercase tracking-[0.12em] mb-3 px-2 flex items-center gap-2">
        <svg class="w-3 h-3 text-slate-300" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/></svg>
        Vistas
      </h3>
      <ul class="space-y-0.5">
        <li v-for="view in viewItems" :key="view.key">
          <a href="#" @click.prevent="$emit('filter-changed', view.key)" 
            :class="[
              'flex items-center justify-between px-3 py-2.5 rounded-xl transition-all duration-200 group',
              activeFilter === view.key 
                ? 'bg-gradient-to-r from-red-50 to-rose-50 text-red-700 shadow-sm shadow-red-100/50 border border-red-100/60' 
                : 'text-slate-600 hover:bg-slate-50/80 border border-transparent'
            ]">
            <div class="flex items-center gap-2.5">
              <span :class="['text-sm transition-transform duration-200', activeFilter === view.key ? 'scale-110' : 'group-hover:scale-105']">{{ view.icon }}</span>
              <span class="text-[13px] font-semibold">{{ view.label }}</span>
            </div>
            <span :class="[
              'text-[10px] min-w-[22px] text-center px-1.5 py-0.5 rounded-md font-bold tabular-nums transition-colors duration-200',
              activeFilter === view.key 
                ? 'bg-red-100 text-red-700' 
                : 'bg-slate-100 text-slate-500'
            ]">{{ view.count }}</span>
          </a>
        </li>
      </ul>
    </div>

    <div class="h-px bg-gradient-to-r from-transparent via-slate-200 to-transparent mx-4"></div>

    <!-- Por Estatus -->
    <div class="px-4 pt-5 pb-4">
      <h3 class="text-[10px] font-extrabold text-slate-400 uppercase tracking-[0.12em] mb-3 px-2 flex items-center gap-2">
        <svg class="w-3 h-3 text-slate-300" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path stroke-linecap="round" d="M12 6v6l4 2"/></svg>
        Estado
      </h3>
      <ul class="space-y-0.5">
        <li v-for="status in statusItems" :key="status.key">
          <a href="#" @click.prevent="$emit('filter-changed', status.key)" 
            :class="[
              'flex items-center justify-between px-3 py-2.5 rounded-xl transition-all duration-200 group',
              activeFilter === status.key 
                ? 'bg-gradient-to-r from-red-50 to-rose-50 text-red-700 shadow-sm shadow-red-100/50 border border-red-100/60' 
                : 'text-slate-600 hover:bg-slate-50/80 border border-transparent'
            ]">
            <div class="flex items-center gap-2.5">
              <span :class="['w-2 h-2 rounded-full ring-2 transition-transform duration-200', status.dotClass, activeFilter === status.key ? 'scale-125' : 'group-hover:scale-110']"></span>
              <span class="text-[13px] font-semibold">{{ status.label }}</span>
            </div>
            <span :class="[
              'text-[10px] min-w-[22px] text-center px-1.5 py-0.5 rounded-md font-bold tabular-nums transition-colors duration-200',
              activeFilter === status.key 
                ? 'bg-red-100 text-red-700' 
                : 'bg-slate-100 text-slate-500'
            ]">{{ status.count }}</span>
          </a>
        </li>
      </ul>
    </div>

    <div class="h-px bg-gradient-to-r from-transparent via-slate-200 to-transparent mx-4"></div>

    <!-- Categorías -->
    <div class="px-4 pt-5 pb-6 flex-1">
      <div class="flex items-center justify-between mb-3 px-2">
        <h3 class="text-[10px] font-extrabold text-slate-400 uppercase tracking-[0.12em] flex items-center gap-2">
          <svg class="w-3 h-3 text-slate-300" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/></svg>
          Categorías
        </h3>
        <button @click="agregarCategoria" 
          class="w-5 h-5 rounded-lg bg-slate-100 flex items-center justify-center text-slate-400 hover:bg-red-500 hover:text-white transition-all duration-200 cursor-pointer hover:shadow-md hover:shadow-red-200/50 hover:scale-110" 
          title="Agregar Categoría">
          <svg class="w-3 h-3" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" d="M12 5v14m-7-7h14"/></svg>
        </button>
      </div>
      <ul class="space-y-0.5">
        <li v-for="cat in categoriasLista" :key="cat.id">
          <div 
            @click.prevent="$emit('filter-changed', 'categoria-' + cat.nombre)"
            class="group flex items-center justify-between px-3 py-2.5 rounded-xl transition-all duration-200 cursor-pointer"
            :class="[
              activeFilter === 'categoria-' + cat.nombre 
                ? 'bg-gradient-to-r from-red-50 to-rose-50 text-red-700 shadow-sm shadow-red-100/50 border border-red-100/60' 
                : 'text-slate-600 hover:bg-slate-50/80 border border-transparent'
            ]">
            <div class="flex items-center gap-2.5 flex-1 min-w-0" :class="{ 'opacity-40': !cat.activa }">
              <span :class="['text-sm transition-transform duration-200', activeFilter === 'categoria-' + cat.nombre ? 'scale-110' : 'group-hover:scale-105']">{{ cat.activa ? '📂' : '🔒' }}</span>
              <span class="text-[13px] font-semibold truncate">{{ cat.nombre }}</span>
            </div>
            <div class="flex items-center gap-1.5 shrink-0">
              <!-- Action buttons (appear on hover) -->
              <div class="flex items-center gap-0.5 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                <button @click.stop="editarCategoria(cat)" class="w-6 h-6 rounded-lg flex items-center justify-center text-slate-400 hover:text-amber-500 hover:bg-amber-50 transition-all" title="Editar">
                  <svg class="w-3 h-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/></svg>
                </button>
                <button @click.stop="toggleCategoria(cat)" class="w-6 h-6 rounded-lg flex items-center justify-center text-slate-400 hover:text-violet-500 hover:bg-violet-50 transition-all" :title="cat.activa ? 'Desactivar' : 'Activar'">
                  <svg v-if="cat.activa" class="w-3 h-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
                  <svg v-else class="w-3 h-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21"/></svg>
                </button>
              </div>
              <span :class="[
                'text-[10px] min-w-[22px] text-center px-1.5 py-0.5 rounded-md font-bold tabular-nums transition-colors duration-200',
                activeFilter === 'categoria-' + cat.nombre 
                  ? 'bg-red-100 text-red-700' 
                  : 'bg-slate-100 text-slate-500'
              ]">{{ getCategoryCount(cat.nombre) }}</span>
            </div>
          </div>
        </li>
        <li v-if="categoriasLista.length === 0" class="px-3 py-4 text-center">
          <p class="text-xs text-slate-400 font-medium">Sin categorías configuradas</p>
        </li>
      </ul>
    </div>
  </aside>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

const props = defineProps({
  counts: {
    type: Object,
    default: () => ({
      todas: 0,
      misEntradas: 0,
      asignado: 0,
      sinAsignacion: 0,
      pendiente: 0,
      enProceso: 0,
      resuelto: 0,
      cancelado: 0
    })
  },
  activeFilter: {
    type: String,
    default: 'todas'
  },
  reportesList: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['filter-changed', 'categorias-actualizadas'])

const categoriasLista = ref([])

const viewItems = computed(() => [
  { key: 'todas', label: 'Todos los reportes', icon: '📋', count: props.counts.todas },
  { key: 'misEntradas', label: 'Mis reportes', icon: '✍️', count: props.counts.misEntradas },
  { key: 'asignado', label: 'Asignados a mí', icon: '👤', count: props.counts.asignado },
  { key: 'sinAsignacion', label: 'Sin asignación', icon: '📭', count: props.counts.sinAsignacion },
])

const statusItems = computed(() => [
  { key: 'estado-Pendiente', label: 'Pendiente', dotClass: 'bg-amber-400 ring-amber-100', count: props.counts.pendiente },
  { key: 'estado-En Proceso', label: 'En Proceso', dotClass: 'bg-blue-500 ring-blue-100', count: props.counts.enProceso },
  { key: 'estado-Resuelto', label: 'Resuelto', dotClass: 'bg-emerald-500 ring-emerald-100', count: props.counts.resuelto },
  { key: 'estado-Cancelado', label: 'Cancelado', dotClass: 'bg-slate-400 ring-slate-100', count: props.counts.cancelado },
])

const getCategoryCount = (nombre) => {
  if (!props.reportesList) return 0;
  return props.reportesList.filter(r => r.categoria === nombre).length;
}

const fetchCategorias = async () => {
  try {
    const res = await axios.get('/api/reportes-incidencia/categorias/lista')
    categoriasLista.value = res.data
    emit('categorias-actualizadas', res.data)
  } catch (error) {
    console.error('Error cargando categorías:', error)
  }
}

const agregarCategoria = async () => {
  const nombre = prompt('Ingresa el nombre de la nueva categoría:')
  if (!nombre || !nombre.trim()) return

  try {
    const res = await axios.post('/api/reportes-incidencia/categorias', { nombre: nombre.trim() })
    fetchCategorias()
  } catch (error) {
    console.error('Error al agregar categoría:', error)
    if (error.response?.data?.error) {
      alert(error.response.data.error)
    } else {
      alert('Hubo un error al agregar la categoría.')
    }
  }
}

const editarCategoria = async (cat) => {
  const nuevoNombre = prompt('Editar nombre de la categoría:', cat.nombre)
  if (!nuevoNombre || !nuevoNombre.trim() || nuevoNombre === cat.nombre) return

  try {
    await axios.put(`/api/reportes-incidencia/categorias/${cat.id}`, {
      nombre: nuevoNombre.trim(),
      activa: cat.activa
    })
    fetchCategorias()
  } catch (error) {
    console.error('Error al editar categoría:', error)
    alert(error.response?.data?.error || 'Error al editar la categoría')
  }
}

const toggleCategoria = async (cat) => {
  const nuevoEstado = !cat.activa
  try {
    await axios.put(`/api/reportes-incidencia/categorias/${cat.id}`, {
      nombre: cat.nombre,
      activa: nuevoEstado
    })
    fetchCategorias()
  } catch (error) {
    console.error('Error al cambiar estado de categoría:', error)
    alert('Error al cambiar el estado')
  }
}

onMounted(() => {
  fetchCategorias()
})
</script>