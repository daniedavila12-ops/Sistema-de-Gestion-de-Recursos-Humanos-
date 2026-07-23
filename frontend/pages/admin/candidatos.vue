<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <!-- SIDEBAR -->
    <AppSidebar />

    <!-- CONTENIDO PRINCIPAL -->
    <main class="w-full overflow-x-hidden transition-all duration-300 flex-1 md:ml-64 p-8">
      <header class="mb-6 flex flex-col gap-5 bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div class="flex justify-between items-center w-full">
          <button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors mr-3 shrink-0">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
          </button>
          <div>
            <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Candidatos Reclutamiento</h1>
            <p class="text-slate-500 mt-1 font-medium italic">Gestión de aspirantes y revisión de Currículums.</p>
          </div>
          <div class="flex items-center gap-4">
            <!-- Botón de Generar QR -->
            <button @click="generarPDFQR" class="bg-blue-600 hover:bg-blue-700 text-white text-sm font-bold py-2.5 px-4 rounded-xl shadow-md transition-all hover:-translate-y-0.5 flex items-center gap-2 group no-print">
              <span class="group-hover:scale-110 transition-transform">📱</span>
              <span>Generar QR PDF</span>
            </button>
            <!-- Botón de Generar PDF -->
            <button @click="generarPDF" class="bg-red-600 hover:bg-red-700 text-white text-sm font-bold py-2.5 px-4 rounded-xl shadow-md transition-all hover:-translate-y-0.5 flex items-center gap-2 group no-print">
              <span class="group-hover:scale-110 transition-transform">📄</span>
              <span>Generar Reporte PDF</span>
            </button>
            <div class="relative w-full md:w-auto flex justify-end">
              <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-6 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors no-print">
                <div v-if="fotoUsuario" class="h-10 w-10 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-slate-100">
                  <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-lg ring-2 ring-slate-100 uppercase">
                  {{ usuarioActual ? usuarioActual.charAt(0) : 'U' }}
                </div>
                <div class="flex flex-col text-left">
                  <span class="text-[10px] text-slate-400 font-black uppercase tracking-widest">Usuario Activo</span>
                  <span class="text-base font-black text-slate-900 leading-tight">{{ usuarioActual || 'Cargando...' }}</span>
                </div>
              </div>

              <!-- Dropdown Menu -->
              <div v-if="dropdownPerfilAbierto" class="absolute right-0 mt-14 w-64 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50 animate-in slide-in-from-top-2 duration-200 no-print">
                <div class="p-5 border-b border-slate-100 bg-slate-50 flex items-center gap-4">
                  <div v-if="fotoUsuario" class="h-12 w-12 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-white shadow-sm shrink-0">
                    <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
                  </div>
                  <div v-else class="h-12 w-12 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-xl ring-2 ring-white shadow-sm shrink-0 uppercase">
                    {{ usuarioActual ? usuarioActual.charAt(0) : 'U' }}
                  </div>
                  <div>
                    <p class="font-black text-slate-800 text-sm leading-tight">{{ usuarioActual || 'Cargando...' }}</p>
                    <p class="text-[10px] font-bold text-blue-500 uppercase tracking-widest mt-0.5">{{ rolNombre || 'Cargando...' }}</p>
                  </div>
                </div>
                <div class="p-2 space-y-1">
                  <button @click="logout" class="w-full text-left flex items-center gap-3 p-3 hover:bg-red-50 rounded-xl transition-colors group">
                    <span class="text-lg group-hover:scale-110 transition-transform">🚪</span>
                    <span class="text-sm font-bold text-red-600">Cerrar Sesión</span>
                  </button>
                </div>
              </div>
              <div v-if="dropdownPerfilAbierto" @click="dropdownPerfilAbierto = false" class="fixed inset-0 z-40"></div>
            </div>
          </div>
        </div>
      </header>

      <!-- Barra de Búsqueda -->
      <div class="mb-6">
        <div class="relative max-w-md">
          <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
            🔍
          </span>
          <input 
            type="text" 
            v-model="searchQuery" 
            placeholder="Buscar por nombre, puesto, correo o teléfono..." 
            class="w-full pl-10 pr-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition shadow-sm text-sm"
          />
        </div>
      </div>

      <!-- Tabla de Candidatos -->
      <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-sm text-slate-600">
            <thead class="bg-slate-50 border-b border-slate-100 text-slate-800 uppercase text-xs font-black tracking-wider">
              <tr>
                <th class="px-6 py-4">Candidato</th>
                <th class="px-6 py-4">Puesto Aplicado</th>
                <th class="px-6 py-4">Contacto</th>
                <th class="px-6 py-4">Fecha</th>
                <th class="px-6 py-4">CV</th>
                <th class="px-6 py-4 text-center">Estado</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr v-if="loadingCandidatos">
                <td colspan="6" class="px-6 py-12 text-center text-slate-400 font-bold">
                  <div class="flex justify-center items-center gap-3">
                    <svg class="animate-spin h-5 w-5 text-blue-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Cargando candidatos...
                  </div>
                </td>
              </tr>
              <tr v-else-if="candidatosFiltrados.length === 0">
                <td colspan="6" class="px-6 py-12 text-center text-slate-400 font-bold">
                  No se encontraron candidatos.
                </td>
              </tr>
              <tr v-else v-for="candidato in candidatosFiltrados" :key="candidato.id" class="hover:bg-slate-50 transition-colors">
                <td class="px-6 py-4">
                  <div class="font-bold text-slate-800">{{ candidato.nombre_completo }}</div>
                </td>
                <td class="px-6 py-4 font-medium">{{ candidato.puesto_aplicado }}</td>
                <td class="px-6 py-4">
                  <div class="font-medium text-slate-800">{{ candidato.correo }}</div>
                  <div class="text-xs text-slate-500">{{ candidato.telefono }}</div>
                </td>
                <td class="px-6 py-4 text-slate-500">
                  {{ formatFecha(candidato.created_at) }}
                </td>
                <td class="px-6 py-4">
                  <a :href="`${$config.public.apiBase}${candidato.cv_url}`" target="_blank" class="inline-flex items-center gap-2 bg-blue-50 text-blue-600 px-3 py-1.5 rounded-lg font-bold hover:bg-blue-100 transition-colors">
                    📄 Ver PDF
                  </a>
                </td>
                <td class="px-6 py-4 text-center">
                  <select 
                    v-model="candidato.estado" 
                    @change="actualizarEstado(candidato)"
                    :class="[
                      'px-3 py-1.5 rounded-full text-xs font-bold border-0 ring-1 outline-none focus:ring-2 appearance-none cursor-pointer text-center w-full max-w-[120px]',
                      estadoClass(candidato.estado)
                    ]">
                    <option value="Recibido">Recibido</option>
                    <option value="Entrevista">Entrevista</option>
                    <option value="Descartado">Descartado</option>
                    <option value="Contratado">Contratado</option>
                  </select>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { useSidebar } from '@/composables/useSidebar'
