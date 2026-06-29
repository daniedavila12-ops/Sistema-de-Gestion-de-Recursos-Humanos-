<template>
  <div class="max-w-7xl mx-auto p-4 md:p-6 bg-gray-50 min-h-screen font-sans">
    
    <div class="mb-6 flex justify-between items-center no-print">
      <button @click="goBack" class="text-sm text-gray-500 hover:text-blue-600 font-medium flex items-center transition-colors">
        <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"></path></svg>
        Volver a la lista
      </button>

      <div class="flex items-center gap-3">
        <button @click="generarPDF" class="px-4 py-2 bg-slate-800 text-white rounded-lg text-xs font-black uppercase tracking-widest shadow-md hover:bg-slate-900 transition-colors flex items-center gap-2">
          <span>📄</span> Crear PDF
        </button>
        <button @click="generarPDFResoluciones" class="px-4 py-2 bg-indigo-600 text-white rounded-lg text-xs font-black uppercase tracking-widest shadow-md hover:bg-indigo-700 transition-colors flex items-center gap-2">
          <span>💬</span> PDF Resoluciones
        </button>
        <button @click="imprimirReporte" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-xs font-black uppercase tracking-widest shadow-md hover:bg-blue-700 transition-colors flex items-center gap-2">
          <span>🖨️</span> Imprimir Reporte
        </button>
      </div>
    </div>

    <!-- Loading state -->
    <div v-if="loading" class="flex justify-center items-center py-20">
      <span class="text-gray-500 font-medium">Cargando detalles del reporte...</span>
    </div>

    <div v-else-if="reporte" class="grid grid-cols-1 lg:grid-cols-3 gap-6" id="reporte-print-area">
      
      <!-- Encabezado exclusivo para impresión -->
      <div class="hidden print-header w-full lg:col-span-3 justify-between items-center border-b-2 border-gray-300 pb-4 mb-2">
        <div>
          <h2 class="text-2xl font-black text-gray-800 uppercase tracking-tight">Reporte de Incidencia</h2>
          <p class="text-sm text-gray-500 font-medium mt-1">Documento de control interno</p>
        </div>
        <img src="http://localhost:3007/uploads/Logo/Logo.png" alt="Logo de la Empresa" class="h-12 object-contain" />
      </div>

      <!-- COLUMNA IZQUIERDA: Contenido Principal -->
      <div class="lg:col-span-2 space-y-6">
        
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden printable-card">
          <div class="p-6 border-b border-gray-100 flex flex-wrap justify-between items-center gap-3 bg-red-50/30">
            <div class="flex items-center gap-3">
              <h1 class="text-2xl font-black text-gray-800 uppercase">Reporte #{{ reporte.id }}</h1>
              <span class="px-3 py-1 text-xs font-bold rounded-full bg-red-100 text-red-700 border border-red-200 uppercase tracking-widest">
                Incidente
              </span>
            </div>
            <div class="flex gap-2">
              <span class="px-3 py-1 text-xs font-bold rounded-full border border-gray-200 bg-gray-100 text-gray-700 uppercase tracking-widest">
                {{ reporte.estado }}
              </span>
            </div>
          </div>

          <div class="p-6">
            <h2 class="text-xl font-bold text-gray-900 mb-6">{{ reporte.tema }}</h2>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
              <!-- Info del Reportado -->
              <div class="bg-slate-50 p-4 rounded-xl border border-slate-100">
                <h3 class="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-3 border-b border-slate-200 pb-2">Empleado Reportado</h3>
                <div class="flex items-center gap-3 mb-2">
                  <div class="w-10 h-10 rounded-full bg-slate-300 flex items-center justify-center font-bold text-slate-600 text-sm overflow-hidden border border-white">
                    <img v-if="reporte.empleado_foto" :src="`http://localhost:3007${reporte.empleado_foto}`" class="w-full h-full object-cover">
                    <span v-else>{{ reporte.empleado_nombre ? reporte.empleado_nombre.charAt(0) : '?' }}</span>
                  </div>
                  <div>
                    <p class="font-bold text-slate-800 text-sm">{{ reporte.empleado_nombre }} {{ reporte.empleado_apellido }}</p>
                    <p class="text-xs text-slate-500">{{ reporte.departamento_nombre || 'Sin Departamento' }}</p>
                  </div>
                </div>
                <div class="text-xs space-y-1 mt-3">
                  <p><span class="font-bold text-slate-600">Identidad:</span> {{ reporte.identidad }}</p>
                </div>
              </div>

              <!-- Info del Jefe -->
              <div class="bg-blue-50/50 p-4 rounded-xl border border-blue-100">
                <h3 class="text-[10px] font-black text-blue-500 uppercase tracking-widest mb-3 border-b border-blue-200 pb-2">Reportado Por</h3>
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full bg-blue-200 flex items-center justify-center font-bold text-blue-700 text-sm">
                    {{ reporte.jefe_reporta.charAt(0) }}
                  </div>
                  <div>
                    <p class="font-bold text-slate-800 text-sm">{{ reporte.jefe_reporta }}</p>
                    <p class="text-xs text-slate-500">Jefe / Encargado</p>
                  </div>
                </div>
                <div class="text-xs mt-4">
                  <p><span class="font-bold text-slate-600">Fecha del Reporte:</span> {{ new Date(reporte.fecha_creacion).toLocaleString() }}</p>
                  <p class="mt-1"><span class="font-bold text-slate-600">Categoría:</span> {{ reporte.categoria }}</p>
                </div>
              </div>
            </div>

            <h3 class="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2 pl-1">Descripción del Incidente</h3>
            <div class="text-gray-700 text-sm leading-relaxed whitespace-pre-line bg-gray-50 p-4 rounded-xl border border-gray-100">
              {{ reporte.descripcion }}
            </div>

            <div v-if="reporte.archivo" class="mt-6 border-2 border-dashed border-gray-300 rounded-xl p-4 flex flex-col gap-4 bg-gray-50/50">
              <div class="flex items-center justify-between no-print">
                <div class="flex items-center gap-3">
                  <div class="p-2 bg-blue-100 text-blue-600 rounded-lg">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"></path></svg>
                  </div>
                  <div>
                    <p class="text-sm font-semibold text-gray-800">Evidencia Adjunta</p>
                  </div>
                </div>
                <a :href="`http://localhost:3007${reporte.archivo}`" target="_blank" class="px-4 py-2 text-sm font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors">
                  Ver Archivo
                </a>
              </div>
              
              <!-- Vista de impresión para la evidencia -->
              <div class="hidden print-evidence mt-4">
                <h3 class="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2 border-b border-gray-200 pb-1">Evidencia Adjunta</h3>
                <div v-if="isImage(reporte.archivo)" class="mt-2 text-center">
                  <img :src="`http://localhost:3007${reporte.archivo}`" class="max-w-full max-h-[500px] print-img object-contain mx-auto border border-gray-200 rounded-md" alt="Evidencia" />
                </div>
                <div v-else class="mt-2 p-3 bg-gray-100 border border-gray-200 rounded-md">
                  <p class="text-xs text-gray-600">El archivo adjunto es un documento. (Ruta: {{ reporte.archivo }})</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Sección de Respuestas -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden mt-6 printable-card">
          <div class="p-6 border-b border-gray-100 bg-slate-50 flex justify-between items-center">
            <h3 class="text-lg font-black text-gray-800 tracking-tight">Conversación y Resoluciones</h3>
            <span class="text-xs font-bold text-slate-500 bg-slate-200 px-2 py-1 rounded-md">{{ respuestas.length }} mensajes</span>
          </div>
          <div class="p-6 space-y-6">
            
            <div v-for="res in respuestas" :key="res.id" class="flex gap-4">
              <div v-if="res.usuario_foto || res.empleado_foto" class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 shrink-0">
                <img :src="`http://localhost:3007${res.usuario_foto || res.empleado_foto}`" class="w-full h-full object-cover" />
              </div>
              <div v-else class="w-10 h-10 rounded-full bg-slate-200 text-slate-500 font-bold flex items-center justify-center shrink-0 uppercase border border-gray-200">
                {{ (res.usuario_nombre || res.empleado_nombre || 'U').charAt(0) }}
              </div>
              
              <div class="flex-1 bg-gray-50 rounded-2xl rounded-tl-none p-4 border border-gray-100">
                <div class="flex justify-between items-center mb-2">
                  <h4 class="text-sm font-bold text-gray-900">{{ res.usuario_nombre || (res.empleado_nombre + ' ' + res.empleado_apellido) }}</h4>
                  <span class="text-[10px] text-gray-500 font-medium">{{ new Date(res.fecha_creacion).toLocaleString() }}</span>
                </div>
                <p class="text-sm text-gray-700 whitespace-pre-line">{{ res.mensaje }}</p>
                
                <div v-if="res.archivo" class="mt-3 inline-flex items-center gap-2 bg-white border border-gray-200 rounded-lg p-2 text-xs hover:border-blue-300 transition-colors no-print">
                  <span>📎</span>
                  <a :href="`http://localhost:3007${res.archivo}`" target="_blank" class="text-blue-600 font-medium hover:underline truncate max-w-[200px]">Archivo Adjunto</a>
                </div>
              </div>
            </div>

            <div v-if="respuestas.length === 0" class="text-center py-6 text-gray-500 text-sm">
              No hay respuestas registradas aún.
            </div>

            <!-- Formulario Nueva Respuesta -->
            <div class="pt-6 border-t border-gray-100 mt-6 no-print">
              <h4 class="text-[10px] font-black text-slate-500 uppercase tracking-widest mb-3">Añadir una respuesta o nota</h4>
              <form @submit.prevent="enviarRespuesta" class="space-y-4">
                <textarea v-model="nuevaRespuestaMensaje" rows="3" class="w-full p-4 bg-slate-50 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none text-sm text-gray-700 resize-none transition-colors" placeholder="Escribe aquí las resoluciones o comentarios..." required></textarea>
                
                <div class="flex flex-wrap items-center justify-between gap-4">
                  <div class="relative overflow-hidden cursor-pointer">
                    <input type="file" @change="manejarArchivo" class="absolute inset-0 opacity-0 cursor-pointer" />
                    <button type="button" class="flex items-center gap-2 px-4 py-2 bg-white border border-slate-200 hover:bg-slate-50 text-slate-700 rounded-xl text-xs font-bold uppercase tracking-widest transition-colors cursor-pointer">
                      <span>📎</span> {{ archivoSeleccionado ? archivoSeleccionado.name : 'Adjuntar' }}
                    </button>
                  </div>
                  
                  <button type="submit" :disabled="enviandoRespuesta" class="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-xl font-black text-xs uppercase tracking-widest shadow-md transition-all disabled:opacity-50">
                    {{ enviandoRespuesta ? 'Enviando...' : 'Enviar Respuesta' }}
                  </button>
                </div>
              </form>
            </div>

          </div>
        </div>
      </div>

      <!-- COLUMNA DERECHA: Panel de Detalles y Acciones -->
      <div class="lg:col-span-1 space-y-6 no-print">
        
        <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
          <div class="p-4 border-b border-gray-100 bg-slate-50">
            <h3 class="text-xs font-black text-slate-800 uppercase tracking-widest">Gestión del Reporte</h3>
          </div>
          <div class="p-4 space-y-5">
            
            <!-- Cambiar Estado -->
            <div>
              <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Cambiar Estado</label>
              <select v-model="estadoActual" @change="actualizarEstado" class="w-full bg-slate-50 border border-slate-200 text-gray-700 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5 outline-none font-medium">
                <option value="Pendiente">Pendiente</option>
                <option value="En Proceso">En Proceso</option>
                <option value="Resuelto">Resuelto</option>
                <option value="Cancelado">Cancelado / Desestimado</option>
              </select>
            </div>

            <hr class="border-gray-100">

            <!-- Asignar a Usuario (Recursos Humanos) -->
            <div>
              <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-2">Asignado A</label>
              
              <div v-if="reporte.asignado_usuario_id" class="flex items-center gap-3 p-3 bg-blue-50 rounded-xl border border-blue-100 mb-3">
                <div class="w-8 h-8 rounded-full bg-blue-200 text-blue-700 font-bold flex items-center justify-center text-xs overflow-hidden">
                  <img v-if="reporte.asignado_usuario_foto" :src="`http://localhost:3007${reporte.asignado_usuario_foto}`" class="w-full h-full object-cover">
                  <span v-else>{{ reporte.asignado_usuario_nombre.charAt(0) }}</span>
                </div>
                <div>
                  <p class="text-xs font-bold text-slate-800">{{ reporte.asignado_usuario_nombre }}</p>
                  <p class="text-[10px] text-slate-500 uppercase tracking-widest">Responsable</p>
                </div>
              </div>

              <div class="flex gap-2">
                <select v-model="usuarioAsignarId" class="flex-1 bg-slate-50 border border-slate-200 text-gray-700 text-xs rounded-lg focus:ring-blue-500 focus:border-blue-500 p-2 outline-none">
                  <option value="" disabled>Seleccionar Usuario...</option>
                  <option v-for="user in usuariosRRHH" :key="user.id" :value="user.id">{{ user.nombre }}</option>
                </select>
                <button @click="asignarUsuario" class="px-3 py-2 bg-slate-800 text-white text-[10px] font-black uppercase tracking-widest rounded-lg hover:bg-slate-700 transition-colors">
                  Asignar
                </button>
              </div>
            </div>

          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import Swal from 'sweetalert2'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

