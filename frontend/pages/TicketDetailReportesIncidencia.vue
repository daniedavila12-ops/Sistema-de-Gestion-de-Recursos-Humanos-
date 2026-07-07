<template>
  <div class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-md p-4 md:p-8 font-sans overflow-hidden">
    
    <!-- Modal Container -->
    <div class="bg-white rounded-[24px] shadow-2xl w-full max-w-6xl h-full max-h-[95vh] flex flex-col overflow-hidden relative animate-in fade-in zoom-in-95 duration-200">
      
      <!-- Top Modal Header -->
      <div class="flex items-center justify-between p-4 md:px-6 md:py-4 border-b border-slate-100 bg-white z-10 shrink-0 no-print">
        <div class="flex items-center gap-3">
          <span class="text-sm font-black text-slate-400 tracking-wider">REP-{{ reporte?.id || '---' }}</span>
          <span v-if="reporte" class="px-3 py-1 text-[10px] font-black uppercase tracking-widest rounded-full"
            :class="{
              'bg-blue-50 text-blue-600': reporte.estado === 'Abierto',
              'bg-purple-50 text-purple-600': reporte.estado === 'En Proceso' || reporte.estado === 'En Progreso',
              'bg-yellow-50 text-yellow-600': reporte.estado === 'Pendiente',
              'bg-emerald-50 text-emerald-600': reporte.estado === 'Resuelto',
              'bg-slate-100 text-slate-600': reporte.estado === 'Cerrado',
              'bg-red-50 text-red-600': reporte.estado === 'Cancelado'
            }">
            {{ reporte.estado }}
          </span>
          <span v-if="reporte" class="px-3 py-1 text-[10px] font-black uppercase tracking-widest rounded-full bg-slate-100 text-slate-600">
            {{ reporte.categoria }}
          </span>
        </div>

        <div class="flex items-center gap-3">
          <button @click="generarPDF" v-if="reporte" class="hidden md:flex items-center gap-2 px-4 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-xs font-bold transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
            PDF Reporte
          </button>
          
          <button @click="generarPDFResoluciones" v-if="reporte" class="hidden md:flex items-center gap-2 px-4 py-2 bg-indigo-50 hover:bg-indigo-100 text-indigo-700 rounded-xl text-xs font-bold transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"></path></svg>
            PDF Resoluciones
          </button>
          

          
          <button @click="goBack" class="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition-colors ml-1">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
          </button>
        </div>
      </div>
      
      <!-- Encabezado exclusivo para impresión -->
      <div class="hidden print-header w-full lg:col-span-3 justify-between items-center border-b-2 border-gray-300 pb-4 mb-2 p-6">
        <div>
          <h2 class="text-2xl font-black text-gray-800 uppercase tracking-tight">Reporte de Incidencia</h2>
          <p class="text-sm text-gray-500 font-medium mt-1">Documento de control interno</p>
        </div>
        <img src="http://localhost:3007/uploads/Logo/Logo.png" alt="Logo de la Empresa" class="h-12 object-contain" />
      </div>

      <!-- Modal Scrollable Content -->
      <div class="flex-1 overflow-y-auto bg-white" id="reporte-print-area">
        
        <!-- Loading state -->
        <div v-if="loading" class="flex justify-center items-center py-32">
          <span class="text-slate-400 font-bold text-xs uppercase tracking-widest animate-pulse">Cargando detalles del reporte...</span>
        </div>

        <!-- Main Content Grid -->
        <div v-else-if="reporte" class="p-6 md:p-8">
          <h1 class="text-2xl font-black text-slate-800 mb-8 tracking-tight leading-tight">{{ reporte.tema }}</h1>
          
          <div class="grid grid-cols-1 lg:grid-cols-3 gap-10">
            
            <!-- COLUMNA IZQUIERDA: Contenido Principal (Ocupa 2/3) -->
            <div class="lg:col-span-2 space-y-8">
              
              <!-- Conversación Inicial -->
              <div class="bg-white rounded-2xl border border-slate-100 overflow-hidden shadow-sm printable-card">
                <div class="p-6">
                  <div class="flex items-start gap-4 mb-5">
                    <div class="w-12 h-12 rounded-full bg-blue-100 text-blue-600 font-bold flex items-center justify-center shrink-0 uppercase border border-slate-200">
                      {{ reporte.jefe_reporta ? reporte.jefe_reporta.charAt(0) : '?' }}
                    </div>
                    <div>
                      <h3 class="text-sm font-bold text-slate-900">{{ reporte.jefe_reporta }} <span class="font-normal text-slate-500 text-xs ml-1">(Reporta)</span></h3>
                      <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-0.5">{{ new Date(reporte.fecha_creacion).toLocaleString() }}</p>
                    </div>
                  </div>

                  <div class="text-slate-600 text-sm leading-relaxed whitespace-pre-line pl-16">
                    {{ reporte.descripcion }}
                  </div>

                  <!-- Archivo Adjunto -->
                  <div v-if="reporte.archivo" class="mt-6 ml-16 no-print">
                    <div v-if="isImage(reporte.archivo)" class="mt-2 text-center rounded-xl overflow-hidden border border-slate-200">
                      <img :src="`http://localhost:3007${reporte.archivo}`" class="max-w-full max-h-[400px] object-contain mx-auto" alt="Evidencia" />
                    </div>
                    <div v-else class="inline-flex items-center gap-3 px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl hover:border-purple-300 transition-colors">
                      <span class="text-purple-500">📎</span>
                      <a :href="`http://localhost:3007${reporte.archivo}`" target="_blank" class="text-xs font-bold text-slate-700 hover:text-purple-600 transition-colors">
                        Archivo Adjunto
                      </a>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Respuestas -->
              <div class="space-y-6 printable-card" id="resoluciones-section">
                
                <div v-for="res in respuestas" :key="res.id" class="bg-slate-50/50 rounded-2xl border border-slate-100 p-6 shadow-sm">
                  <div class="flex items-start gap-4 mb-4">
                    <div v-if="res.usuario_foto || res.empleado_foto" class="w-10 h-10 rounded-full overflow-hidden border border-slate-200 shrink-0 shadow-sm">
                      <img :src="`http://localhost:3007${res.usuario_foto || res.empleado_foto}`" class="w-full h-full object-cover" />
                    </div>
                    <div v-else class="w-10 h-10 rounded-full bg-indigo-50 text-indigo-600 font-black flex items-center justify-center shrink-0 uppercase border border-indigo-100 shadow-sm">
                      {{ (res.usuario_nombre || res.empleado_nombre || 'U').charAt(0) }}
                    </div>
                    <div>
                      <div class="flex items-center gap-2">
                        <h4 class="text-sm font-bold text-slate-900">{{ res.usuario_nombre || (res.empleado_nombre + ' ' + res.empleado_apellido) }}</h4>
                      </div>
                      <p class="text-[10px] font-bold text-slate-400 uppercase tracking-widest mt-0.5">{{ new Date(res.fecha_creacion).toLocaleString() }}</p>
                    </div>
                  </div>
                  
                  <p class="text-sm text-slate-600 leading-relaxed whitespace-pre-line pl-14">{{ res.mensaje }}</p>
                  
                  <div v-if="res.archivo" class="mt-4 ml-14 inline-flex items-center gap-2 px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-xs hover:border-indigo-300 transition-colors no-print">
                    <span>📎</span>
                    <a :href="`http://localhost:3007${res.archivo}`" target="_blank" class="text-indigo-600 font-bold truncate max-w-[200px] hover:underline">Archivo Adjunto</a>
                  </div>
                </div>

                <div v-if="respuestas.length === 0" class="text-center py-6 text-slate-400 font-bold text-xs uppercase tracking-widest">
                  No hay respuestas registradas aún.
                </div>

              </div>

              <!-- Formulario Nueva Respuesta -->
              <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mt-8 no-print">
                <div class="p-4 bg-slate-50 border-b border-slate-100">
                  <h4 class="text-xs font-black text-slate-500 uppercase tracking-widest">Añadir una respuesta o nota</h4>
                </div>
                <form @submit.prevent="enviarRespuesta" class="p-5 space-y-4">
                  <textarea v-model="nuevaRespuestaMensaje" rows="3" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:bg-white outline-none text-sm text-slate-700 transition-all resize-none" placeholder="Escribe tus resoluciones o comentarios aquí..." required></textarea>
                  
                  <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div class="relative overflow-hidden cursor-pointer group">
                      <input type="file" @change="manejarArchivo" class="absolute inset-0 opacity-0 cursor-pointer" />
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
              <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5 no-print">
                <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Cambiar de Estado</label>
                <div class="relative">
                  <select v-model="estadoActual" @change="actualizarEstado" class="block w-full pl-3 pr-10 py-2.5 text-sm border border-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500 rounded-lg appearance-none bg-white font-medium text-gray-700 cursor-pointer">
                    <option value="Pendiente">Pendiente</option>
                    <option value="En Proceso">En Proceso</option>
                    <option value="Resuelto">Resuelto</option>
                    <option value="Cancelado">Cancelado / Desestimado</option>
                  </select>
                  <div class="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-500">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
                  </div>
                </div>
              </div>

              <!-- Tarjeta Información del Empleado Reportado -->
              <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5 printable-card">
                <h3 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-4 border-b border-gray-100 pb-2">Empleado(s) Reportado(s)</h3>
                
                <div v-if="empleadosReportados.length > 0" class="space-y-4">
                  <div v-for="emp in empleadosReportados" :key="emp.identidad" class="flex items-center gap-3 border-b border-gray-50 pb-3 last:border-0 last:pb-0">
                    <div class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 shrink-0 bg-slate-100 flex items-center justify-center font-bold text-slate-500">
                      <img v-if="emp.foto" :src="`http://localhost:3007${emp.foto}`" alt="Avatar Empleado" class="w-full h-full object-cover" />
                      <span v-else>{{ emp.nombre ? emp.nombre.charAt(0) : '?' }}</span>
                    </div>
                    <div>
                      <p class="text-sm font-bold text-gray-900">{{ emp.nombre }} {{ emp.apellido }}</p>
                      <p class="text-[10px] text-gray-500 font-bold uppercase tracking-widest mt-0.5">Identidad: {{ emp.identidad }}</p>
                    </div>
                  </div>
                </div>

                <div v-else>
                  <div class="flex items-center gap-3 mb-4">
                    <div class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 shrink-0 bg-slate-100 flex items-center justify-center font-bold text-slate-500">
                      <img v-if="reporte.empleado_foto" :src="`http://localhost:3007${reporte.empleado_foto}`" alt="Avatar Empleado" class="w-full h-full object-cover" />
                      <span v-else>{{ reporte.empleado_nombre ? reporte.empleado_nombre.charAt(0) : '?' }}</span>
                    </div>
                    <div>
                      <p class="text-sm font-bold text-gray-900">{{ reporte.empleado_nombre || 'Desconocido' }} {{ reporte.empleado_apellido || '' }}</p>
                      <p class="text-[10px] text-gray-500 font-bold uppercase tracking-widest mt-0.5">
                        {{ reporte.departamento_nombre || 'Sin Departamento' }}
                      </p>
                    </div>
                  </div>
                  <div class="space-y-2 mt-4">
                    <div class="flex justify-between items-center text-xs">
                      <span class="text-gray-500 font-medium">Identidad</span>
                      <span class="font-bold text-gray-800">{{ reporte.identidad }}</span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Tarjeta Asignado A -->
              <div class="bg-white rounded-xl shadow-sm border border-gray-200 p-5 no-print">
                <h3 class="text-xs font-bold text-gray-500 uppercase tracking-wider mb-4 border-b border-gray-100 pb-2">Asignado A</h3>
                
                <div v-if="reporte.asignado_usuario_id" class="flex items-center gap-3 mb-4">
                  <div class="w-10 h-10 rounded-full overflow-hidden border border-blue-200 shrink-0 bg-blue-100 flex items-center justify-center font-bold text-blue-500">
                    <img v-if="reporte.asignado_usuario_foto" :src="`http://localhost:3007${reporte.asignado_usuario_foto}`" alt="Avatar Solicitante" class="w-full h-full object-cover" />
                    <span v-else>{{ reporte.asignado_usuario_nombre ? reporte.asignado_usuario_nombre.charAt(0) : '?' }}</span>
                  </div>
                  <div>
                    <p class="text-sm font-bold text-gray-900">{{ reporte.asignado_usuario_nombre }}</p>
                    <p class="text-[10px] text-gray-500 font-bold uppercase tracking-widest mt-0.5">RRHH / Responsable</p>
                  </div>
                </div>
                
                <div class="mt-2">
                  <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Reasignar o Asignar</label>
                  <div class="flex gap-2">
                    <select v-model="usuarioAsignarId" class="flex-1 bg-slate-50 border border-slate-200 text-gray-700 text-xs rounded-lg focus:ring-blue-500 focus:border-blue-500 p-2 outline-none">
                      <option value="" disabled>Seleccione...</option>
                      <option v-for="user in usuariosRRHH" :key="user.id" :value="user.id">{{ user.nombre }}</option>
                    </select>
                    <button @click="asignarUsuario" class="px-3 py-2 bg-slate-800 text-white text-[10px] font-black uppercase tracking-widest rounded-lg hover:bg-slate-700 transition-colors">
                      Guardar
                    </button>
                  </div>
                </div>
              </div>

            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, defineProps, defineEmits } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import Swal from 'sweetalert2'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

