<template>
  <div 
    class="min-h-screen bg-cover bg-center bg-no-repeat bg-fixed font-sans relative" 
    style="background-image: url(`${$config.public.apiBase}/uploads/Fondo/Fondo%20Seguimiento.jpeg`);"
  >
    <!-- Overlay para legibilidad -->
    <div class="absolute inset-0 bg-slate-900/60 backdrop-blur-[4px] z-0"></div>

    <div class="relative z-10 w-full max-w-4xl mx-auto p-4 md:p-8">
      
      <!-- Botón de regreso -->
      <div class="mb-8">
        <button @click="goBack" class="text-sm text-white/80 hover:text-white font-medium flex items-center transition-all bg-white/10 px-4 py-2 rounded-xl backdrop-blur-md border border-white/20 hover:bg-white/20 hover:shadow-lg">
          <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
          Volver al Inicio
        </button>
      </div>

      <!-- Header & Buscador -->
      <div class="bg-white/95 backdrop-blur-xl rounded-3xl shadow-2xl border border-white/20 p-8 mb-8 text-center">
        <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase mb-2">Seguimiento de Ticket</h1>
        <p class="text-slate-500 text-sm font-medium italic mb-8">Consulta el estado y la conversación de tu solicitud.</p>
        
        <form @submit.prevent="buscarTicket" class="max-w-md mx-auto flex gap-3">
          <input 
            v-model="searchId" 
            type="text" 
            placeholder="Ej: TKT-018 o 18" 
            class="flex-1 px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all duration-200 text-center font-bold tracking-widest uppercase"
            required
          />
          <button type="submit" :disabled="loading" class="px-8 py-4 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-2xl font-black text-sm uppercase tracking-widest hover:from-blue-700 hover:to-indigo-700 shadow-lg shadow-blue-500/30 active:scale-[0.98] transition-all disabled:opacity-50">
            {{ loading ? '...' : 'Buscar' }}
          </button>
        </form>

        <div v-if="errorMsg" class="mt-4 px-4 py-3 bg-red-50 text-red-600 rounded-xl text-sm font-bold border border-red-100 inline-block">
          {{ errorMsg }}
        </div>
      </div>

      <!-- Resultados del Ticket -->
      <div v-if="ticket" class="space-y-6">
        
        <!-- Info del Ticket -->
        <div class="bg-white/95 backdrop-blur-xl rounded-3xl shadow-xl border border-white/20 p-6 md:p-8">
          <div class="flex flex-wrap justify-between items-center border-b border-slate-100 pb-5 mb-5">
            <div class="flex items-center gap-3">
              <h2 class="text-2xl md:text-3xl font-black text-slate-800 tracking-tight">{{ ticket.displayId }}</h2>
              <span :class="['px-3 py-1.5 rounded-full text-xs font-black uppercase tracking-widest shadow-sm', estadoClass(ticket.estado)]">
                {{ ticket.estado }}
              </span>
            </div>
            <div class="text-sm text-slate-500 font-medium mt-2 md:mt-0 bg-slate-50 px-3 py-1 rounded-lg border border-slate-100">
              🗓️ {{ ticket.fechaFormateada }}
            </div>
          </div>
          
          <div class="mb-6">
            <h3 class="text-xl font-bold text-slate-900 mb-3">{{ ticket.tema || ticket.Categoria || ticket.tipo }}</h3>
            <p class="text-slate-700 whitespace-pre-line bg-slate-50 p-5 rounded-2xl border border-slate-100 text-sm leading-relaxed">{{ ticket.descripcion }}</p>
          </div>

          <div class="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm bg-slate-50/50 p-4 rounded-2xl border border-slate-50">
            <div>
              <span class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Categoría</span>
              <span class="font-bold text-slate-800">{{ ticket.Categoria || ticket.tipo || 'General' }}</span>
            </div>
            <div>
              <span class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Prioridad</span>
              <span class="font-bold text-slate-800">{{ ticket.prioridad }}</span>
            </div>
            <div>
              <span class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Solicitante</span>
              <span class="font-bold text-slate-800">{{ ticket.creadorNombre }}</span>
            </div>
            <div>
              <span class="block text-[10px] font-black text-slate-400 uppercase tracking-widest mb-1">Asignado a</span>
              <span class="font-bold text-slate-800">{{ ticket.asignadoNombre }}</span>
            </div>
          </div>
        </div>

        <!-- Conversación / Respuestas -->
        <div v-if="ticket.estado !== 'Cerrado'" class="bg-white/95 backdrop-blur-xl rounded-3xl shadow-xl border border-white/20 overflow-hidden">
          <div class="p-6 border-b border-slate-100 bg-slate-50/80 flex items-center justify-between">
            <h3 class="font-black text-slate-800 uppercase tracking-tight text-sm">Historial de Conversación</h3>
            <span class="text-xs font-bold text-blue-700 bg-blue-100 px-3 py-1.5 rounded-full">{{ respuestas.length }} mensajes</span>
          </div>
          
          <div class="p-6 space-y-6">
            <div v-if="respuestas.length === 0" class="text-center py-12 bg-slate-50 rounded-2xl border border-slate-100 border-dashed">
              <span class="text-4xl mb-3 block">💬</span>
              <p class="text-slate-500 font-medium">Aún no hay respuestas en este ticket.</p>
            </div>

            <div v-for="res in respuestas" :key="res.id" class="flex gap-4">
              <div class="w-10 h-10 md:w-12 md:h-12 rounded-full overflow-hidden border-2 border-white shadow-sm shrink-0 bg-blue-50 flex items-center justify-center">
                <img v-if="res.avatar" :src="res.avatar" class="w-full h-full object-cover" />
                <span v-else class="text-blue-600 font-black text-lg">{{ res.nombre.charAt(0) }}</span>
              </div>
              
              <div class="flex-1 bg-white shadow-sm rounded-2xl rounded-tl-none p-5 border border-slate-100">
                <div class="flex flex-col md:flex-row md:justify-between md:items-center mb-3 gap-1">
                  <h4 class="text-sm font-bold text-slate-900">{{ res.nombre }}</h4>
                  <span class="text-xs text-slate-400 font-medium bg-slate-50 px-2 py-1 rounded-md">{{ res.fecha }}</span>
                </div>
                <p class="text-sm text-slate-700 whitespace-pre-line leading-relaxed">{{ res.mensaje }}</p>
                
                <div v-if="res.archivo" class="mt-4 inline-flex items-center gap-2 bg-slate-50 border border-slate-200 rounded-xl p-2.5 text-xs hover:border-blue-300 transition-colors">
                  <span class="text-lg">📎</span>
                  <a :href="res.archivo" target="_blank" class="text-blue-600 font-bold hover:underline truncate max-w-[200px]">{{ res.archivo_nombre }}</a>
                </div>
              </div>
            </div>

            <!-- Formulario Nueva Respuesta -->
            <div class="pt-8 border-t border-slate-100 mt-8">
              <h4 class="text-sm font-black text-slate-800 uppercase tracking-tight mb-4 flex items-center gap-2">
                <span>📝</span> Añadir una respuesta
              </h4>
              <form @submit.prevent="enviarRespuesta" class="space-y-4">
                <textarea v-model="nuevaRespuesta.mensaje" rows="4" class="w-full p-4 border border-slate-200 bg-slate-50 rounded-2xl focus:ring-4 focus:ring-blue-500/20 focus:border-blue-500 outline-none text-sm text-slate-700 transition-all shadow-inner" placeholder="Escribe tu mensaje aquí..." required></textarea>
                
                <div class="flex flex-col md:flex-row items-center justify-between gap-4">
                  <div class="relative overflow-hidden cursor-pointer w-full md:w-auto">
                    <input type="file" ref="archivoRespuesta" @change="manejarArchivo" class="absolute inset-0 opacity-0 cursor-pointer" />
                    <button type="button" class="w-full md:w-auto flex items-center justify-center gap-2 px-5 py-3 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 rounded-xl text-sm font-bold transition-all shadow-sm">
                      <span class="text-lg">📎</span> <span class="truncate max-w-[150px]">{{ archivoSeleccionado ? archivoSeleccionado.name : 'Adjuntar Archivo' }}</span>
                    </button>
                  </div>
                  
                  <button type="submit" :disabled="enviandoRespuesta || ticket.estado === 'Cerrado'" class="w-full md:w-auto px-8 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white rounded-xl font-black uppercase text-sm tracking-widest shadow-lg shadow-blue-500/30 active:scale-[0.98] transition-all disabled:opacity-50 disabled:from-slate-400 disabled:to-slate-500">
                    {{ enviandoRespuesta ? 'Enviando...' : 'Enviar Respuesta' }}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>

        <!-- Mensaje de CERRADO -->
        <div v-else class="bg-red-50/95 backdrop-blur-xl rounded-3xl shadow-xl border border-red-200 overflow-hidden p-8 text-center">
          <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-red-100 text-red-600 mb-4 shadow-inner">
            <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path></svg>
          </div>
          <h3 class="text-2xl font-black text-red-800 uppercase tracking-tight mb-2">Ticket Cerrado</h3>
          <p class="text-red-700/80 font-medium max-w-md mx-auto">Este ticket ha sido cerrado y ya no admite nuevas respuestas ni es posible ver el historial de conversación.</p>
        </div>
        
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const searchId = ref('')
const loading = ref(false)
const errorMsg = ref('')
const ticket = ref(null)
const respuestas = ref([])

