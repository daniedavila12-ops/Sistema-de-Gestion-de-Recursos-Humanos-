<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-md p-4 md:p-8 font-sans overflow-hidden">
    
    <!-- Modal Container -->
    <div class="bg-white rounded-[24px] shadow-2xl w-full max-w-6xl h-full max-h-[95vh] flex flex-col overflow-hidden relative animate-in fade-in zoom-in-95 duration-200">
      
      <!-- Top Modal Header -->
      <div class="flex items-center justify-between p-4 md:px-6 md:py-4 border-b border-slate-100 bg-white z-10 shrink-0">
        <div class="flex items-center gap-3">
          <span class="text-sm font-black text-slate-400 tracking-wider">{{ ticket?.id || '---' }}</span>
          <span v-if="ticket" class="px-3 py-1 text-[10px] font-black uppercase tracking-widest rounded-full"
            :class="{
              'bg-red-50 text-red-600': ticket.priority === 'Urgente',
              'bg-orange-50 text-orange-600': ticket.priority === 'Alta',
              'bg-yellow-50 text-yellow-600': ticket.priority === 'Media',
              'bg-green-50 text-green-600': ticket.priority === 'Baja'
            }">
            {{ ticket.priority }}
          </span>
          <span v-if="ticket" class="px-3 py-1 text-[10px] font-black uppercase tracking-widest rounded-full"
            :class="{
              'bg-blue-50 text-blue-600': ticket.status === 'Abierto',
              'bg-purple-50 text-purple-600': ticket.status === 'En Progreso',
              'bg-yellow-50 text-yellow-600': ticket.status === 'Pendiente',
              'bg-emerald-50 text-emerald-600': ticket.status === 'Resuelto',
              'bg-slate-100 text-slate-600': ticket.status === 'Cerrado'
            }">
            {{ ticket.status }}
          </span>
        </div>

        <div class="flex items-center gap-3">
          <button @click="generarPDFTicket" v-if="ticket" class="hidden md:flex items-center gap-2 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
            PDF
          </button>
          
          <!-- Dropdown Status -->
          <div v-if="ticket" class="relative">
            <select v-model="ticket.status" @change="updateStatus" class="appearance-none pl-4 pr-10 py-2 bg-white border border-slate-200 hover:border-slate-300 rounded-xl outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500 text-xs font-bold text-slate-700 transition-colors cursor-pointer shadow-sm">
              <option v-for="status in availableStatuses" :key="status" :value="status">{{ status }}</option>
            </select>
            <svg class="absolute right-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-400 pointer-events-none" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
          </div>
          
          <button @click="goBack" class="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition-colors ml-1">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
          </button>
        </div>
      </div>
      
      <!-- Modal Scrollable Content -->
      <div class="flex-1 overflow-y-auto bg-white">
        
        <!-- Loading state -->
        <div v-if="loading" class="flex justify-center items-center py-32">
          <span class="text-slate-400 font-bold text-xs uppercase tracking-widest animate-pulse">Cargando detalles del ticket...</span>
        </div>

        <!-- Main Content Grid -->
        <div v-else-if="ticket" class="p-6 md:p-8">
          <h1 class="text-2xl font-black text-slate-800 mb-8 tracking-tight leading-tight">{{ ticket.title }}</h1>
          
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-10">
            
            <!-- COLUMNA IZQUIERDA: Contenido Principal (Ocupa 2/3) -->
            <div class="lg:col-span-2 space-y-8">
              
              <!-- Conversación Inicial -->
              <div class="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm">
                <div class="p-6">
                  <div class="flex items-start gap-4 mb-5">
                    <div v-if="ticket.requesters[0].avatar" class="w-12 h-12 rounded-full overflow-hidden border border-slate-200 shrink-0">
                      <img :src="ticket.requesters[0].avatar" alt="Avatar" class="w-full h-full object-cover" />
                    </div>
                    <div v-else class="w-12 h-12 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center shrink-0 uppercase border border-slate-300">
                      {{ ticket.requesters[0].name ? ticket.requesters[0].name.charAt(0) : '?' }}
                    </div>
                    <div>
                      <h3 class="text-sm font-bold text-slate-900">{{ ticket.requesters[0].name }} <span v-if="ticket.requesters.length > 1" class="text-xs font-normal text-slate-500">y otros</span></h3>
                      <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-0.5">{{ ticket.timeAgo }}</p>
                    </div>
                  </div>

                  <div class="text-slate-600 text-sm leading-relaxed whitespace-pre-line pl-16">
                    {{ ticket.description }}
                  </div>

                  <!-- Archivo Adjunto -->
                  <div v-if="ticket.attachment" class="mt-6 ml-16">
                    <div v-if="isImage(ticket.attachment.url)" class="mt-2 rounded-xl overflow-hidden border border-slate-200 inline-block max-w-sm">
                      <a :href="ticket.attachment.url" target="_blank">
                        <img :src="ticket.attachment.url" alt="Evidencia" class="w-full h-auto object-contain max-h-64" />
                      </a>
                    </div>
                    <div v-else class="inline-flex items-center gap-3 px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl hover:border-purple-300 transition-colors">
                      <span class="text-purple-500">📎</span>
                      <a :href="ticket.attachment.url" target="_blank" class="text-xs font-bold text-slate-700 hover:text-purple-600 transition-colors">
                        {{ ticket.attachment.name || 'documento_adjunto' }}
                      </a>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Respuestas -->
              <div class="space-y-6">
                
                <div v-for="res in respuestas" :key="res.id" class="bg-slate-50/50 rounded-2xl border border-slate-100 p-6 shadow-sm">
                  <div class="flex items-start gap-4 mb-4">
                    <div v-if="res.avatar" class="w-10 h-10 rounded-full overflow-hidden border border-slate-200 shrink-0 shadow-sm">
                      <img :src="res.avatar" class="w-full h-full object-cover" />
                    </div>
                    <div v-else class="w-10 h-10 rounded-full bg-indigo-50 text-indigo-600 font-black flex items-center justify-center shrink-0 uppercase border border-indigo-100 shadow-sm">
                      {{ res.nombre ? res.nombre.charAt(0) : '?' }}
                    </div>
                    <div>
                      <div class="flex items-center gap-2">
                        <h4 class="text-sm font-bold text-slate-900">{{ res.nombre }}</h4>
                        <span v-if="res.es_admin" class="px-2 py-0.5 bg-indigo-100 text-indigo-700 text-[9px] font-black uppercase tracking-widest rounded-md">Soporte</span>
                      </div>
                      <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-0.5">{{ res.fecha }}</p>
                    </div>
                  </div>
                  
                  <p class="text-sm text-slate-600 leading-relaxed whitespace-pre-line pl-14">{{ res.mensaje }}</p>
                  
                  <div v-if="res.archivo" class="mt-4 ml-14">
                    <div v-if="isImage(res.archivo)" class="mt-2 rounded-xl overflow-hidden border border-slate-200 inline-block max-w-xs">
                      <a :href="res.archivo" target="_blank">
                        <img :src="res.archivo" alt="Evidencia de Respuesta" class="w-full h-auto object-contain max-h-48" />
                      </a>
                    </div>
                    <div v-else class="inline-flex items-center gap-2 px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-xs hover:border-indigo-300 transition-colors">
                      <span>📎</span>
                      <a :href="res.archivo" target="_blank" class="text-indigo-600 font-bold truncate max-w-[200px] hover:underline">{{ res.archivo_nombre || 'Documento adjunto' }}</a>
                    </div>
                  </div>
                </div>

              </div>

              <!-- Formulario Nueva Respuesta -->
              <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mt-8">
                <div class="p-4 bg-slate-50 border-b border-slate-100">
                  <h4 class="text-xs font-black text-slate-500 uppercase tracking-widest">Responder al ticket</h4>
                </div>
                <form @submit.prevent="enviarRespuesta" class="p-5 space-y-4">
                  <textarea v-model="nuevaRespuesta.mensaje" rows="3" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:bg-white outline-none text-sm text-slate-700 transition-all resize-none" placeholder="Escribe tu respuesta aquí..." required></textarea>
                  
                  <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div class="relative overflow-hidden cursor-pointer group">
                      <input type="file" ref="archivoRespuesta" @change="manejarArchivo" class="absolute inset-0 opacity-0 cursor-pointer" />
                      <button type="button" class="flex items-center gap-2 px-4 py-2 bg-slate-50 border border-slate-200 group-hover:border-indigo-300 group-hover:bg-indigo-50 text-slate-600 rounded-xl text-xs font-bold transition-all">
                        <span>📎</span> {{ archivoSeleccionado ? archivoSeleccionado.name : 'Añadir archivo adjunto' }}
                      </button>
                    </div>
                    
                    <button type="submit" :disabled="enviandoRespuesta" class="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl font-black text-xs uppercase tracking-widest shadow-lg shadow-indigo-200 transition-all disabled:opacity-50">
                      {{ enviandoRespuesta ? 'Enviando...' : 'Enviar Respuesta' }}
                    </button>
                  </div>
                </form>
              </div>
            </div>

            <!-- COLUMNA DERECHA: Panel de Detalles (Ocupa 1/3) -->
            <div class="lg:col-span-1 space-y-8 border-l border-slate-100 pl-8">
        
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
          
          <div v-for="(req, idx) in ticket.requesters" :key="idx" class="mb-4 last:mb-0 pb-4 last:pb-0 border-b border-gray-100 last:border-0">
            <div class="flex items-center gap-3 mb-4">
              <div v-if="req.avatar" class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 shrink-0">
                <img :src="req.avatar" alt="Avatar Solicitante" class="w-full h-full object-cover" />
              </div>
              <div v-else class="w-10 h-10 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center shrink-0 uppercase border border-gray-200">
                {{ req.name ? req.name.charAt(0) : '?' }}
              </div>
              <div>
                <p class="text-sm font-bold text-gray-900">{{ req.name }}</p>
                <p class="text-xs text-gray-500 flex items-center mt-0.5">
                  <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"></path></svg>
                  {{ req.phone }}
                </p>
              </div>
            </div>
            
            <div class="grid grid-cols-2 gap-3" v-if="ticket.requesters.length === 1">
              <div class="bg-blue-50 border border-blue-200 rounded-lg p-3 text-center">
                <p class="text-[10px] font-bold text-blue-700 uppercase tracking-wide">Total de entradas</p>
                <p class="text-xl font-extrabold text-blue-800">{{ req.totalTickets }}</p>
              </div>
              <div class="bg-green-50 border border-green-200 rounded-lg p-3 text-center">
                <p class="text-[10px] font-bold text-green-700 uppercase tracking-wide">Entradas resueltas</p>
                <p class="text-xl font-extrabold text-green-800">{{ req.resolvedTickets }}</p>
              </div>
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
              <p class="text-xs text-gray-500 mb-2">{{ ticket.timeAgo }} por <span class="font-bold">{{ ticket.requesters[0].name }}</span></p>
              
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

            </div> <!-- close right col -->
          </div> <!-- close grid -->
        </div> <!-- close padding container -->
      </div> <!-- close scrollable content -->
    </div> <!-- close modal container -->

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
            </select>
          </div>
          
          <div v-if="assignType === 'usuario'">
            <label class="block text-xs font-bold text-gray-500 uppercase mb-2">Seleccionar Usuario</label>
            <select v-model="selectedAssignee" class="w-full p-3 border border-gray-300 rounded-lg text-sm bg-white focus:ring-2 focus:ring-purple-500 outline-none">
              <option value="">Seleccione...</option>
              <option v-for="u in usersList" :key="u.id" :value="u.id">{{ u.nombre }}</option>
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
import { ref, onMounted, defineProps, defineEmits } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import axios from 'axios';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