const props = defineProps({
  id: {
    type: [String, Number],
    default: null
  }
})
const emit = defineEmits(['close'])

const route = useRoute()
const router = useRouter()
const reporteId = props.id || route.query.id
const reporte = ref(null)
const respuestas = ref([])
const empleadosReportados = ref([])
const loading = ref(true)

// Formularios
const nuevaRespuestaMensaje = ref('')
const archivoSeleccionado = ref(null)
const enviandoRespuesta = ref(false)
const estadoActual = ref('')
const usuarioAsignarId = ref('')

const usuariosRRHH = ref([])
const usuarioActualId = ref(null)

const isImage = (filepath) => {
  if (!filepath) return false;
  return /\.(jpg|jpeg|png|gif|webp)$/i.test(filepath);
}

const goBack = () => {
  if (props.id) {
    emit('close')
  } else {
    router.push('/reportes-incidencia')
  }
}

const imprimirReporte = () => {
  window.print()
}

const generarPDF = async () => {
  if (!reporte.value) return;

  try {
    const doc = new jsPDF();
    
    // Encabezado
    doc.setFontSize(22);
    doc.setTextColor(220, 38, 38);
    doc.setFont('helvetica', 'bold');
    doc.text(`REPORTE DE INCIDENCIA`, 14, 20);
    
    doc.setFontSize(11);
    doc.setTextColor(100, 116, 139);
    doc.setFont('helvetica', 'normal');
    doc.text(`N° de Ticket: ${reporte.value.id}`, 14, 28);
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 33);
    doc.text(`Estado: ${(reporte.value.estado || '').toUpperCase()}`, 14, 38);
    
    // Línea divisoria
    doc.setDrawColor(220, 38, 38);
    doc.setLineWidth(0.5);
    doc.line(14, 42, 196, 42);



    // Información del Reporte
    autoTable(doc, {
      startY: 46,
      head: [['Información General', '']],
      body: [
        ['Tema / Asunto', reporte.value.tema || 'N/A'],
        ['Categoría', reporte.value.categoria || 'N/A'],
        ['Reportado Por', reporte.value.jefe_reporta || 'N/A'],
        ['Fecha del Reporte', new Date(reporte.value.fecha_creacion).toLocaleString('es-HN')],
      ],
      theme: 'grid',
      margin: { bottom: 60 },
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42] },
      columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } }
    });

    // Cargar fotos de empleados reportados
    let startYEmpTable = doc.lastAutoTable.finalY + 4;
    
    const empleadosConFoto = empleadosReportados.value.length > 0 
      ? empleadosReportados.value.filter(e => e.foto) 
      : (reporte.value.empleado_foto ? [{ foto: reporte.value.empleado_foto }] : []);

    if (empleadosConFoto.length > 0) {
      let currentX = 14;
      const imgY = doc.lastAutoTable.finalY + 4;
      const imgWidth = 30;
      const imgHeight = 30;
      let fotosAgregadas = false;

      for (let i = 0; i < empleadosConFoto.length; i++) {
        if (currentX + imgWidth > 196) break;
        const imgEmp = new Image();
        imgEmp.crossOrigin = 'Anonymous';
        imgEmp.src = `http://localhost:3007${empleadosConFoto[i].foto}`;
        await new Promise((resolve) => { imgEmp.onload = resolve; imgEmp.onerror = resolve; });
        try {
          doc.setFillColor(241, 245, 249);
          doc.roundedRect(currentX - 1, imgY - 1, imgWidth + 2, imgHeight + 2, 2, 2, 'F');
          const ext = imgEmp.src.toUpperCase().includes('.PNG') ? 'PNG' : 'JPEG';
          doc.addImage(imgEmp, ext, currentX, imgY, imgWidth, imgHeight);
          doc.setDrawColor(203, 213, 225);
          doc.setLineWidth(0.3);
          doc.roundedRect(currentX - 1, imgY - 1, imgWidth + 2, imgHeight + 2, 2, 2, 'S');
          
          currentX += imgWidth + 5;
          fotosAgregadas = true;
        } catch(e) {}
      }
      
      if (fotosAgregadas) {
        startYEmpTable = imgY + imgHeight + 3;
      }
    }

    // Información del Empleado
    autoTable(doc, {
      startY: startYEmpTable,
      head: [['Datos del Empleado Reportado', '']],
      body: [
        ['Nombre', `${reporte.value.empleado_nombre || ''} ${reporte.value.empleado_apellido || ''}`.trim() || 'N/A'],
        ['Identidad', reporte.value.identidad || 'N/A'],
        ['Departamento', reporte.value.departamento_nombre || 'No asignado']
      ],
      theme: 'grid',
      margin: { bottom: 60 },
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42] },
      columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } }
    });

    // Descripción
    const startYDesc = doc.lastAutoTable.finalY + 8;
    doc.setFontSize(12);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('Descripción del Incidente:', 14, startYDesc);
    
    doc.setFontSize(10);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(51, 65, 85);
    
    // Cargar la imagen del logo antes de generar el documento
    const img = new Image();
    img.crossOrigin = "Anonymous";
    img.src = 'http://localhost:3007/uploads/Logo/Logo.png';
    await new Promise((resolve) => {
      img.onload = resolve;
      img.onerror = resolve; // Continuar aunque falle la carga del logo
    });

    // Agregar Logo (esquina superior derecha)
    // x = 160, y = 15, ancho = 35, alto = 15 (ajustar según el logo)
    try {
      doc.addImage(img, 'PNG', 160, 15, 35, 15);
    } catch (e) {
      console.warn("No se pudo agregar el logo al PDF", e);
    }
    
    // Ajuste de texto para evitar salir del margen derecho
    const splitDesc = doc.splitTextToSize(reporte.value.descripcion || 'Sin descripción.', 180);
    doc.text(splitDesc, 14, startYDesc + 6);

    let currentY = startYDesc + 6 + splitDesc.length * 5;

    // --- Evidencia Adjunta ---
    if (reporte.value.archivo) {
      const isImg = isImage(reporte.value.archivo);
      const neededSpace = isImg ? 65 : 30;
      if (currentY + neededSpace > 255) { 
        doc.addPage(); 
        currentY = 20; 
      }
      
      doc.setFontSize(12);
      doc.setTextColor(15, 23, 42);
      doc.setFont('helvetica', 'bold');
      doc.text('Evidencia Adjunta del Incidente:', 14, currentY);
      currentY += 8;
      
      if (isImg) {
        try {
          const imgEvi = new Image();
          imgEvi.crossOrigin = "Anonymous";
          imgEvi.src = `http://localhost:3007${reporte.value.archivo}`;
          await new Promise((resolve) => {
            imgEvi.onload = resolve;
            imgEvi.onerror = resolve;
          });
          const extEvi = imgEvi.src.toUpperCase().includes('.PNG') ? 'PNG' : 'JPEG';
          
          const maxWidth = 55;
          const maxHeight = 45;
          let width = imgEvi.width || 80;
          let height = imgEvi.height || 80;
          
          if (width > maxWidth) {
            height = Math.round((height * maxWidth) / width);
            width = maxWidth;
          }
          if (height > maxHeight) {
            width = Math.round((width * maxHeight) / height);
            height = maxHeight;
          }

          const frameWidth = width + 6;
          const frameHeight = height + 6;
          
          doc.setFillColor(248, 250, 252);
          doc.setDrawColor(203, 213, 225);
          doc.setLineWidth(0.5);
          doc.roundedRect(14, currentY, frameWidth, frameHeight, 2, 2, 'FD');
          
          doc.addImage(imgEvi, extEvi, 17, currentY + 3, width, height);
          currentY += frameHeight + 10;
        } catch(e) {}
      } else {
        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        doc.setTextColor(59, 130, 246);
        doc.text('Documento adjunto disponible en el sistema (PDF/Doc)', 14, currentY);
        currentY += 10;
      }
    }

    // --- PIE DE PÁGINA (Firma) en todas las hojas ---
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      const pageHeight = doc.internal.pageSize.height;
      const footerY = pageHeight - 40; // Más espacio desde el fondo
      
      doc.setDrawColor(0);
      doc.setLineWidth(0.5);
      doc.line(65, footerY, 145, footerY); // Línea de la firma
      
      doc.setFontSize(11);
      doc.setTextColor(51, 65, 85);
      doc.setFont('helvetica', 'bold');
      doc.text('Firma de Jefe inmediato / supervisor', 105, footerY + 10, { align: 'center' });
      
      // Opcional: Numeración de página
      doc.setFontSize(8);
      doc.setTextColor(100, 116, 139);
      doc.text(`Página ${i} de ${totalPages}`, 196, pageHeight - 10, { align: 'right' });
    }

    // Guardar archivo
    doc.save(`Reporte_Incidencia_${reporte.value.id}.pdf`);
  } catch (error) {
    console.error("Error al generar PDF:", error);
    Swal.fire('Error', 'No se pudo generar el PDF: ' + error.message, 'error');
  }
}