const { toggleMobileMenu } = useSidebar()
import { ref, onMounted, computed } from 'vue';
import axios from 'axios';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

// Variables de estado global y Sidebar
const rolID = ref(null);
const rolNombre = ref('Cargando...');
;
const usuarioActual = ref('');
const fotoUsuario = ref(null);
const dropdownPerfilAbierto = ref(false);

// Variables del componente Candidatos
const candidatos = ref([]);
const loadingCandidatos = ref(true);
const searchQuery = ref('');

const candidatosFiltrados = computed(() => {
  if (!searchQuery.value) return candidatos.value;
  const q = searchQuery.value.toLowerCase();
  return candidatos.value.filter(c => 
    c.nombre_completo?.toLowerCase().includes(q) ||
    c.puesto_aplicado?.toLowerCase().includes(q) ||
    c.correo?.toLowerCase().includes(q) ||
    c.telefono?.toLowerCase().includes(q)
  );
});

const logout = () => {
  localStorage.clear();
  navigateTo('/dashboard');
};

const formatFecha = (fecha) => {
  return new Date(fecha).toLocaleDateString('es-ES', {
    day: '2-digit', month: 'short', year: 'numeric'
  });
};

const estadoClass = (estado) => {
  switch (estado) {
    case 'Recibido': return 'bg-sky-50 text-sky-700 ring-sky-200 focus:ring-sky-500';
    case 'Entrevista': return 'bg-amber-50 text-amber-700 ring-amber-200 focus:ring-amber-500';
    case 'Descartado': return 'bg-red-50 text-red-700 ring-red-200 focus:ring-red-500';
    case 'Contratado': return 'bg-emerald-50 text-emerald-700 ring-emerald-200 focus:ring-emerald-500';
    default: return 'bg-gray-50 text-gray-700 ring-gray-200 focus:ring-gray-500';
  }
};

