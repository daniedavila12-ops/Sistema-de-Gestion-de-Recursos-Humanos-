<template>
  <div class="relative no-print">
    <div 
      @click="toggleDropdown" 
      class="relative cursor-pointer p-2 rounded-xl hover:bg-slate-50 transition-colors flex items-center justify-center"
      v-click-outside="closeDropdown"
    >
      <span class="text-2xl">🔔</span>
      <div 
        v-if="noLeidas > 0" 
        class="absolute top-1 right-1 bg-red-500 text-white text-[9px] font-black w-4 h-4 rounded-full flex items-center justify-center ring-2 ring-white"
      >
        {{ noLeidas > 9 ? '9+' : noLeidas }}
      </div>
    </div>

    <!-- Dropdown -->
    <div 
      v-if="dropdownAbierto" 
      class="absolute right-0 mt-2 w-80 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50 animate-in slide-in-from-top-2 duration-200"
    >
      <div class="p-4 border-b border-slate-100 bg-slate-50 flex justify-between items-center">
        <h3 class="font-black text-slate-800 text-sm uppercase tracking-tight">Notificaciones</h3>
        <button 
          v-if="noLeidas > 0" 
          @click="marcarTodasComoLeidas" 
          class="text-[10px] font-bold text-blue-500 hover:text-blue-700 transition-colors uppercase tracking-widest"
        >
          Marcar leídas
        </button>
      </div>

      <div class="max-h-80 overflow-y-auto scrollbar-thin">
        <div v-if="loading" class="p-4 text-center text-slate-400 text-xs font-bold">
          Cargando...
        </div>
        <div v-else-if="notificaciones.length === 0" class="p-6 text-center text-slate-400">
          <span class="text-3xl mb-2 block opacity-50">📭</span>
          <p class="text-xs font-medium">No tienes notificaciones</p>
        </div>
        <div 
          v-else 
          v-for="notif in notificacionesEnriquecidas" 
          :key="notif.id"
          @click="manejarClickNotificacion(notif)"
          class="p-4 border-b border-slate-50 hover:bg-slate-50 cursor-pointer transition-colors relative flex items-start gap-3"
          :class="{'bg-slate-50/50': !notif.leido}"
        >
          <!-- Indicador de no leído -->
          <div 
            v-if="!notif.leido" 
            class="absolute left-1.5 top-1/2 -translate-y-1/2 w-1.5 h-1.5 rounded-full bg-indigo-500"
          ></div>
          
          <!-- Avatar -->
          <div class="shrink-0 relative" :class="{'ml-2': !notif.leido}">
            <div class="w-10 h-10 rounded-full overflow-hidden bg-slate-100 shadow-sm flex items-center justify-center text-slate-500 font-bold uppercase">
              <img :src="notif.avatarUrl" class="w-full h-full object-cover" />
            </div>
          </div>

          <!-- Contenido -->
          <div class="flex-1 min-w-0 pt-0.5">
            <p class="text-[13px] font-bold text-slate-800 leading-tight mb-0.5 truncate">{{ notif.nombreMostrar }}</p>
            <p class="text-[11px] text-slate-500 leading-snug line-clamp-2 pr-2">{{ notif.mensajeLimpio }}</p>
            <p class="text-[9px] text-slate-400 font-medium uppercase mt-1">{{ formatearFecha(notif.fecha_creacion) }}</p>
          </div>
        </div>
      </div>
      
      <div class="p-3 border-t border-slate-100 bg-slate-50 text-center">
        <NuxtLink to="/" class="text-[10px] font-black text-slate-500 hover:text-slate-700 uppercase tracking-widest">
          Ver panel principal
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';
import { io } from 'socket.io-client';

const router = useRouter();

const notificaciones = ref([]);
const empleados = ref([]);
const dropdownAbierto = ref(false);
const loading = ref(true);
let socket = null;

const noLeidas = computed(() => {
  return notificaciones.value.filter(n => !n.leido).length;
});

const toggleDropdown = () => {
  dropdownAbierto.value = !dropdownAbierto.value;
  if (dropdownAbierto.value) {
    cargarNotificaciones();
  }
};

const closeDropdown = () => {
  dropdownAbierto.value = false;
};

// Directiva v-click-outside personalizada (sencilla)
const vClickOutside = {
  mounted(el, binding) {
    el.clickOutsideEvent = function(event) {
      if (!(el === event.target || el.contains(event.target))) {
        binding.value(event);
      }
    };
    document.body.addEventListener('click', el.clickOutsideEvent);
  },
  unmounted(el) {
    document.body.removeEventListener('click', el.clickOutsideEvent);
  }
};

const cargarEmpleados = async () => {
  try {
    const res = await axios.get('/api/empleados/lista');
    empleados.value = res.data;
  } catch (err) {
    console.error('Error cargando empleados:', err);
  }
};

const cargarNotificaciones = async () => {
  const usuarioId = localStorage.getItem('usuarioID');
  if (!usuarioId) return;

  try {
    const res = await axios.get(`/api/notificaciones/${usuarioId}`);
    notificaciones.value = res.data;
  } catch (err) {
    console.error('Error cargando notificaciones:', err);
  } finally {
    loading.value = false;
  }
};

const marcarComoLeida = async (id) => {
  try {
    await axios.put(`/api/notificaciones/${id}/leer`);
    const notif = notificaciones.value.find(n => n.id === id);
    if (notif) notif.leido = 1;
  } catch (err) {
    console.error('Error marcando como leída:', err);
  }
};