const generarPDFResoluciones = async () => {
  if (!reporte.value) return;

  try {
    const doc = new jsPDF();
    
    // Encabezado
    doc.setFontSize(14); // Reducido para que no pegue con el logo
    doc.setTextColor(220, 38, 38);
    doc.setFont('helvetica', 'bold');
    doc.text(`REPORTE DE INCIDENCIA - RESOLUCIONES`, 14, 20);
    
    doc.setFontSize(11);
    doc.setTextColor(100, 116, 139);
    doc.setFont('helvetica', 'normal');
    doc.text(`N° de Ticket: ${reporte.value.id}`, 14, 28);
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 33);
    doc.text(`Estado: ${(reporte.value.estado || '').toUpperCase()}`, 14, 38);
    
    // Cargar Logo Superior Derecho
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = 'http://localhost:3007/uploads/Logo/Logo.png';
    await new Promise((resolve) => {
      imgLogo.onload = resolve;
      imgLogo.onerror = resolve;
    });
    try { doc.addImage(imgLogo, 'PNG', 160, 15, 35, 15); } catch(e) {}
    
    // Línea divisoria
    doc.setDrawColor(220, 38, 38);
    doc.setLineWidth(0.5);
    doc.line(14, 42, 196, 42);

    // --- Información General ---
    autoTable(doc, {
      startY: 48,
      head: [['Información General', '']],
      body: [
        ['Tema / Asunto', reporte.value.tema || 'N/A'],
        ['Categoría', reporte.value.categoria || 'N/A'],
        ['Reportado Por', reporte.value.jefe_reporta || 'N/A'],
        ['Fecha del Reporte', new Date(reporte.value.fecha_creacion).toLocaleString('es-HN')],
      ],
      theme: 'grid',
      margin: { bottom: 60 },
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42] },
      columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } }
    });

    // --- Cargar fotos del Empleado ---
    let startYEmpTableRes = doc.lastAutoTable.finalY + 8;
    
    const empleadosConFotoRes = empleadosReportados.value.length > 0 
      ? empleadosReportados.value.filter(e => e.foto) 
      : (reporte.value.empleado_foto ? [{ foto: reporte.value.empleado_foto }] : []);

    if (empleadosConFotoRes.length > 0) {
      let currentX = 14;
      const imgY = doc.lastAutoTable.finalY + 8;
      const imgWidth = 30;
      const imgHeight = 30;
      let fotosAgregadas = false;

      for (let i = 0; i < empleadosConFotoRes.length; i++) {
        if (currentX + imgWidth > 196) break;
        const imgEmp = new Image();
        imgEmp.crossOrigin = 'Anonymous';
        imgEmp.src = `http://localhost:3007${empleadosConFotoRes[i].foto}`;
        await new Promise((resolve) => { imgEmp.onload = resolve; imgEmp.onerror = resolve; });
        try {
          doc.setFillColor(241, 245, 249);
          doc.roundedRect(currentX - 1, imgY - 1, imgWidth + 2, imgHeight + 2, 2, 2, 'F');
          const ext = imgEmp.src.toUpperCase().includes('.PNG') ? 'PNG' : 'JPEG';
          doc.addImage(imgEmp, ext, currentX, imgY, imgWidth, imgHeight);
          doc.setDrawColor(203, 213, 225);
          doc.setLineWidth(0.3);
          doc.roundedRect(currentX - 1, imgY - 1, imgWidth + 2, imgHeight + 2, 2, 2, 'S');
          
          currentX += imgWidth + 5;
          fotosAgregadas = true;
        } catch(e) {}
      }
      
      if (fotosAgregadas) {
        startYEmpTableRes = imgY + imgHeight + 6;
      }
    }

    // --- Información del Empleado ---
    autoTable(doc, {
      startY: startYEmpTableRes,
      head: [['Datos del Empleado Reportado', '']],
      body: [
        ['Nombre', `${reporte.value.empleado_nombre || ''} ${reporte.value.empleado_apellido || ''}`.trim() || 'N/A'],
        ['Identidad', reporte.value.identidad || 'N/A'],
        ['Departamento', reporte.value.departamento_nombre || 'No asignado']
      ],
      theme: 'grid',
      margin: { bottom: 60 },
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42] },
      columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } }
    });

    let currentY = doc.lastAutoTable.finalY + 12;

    // --- Descripción del Incidente ---
    doc.setFontSize(12);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('Descripción del Incidente:', 14, currentY);
    
    doc.setFontSize(10);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(51, 65, 85);
    
    const splitDesc = doc.splitTextToSize(reporte.value.descripcion || 'Sin descripción.', 180);
    doc.text(splitDesc, 14, currentY + 7);
    
    currentY += 10 + (splitDesc.length * 5);

    // --- Evidencia Adjunta del Reporte Inicial ---
    if (reporte.value.archivo) {
      const isImg = isImage(reporte.value.archivo);
      const neededSpace = isImg ? 65 : 30;
      if (currentY + neededSpace > 255) { 
        doc.addPage(); 
        currentY = 20; 
      }
      
      doc.setFontSize(12);
      doc.setTextColor(15, 23, 42);
      doc.setFont('helvetica', 'bold');
      doc.text('Evidencia Adjunta del Incidente:', 14, currentY);
      currentY += 8;
      
      if (isImg) {
        try {
          const imgEvi = new Image();
          imgEvi.crossOrigin = "Anonymous";
          imgEvi.src = `http://localhost:3007${reporte.value.archivo}`;
          await new Promise((resolve) => {
            imgEvi.onload = resolve;
            imgEvi.onerror = resolve;
          });
          const extEvi = imgEvi.src.toUpperCase().includes('.PNG') ? 'PNG' : 'JPEG';
          
          const maxWidth = 55;
          const maxHeight = 45;
          let width = imgEvi.width || 80;
          let height = imgEvi.height || 80;
          
          if (width > maxWidth) {
            height = Math.round((height * maxWidth) / width);
            width = maxWidth;
          }
          if (height > maxHeight) {
            width = Math.round((width * maxHeight) / height);
            height = maxHeight;
          }

          const frameWidth = width + 6;
          const frameHeight = height + 6;
          
          doc.setFillColor(248, 250, 252);
          doc.setDrawColor(203, 213, 225);
          doc.setLineWidth(0.5);
          doc.roundedRect(14, currentY, frameWidth, frameHeight, 2, 2, 'FD');
          
          doc.addImage(imgEvi, extEvi, 17, currentY + 3, width, height);
          currentY += frameHeight + 10;
        } catch (e) {
          doc.setFontSize(10);
          doc.setFont('helvetica', 'normal');
          doc.text(`[Imagen no disponible en PDF] Archivo: ${reporte.value.archivo}`, 14, currentY);
          currentY += 10;
        }
      } else {
        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        doc.setTextColor(51, 65, 85);
        doc.text(`Archivo de documento adjunto: ${reporte.value.archivo}`, 14, currentY);
        currentY += 10;
      }
    } else {
      doc.setFontSize(10);
      doc.setFont('helvetica', 'italic');
      doc.setTextColor(100, 116, 139);
      doc.text('No hay evidencia adjunta al reporte inicial.', 14, currentY);
      currentY += 12;
    }

    // --- Conversación y Resoluciones ---
    if (currentY > 250) { doc.addPage(); currentY = 20; }
    
    doc.setFontSize(14);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('Conversación y Resoluciones:', 14, currentY);
    currentY += 6;

    if (respuestas.value && respuestas.value.length > 0) {
      const rows = respuestas.value.map(res => {
        const nombre = res.usuario_nombre || (res.empleado_nombre + ' ' + res.empleado_apellido);
        const fecha = new Date(res.fecha_creacion).toLocaleString('es-HN');
        let msg = res.mensaje;
        if (res.archivo) {
          msg += `\n\n[📎 Archivo Adjunto: ${res.archivo}]`;
        }
        return [
          `${nombre}\n${fecha}`,
          msg
        ];
      });

      autoTable(doc, {
        startY: currentY,
        head: [['Usuario / Fecha', 'Mensaje']],
        body: rows,
        theme: 'grid',
        margin: { bottom: 60 },
        headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42] },
        columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } },
        styles: { overflow: 'linebreak' }
      });
      currentY = doc.lastAutoTable.finalY + 20;
    } else {
      currentY += 4;
      doc.setFontSize(10);
      doc.setFont('helvetica', 'italic');
      doc.setTextColor(100, 116, 139);
      doc.text('No hay respuestas registradas aún.', 14, currentY);
      currentY += 20;
    }

    // --- PIE DE PÁGINA (Firma) en todas las hojas ---
    const totalPagesRes = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPagesRes; i++) {
      doc.setPage(i);
      const pageHeight = doc.internal.pageSize.height;
      const footerY = pageHeight - 40; // Más espacio desde el fondo
      
      doc.setDrawColor(0);
      doc.setLineWidth(0.5);
      doc.line(65, footerY, 145, footerY); // Línea de la firma
      
      doc.setFontSize(11);
      doc.setTextColor(51, 65, 85);
      doc.setFont('helvetica', 'bold');
      doc.text('Firma de Jefe inmediato / supervisor', 105, footerY + 10, { align: 'center' });
      
      // Opcional: Numeración de página
      doc.setFontSize(8);
      doc.setTextColor(100, 116, 139);
      doc.text(`Página ${i} de ${totalPagesRes}`, 196, pageHeight - 10, { align: 'right' });
    }

    doc.save(`Resoluciones_Incidencia_${reporte.value.id}.pdf`);
  } catch (error) {
    console.error("Error al generar PDF de resoluciones:", error);
    Swal.fire('Error', 'No se pudo generar el PDF de Resoluciones: ' + error.message, 'error');
  }
}

