<template>
  <div @click="$emit('ver-detalle', ticket.id)"
    class="px-5 py-4 hover:bg-slate-50/60 transition-all duration-200 cursor-pointer group border-b border-slate-100 last:border-0">
    <div class="flex items-start gap-4">

      <!-- Left: Avatar asignado -->
      <div class="shrink-0 mt-0.5">
        <div class="h-9 w-9 rounded-xl overflow-hidden border border-slate-200 shadow-sm" :title="`Asignado: ${asignadoNombre !== '?' ? asignadoNombre : 'Sin asignar'}`">
          <img v-if="asignadoAvatar" :src="asignadoAvatar" class="w-full h-full object-cover" />
          <div v-else class="w-full h-full bg-gradient-to-br from-violet-100 to-purple-200 flex items-center justify-center text-violet-600 font-bold text-xs uppercase">
            {{ asignadoNombre !== '?' ? asignadoNombre.charAt(0) : '?' }}
          </div>
        </div>
      </div>

      <!-- Center: Content -->
      <div class="flex-1 min-w-0">
        <div class="flex items-center gap-2 mb-1.5 flex-wrap">
          <span class="text-[11px] font-bold text-slate-400 tabular-nums">{{ displayId }}</span>
          <span :class="['inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wide', prioridadClass(ticket.prioridad)]">
            <span class="w-1.5 h-1.5 rounded-full" :class="prioridadDotClass(ticket.prioridad)"></span>
            {{ ticket.prioridad || 'Media' }}
          </span>
          <span :class="['inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wide', estadoClass(ticket.estado)]">
            {{ ticket.estado || 'Pendiente' }}
          </span>
        </div>
        <h3 class="text-slate-800 font-semibold text-[14px] leading-snug group-hover:text-violet-600 transition-colors mb-1">
          {{ titulo }}
        </h3>
        <p class="text-slate-400 text-xs leading-relaxed line-clamp-1">
          <span class="font-medium text-slate-500">{{ creadorNombre }}</span>
          <span class="mx-1.5 text-slate-300">·</span>
          {{ ticket.descripcion }}
        </p>
      </div>

      <!-- Right: Meta -->
      <div class="shrink-0 flex flex-col items-end gap-2 text-right">
        <span class="text-[11px] text-slate-400 font-medium tabular-nums whitespace-nowrap">{{ tiempo }}</span>
        <div class="flex items-center gap-3 text-[11px] text-slate-400">
          <span class="flex items-center gap-1" :title="categoria">
            <svg class="w-3 h-3 text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/></svg>
            {{ categoria }}
          </span>
          <span class="flex items-center gap-1" :title="`${ticket.respuestas_count || ticket.respuestas || 0} respuestas`">
            <svg class="w-3 h-3 text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
            {{ ticket.respuestas_count || ticket.respuestas || 0 }}
          </span>
          <button @click.stop="$emit('eliminar', ticket.id)" class="opacity-0 group-hover:opacity-100 p-1 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-all" title="Eliminar ticket">
            <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  ticket: { type: Object, required: true }
})

defineEmits(['ver-detalle', 'eliminar'])

const displayId = computed(() => {
  if (typeof props.ticket.id === 'string' && props.ticket.id.startsWith('#')) return props.ticket.id
  return `#TKT-${String(props.ticket.id).padStart(3, '0')}`
})

const titulo = computed(() => props.ticket.titulo || props.ticket.tema || 'Sin título')

const creadorNombre = computed(() => {
  if (props.ticket.creadorNombre) return props.ticket.creadorNombre
  if (props.ticket.empleado_nombre) return `${props.ticket.empleado_nombre} ${props.ticket.empleado_apellido || ''}`.trim()
  return 'Usuario'
})

const asignadoNombre = computed(() => {
  if (props.ticket.asignado_empleado_nombre) return `${props.ticket.asignado_empleado_nombre} ${props.ticket.asignado_empleado_apellido || ''}`.trim()
  if (props.ticket.asignado_usuario_nombre) return props.ticket.asignado_usuario_nombre
  return '?'
})

const asignadoAvatar = computed(() => {
  if (props.ticket.asignado_empleado_foto) return `http://localhost:3007${props.ticket.asignado_empleado_foto}`
  if (props.ticket.asignado_usuario_foto) return `http://localhost:3007${props.ticket.asignado_usuario_foto}`
  return null
})

const categoria = computed(() => props.ticket.Categoria || props.ticket.categoria || props.ticket.tipo || 'General')

const tiempo = computed(() => {
  if (props.ticket.tiempo) return props.ticket.tiempo
  if (!props.ticket.fecha_creacion) return '-'
  return new Date(props.ticket.fecha_creacion).toLocaleDateString('es-HN', { year: 'numeric', month: 'short', day: 'numeric' })
})

const prioridadClass = (p) => {
  const prio = (p || '').toLowerCase()
  if (prio === 'urgente') return 'bg-red-50 text-red-600 border border-red-100'
  if (prio === 'alta') return 'bg-orange-50 text-orange-600 border border-orange-100'
  if (prio === 'baja') return 'bg-emerald-50 text-emerald-600 border border-emerald-100'
  return 'bg-amber-50 text-amber-600 border border-amber-100'
}

const prioridadDotClass = (p) => {
  const prio = (p || '').toLowerCase()
  if (prio === 'urgente') return 'bg-red-500'
  if (prio === 'alta') return 'bg-orange-500'
  if (prio === 'baja') return 'bg-emerald-500'
  return 'bg-amber-500'
}

const estadoClass = (e) => {
  const est = (e || 'Pendiente').toLowerCase()
  if (est === 'resuelto') return 'bg-emerald-50 text-emerald-600 border border-emerald-100'
  if (est === 'cerrado') return 'bg-slate-100 text-slate-500 border border-slate-200'
  if (est === 'abierto') return 'bg-blue-50 text-blue-600 border border-blue-100'
  if (est === 'en progreso') return 'bg-violet-50 text-violet-600 border border-violet-100'
  return 'bg-amber-50 text-amber-600 border border-amber-100'
}
</script>
