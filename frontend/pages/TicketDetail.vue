<template>
  <div class="max-w-7xl mx-auto p-4 md:p-6 bg-gray-50 min-h-screen font-sans">
    
    <!-- Botón de regreso (Opcional, pero buena práctica) -->
    <div class="mb-6">
      <button @click="goBack" class="text-sm text-gray-500 hover:text-purple-600 font-medium flex items-center transition-colors">
        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
        Volver a la lista
      </button>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="flex justify-center items-center py-20">
      <span class="text-gray-500 font-medium">Cargando detalles del ticket...</span>
    </div>

    <!-- Layout Principal: 2 Columnas -->
    <div v-else-if="ticket" class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      
      <!-- COLUMNA IZQUIERDA: Contenido Principal (Ocupa 2/3 en pantallas grandes) -->
      <div class="lg:col-span-2 space-y-6">
        
        <!-- Tarjeta Principal del Ticket -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          
          <!-- Encabezado del Ticket -->
          <div class="p-6 border-b border-gray-100 flex flex-wrap items-center gap-3">
            <h1 class="text-xl font-bold text-gray-800 mr-2">{{ ticket.id }}</h1>
            <span class="px-3 py-1 text-xs font-semibold rounded-full border"
              :class="{
                'bg-red-600 text-white border-red-700': ticket.priority === 'Urgente',
                'bg-red-100 text-red-700 border-red-200': ticket.priority === 'Alta',
                'bg-yellow-100 text-yellow-700 border-yellow-200': ticket.priority === 'Media',
                'bg-green-100 text-green-700 border-green-200': ticket.priority === 'Baja'
              }">
              {{ ticket.priority }}
            </span>
            <span class="px-3 py-1 text-xs font-semibold rounded-full border"
              :class="{
                'bg-blue-100 text-blue-700 border-blue-200': ticket.status === 'Abierto',
                'bg-purple-100 text-purple-700 border-purple-200': ticket.status === 'En Progreso',
                'bg-yellow-100 text-yellow-700 border-yellow-200': ticket.status === 'Pendiente',
                'bg-green-100 text-green-700 border-green-200': ticket.status === 'Resuelto',
                'bg-gray-100 text-gray-700 border-gray-200': ticket.status === 'Cerrado'
              }">
              {{ ticket.status }}
            </span>
          </div>

          <!-- Cuerpo del Mensaje -->
          <div class="p-6">
            <h2 class="text-lg font-semibold text-gray-900 mb-4">{{ ticket.title }}</h2>
            
            <div class="flex items-start gap-4 mb-6">
              <div v-if="ticket.requester.avatar" class="w-12 h-12 rounded-full overflow-hidden border border-gray-200 shrink-0">
                <img :src="ticket.requester.avatar" alt="Avatar" class="w-full h-full object-cover" />
              </div>
              <div v-else class="w-12 h-12 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center shrink-0 uppercase border border-gray-200">
                {{ ticket.requester.name ? ticket.requester.name.charAt(0) : '?' }}
              </div>
              <div>
                <h3 class="text-sm font-bold text-gray-900">{{ ticket.requester.name }}</h3>
                <p class="text-xs text-gray-500">{{ ticket.dateCreated }}</p>
              </div>
            </div>

            <div class="text-gray-700 text-sm leading-relaxed whitespace-pre-line bg-gray-50 p-4 rounded-lg border border-gray-100">
              {{ ticket.description }}
            </div>

            <!-- Archivo Adjunto -->
            <div v-if="ticket.attachment" class="mt-6 border-2 border-dashed border-gray-300 rounded-lg p-4 flex items-center justify-between hover:border-purple-400 transition-colors bg-gray-50/50">
              <div class="flex items-center gap-3">
                <div class="p-2 bg-purple-100 text-purple-600 rounded-lg">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"></path></svg>
                </div>
                <div>
                  <p class="text-sm font-semibold text-gray-800">{{ ticket.attachment.name }}</p>
                  <p class="text-xs text-gray-500">Documento Adjunto</p>
                </div>
              </div>
              <a :href="ticket.attachment.url" target="_blank" class="px-4 py-2 text-sm font-medium text-purple-600 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors">
                Descargar / Ver
              </a>
            </div>
          </div>
        </div>

        <!-- Sección de Respuestas -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden mt-6">
          <div class="p-6 border-b border-gray-100 bg-gray-50">
            <h3 class="text-lg font-bold text-gray-800">Respuestas ({{ respuestas.length }})</h3>
          </div>
          <div class="p-6 space-y-6">
            
            <!-- Lista de Respuestas -->
            <div v-for="res in respuestas" :key="res.id" class="flex gap-4">
              <div v-if="res.avatar" class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 shrink-0">
                <img :src="res.avatar" class="w-full h-full object-cover" />
              </div>
              <div v-else class="w-10 h-10 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center shrink-0 uppercase border border-gray-200">
                {{ res.nombre ? res.nombre.charAt(0) : '?' }}
              </div>
              
              <div class="flex-1 bg-gray-50 rounded-2xl rounded-tl-none p-4 border border-gray-100">
                <div class="flex justify-between items-center mb-2">
                  <h4 class="text-sm font-bold text-gray-900">{{ res.nombre }}</h4>
                  <span class="text-xs text-gray-500">{{ res.fecha }}</span>
                </div>
                <p class="text-sm text-gray-700 whitespace-pre-line">{{ res.mensaje }}</p>
                
                <div v-if="res.archivo" class="mt-3 inline-flex items-center gap-2 bg-white border border-gray-200 rounded-lg p-2 text-xs hover:border-purple-300 transition-colors">
                  <span>📎</span>
                  <a :href="res.archivo" target="_blank" class="text-purple-600 font-medium hover:underline truncate max-w-[200px]">{{ res.archivo_nombre }}</a>
                </div>
              </div>
            </div>

            <div v-if="respuestas.length === 0" class="text-center py-6 text-gray-500 text-sm">
              No hay respuestas en este ticket todavía.
            </div>

            <!-- Formulario Nueva Respuesta -->
            <div class="pt-6 border-t border-gray-100 mt-6">
              <h4 class="text-sm font-bold text-gray-800 mb-4">Añadir una respuesta</h4>
              <form @submit.prevent="enviarRespuesta" class="space-y-4">
                <textarea v-model="nuevaRespuesta.mensaje" rows="3" class="w-full p-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 outline-none text-sm text-gray-700" placeholder="Escribe tu respuesta aquí..." required></textarea>
                
                <div class="flex items-center justify-between">
                  <div class="relative overflow-hidden cursor-pointer">
                    <input type="file" ref="archivoRespuesta" @change="manejarArchivo" class="absolute inset-0 opacity-0 cursor-pointer" />
                    <button type="button" class="flex items-center gap-2 px-4 py-2 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-lg text-sm font-medium transition-colors cursor-pointer">
                      <span>📎</span> {{ archivoSeleccionado ? archivoSeleccionado.name : 'Adjuntar Archivo' }}
                    </button>
                  </div>
                  
                  <button type="submit" :disabled="enviandoRespuesta" class="px-6 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-bold text-sm shadow-md shadow-purple-200 transition-all disabled:opacity-50">
                    {{ enviandoRespuesta ? 'Enviando...' : 'Enviar Respuesta' }}
                  </button>
                </div>
              </form>
            </div>

          </div>
        </div>
      </div>

      <!-- COLUMNA DERECHA: Panel de Detalles (Ocupa 1/3) -->
      <div class="lg:col-span-1 space-y-6">
        
        <!-- Tarjeta de Gestión de Estatus -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5">
          <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Cambio de Estatus</label>
          <div class="relative">
            <select v-model="ticket.status" @change="updateStatus" class="block w-full pl-3 pr-10 py-2.5 text-sm border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500 rounded-lg appearance-none bg-white font-medium text-gray-700 cursor-pointer">
              <option v-for="status in availableStatuses" :key="status" :value="status">
                {{ status }}
              </option>
            </select>
            <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-500">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
            </div>
          </div>
        </div>

        <!-- Tarjeta Información del Solicitante -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5">
          <h3 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-4 border-b border-gray-100 pb-2">Información del Solicitante</h3>
          <div class="flex items-center gap-3 mb-4">
            <div v-if="ticket.requester.avatar" class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 shrink-0">
              <img :src="ticket.requester.avatar" alt="Avatar Solicitante" class="w-full h-full object-cover" />
            </div>
            <div v-else class="w-10 h-10 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center shrink-0 uppercase border border-gray-200">
              {{ ticket.requester.name ? ticket.requester.name.charAt(0) : '?' }}
            </div>
            <div>
              <p class="text-sm font-bold text-gray-900">{{ ticket.requester.name }}</p>
              <p class="text-xs text-gray-500 flex items-center mt-0.5">
                <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path></svg>
                {{ ticket.requester.phone }}
              </p>
            </div>
          </div>
          <div class="grid grid-cols-2 gap-3">
            <div class="bg-blue-50 border border-blue-200 rounded-lg p-3 text-center">
              <p class="text-[10px] font-bold text-blue-700 uppercase tracking-wide">Total de entradas</p>
              <p class="text-xl font-extrabold text-blue-800">{{ ticket.requester.totalTickets }}</p>
            </div>
            <div class="bg-green-50 border border-green-200 rounded-lg p-3 text-center">
              <p class="text-[10px] font-bold text-green-700 uppercase tracking-wide">Entradas resueltas</p>
              <p class="text-xl font-extrabold text-green-800">{{ ticket.requester.resolvedTickets }}</p>
            </div>
          </div>
        </div>

        <!-- Tarjeta de Asignación -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5">
          <h3 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-4 border-b border-gray-100 pb-2">Asignado a</h3>
          <div @click="openAssignModal" class="flex items-center justify-between p-2 hover:bg-gray-50 rounded-lg cursor-pointer transition-colors border border-transparent hover:border-gray-200">
            <div class="flex items-center gap-3">
              <div v-if="ticket.assignedTo.avatar" class="w-8 h-8 rounded-full overflow-hidden border border-gray-200 shrink-0">
                <img :src="ticket.assignedTo.avatar" alt="Avatar Empleado" class="w-full h-full object-cover" />
              </div>
              <div v-else class="w-8 h-8 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center shrink-0 uppercase border border-gray-200">
                {{ ticket.assignedTo.name ? ticket.assignedTo.name.charAt(0) : '?' }}
              </div>
              <p class="text-sm font-semibold text-gray-800">{{ ticket.assignedTo.name }}</p>
            </div>
            <span class="text-xs text-purple-600 font-medium bg-purple-50 px-2 py-1 rounded">Cambiar</span>
          </div>
        </div>

        <!-- Tarjeta de Detalles Técnicos -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5">
          <h3 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-4 border-b border-gray-100 pb-2">Detalles</h3>
          <ul class="space-y-3 text-sm">
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Categoría</span>
              <span class="font-medium text-gray-800">{{ ticket.category }}</span>
            </li>
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Prioridad</span>
              <span class="font-medium text-gray-800">{{ ticket.priority }}</span>
            </li>
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Creación</span>
              <span class="font-medium text-gray-800">{{ ticket.dateCreated }}</span>
            </li>
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Última act.</span>
              <span class="font-medium text-gray-800">{{ ticket.lastUpdated }}</span>
            </li>
            <li class="flex justify-between items-center">
              <span class="text-gray-500">Respuesta</span>
              <span class="font-medium text-gray-800">{{ ticket.responseTime }}</span>
            </li>
          </ul>
        </div>

        <!-- Tarjeta de Actividad -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5">
          <h3 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-4 border-b border-gray-100 pb-2">Actividad</h3>
          
          <div class="relative pl-4 border-l-2 border-purple-100 space-y-6">
            <!-- Punto de actividad (Creación) -->
            <div class="relative">
              <div class="absolute -left-[21px] bg-purple-500 h-3 w-3 rounded-full border-2 border-white"></div>
              <div class="flex items-center justify-between mb-1">
                <p class="text-sm font-bold text-gray-800">Entrada creada</p>
                <p class="text-[10px] text-gray-500 font-medium">{{ ticket.dateCreated }}</p>
              </div>
              <p class="text-xs text-gray-500 mb-2">{{ ticket.timeAgo }} por <span class="font-bold">{{ ticket.requester.name }}</span></p>
              
              <div class="bg-gray-50 p-3 rounded-lg border border-gray-100 space-y-2 text-xs mt-3">
                <div class="flex flex-wrap items-center gap-2">
                  <span class="text-gray-500 font-medium">Prioridad cambiada a:</span> 
                  <select v-model="ticket.priority" @change="updatePriority" class="bg-white border border-gray-200 rounded px-2 py-0.5 font-bold text-gray-800 outline-none focus:border-purple-400">
                    <option value="Baja">Baja</option>
                    <option value="Media">Media</option>
                    <option value="Alta">Alta</option>
                    <option value="Urgente">Urgente</option>
                  </select>
                  <span class="text-gray-500 ml-1">{{ ticket.updatedTimeAgo }} fue cambiado por <span class="font-bold">{{ nombreUsuario }}</span></span>
                </div>
                <p><span class="text-gray-500 font-medium">Asignado a:</span> <span class="font-bold text-gray-800">{{ ticket.assignedTo.name }}</span> <span class="text-gray-500 ml-1">{{ ticket.updatedTimeAgo }}</span></p>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- Modal Reasignar -->
    <div v-if="showAssignModal" class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4">
      <div class="bg-white rounded-2xl shadow-xl w-full max-w-md overflow-hidden">
        <div class="p-5 border-b border-gray-100 flex justify-between items-center bg-gray-50">
          <h3 class="font-bold text-gray-800">Reasignar Ticket</h3>
          <button @click="showAssignModal = false" class="text-gray-400 hover:text-red-500 font-black">✕</button>
        </div>
        <div class="p-5 space-y-4">
          <div>
            <label class="block text-xs font-bold text-gray-500 uppercase mb-2">Tipo de Asignación</label>
            <select v-model="assignType" class="w-full p-3 border border-gray-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-purple-500 outline-none">
              <option value="none">Sin asignación</option>
              <option value="me">Asignado a mí</option>
              <option value="usuario">A un Usuario</option>
              <option value="empleado">A un Empleado</option>
            </select>
          </div>
          
          <div v-if="assignType === 'usuario'">
            <label class="block text-xs font-bold text-gray-500 uppercase mb-2">Seleccionar Usuario</label>
            <select v-model="selectedAssignee" class="w-full p-3 border border-gray-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-purple-500 outline-none">
              <option value="">Seleccione...</option>
              <option v-for="u in usersList" :key="u.id" :value="u.id">{{ u.nombre }}</option>
            </select>
          </div>

          <div v-if="assignType === 'empleado'">
            <label class="block text-xs font-bold text-gray-500 uppercase mb-2">Seleccionar Empleado</label>
            <select v-model="selectedAssignee" class="w-full p-3 border border-gray-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-purple-500 outline-none">
              <option value="">Seleccione...</option>
              <option v-for="e in employeesList" :key="e.id" :value="e.id">{{ e.nombre }} {{ e.apellido }}</option>
            </select>
          </div>

          <div class="flex justify-end gap-3 mt-4 pt-4 border-t border-gray-100">
            <button @click="showAssignModal = false" class="px-5 py-2.5 text-sm text-gray-500 font-bold hover:bg-gray-100 rounded-lg transition-colors">Cancelar</button>
            <button @click="saveAssignment" class="px-5 py-2.5 bg-purple-600 text-white rounded-lg text-sm font-bold hover:bg-purple-700 shadow-md shadow-purple-200 transition-all">Guardar Cambios</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';