const generarPDF = async () => {
  const doc = new jsPDF();
  
  try {
    // Intentar cargar el logo desde el backend
    const logoUrl = `${useRuntimeConfig().public.apiBase}/uploads/Logo/Logo.png`;
    const imgElement = new Image();
    imgElement.crossOrigin = 'Anonymous';
    imgElement.src = logoUrl;
    
    await new Promise((resolve, reject) => {
      imgElement.onload = resolve;
      imgElement.onerror = reject;
    });

    const canvas = document.createElement('canvas');
    canvas.width = imgElement.width;
    canvas.height = imgElement.height;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(imgElement, 0, 0);
    const dataURL = canvas.toDataURL('image/png');
    
    // Texto a la izquierda
    doc.setTextColor(30, 41, 59); // text-slate-800
    doc.setFontSize(24);
    doc.text('INNOVA', 14, 22);
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); // text-slate-500
    doc.text('RRHH - Sistema de Gestión', 14, 27);

    // Proporciones del logo (ajustar según la imagen real)
    const imgRatio = imgElement.width / imgElement.height;
    const newHeight = 16;
    const newWidth = newHeight * imgRatio;

    // Calcular posición X para alinear a la derecha (margen derecho 14)
    const pageWidth = doc.internal.pageSize.getWidth();
    const logoX = pageWidth - 14 - newWidth;

    doc.addImage(dataURL, 'PNG', logoX, 12, newWidth, newHeight);

    // --- QR Code ---
    try {
      const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${encodeURIComponent('https://sistema-de-gestion-de-recursos-humanos-production-4a18.up.railway.app/reclutamiento')}`;
      const qrImg = new Image();
      qrImg.crossOrigin = 'Anonymous';
      qrImg.src = qrUrl;
      
      await new Promise((resolve, reject) => {
        qrImg.onload = resolve;
        qrImg.onerror = reject;
      });

      const qrCanvas = document.createElement('canvas');
      qrCanvas.width = qrImg.width;
      qrCanvas.height = qrImg.height;
      const qrCtx = qrCanvas.getContext('2d');
      qrCtx.drawImage(qrImg, 0, 0);
      const qrDataURL = qrCanvas.toDataURL('image/png');
      
      const qrSize = 16;
      const qrX = logoX - qrSize - 5; // 5px de separación del logo
      doc.addImage(qrDataURL, 'PNG', qrX, 12, qrSize, qrSize);
      
      // Pequeño texto debajo del QR
      doc.setFontSize(6);
      doc.setTextColor(148, 163, 184); // text-slate-400
      doc.text('Portal Reclutamiento', qrX + (qrSize / 2), 30, { align: 'center' });
    } catch (qrError) {
      console.error("Error cargando QR:", qrError);
    }

  } catch (error) {
    console.error("Error cargando logo, usando fallback:", error);
    
    // Texto a la izquierda
    doc.setTextColor(30, 41, 59); // text-slate-800
    doc.setFontSize(24);
    doc.text('INNOVA', 14, 22);
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); // text-slate-500
    doc.text('RRHH - Sistema de Gestión', 14, 27);

    // LOGO - Fallback (Simulamos un logo estilizado a la derecha)
    const pageWidth = doc.internal.pageSize.getWidth();
    const fallbackX = pageWidth - 14 - 12; // 12 es el ancho del rect

    doc.setFillColor(30, 41, 59); // bg-slate-800
    doc.rect(fallbackX, 15, 12, 12, 'F');
    doc.setTextColor(96, 165, 250); // text-blue-400
    doc.setFontSize(16);
    doc.setFont('helvetica', 'bold');
    doc.text('I', fallbackX + 3.5, 24);
  }
  
  // Línea separadora
  doc.setDrawColor(226, 232, 240); // border-slate-200
  doc.setLineWidth(0.5);
  doc.line(14, 35, 196, 35);

  // Título del reporte
  doc.setFontSize(16);
  doc.setTextColor(15, 23, 42); // text-slate-900
  doc.text('Reporte de Gestión de Aspirantes y Revisión de CVs', 14, 46);
  
  // Fecha
  doc.setFontSize(10);
  doc.setTextColor(100, 116, 139); // text-slate-500
  doc.text(`Fecha de Generación: ${new Date().toLocaleDateString('es-ES')}`, 14, 53);

  // Generar tabla
  const tableColumn = ["Candidato", "Puesto Aplicado", "Correo", "Teléfono", "Fecha", "Estado"];
  const tableRows = [];

  candidatos.value.forEach(c => {
    const data = [
      c.nombre_completo,
      c.puesto_aplicado,
      c.correo,
      c.telefono,
      formatFecha(c.created_at),
      c.estado
    ];
    tableRows.push(data);
  });

  autoTable(doc, {
    head: [tableColumn],
    body: tableRows,
    startY: 60,
    theme: 'grid',
    headStyles: { fillColor: [30, 41, 59], textColor: [255, 255, 255], fontStyle: 'bold' },
    alternateRowStyles: { fillColor: [248, 250, 252] },
    styles: { font: 'helvetica', fontSize: 9, cellPadding: 4, textColor: [71, 85, 105] },
    columnStyles: {
      0: { fontStyle: 'bold', textColor: [30, 41, 59] },
    }
  });

  // Numeración de páginas
  const pageCount = doc.internal.getNumberOfPages();
  for(let i = 1; i <= pageCount; i++) {
    doc.setPage(i);
    doc.setFontSize(8);
    doc.setTextColor(148, 163, 184); // text-slate-400
    doc.text(`Página ${i} de ${pageCount}`, doc.internal.pageSize.getWidth() / 2, doc.internal.pageSize.getHeight() - 10, { align: 'center' });
  }

  doc.save('reporte_candidatos_innova.pdf');
};

const generarPDFQR = async () => {
  const doc = new jsPDF();
  
  try {
    const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=500x500&data=${encodeURIComponent('https://sistema-de-gestion-de-recursos-humanos-production-4a18.up.railway.app/reclutamiento')}`;
    const qrImg = new Image();
    qrImg.crossOrigin = 'Anonymous';
    qrImg.src = qrUrl;
    
    await new Promise((resolve, reject) => {
      qrImg.onload = resolve;
      qrImg.onerror = reject;
    });

    const qrCanvas = document.createElement('canvas');
    qrCanvas.width = qrImg.width;
    qrCanvas.height = qrImg.height;
    const qrCtx = qrCanvas.getContext('2d');
    qrCtx.drawImage(qrImg, 0, 0);
    const qrDataURL = qrCanvas.toDataURL('image/png');
    
    // Configurar poster
    doc.setFillColor(30, 41, 59); // bg-slate-800
    doc.rect(0, 0, doc.internal.pageSize.getWidth(), 45, 'F');
    
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(28);
    doc.setFont('helvetica', 'bold');
    doc.text('INNOVA - RECLUTAMIENTO', doc.internal.pageSize.getWidth() / 2, 28, { align: 'center' });

    doc.setTextColor(30, 41, 59);
    doc.setFontSize(22);
    doc.text('¡Únete a nuestro equipo!', doc.internal.pageSize.getWidth() / 2, 80, { align: 'center' });
    
    doc.setFontSize(12);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(100, 116, 139);
    doc.text('Escanea el código QR desde tu celular para acceder', doc.internal.pageSize.getWidth() / 2, 92, { align: 'center' });
    doc.text('rápidamente a nuestro portal de reclutamiento.', doc.internal.pageSize.getWidth() / 2, 98, { align: 'center' });

    const qrSize = 100;
    const qrX = (doc.internal.pageSize.getWidth() - qrSize) / 2;
    doc.addImage(qrDataURL, 'PNG', qrX, 115, qrSize, qrSize);
    
    // Decoración inferior
    doc.setDrawColor(30, 41, 59);
    doc.setLineWidth(1);
    doc.line(qrX - 10, 115 + qrSize + 20, qrX + qrSize + 10, 115 + qrSize + 20);
    
    doc.setFontSize(10);
    doc.text('https://sistema-de-gestion-de-recursos-humanos-production-4a18.up.railway.app/reclutamiento', doc.internal.pageSize.getWidth() / 2, 115 + qrSize + 35, { align: 'center' });

    doc.save('poster_qr_reclutamiento.pdf');
  } catch (error) {
    console.error("Error generando PDF QR:", error);
    alert('No se pudo generar el QR.');
  }
};