const props = defineProps({
  id: {
    type: [String, Number],
    default: null
  }
});
const emit = defineEmits(['close']);

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

const isImage = (url) => {
  if (!url) return false;
  return /\.(jpeg|jpg|gif|png|webp)(\?.*)?$/i.test(url);
};

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
  const id = props.id || route.query.id;
  if (!id) {
    loading.value = false;
    return;
  }
  try {
    const { data } = await axios.get(`http://localhost:3007/api/tickets/${id}`);
    
    // Fetch respuestas
    await fetchRespuestas(id);
    
    if (employeesList.value.length === 0) {
      try {
        const resE = await axios.get('http://localhost:3007/api/empleados/lista');
        employeesList.value = resE.data;
      } catch(e) { console.error(e) }
    }

    
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

    // Procesar los solicitantes
    let requesters = [];
    if (data.identidad && data.identidad.includes(',')) {
      const identidadesArr = data.identidad.split(',').map(i => i.trim());
      requesters = employeesList.value.filter(e => identidadesArr.includes(e.identidad)).map(e => ({
        name: `${e.nombre} ${e.apellido}`,
        avatar: e.foto ? `http://localhost:3007${e.foto}` : null,
        phone: e.telefono || 'N/D',
        totalTickets: data.tickets_totales || 0, // Fallback, no es 100% preciso por empleado individual
        resolvedTickets: data.tickets_resueltos || 0
      }));
    }
    
    if (requesters.length === 0) {
      requesters = [{
        name: data.empleado_nombre ? `${data.empleado_nombre} ${data.empleado_apellido || ''}` : 'Externo',
        avatar: data.empleado_foto ? `http://localhost:3007${data.empleado_foto}` : null,
        phone: data.empleado_telefono || 'N/D',
        totalTickets: data.tickets_totales || 0,
        resolvedTickets: data.tickets_resueltos || 0
      }];
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
      requesters: requesters,
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
  if (props.id) {
    emit('close');
  } else {
    router.push('/tickets');
  }
};

const generarPDFTicket = async () => {
  if (!ticket.value) return;

  try {
    const doc = new jsPDF();
    
    // --- CABECERA ---
    doc.setFontSize(18);
    doc.setTextColor(220, 38, 38);
    doc.setFont('helvetica', 'bold');
    doc.text('REPORTE DE INCIDENCIA DE TICKET', 14, 20);

    doc.setFontSize(11);
    doc.setTextColor(100, 116, 139);
    doc.setFont('helvetica', 'normal');
    doc.text(`N° de Ticket: ${ticket.value.rawId}`, 14, 28);
    doc.text(`Generado el: ${ticket.value.dateCreated}`, 14, 34);
    doc.text(`Estado: ${ticket.value.status.toUpperCase()}`, 14, 40);

    // Intentar cargar logo
    try {
      const logoUrl = 'http://localhost:3007/uploads/Logo/Logo.png';
      const img = new Image();
      img.crossOrigin = "Anonymous";
      img.src = logoUrl;
      await new Promise((resolve) => {
        img.onload = resolve;
        img.onerror = resolve;
      });
      if (img.complete && img.naturalWidth > 0) {
        doc.addImage(img, 'PNG', 150, 15, 45, 18);
      }
    } catch (e) {
      console.log('Error cargando logo', e);
    }

    doc.setDrawColor(220, 38, 38);
    doc.setLineWidth(0.5);
    doc.line(14, 45, 196, 45);

    // --- INFORMACIÓN GENERAL ---
    let currentY = 55;
    autoTable(doc, {
      startY: currentY,
      head: [['Información General', '']],
      body: [
        ['Tema / Asunto', ticket.value.title || 'Sin tema'],
        ['Categoría', ticket.value.category || 'Sin categoría'],
        ['Prioridad', ticket.value.priority || 'N/A'],
        ['Asignado A', ticket.value.assignedTo?.name || 'Sin Asignar'],
      ],
      theme: 'grid',
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42], fontStyle: 'bold' },
      styles: { cellPadding: 3, fontSize: 10, textColor: [51, 65, 85] },
      columnStyles: { 0: { cellWidth: 50, fontStyle: 'bold' } },
    });

    // --- DATOS DEL SOLICITANTE ---
    currentY = doc.lastAutoTable.finalY + 10;
    
    let currentX = 14;
    for (const req of ticket.value.requesters) {
      if (req.avatar) {
        try {
          const avatarImg = new Image();
          avatarImg.crossOrigin = "Anonymous";
          avatarImg.src = req.avatar;
          await new Promise((resolve) => {
            avatarImg.onload = resolve;
            avatarImg.onerror = resolve;
          });
          if (avatarImg.complete && avatarImg.naturalWidth > 0) {
            doc.addImage(avatarImg, 'JPEG', currentX, currentY, 20, 20);
            currentX += 25;
          }
        } catch (e) {
          console.log('Error cargando avatar', e);
        }
      }
    }

    if (currentX > 14) {
      currentY += 25;
    }

    const nombresStr = ticket.value.requesters.map(r => r.name || 'N/A').join(', ');
    const telefonosStr = ticket.value.requesters.map(r => r.phone || 'N/A').join(', ');

    autoTable(doc, {
      startY: currentY,
      head: [['Datos del Solicitante', '']],
      body: [
        ['Nombre', nombresStr],
        ['Teléfono', telefonosStr],
      ],
      theme: 'grid',
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42], fontStyle: 'bold' },
      styles: { cellPadding: 3, fontSize: 10, textColor: [51, 65, 85] },
      columnStyles: { 0: { cellWidth: 50, fontStyle: 'bold' } },
    });

    // --- DESCRIPCIÓN ---
    currentY = doc.lastAutoTable.finalY + 15;
    doc.setFontSize(12);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('Descripción del Ticket:', 14, currentY);

    doc.setFontSize(10);
    doc.setTextColor(51, 65, 85);
    doc.setFont('helvetica', 'normal');
    const splitDesc = doc.splitTextToSize(ticket.value.description || 'Sin descripción.', 180);
    doc.text(splitDesc, 14, currentY + 7);
    currentY += 10 + (splitDesc.length * 5);

    // --- EVIDENCIA ADJUNTA ---
    if (ticket.value.attachment?.url) {
      doc.setFontSize(12);
      doc.setTextColor(15, 23, 42);
      doc.setFont('helvetica', 'bold');
      doc.text('Evidencia Adjunta del Incidente:', 14, currentY + 5);
      currentY += 12;
      
      if (isImage(ticket.value.attachment.url)) {
        try {
          const evidenceImg = new Image();
          evidenceImg.crossOrigin = "Anonymous";
          evidenceImg.src = ticket.value.attachment.url;
          await new Promise((resolve) => {
            evidenceImg.onload = resolve;
            evidenceImg.onerror = resolve;
          });
          if (evidenceImg.complete && evidenceImg.naturalWidth > 0) {
            const maxWidth = 80;
            const maxHeight = 60;
            const ratio = Math.min(maxWidth / evidenceImg.naturalWidth, maxHeight / evidenceImg.naturalHeight);
            const w = evidenceImg.naturalWidth * ratio;
            const h = evidenceImg.naturalHeight * ratio;
            
            doc.setDrawColor(203, 213, 225);
            doc.roundedRect(14, currentY, w + 4, h + 4, 2, 2, 'S');
            doc.addImage(evidenceImg, 'JPEG', 16, currentY + 2, w, h);
            currentY += h + 15;
          }
        } catch (e) {
          console.log('Error cargando evidencia', e);
        }
      } else {
        doc.setFontSize(10);
        doc.setTextColor(79, 70, 229);
        doc.setFont('helvetica', 'normal');
        doc.text(`Archivo de documento adjunto: ${ticket.value.attachment.name || 'documento'}`, 14, currentY);
        currentY += 10;
      }
    }

    // --- RESPUESTAS / CONVERSACIÓN ---
    if (respuestas.value && respuestas.value.length > 0) {
      currentY += 10;
      const respData = respuestas.value.map(r => [
        `${r.nombre}\n${r.fecha}`, 
        r.archivo ? `${r.mensaje}\n\n[📎 Archivo Adjunto]` : r.mensaje
      ]);
      
      autoTable(doc, {
        startY: currentY,
        head: [['Usuario / Fecha', 'Mensaje']],
        body: respData,
        theme: 'grid',
        headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42], fontStyle: 'bold' },
        styles: { cellPadding: 4, fontSize: 10, textColor: [51, 65, 85] },
        columnStyles: { 0: { cellWidth: 40, fontStyle: 'bold' } },
      });
      currentY = doc.lastAutoTable.finalY;
    }

    // --- FIRMA EN TODAS LAS HOJAS ---
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      const pageHeight = doc.internal.pageSize.height;
      const footerY = pageHeight - 30; 
      
      doc.setDrawColor(0);
      doc.setLineWidth(0.5);
      doc.line(65, footerY, 145, footerY); 
      
      doc.setFontSize(10);
      doc.setTextColor(0, 0, 0);
      doc.setFont('helvetica', 'normal');
      doc.text('Firma de Jefe inmediato / supervisor', 105, footerY + 5, { align: 'center' });
      
      doc.setFontSize(8);
      doc.setTextColor(100, 116, 139);
      doc.text(`Página ${i} de ${totalPages}`, 196, pageHeight - 10, { align: 'right' });
    }

    doc.save(`Ticket_Soporte_${ticket.value.rawId}.pdf`);
  } catch (error) {
    console.error("Error al generar PDF del ticket:", error);
    alert("Hubo un error al generar el PDF.");
  }
};

onMounted(() => {
  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Usuario';
  fetchTicket();
});
</script>