const marcarTodasComoLeidas = async () => {
  const usuarioId = localStorage.getItem('usuarioID');
  if (!usuarioId) return;

  try {
    await axios.put(`/api/notificaciones/leer-todas/${usuarioId}`);
    notificaciones.value.forEach(n => n.leido = 1);
  } catch (err) {
    console.error('Error marcando todas como leídas:', err);
  }
};

const manejarClickNotificacion = (notif) => {
  if (!notif.leido) {
    marcarComoLeida(notif.id);
  }
  closeDropdown();
  
  const titulo = notif.titulo ? notif.titulo.toLowerCase() : '';
  const mensaje = notif.mensaje ? notif.mensaje : '';
  
  // Extraer el ID si viene en el mensaje (ej: "al Ticket #12" o "Incidente #5" o "ID: 4")
  const matchId = mensaje.match(/(?:#|ID:\s*)(\d+)/i);
  const itemId = matchId ? matchId[1] : null;

  if (titulo.includes('ticket')) {
    if (itemId) {
      router.push({ path: '/tickets', query: { id: itemId } });
    } else {
      router.push('/tickets');
    }
  } else if (titulo.includes('incidente') || titulo.includes('reporte') || titulo.includes('respuesta en incidente')) {
    if (itemId) {
      router.push({ path: '/reportes-incidencia', query: { id: itemId } });
    } else {
      router.push('/reportes-incidencia');
    }
  } else if (titulo.includes('empleado inactivo')) {
    router.push({ path: '/empleados', query: { status: 'inactivos' } });
  } else if (titulo.includes('empleado') || titulo.includes('cumpleaños') || titulo.includes('contrato')) {
    router.push('/empleados');
  } else if (titulo.includes('vacaciones') || titulo.includes('vacacion')) {
    if (itemId) {
      router.push({ path: `/empleados/${itemId}`, query: { tab: 'VACACIONES' } });
    } else {
      router.push('/empleados');
    }
  } else if (titulo.includes('departamento')) {
    router.push('/departamentos');
  }
};

const formatearFecha = (fechaStr) => {
  if (!fechaStr) return '';
  const date = new Date(fechaStr);
  const hoy = new Date();
  
  // Si es de hoy, mostrar hora
  if (date.toDateString() === hoy.toDateString()) {
    return date.toLocaleTimeString('es-HN', { hour: '2-digit', minute: '2-digit' });
  }
  // Si es de ayer
  const ayer = new Date(hoy);
  ayer.setDate(ayer.getDate() - 1);
  if (date.toDateString() === ayer.toDateString()) {
    return 'Ayer, ' + date.toLocaleTimeString('es-HN', { hour: '2-digit', minute: '2-digit' });
  }
  // Si es más antigua
  return date.toLocaleDateString('es-HN', { day: 'numeric', month: 'short' });
};

const notificacionesEnriquecidas = computed(() => {
  return notificaciones.value.map(notif => {
    let nombreEncontrado = null;
    let mensajeLimpio = notif.mensaje || '';
    const msg = notif.mensaje || '';
    let fotoUrl = null;
    
    // Extraer el nombre basado en patrones conocidos de los mensajes del sistema
    if (msg.includes(' añadió una respuesta')) {
      nombreEncontrado = msg.split(' añadió una respuesta')[0];
      mensajeLimpio = msg.replace(nombreEncontrado, '').trim(); 
    } else if (msg.includes(' creó un')) {
      nombreEncontrado = msg.split(' creó un')[0];
      mensajeLimpio = msg.replace(nombreEncontrado, '').trim();
    } else if (msg.includes(' asignó')) {
      nombreEncontrado = msg.split(' asignó')[0];
      mensajeLimpio = msg.replace(nombreEncontrado, '').trim();
    } else if (msg.includes(' acaba de actualizar')) {
      nombreEncontrado = msg.split(' acaba de actualizar')[0];
      mensajeLimpio = msg.replace(nombreEncontrado, '').trim();
    }

    if (nombreEncontrado) {
      nombreEncontrado = nombreEncontrado.trim();
      if (mensajeLimpio) {
        mensajeLimpio = mensajeLimpio.charAt(0).toUpperCase() + mensajeLimpio.slice(1);
      }

      // Buscar en la lista de empleados si coinciden con ese nombre
      const empleado = empleados.value.find(e => {
        const nombreCompleto = `${e.nombre} ${e.apellido}`.trim().toLowerCase();
        return nombreCompleto === nombreEncontrado.toLowerCase() || e.nombre.toLowerCase() === nombreEncontrado.toLowerCase();
      });

      if (empleado && empleado.foto) {
        fotoUrl = `${useRuntimeConfig().public.apiBase}${empleado.foto}`;
      }
    }

    const nombreMostrar = nombreEncontrado || notif.titulo;
    const avatarUrl = fotoUrl || `https://ui-avatars.com/api/?name=${encodeURIComponent(nombreMostrar)}&background=random&color=fff&size=128&bold=true`;

    return {
      ...notif,
      nombreMostrar,
      mensajeLimpio: nombreEncontrado ? mensajeLimpio : notif.mensaje,
      avatarUrl
    };
  });
});

onMounted(() => {
  cargarEmpleados();
  cargarNotificaciones();
  
  // Conectar a socket.io
  socket = io(useRuntimeConfig().public.apiBase);
  
  socket.on('nuevo_ticket', (data) => {
    // Cuando hay un nuevo ticket, recargamos notificaciones
    cargarNotificaciones();
  });

  socket.on('reportes_actualizados', (data) => {
    // Cuando hay un nuevo incidente, recargamos notificaciones
    cargarNotificaciones();
  });

  socket.on('nueva_notificacion', (data) => {
    cargarNotificaciones();
  });
});

onUnmounted(() => {
  if (socket) socket.disconnect();
});
</script>