const cargarDetalles = async () => {
  if (!reporteId) return
  loading.value = true
  try {
    const res = await axios.get(`http://localhost:3007/api/reportes-incidencia/${reporteId}`)
    reporte.value = res.data
    estadoActual.value = res.data.estado
    await cargarRespuestas()

    try {
      const empRes = await axios.get('http://localhost:3007/api/empleados/lista')
      if (res.data.identidad) {
        const identidadesArr = res.data.identidad.split(',').map(i => i.trim())
        empleadosReportados.value = empRes.data.filter(e => identidadesArr.includes(e.identidad))
        if (empleadosReportados.value.length > 0) {
          reporte.value.empleado_nombre = empleadosReportados.value.map(e => `${e.nombre} ${e.apellido}`.trim()).join(', ')
          reporte.value.empleado_apellido = ''
          reporte.value.departamento_nombre = empleadosReportados.value
            .map(e => `${e.nombre} ${e.apellido}: ${e.departamento_nombre || 'Sin Departamento'}`)
            .join(', ')
          
          // Set the first employee's photo so at least one is shown in the PDF
          const firstWithPhoto = empleadosReportados.value.find(e => e.foto)
          if (firstWithPhoto) {
            reporte.value.empleado_foto = firstWithPhoto.foto
          }
        }
      }
    } catch (err) {
      console.error("Error al cargar lista de empleados para match:", err)
    }

    if (route.hash === '#resoluciones-section') {
      setTimeout(() => {
        const el = document.getElementById('resoluciones-section');
        if (el) el.scrollIntoView({ behavior: 'smooth' });
      }, 500);
    }
  } catch (error) {
    console.error("Error al cargar reporte:", error)
    Swal.fire('Error', 'No se pudo cargar el reporte', 'error')
  } finally {
    loading.value = false
  }
}

