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
                ? 'bg-gradient-to-r from-violet-50 to-purple-50 text-violet-700 shadow-sm shadow-violet-100/50 border border-violet-100/60'
                : 'text-slate-600 hover:bg-slate-50/80 border border-transparent'
            ]">
            <div class="flex items-center gap-2.5">
              <span :class="['transition-transform duration-200', activeFilter === view.key ? 'scale-110' : 'group-hover:scale-105']">
                <svg v-if="view.key === 'todas'" class="w-3.5 h-3.5" :class="activeFilter === view.key ? 'text-violet-500' : 'text-slate-400'" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
                <svg v-else-if="view.key === 'misEntradas'" class="w-3.5 h-3.5" :class="activeFilter === view.key ? 'text-violet-500' : 'text-slate-400'" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                <svg v-else-if="view.key === 'asignado'" class="w-3.5 h-3.5" :class="activeFilter === view.key ? 'text-violet-500' : 'text-slate-400'" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                <svg v-else class="w-3.5 h-3.5" :class="activeFilter === view.key ? 'text-violet-500' : 'text-slate-400'" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"/></svg>
              </span>
              <span class="text-[13px] font-semibold">{{ view.label }}</span>
            </div>
            <span :class="[
              'text-[10px] min-w-[22px] text-center px-1.5 py-0.5 rounded-md font-bold tabular-nums transition-colors duration-200',
              activeFilter === view.key ? 'bg-violet-100 text-violet-700' : 'bg-slate-100 text-slate-500'
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
              'flex items-center justify-between px-3 py-2.5 rounded-xl transition-all duration-200 group border',
              activeFilter === status.key
                ? `${status.activeBg} ${status.activeText} shadow-sm border-${status.color}-100/60`
                : 'text-slate-600 hover:bg-slate-50/80 border-transparent'
            ]">
            <div class="flex items-center gap-2.5">
              <span :class="['w-2 h-2 rounded-full shrink-0', `bg-${status.color}-500`]"></span>
              <span class="text-[13px] font-semibold">{{ status.label }}</span>
            </div>
            <span :class="[
              'text-[10px] min-w-[22px] text-center px-1.5 py-0.5 rounded-md font-bold tabular-nums transition-colors',
              activeFilter === status.key ? `bg-${status.color}-100 text-${status.color}-700` : 'bg-slate-100 text-slate-500'
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
        <button @click="agregarCategoria" class="w-5 h-5 rounded-full bg-slate-100 flex items-center justify-center text-slate-400 hover:bg-violet-500 hover:text-white transition-all text-xs font-bold" title="Agregar Categoría">+</button>
      </div>
      <ul class="space-y-0.5">
        <li v-for="cat in categoriasLista" :key="cat.id"
            @click.prevent="$emit('filter-changed', 'categoria-' + cat.nombre)"
            :class="[
              'group flex items-center justify-between px-3 py-2.5 rounded-xl transition-all duration-200 cursor-pointer border',
              activeFilter === 'categoria-' + cat.nombre
                ? 'bg-gradient-to-r from-violet-50 to-purple-50 text-violet-700 shadow-sm border-violet-100/60'
                : 'text-slate-600 hover:bg-slate-50/80 border-transparent'
            ]">
          <div class="flex items-center gap-2.5 flex-1 min-w-0" :class="{ 'opacity-50': !cat.activa }">
            <svg v-if="cat.activa" class="w-3.5 h-3.5 text-amber-400 shrink-0" fill="currentColor" viewBox="0 0 24 24"><path d="M10 4H4c-1.1 0-2 .9-2 2v4h20V6c0-1.1-.9-2-2-2h-8l-2-2z"/><path d="M4 10v8c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2v-8H4z" opacity=".3"/></svg>
            <svg v-else class="w-3.5 h-3.5 text-slate-400 shrink-0" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
            <span class="text-[13px] font-semibold truncate">{{ cat.nombre }}</span>
          </div>
          <div class="flex items-center gap-1.5">
            <span :class="[
              'text-[10px] min-w-[22px] text-center px-1.5 py-0.5 rounded-md font-bold tabular-nums',
              activeFilter === 'categoria-' + cat.nombre ? 'bg-violet-100 text-violet-700' : 'bg-slate-100 text-slate-500'
            ]">{{ getCategoryCount(cat.nombre) }}</span>
            <div class="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
              <button @click.stop="editarCategoria(cat)" class="p-1 rounded-md text-slate-400 hover:text-violet-500 hover:bg-violet-50 transition-all" title="Editar">
                <svg class="w-3 h-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>
              </button>
              <button @click.stop="toggleCategoria(cat)" :title="cat.activa ? 'Desactivar' : 'Activar'" class="p-1 rounded-md text-slate-400 hover:text-amber-500 hover:bg-amber-50 transition-all">
                <svg class="w-3 h-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
              </button>
            </div>
          </div>
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
      todas: 0, misEntradas: 0, asignado: 0, sinAsignacion: 0,
      abierto: 0, enProgreso: 0, pendiente: 0, resuelto: 0, cerrado: 0,
    })
  },
  activeFilter: { type: String, default: 'todas' },
  ticketsList: { type: Array, default: () => [] }
})