const route = useRoute()
const router = useRouter()
const reporteId = route.query.id
const reporte = ref(null)
const respuestas = ref([])
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
  router.push('/reportes-incidencia')
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
      startY: 48,
      head: [['Información General', '']],
      body: [
        ['Tema / Asunto', reporte.value.tema || 'N/A'],
        ['Categoría', reporte.value.categoria || 'N/A'],
        ['Reportado Por', reporte.value.jefe_reporta || 'N/A'],
        ['Fecha del Reporte', new Date(reporte.value.fecha_creacion).toLocaleString('es-HN')],
      ],
      theme: 'grid',
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42] },
      columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } }
    });

    // Información del Empleado
    autoTable(doc, {
      startY: doc.lastAutoTable.finalY + 10,
      head: [['Datos del Empleado Reportado', '']],
      body: [
        ['Nombre', `${reporte.value.empleado_nombre || ''} ${reporte.value.empleado_apellido || ''}`.trim() || 'N/A'],
        ['Identidad', reporte.value.identidad || 'N/A'],
        ['Departamento', reporte.value.departamento_nombre || 'No asignado']
      ],
      theme: 'grid',
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42] },
      columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } }
    });

    // Descripción
    const startYDesc = doc.lastAutoTable.finalY + 15;
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
    doc.text(splitDesc, 14, startYDesc + 7);

    // --- PIE DE PÁGINA (Firma) en todas las hojas ---
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      const pageHeight = doc.internal.pageSize.height;
      const footerY = pageHeight - 30; // Posición fija al fondo de cada hoja
      
      doc.setDrawColor(0);
      doc.setLineWidth(0.5);
      doc.line(65, footerY, 145, footerY); // Línea de la firma
      
      doc.setFontSize(10);
      doc.setTextColor(0, 0, 0);
      doc.setFont('helvetica', 'normal');
      doc.text('Firma de Jefe inmediato / supervisor', 105, footerY + 5, { align: 'center' });
      
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
      headStyles: { fillColor: [241, 245, 249], textColor: [15, 23, 42] },
      columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } }
    });

    // --- Información del Empleado ---
    autoTable(doc, {
      startY: doc.lastAutoTable.finalY + 8,
      head: [['Datos del Empleado Reportado', '']],
      body: [
        ['Nombre', `${reporte.value.empleado_nombre || ''} ${reporte.value.empleado_apellido || ''}`.trim() || 'N/A'],
        ['Identidad', reporte.value.identidad || 'N/A'],
        ['Departamento', reporte.value.departamento_nombre || 'No asignado']
      ],
      theme: 'grid',
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
      if (currentY > 230) { doc.addPage(); currentY = 20; }
      
      doc.setFontSize(12);
      doc.setTextColor(15, 23, 42);
      doc.setFont('helvetica', 'bold');
      doc.text('Evidencia Adjunta del Incidente:', 14, currentY);
      currentY += 8;
      
      if (isImage(reporte.value.archivo)) {
        try {
          const imgEvi = new Image();
          imgEvi.crossOrigin = "Anonymous";
          imgEvi.src = `http://localhost:3007${reporte.value.archivo}`;
          await new Promise((resolve) => {
            imgEvi.onload = resolve;
            imgEvi.onerror = resolve;
          });
          
          doc.addImage(imgEvi, 'JPEG', 14, currentY, 80, 80);
          currentY += 85;
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
      const footerY = pageHeight - 30; // Posición fija al fondo de cada hoja
      
      doc.setDrawColor(0);
      doc.setLineWidth(0.5);
      doc.line(65, footerY, 145, footerY); // Línea de la firma
      
      doc.setFontSize(10);
      doc.setTextColor(0, 0, 0);
      doc.setFont('helvetica', 'normal');
      doc.text('Firma de Jefe inmediato / supervisor', 105, footerY + 5, { align: 'center' });
      
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