const route = useRoute();
const router = useRouter();

// Lista de estados para el Dropdown
const availableStatuses = ['Abierto', 'En Progreso', 'Pendiente', 'Resuelto', 'Cerrado'];

const ticket = ref(null);
const loading = ref(true);
const nombreUsuario = ref('Usuario');

const showAssignModal = ref(false);
const assignType = ref('none');
const selectedAssignee = ref('');
const usersList = ref([]);
const employeesList = ref([]);

// Variables de respuestas
const respuestas = ref([]);
const nuevaRespuesta = ref({ mensaje: '' });
const enviandoRespuesta = ref(false);
const archivoSeleccionado = ref(null);
const archivoRespuesta = ref(null);

const fetchRespuestas = async (ticketId) => {
  try {
    const { data } = await axios.get(`http://localhost:3007/api/tickets/${ticketId}/respuestas`);
    respuestas.value = data.map(r => ({
      id: r.id,
      mensaje: r.mensaje,
      fecha: new Date(r.fecha_creacion).toLocaleDateString('es-HN', {
        day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit'
      }),
      archivo: r.archivo ? `http://localhost:3007${r.archivo}` : null,
      archivo_nombre: r.archivo ? r.archivo.split('/').pop() : null,
      nombre: r.empleado_nombre ? `${r.empleado_nombre} ${r.empleado_apellido || ''}` : r.usuario_nombre || 'Usuario Desconocido',
      avatar: r.empleado_foto ? `http://localhost:3007${r.empleado_foto}` : (r.usuario_foto ? `http://localhost:3007${r.usuario_foto}` : null)
    }));
  } catch (error) {
    console.error("Error al cargar respuestas:", error);
  }
};