const emit = defineEmits(['filter-changed', 'categorias-actualizadas'])
const categoriasLista = ref([])

const viewItems = computed(() => [
  { key: 'todas',         label: 'Todas las entradas', count: props.counts.todas },
  { key: 'misEntradas',   label: 'Mis entradas',       count: props.counts.misEntradas },
  { key: 'asignado',      label: 'Asignado a mí',      count: props.counts.asignado },
  { key: 'sinAsignacion', label: 'Sin asignación',     count: props.counts.sinAsignacion },
])

const statusItems = computed(() => [
  { key: 'estado-Abierto',     label: 'Abierto',     count: props.counts.abierto,    color: 'purple', activeBg: 'bg-purple-50/50',  activeText: 'text-purple-700' },
  { key: 'estado-En Progreso', label: 'En Progreso', count: props.counts.enProgreso, color: 'blue',   activeBg: 'bg-blue-50/50',    activeText: 'text-blue-700' },
  { key: 'estado-Pendiente',   label: 'Pendiente',   count: props.counts.pendiente,  color: 'amber',  activeBg: 'bg-amber-50/50',   activeText: 'text-amber-700' },
  { key: 'estado-Resuelto',    label: 'Resuelto',    count: props.counts.resuelto,   color: 'emerald',activeBg: 'bg-emerald-50/50', activeText: 'text-emerald-700' },
  { key: 'estado-Cerrado',     label: 'Cerrado',     count: props.counts.cerrado,    color: 'slate',  activeBg: 'bg-slate-100',     activeText: 'text-slate-700' },
])

const getCategoryCount = (nombre) => {
  if (!props.ticketsList) return 0
  return props.ticketsList.filter(t => t.tipo === nombre || t.Categoria === nombre).length
}

const fetchCategorias = async () => {
  try {
    const res = await axios.get('/api/tickets/categorias/lista')
    categoriasLista.value = res.data
    emit('categorias-actualizadas', res.data)
  } catch (error) { console.error('Error cargando categorías:', error) }
}

const agregarCategoria = async () => {
  const nombre = prompt('Ingresa el nombre de la nueva categoría:')
  if (!nombre || !nombre.trim()) return
  try {
    await axios.post('/api/tickets/categorias', { nombre: nombre.trim() })
    fetchCategorias()
  } catch (error) {
    alert(error.response?.data?.error || 'Hubo un error al agregar la categoría.')
  }
}

const editarCategoria = async (cat) => {
  const nuevoNombre = prompt('Editar nombre de la categoría:', cat.nombre)
  if (!nuevoNombre || !nuevoNombre.trim() || nuevoNombre === cat.nombre) return
  try {
    await axios.put(`/api/tickets/categorias/${cat.id}`, { nombre: nuevoNombre.trim(), activa: cat.activa })
    fetchCategorias()
  } catch (error) { alert(error.response?.data?.error || 'Error al editar la categoría') }
}

const toggleCategoria = async (cat) => {
  try {
    await axios.put(`/api/tickets/categorias/${cat.id}`, { nombre: cat.nombre, activa: !cat.activa })
    fetchCategorias()
  } catch (error) { alert('Error al cambiar el estado') }
}

onMounted(() => fetchCategorias())
</script>
