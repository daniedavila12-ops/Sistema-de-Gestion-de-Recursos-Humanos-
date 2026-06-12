<template>
  <div class="bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:shadow-md transition-shadow flex flex-col gap-3">
    <!-- Fila 1 -->
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <input type="checkbox" class="w-4 h-4 rounded border-gray-300 text-blue-600 focus:ring-purple-600 cursor-pointer accent-purple-600" />
        <span class="font-bold text-slate-700 text-sm">#{{ reporte.id }}</span>
        <span :class="['px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-widest', prioridadClass(reporte.prioridad)]">
          {{ reporte.prioridad || 'Media' }}
        </span>
        <span :class="['px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-widest', estadoClass(reporte.estado)]">
          {{ reporte.estado || 'Pendiente' }}
        </span>
      </div>
      <div class="h-8 w-8 rounded-full overflow-hidden border border-slate-200 shrink-0" :title="`Asignado a: ${asignadoNombre !== '?' ? asignadoNombre : 'Nadie'}`">
        <img v-if="asignadoAvatar" :src="asignadoAvatar" class="w-full h-full object-cover" />
        <div v-else class="w-full h-full bg-slate-200 flex items-center justify-center text-slate-500 font-bold text-xs uppercase">
          {{ asignadoNombre.charAt(0) }}
        </div>
      </div>
    </div>

    <!-- Fila 2 -->
    <div>
      <h3 class="text-slate-800 font-semibold text-base leading-tight cursor-pointer hover:text-blue-600 transition-colors" @click="$emit('ver-detalle', reporte.id)">
        {{ reporte.tema || reporte.categoria || 'Incidente' }}
      </h3>
      <p class="text-slate-500 text-sm mt-1 line-clamp-2 truncate">{{ reporte.descripcion || 'Sin descripción' }}</p>
    </div>

    <!-- Fila 3 -->
    <div class="flex items-center gap-4 text-xs text-slate-400 font-medium mt-1">
      <div class="flex items-center gap-1" title="Reportado Por">
        <div class="h-4 w-4 rounded-full overflow-hidden bg-blue-100 flex items-center justify-center shrink-0 text-blue-600 font-bold">
          <span class="text-[8px]">{{ (reporte.jefe_reporta || '?').charAt(0) }}</span>
        </div>
        <span>{{ reporte.jefe_reporta || 'Desconocido' }}</span>
      </div>
      <div class="flex items-center gap-1" title="Reportado">
        <span>👤</span>
        <span>{{ empleadoNombre }}</span>
      </div>
      <div class="flex items-center gap-1">
        <span>📁</span>
        <span>{{ reporte.categoria || 'Incidente' }}</span>
      </div>
      <div class="flex items-center gap-1">
        <span>⏱️</span>
        <span>{{ tiempo }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  reporte: {
    type: Object,
    required: true
  }
})

defineEmits(['ver-detalle'])

const empleadoNombre = computed(() => {
  if (props.reporte.empleado_nombre) return `${props.reporte.empleado_nombre} ${props.reporte.empleado_apellido || ''}`.trim()
  return props.reporte.identidad || 'Sin identificar'
})

const asignadoNombre = computed(() => {
  if (props.reporte.asignado_usuario_nombre) return props.reporte.asignado_usuario_nombre
  return '?'
})

const asignadoAvatar = computed(() => {
  if (props.reporte.asignado_usuario_foto) return `http://localhost:3007${props.reporte.asignado_usuario_foto}`
  return null
})

const tiempo = computed(() => {
  if (!props.reporte.fecha_creacion) return 'Desconocido'
  const d = new Date(props.reporte.fecha_creacion)
  return d.toLocaleDateString('es-HN', { year: 'numeric', month: 'short', day: 'numeric' })
})

const prioridadClass = (p) => {
  const prio = (p || '').toLowerCase()
  if (prio === 'urgente') return 'bg-red-100 text-red-700 border border-red-200'
  if (prio === 'alta') return 'bg-orange-100 text-orange-700 border border-orange-200'
  if (prio === 'baja') return 'bg-green-100 text-green-700 border border-green-200'
  return 'bg-yellow-100 text-yellow-700 border border-yellow-200'
}

const estadoClass = (e) => {
  const est = (e || 'Pendiente').toLowerCase()
  if (est === 'resuelto' || est === 'cerrado' || est === 'cancelado') return 'bg-green-100 text-green-700 border border-green-200'
  if (est === 'abierto' || est === 'en proceso') return 'bg-blue-100 text-blue-700 border border-blue-200'
  return 'bg-slate-100 text-slate-700 border border-slate-200'
}
</script>