const manejarArchivo = (e) => {
  archivoSeleccionado.value = e.target.files[0];
};

const enviarRespuesta = async () => {
  if (!ticket.value) return;
  if (!nuevaRespuesta.value.mensaje.trim()) {
    return alert("El mensaje no puede estar vacío");
  }
  
  enviandoRespuesta.value = true;
  const formData = new FormData();
  formData.append('mensaje', nuevaRespuesta.value.mensaje);
  
  const usuarioID = localStorage.getItem('usuarioID');
  if (usuarioID) formData.append('usuario_id', usuarioID);
  
  // Opcional: si hay un empleado_id vinculado al usuario actual, podría enviarse. Por defecto, enviamos el usuario_id.
  
  if (archivoSeleccionado.value) {
    formData.append('archivo', archivoSeleccionado.value);
  }
  
  try {
    await axios.post(`http://localhost:3007/api/tickets/${ticket.value.rawId}/respuestas`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });
    
    // Limpiar formulario y recargar respuestas
    nuevaRespuesta.value.mensaje = '';
    archivoSeleccionado.value = null;
    if (archivoRespuesta.value) archivoRespuesta.value.value = '';
    
    await fetchRespuestas(ticket.value.rawId);
    await fetchTicket(); // Para actualizar la última fecha
  } catch (error) {
    console.error("Error al enviar respuesta:", error);
    alert("Hubo un error al enviar tu respuesta.");
  } finally {
    enviandoRespuesta.value = false;
  }
};

