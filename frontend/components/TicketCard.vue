<template>
  <div class="bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:shadow-md transition-shadow flex flex-col gap-3">
    <!-- Fila 1 -->
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <input type="checkbox" class="w-4 h-4 rounded border-gray-300 text-blue-600 focus:ring-purple-600 cursor-pointer accent-purple-600" />
        <span class="font-bold text-slate-700 text-sm">{{ displayId }}</span>
        <span :class="['px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-widest', prioridadClass(ticket.prioridad)]">
          {{ ticket.prioridad || 'Media' }}
        </span>
        <span :class="['px-2 py-0.5 rounded-full text-[10px] font-black uppercase tracking-widest', estadoClass(ticket.estado)]">
          {{ ticket.estado || 'Pendiente' }}
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
      <h3 class="text-slate-800 font-semibold text-base leading-tight cursor-pointer hover:text-blue-600 transition-colors" @click="$emit('ver-detalle', ticket.id)">{{ titulo }}</h3>
      <p class="text-slate-500 text-sm mt-1 line-clamp-2 truncate">{{ ticket.descripcion }}</p>
    </div>

    <!-- Fila 3 -->
    <div class="flex items-center gap-4 text-xs text-slate-400 font-medium mt-1">
      <div class="flex items-center gap-1">
        <div class="h-4 w-4 rounded-full overflow-hidden bg-slate-200 flex items-center justify-center shrink-0">
          <img v-if="creadorAvatar" :src="creadorAvatar" class="w-full h-full object-cover" />
          <span v-else class="text-[8px]">{{ creadorNombre.charAt(0) || '?' }}</span>
        </div>
        <span>{{ creadorNombre }}</span>
      </div>
      <div class="flex items-center gap-1">
        <span>📁</span>
        <span>{{ categoria }}</span>
      </div>
      <div class="flex items-center gap-1">
        <span>⏱️</span>
        <span>{{ tiempo }}</span>
      </div>
      <div class="flex items-center gap-1">
        <span>💬</span>
        <span>{{ ticket.respuestas_count || ticket.respuestas || 0 }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  ticket: {
    type: Object,
    required: true
  }
})

defineEmits(['ver-detalle'])

const displayId = computed(() => {
  if (typeof props.ticket.id === 'string' && props.ticket.id.startsWith('#')) return props.ticket.id;
  return `#TKT-${String(props.ticket.id).padStart(3, '0')}`;
})

const titulo = computed(() => props.ticket.titulo || props.ticket.tema || 'Sin título')

const creadorNombre = computed(() => {
  if (props.ticket.creadorNombre) return props.ticket.creadorNombre;
  if (props.ticket.empleado_nombre) return `${props.ticket.empleado_nombre} ${props.ticket.empleado_apellido || ''}`.trim();
  return 'Usuario Desconocido';
})

const creadorAvatar = computed(() => {
  if (props.ticket.creadorAvatar) return props.ticket.creadorAvatar;
  if (props.ticket.empleado_foto) return `http://localhost:3007${props.ticket.empleado_foto}`;
  return null;
})

const asignadoNombre = computed(() => {
  if (props.ticket.asignado_empleado_nombre) return `${props.ticket.asignado_empleado_nombre} ${props.ticket.asignado_empleado_apellido || ''}`.trim();
  if (props.ticket.asignado_usuario_nombre) return props.ticket.asignado_usuario_nombre;
  return '?';
})

const asignadoAvatar = computed(() => {
  if (props.ticket.asignado_empleado_foto) return `http://localhost:3007${props.ticket.asignado_empleado_foto}`;
  if (props.ticket.asignado_usuario_foto) return `http://localhost:3007${props.ticket.asignado_usuario_foto}`;
  return null;
})

const categoria = computed(() => props.ticket.Categoria || props.ticket.categoria || props.ticket.tipo || 'General')

const tiempo = computed(() => {
  if (props.ticket.tiempo) return props.ticket.tiempo;
  if (!props.ticket.fecha_creacion) return 'Desconocido';
  const d = new Date(props.ticket.fecha_creacion);
  return d.toLocaleDateString('es-HN', { year: 'numeric', month: 'short', day: 'numeric' });
})

const prioridadClass = (p) => {
  const prio = (p || '').toLowerCase();
  if (prio === 'urgente') return 'bg-red-100 text-red-700 border border-red-200'
  if (prio === 'alta') return 'bg-orange-100 text-orange-700 border border-orange-200'
  if (prio === 'baja') return 'bg-green-100 text-green-700 border border-green-200'
  return 'bg-yellow-100 text-yellow-700 border border-yellow-200'
}

const estadoClass = (e) => {
  const est = (e || 'Pendiente').toLowerCase();
  if (est === 'resuelto' || est === 'cerrado') return 'bg-green-100 text-green-700 border border-green-200'
  if (est === 'abierto') return 'bg-blue-100 text-blue-700 border border-blue-200'
  if (est === 'en progreso') return 'bg-purple-100 text-purple-700 border border-purple-200'
  return 'bg-slate-100 text-slate-700 border border-slate-200'
}
</script>