const cargarCandidatos = async () => {
  try {
    loadingCandidatos.value = true;
    const response = await axios.get('/api/candidatos');
    candidatos.value = response.data;
  } catch (error) {
    console.error('Error de conexión:', error);
  } finally {
    loadingCandidatos.value = false;
  }
};

const actualizarEstado = async (candidato) => {
  try {
    await axios.put(`/api/candidatos/${candidato.id}/estado`, {
      estado: candidato.estado
    });
  } catch (error) {
    alert('Error de conexión al actualizar estado');
    cargarCandidatos();
  }
};

onMounted(async () => {
  rolID.value = localStorage.getItem('usuarioRol') || 2;
  usuarioActual.value = localStorage.getItem('usuarioNombre') || 'Usuario';
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null;

  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT';
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos';
  } else {
    rolNombre.value = 'Empleado';
  }

  // Cargar Sidebar (usando la API del proyecto original, en puerto 3007)
  try {
    const usuarioID = localStorage.getItem('usuarioID');
    const urlMenu = usuarioID 
      ? `/api/menu/${rolID.value}?usuario_id=${usuarioID}`
      : `/api/menu/${rolID.value}`;
    
    const response = await axios.get(urlMenu);
    menuUsuario.value = response.data;
  } catch (e) {
    console.error('Error cargando menú', e);
  }

  // Cargar Datos
  cargarCandidatos();
});
</script>