const cargarRespuestas = async () => {
  try {
    const res = await axios.get(`http://localhost:3007/api/reportes-incidencia/${reporteId}/respuestas`)
    respuestas.value = res.data
  } catch (error) {
    console.error("Error cargando respuestas:", error)
  }
}

const cargarUsuariosRRHH = async () => {
  try {
    // Podríamos filtrar solo los de RRHH, pero cargamos todos los usuarios activos por ahora
    const res = await axios.get('http://localhost:3007/api/usuarios')
    usuariosRRHH.value = res.data.filter(u => u.estado === 1)
  } catch (error) {
    console.error("Error cargando usuarios:", error)
  }
}

const manejarArchivo = (e) => {
  archivoSeleccionado.value = e.target.files[0]
}

const enviarRespuesta = async () => {
  if (!nuevaRespuestaMensaje.value.trim()) return

  try {
    enviandoRespuesta.value = true
    const formData = new FormData()
    formData.append('usuario_id', usuarioActualId.value)
    formData.append('mensaje', nuevaRespuestaMensaje.value)
    if (archivoSeleccionado.value) {
      formData.append('archivo', archivoSeleccionado.value)
    }

    await axios.post(`http://localhost:3007/api/reportes-incidencia/${reporteId}/respuestas`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })

    nuevaRespuestaMensaje.value = ''
    archivoSeleccionado.value = null
    await cargarRespuestas()
    
    // Si estaba Pendiente, cambiar a En Proceso
    if (reporte.value.estado === 'Pendiente') {
      await axios.put(`http://localhost:3007/api/reportes-incidencia/${reporteId}/estado`, { estado: 'En Proceso' })
      reporte.value.estado = 'En Proceso'
      estadoActual.value = 'En Proceso'
    }

  } catch (error) {
    console.error("Error al enviar respuesta:", error)
    Swal.fire('Error', 'No se pudo enviar la respuesta', 'error')
  } finally {
    enviandoRespuesta.value = false
  }
}