// Formulario de respuesta
const nuevaRespuesta = ref({ mensaje: '' })
const enviandoRespuesta = ref(false)
const archivoSeleccionado = ref(null)
const archivoRespuesta = ref(null)

const goBack = () => {
  router.push('/login') // O regresar a donde considere necesario el usuario externo
}

const manejarArchivo = (e) => {
  archivoSeleccionado.value = e.target.files[0]
}

const enviarRespuesta = async () => {
  if (!ticket.value) return;
  if (!nuevaRespuesta.value.mensaje.trim()) {
    return alert("El mensaje no puede estar vacío");
  }
  
  enviandoRespuesta.value = true;
  const formData = new FormData();
  formData.append('mensaje', nuevaRespuesta.value.mensaje);
  
  // Tratar de obtener el ID del usuario / empleado si está logueado, sino será externo
  const usuarioID = localStorage.getItem('usuarioID');
  if (usuarioID) formData.append('usuario_id', usuarioID);
  
  if (ticket.value.empleado_id) {
    // Si sabemos qué empleado creó el ticket, y es el mismo (como empleado)
    formData.append('empleado_id', ticket.value.empleado_id);
  }
  
  if (archivoSeleccionado.value) {
    formData.append('archivo', archivoSeleccionado.value);
  }
  
  try {
    await axios.post(`/api/tickets/${ticket.value.rawId || ticket.value.id}/respuestas`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
    
    nuevaRespuesta.value.mensaje = '';
    archivoSeleccionado.value = null;
    if (archivoRespuesta.value) archivoRespuesta.value.value = '';
    
    // Recargar el ticket para ver la nueva respuesta
    await buscarTicketPorId(ticket.value.rawId || ticket.value.id);
  } catch (error) {
    console.error("Error al enviar respuesta:", error);
    alert("Hubo un error al enviar tu respuesta.");
  } finally {
    enviandoRespuesta.value = false;
  }
}

const buscarTicketPorId = async (numericId) => {
  try {
    const res = await axios.get(`/api/tickets/${numericId}`)
    const data = res.data

    let asignado = 'Sin asignar'
    if (data.asignado_empleado_nombre) asignado = `${data.asignado_empleado_nombre} ${data.asignado_empleado_apellido || ''}`.trim()
    else if (data.asignado_usuario_nombre) asignado = data.asignado_usuario_nombre
    
    let creador = 'Externo/Desconocido'
    if (data.empleado_nombre) creador = `${data.empleado_nombre} ${data.empleado_apellido || ''}`.trim()

    ticket.value = {
      ...data,
      displayId: `#TKT-${String(data.id).padStart(3, '0')}`,
      rawId: data.id,
      creadorNombre: creador,
      asignadoNombre: asignado,
      fechaFormateada: new Date(data.fecha_creacion).toLocaleDateString('es-HN', {
        day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit'
      })
    }

    const resR = await axios.get(`/api/tickets/${numericId}/respuestas`)
    respuestas.value = resR.data.map(r => ({
      id: r.id,
      mensaje: r.mensaje,
      fecha: new Date(r.fecha_creacion).toLocaleDateString('es-HN', {
        day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit'
      }),
      archivo: r.archivo ? `${useRuntimeConfig().public.apiBase}${r.archivo}` : null,
      archivo_nombre: r.archivo ? r.archivo.split('/').pop() : null,
      nombre: r.empleado_nombre ? `${r.empleado_nombre} ${r.empleado_apellido || ''}` : r.usuario_nombre || 'Usuario',
      avatar: r.empleado_foto ? `${useRuntimeConfig().public.apiBase}${r.empleado_foto}` : (r.usuario_foto ? `${useRuntimeConfig().public.apiBase}${r.usuario_foto}` : null)
    }))
  } catch (err) {
    throw err;
  }
}

const buscarTicket = async () => {
  errorMsg.value = ''
  ticket.value = null
  respuestas.value = []
  
  if (!searchId.value.trim()) return;

  const match = searchId.value.match(/\d+/)
  if (!match) {
    errorMsg.value = 'Formato de ticket inválido. Intenta con un número (ej. 18)'
    return
  }
  
  const numericId = parseInt(match[0], 10)
  
  try {
    loading.value = true
    await buscarTicketPorId(numericId)
  } catch (err) {
    if (err.response && err.response.status === 404) {
      errorMsg.value = 'Ticket no encontrado. Verifica el número.'
    } else {
      errorMsg.value = 'Error de conexión con el servidor.'
    }
  } finally {
    loading.value = false
  }
}

const estadoClass = (e) => {
  const est = (e || 'Pendiente').toLowerCase()
  if (est === 'resuelto' || est === 'cerrado') return 'bg-green-100 text-green-700 border border-green-200'
  if (est === 'abierto') return 'bg-blue-100 text-blue-700 border border-blue-200'
  if (est === 'en progreso') return 'bg-purple-100 text-purple-700 border border-purple-200'
  return 'bg-slate-100 text-slate-700 border border-slate-200'
}
</script>