const fetchTicket = async () => {
  const id = route.query.id;
  if (!id) {
    loading.value = false;
    return;
  }
  try {
    const { data } = await axios.get(`http://localhost:3007/api/tickets/${id}`);
    
    // Fetch respuestas
    await fetchRespuestas(id);

    
    // Formatear la fecha
    const fecha = new Date(data.fecha_creacion);
    const dateOptions = { day: 'numeric', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' };
    
    let assignedName = 'Sin Asignar';
    let assignedAvatar = null;
    if (data.asignado_empleado_nombre) {
      assignedName = `${data.asignado_empleado_nombre} ${data.asignado_empleado_apellido || ''}`;
      assignedAvatar = data.asignado_empleado_foto ? `http://localhost:3007${data.asignado_empleado_foto}` : null;
    } else if (data.asignado_usuario_nombre) {
      assignedName = data.asignado_usuario_nombre;
      assignedAvatar = data.asignado_usuario_foto ? `http://localhost:3007${data.asignado_usuario_foto}` : null;
    }
    
    const fechaUpdated = data.updated_at ? new Date(data.updated_at) : fecha;
    const diffMs = fechaUpdated - fecha;
    const diffHrs = Math.floor(diffMs / (1000 * 60 * 60));
    const diffMins = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
    let responseTimeStr = diffMs > 0 ? (diffHrs > 0 ? `${diffHrs}h ${diffMins}m` : `${diffMins}m`) : 'Sin respuesta';

    // Calculate time ago
    const diffMsCreated = Date.now() - fecha;
    const diffHrsCreated = Math.floor(diffMsCreated / (1000 * 60 * 60));
    let timeAgoStr = '';
    if (diffHrsCreated === 0) {
      const diffMinsCreated = Math.floor(diffMsCreated / (1000 * 60));
      timeAgoStr = `Hace ${diffMinsCreated} minutos`;
    } else if (diffHrsCreated < 24) {
      timeAgoStr = `Hace ${diffHrsCreated} horas`;
    } else {
      const diffDaysCreated = Math.floor(diffHrsCreated / 24);
      timeAgoStr = `Hace ${diffDaysCreated} días`;
    }

    // Calculate updated time ago
    const diffMsUpdated = Date.now() - fechaUpdated;
    const diffHrsUpdated = Math.floor(diffMsUpdated / (1000 * 60 * 60));
    let updatedTimeAgoStr = '';
    if (diffHrsUpdated === 0) {
      const diffMinsUpdated = Math.floor(diffMsUpdated / (1000 * 60));
      updatedTimeAgoStr = `Hace ${diffMinsUpdated} minutos`;
    } else if (diffHrsUpdated < 24) {
      updatedTimeAgoStr = `Hace ${diffHrsUpdated} horas`;
    } else {
      const diffDaysUpdated = Math.floor(diffHrsUpdated / 24);
      updatedTimeAgoStr = `Hace ${diffDaysUpdated} días`;
    }

    ticket.value = {
      id: `#TKT-${data.id.toString().padStart(3, '0')}`,
      title: data.tema || data.Categoria || data.tipo,
      priority: data.prioridad || 'Media',
      status: data.estado || 'Pendiente',
      category: data.Categoria || data.tipo,
      dateCreated: fecha.toLocaleDateString('es-HN', dateOptions),
      lastUpdated: fechaUpdated.toLocaleDateString('es-HN', dateOptions),
      responseTime: responseTimeStr,
      timeAgo: timeAgoStr,
      updatedTimeAgo: updatedTimeAgoStr,
      description: data.descripcion,
      attachment: data.archivo ? {
        name: data.archivo.split('/').pop(),
        url: `http://localhost:3007${data.archivo}`
      } : null,
      requester: {
        name: data.empleado_nombre ? `${data.empleado_nombre} ${data.empleado_apellido || ''}` : 'Externo',
        avatar: data.empleado_foto ? `http://localhost:3007${data.empleado_foto}` : null,
        phone: data.empleado_telefono || 'N/D',
        totalTickets: data.tickets_totales || 0,
        resolvedTickets: data.tickets_resueltos || 0
      },
      assignedTo: {
        name: assignedName,
        avatar: assignedAvatar
      },
      rawId: data.id
    };
  } catch (error) {
    console.error("Error al cargar ticket:", error);
    alert("No se pudo cargar la información del ticket.");
  } finally {
    loading.value = false;
  }
};

const openAssignModal = async () => {
  showAssignModal.value = true;
  assignType.value = 'none';
  selectedAssignee.value = '';
  
  if (usersList.value.length === 0) {
    try {
      const resU = await axios.get('http://localhost:3007/api/usuarios');
      usersList.value = resU.data;
    } catch(e) { console.error(e) }
  }
  if (employeesList.value.length === 0) {
    try {
      const resE = await axios.get('http://localhost:3007/api/empleados/lista');
      employeesList.value = resE.data;
    } catch(e) { console.error(e) }
  }
};

const saveAssignment = async () => {
  if (!ticket.value) return;
  
  let payload = { tipo: null, id_asignado: null };
  
  if (assignType.value === 'me') {
    payload.tipo = 'usuario';
    payload.id_asignado = localStorage.getItem('usuarioID');
  } else if (assignType.value === 'usuario') {
    if (!selectedAssignee.value) return alert("Seleccione un usuario");
    payload.tipo = 'usuario';
    payload.id_asignado = selectedAssignee.value;
  } else if (assignType.value === 'empleado') {
    if (!selectedAssignee.value) return alert("Seleccione un empleado");
    payload.tipo = 'empleado';
    payload.id_asignado = selectedAssignee.value;
  }
  
  try {
    await axios.put(`http://localhost:3007/api/tickets/${ticket.value.rawId}/asignar`, payload);
    alert("Asignación actualizada con éxito");
    showAssignModal.value = false;
    await fetchTicket();
  } catch (error) {
    console.error("Error al asignar:", error);
    alert("Error al actualizar la asignación");
  }
};

const updateStatus = async () => {
  if (!ticket.value) return;
  try {
    await axios.put(`http://localhost:3007/api/tickets/${ticket.value.rawId}/estado`, {
      estado: ticket.value.status
    });
    alert("Estado actualizado con éxito");
  } catch (error) {
    console.error("Error al actualizar estado:", error);
    alert("Error al actualizar el estado");
  }
};

const updatePriority = async () => {
  if (!ticket.value) return;
  try {
    await axios.put(`http://localhost:3007/api/tickets/${ticket.value.rawId}/prioridad`, {
      prioridad: ticket.value.priority
    });
    alert("Prioridad actualizada con éxito");
  } catch (error) {
    console.error("Error al actualizar prioridad:", error);
    alert("Error al actualizar la prioridad");
  }
};

const goBack = () => {
  router.push('/tickets');
};

onMounted(() => {
  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Usuario';
  fetchTicket();
});
</script>