const actualizarEstado = async () => {
  try {
    await axios.put(`http://localhost:3007/api/reportes-incidencia/${reporteId}/estado`, { estado: estadoActual.value })
    reporte.value.estado = estadoActual.value
    Swal.fire({ icon: 'success', title: 'Estado actualizado', timer: 1500, showConfirmButton: false })
  } catch (error) {
    console.error("Error al actualizar estado:", error)
    Swal.fire('Error', 'No se pudo actualizar el estado', 'error')
  }
}

const asignarUsuario = async () => {
  if (!usuarioAsignarId.value) return
  
  try {
    await axios.put(`http://localhost:3007/api/reportes-incidencia/${reporteId}/asignar`, { usuario_id: usuarioAsignarId.value })
    Swal.fire({ icon: 'success', title: 'Asignado con éxito', timer: 1500, showConfirmButton: false })
    await cargarDetalles() // Recargar para mostrar el usuario asignado
  } catch (error) {
    console.error("Error al asignar:", error)
    Swal.fire('Error', 'No se pudo asignar el usuario', 'error')
  }
}

onMounted(() => {
  usuarioActualId.value = localStorage.getItem('usuarioID')
  cargarDetalles()
  cargarUsuariosRRHH()
})
</script>

<style>
@media print {
  @page {
    margin: 1cm;
    size: letter portrait;
  }
  
  html {
    font-size: 9px !important; /* Reduce el tamaño base para que todo quepa en una sola hoja */
  }

  body {
    background-color: white !important;
  }

  body * {
    visibility: hidden;
  }

  #reporte-print-area, #reporte-print-area * {
    visibility: visible;
  }

  #reporte-print-area {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    margin: 0;
    padding: 0;
  }

  /* Forzar la impresión de colores de fondo (badges, avatares, etc.) */
  * {
    -webkit-print-color-adjust: exact !important;
    print-color-adjust: exact !important;
  }

  .no-print {
    display: none !important;
  }

  .print-header {
    display: flex !important;
  }

  .print-evidence {
    display: block !important;
  }

  .print-img {
    max-height: 250px !important; /* Limita la altura de la imagen para ahorrar espacio */
  }

  .printable-card {
    border: 1px solid #e2e8f0 !important; /* Borde sutil y profesional */
    border-radius: 0.75rem !important;
    box-shadow: none !important;
    margin-bottom: 10px;
    page-break-inside: avoid; /* Evita que el cuadro se divida en dos páginas */
    break-inside: avoid;
  }
  
  /* Asegurar que el contenido del chat no se corte abruptamente */
  .flex-1.bg-gray-50 {
    page-break-inside: avoid;
    break-inside: avoid;
  }
}
</style>