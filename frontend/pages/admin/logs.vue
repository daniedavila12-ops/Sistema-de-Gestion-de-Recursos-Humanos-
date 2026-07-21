<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <aside class="w-64 bg-slate-800 text-white flex flex-col shadow-xl fixed h-full z-10">
      <div class="p-6 text-2xl font-bold border-b border-slate-700 tracking-tight text-blue-400 uppercase">
        RRHH Innova
      </div>
      
      <nav class="flex-1 p-4 space-y-1 overflow-y-auto">
        <div v-for="(item, index) in menuUsuario" :key="item.ruta || index">
          <div v-if="item.esCabecera" class="text-[10px] font-black text-slate-500 uppercase tracking-widest mt-6 mb-2 px-3">
            {{ item.nombre }}
          </div>
          <NuxtLink v-else :to="item.ruta" 
            class="flex items-center gap-3 p-3 rounded-xl hover:bg-slate-700 transition-all duration-200 group"
            active-class="bg-blue-600 shadow-lg">
            <span class="text-xl group-hover:scale-110 transition-transform">{{ item.icono }}</span>
            <span class="text-sm font-medium">{{ item.nombre }}</span>
          </NuxtLink>
        </div>
      </nav>

      <div class="p-4 border-t border-slate-700 bg-slate-900/50">
        <div class="mb-4 px-2 flex flex-col">
          <span class="text-[9px] font-black text-slate-500 uppercase tracking-widest">Nivel de Acceso</span>
          <span class="text-xs font-bold text-blue-400">{{ rolNombre }}</span>
        </div>
        <button @click="logout" class="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-red-500/10 hover:text-red-400 transition-all font-bold text-xs uppercase tracking-widest">
          <span>🚪</span> Cerrar Sesión
        </button>
      </div>
    </aside>

    <main class="flex-1 ml-64 p-8">
      <header class="mb-8 flex flex-col gap-5 bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div class="flex justify-between items-center w-full">
          <div>
            <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Logs de Sistema</h1>
            <p class="text-slate-500 mt-1 font-medium italic">Registro de auditoría y actividades de los usuarios.</p>
          </div>
          <div class="flex items-center gap-4">
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
                  <button @click="abrirModalPerfil(); dropdownPerfilAbierto = false" class="w-full text-left flex items-center gap-3 p-3 hover:bg-slate-50 rounded-xl transition-colors group">
                    <span class="text-lg group-hover:scale-110 transition-transform">👤</span>
                    <span class="text-sm font-bold text-slate-700">Mi Perfil de Usuario</span>
                  </button>
                  <button @click="logout" class="w-full text-left flex items-center gap-3 p-3 hover:bg-red-50 rounded-xl transition-colors group">
                    <span class="text-lg group-hover:scale-110 transition-transform">🚪</span>
                    <span class="text-sm font-bold text-red-600">Cerrar Sesión</span>
                  </button>
                </div>
              </div>
              <!-- Overlay invisible para cerrar el dropdown si se hace click fuera -->
              <div v-if="dropdownPerfilAbierto" @click="dropdownPerfilAbierto = false" class="fixed inset-0 z-40"></div>
            </div>
          </div>
        </div>
        <div class="w-full flex gap-4">
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="Buscar por usuario, acción o módulo..." 
            class="w-full p-3 rounded-xl bg-slate-50 border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all placeholder:italic"
          >
          <button @click="generarPDFAuditoria" class="bg-red-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-red-700 transition-all shadow-lg shadow-red-200 shrink-0 flex items-center gap-2">
            <span>📄</span> PDF Auditoría
          </button>
        </div>
      </header>

      <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left whitespace-nowrap">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-100">
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">ID</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Fecha y Hora</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Usuario</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Módulo</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Acción</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Detalles</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">IP</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading" class="border-b border-slate-50">
                <td colspan="7" class="p-10 text-center text-slate-400 italic">Cargando registros de auditoría...</td>
              </tr>
              <tr v-else-if="filteredLogs.length === 0" class="border-b border-slate-50">
                <td colspan="7" class="p-10 text-center text-slate-400 italic">No se encontraron registros.</td>
              </tr>
              <tr v-else v-for="log in filteredLogs" :key="log.id" class="border-b border-slate-50 hover:bg-slate-50 transition-colors">
                <td class="p-5 text-xs text-slate-500">#{{ log.id }}</td>
                <td class="p-5 text-sm text-slate-800 font-bold">
                  {{ new Date(log.fecha_creacion).toLocaleString('es-HN') }}
                </td>
                <td class="p-5">
                  <div class="flex flex-col">
                    <span class="font-bold text-blue-600">{{ log.usuario_nombre || 'Sistema' }}</span>
                    <span class="text-xs text-slate-400">{{ log.usuario_correo || 'N/A' }}</span>
                  </div>
                </td>
                <td class="p-5">
                  <span class="px-3 py-1 bg-slate-100 text-slate-600 text-[10px] font-black uppercase rounded-lg border border-slate-200">
                    {{ log.modulo || 'General' }}
                  </span>
                </td>
                <td class="p-5">
                  <span class="px-3 py-1 text-[10px] font-black uppercase rounded-lg border" :class="getAccionClass(log.accion)">
                    {{ log.accion }}
                  </span>
                </td>
                <td class="p-5 text-sm text-slate-600 max-w-xs truncate" :title="log.detalles">
                  {{ log.detalles || 'Sin detalles' }}
                </td>
                <td class="p-5 text-xs text-slate-400 font-mono">
                  {{ log.ip_address || '0.0.0.0' }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <!-- Modal Perfil -->
      <div v-if="modalAbiertoPerfil" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex justify-center items-center p-4">
        <div class="bg-white w-full max-w-md overflow-hidden rounded-3xl shadow-2xl animate-in fade-in zoom-in duration-200">
          <div class="p-6 border-b bg-white flex justify-between items-center">
            <h2 class="text-2xl font-black text-slate-800 uppercase tracking-tight">👤 Perfil de Usuario</h2>
            <button @click="cerrarModalPerfil" class="text-slate-400 hover:text-red-500 transition text-2xl">&times;</button>
          </div>

          <form @submit.prevent="cambiarPassword" class="p-8 space-y-6">
            <div class="mb-6 flex flex-col items-center">
              <div class="relative group cursor-pointer" @click="triggerFileInputPerfil">
                <div v-if="fotoUsuario" class="h-20 w-20 rounded-full flex items-center justify-center overflow-hidden ring-4 ring-slate-100 shadow-lg mb-4">
                  <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-20 w-20 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-3xl ring-4 ring-slate-100 uppercase mb-4 shadow-lg">
                  {{ usuarioActual ? usuarioActual.charAt(0) : 'U' }}
                </div>
                <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity rounded-full bg-black/50 mb-4">
                  <span class="text-white text-[10px] font-bold px-2 py-1 text-center">Cambiar<br>Foto</span>
                </div>
                <input type="file" ref="fileInputPerfil" class="hidden" accept="image/*" @change="uploadFotoPerfil" />
              </div>
              <h3 class="text-xl font-black text-slate-900">{{ usuarioActual }}</h3>
              <p class="text-xs font-bold text-slate-400 uppercase tracking-widest mt-1">{{ rolNombre }}</p>
            </div>

            <div>
              <h3 class="text-[10px] font-black text-blue-500 uppercase tracking-widest mb-4 border-b pb-2">Seguridad - Cambiar Contraseña</h3>
              <div class="space-y-4">
                <div>
                  <label class="block text-[10px] font-bold text-slate-400 uppercase mb-1">Contraseña Actual</label>
                  <input v-model="formPassword.actual" type="password" required class="w-full p-3 bg-slate-50 border rounded-xl outline-none focus:border-blue-500">
                </div>
                <div>
                  <label class="block text-[10px] font-bold text-slate-400 uppercase mb-1">Nueva Contraseña</label>
                  <input v-model="formPassword.nueva" type="password" required class="w-full p-3 bg-slate-50 border rounded-xl outline-none focus:border-blue-500">
                </div>
                <div>
                  <label class="block text-[10px] font-bold text-slate-400 uppercase mb-1">Confirmar Contraseña</label>
                  <input v-model="formPassword.confirmar" type="password" required class="w-full p-3 bg-slate-50 border rounded-xl outline-none focus:border-blue-500">
                </div>
              </div>
            </div>

            <div class="flex justify-end gap-3 pt-4 border-t">
              <button type="button" @click="cerrarModalPerfil" class="px-6 py-3 text-slate-400 font-bold uppercase text-xs">Cancelar</button>
              <button type="submit" :disabled="loadingPassword" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-black uppercase text-xs shadow-lg shadow-blue-200">
                {{ loadingPassword ? 'Actualizando...' : 'Actualizar' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </main>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

const router = useRouter()
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const menuUsuario = ref([])
const usuarioActual = ref('')

const logs = ref([])
const loading = ref(true)
const searchQuery = ref('')

// Lógica Modal Perfil
const dropdownPerfilAbierto = ref(false)
const modalAbiertoPerfil = ref(false)
const loadingPassword = ref(false)
const formPassword = ref({ actual: '', nueva: '', confirmar: '' })
const fileInputPerfil = ref(null)
const fotoUsuario = ref(null)

const triggerFileInputPerfil = () => {
  fileInputPerfil.value.click()
}

const uploadFotoPerfil = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  const formData = new FormData()
  formData.append('foto', file)

  try {
    const id = localStorage.getItem('usuarioID')
    const res = await axios.post(`/api/auth/${id}/foto`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })

    fotoUsuario.value = res.data.fotoUrl
    localStorage.setItem('usuarioFoto', res.data.fotoUrl)
    alert('✅ ' + res.data.mensaje)
  } catch (err) {
    console.error("Error al subir la foto:", err)
    alert('❌ Error al subir la foto')
  }
}

const abrirModalPerfil = () => { modalAbiertoPerfil.value = true }
const cerrarModalPerfil = () => {
  modalAbiertoPerfil.value = false
  formPassword.value = { actual: '', nueva: '', confirmar: '' }
}

const cambiarPassword = async () => {
  if (formPassword.value.nueva !== formPassword.value.confirmar) {
    alert('❌ Las contraseñas nuevas no coinciden')
    return
  }
  try {
    loadingPassword.value = true
    const userId = localStorage.getItem('usuarioID')
    const res = await axios.put(`/api/auth/${userId}/password`, {
      actual: formPassword.value.actual,
      nueva: formPassword.value.nueva
    })
    alert('✅ ' + res.data.mensaje)
    cerrarModalPerfil()
  } catch (err) {
    alert('❌ ' + (err.response?.data?.error || 'Error al cambiar contraseña'))
  } finally {
    loadingPassword.value = false
  }
}

const filteredLogs = computed(() => {
  if (!searchQuery.value) return logs.value;
  const lowerCaseQuery = searchQuery.value.toLowerCase();
  return logs.value.filter(log => 
    (log.usuario_nombre && log.usuario_nombre.toLowerCase().includes(lowerCaseQuery)) ||
    (log.accion && log.accion.toLowerCase().includes(lowerCaseQuery)) ||
    (log.modulo && log.modulo.toLowerCase().includes(lowerCaseQuery)) ||
    (log.detalles && log.detalles.toLowerCase().includes(lowerCaseQuery))
  );
})

const getAccionClass = (accion) => {
  const acc = accion.toLowerCase();
  if (acc.includes('crea') || acc.includes('insert') || acc.includes('registr')) {
    return 'bg-emerald-50 text-emerald-600 border-emerald-200';
  } else if (acc.includes('elimina') || acc.includes('delete') || acc.includes('borr') || acc.includes('error')) {
    return 'bg-red-50 text-red-600 border-red-200';
  } else if (acc.includes('actualiza') || acc.includes('edit') || acc.includes('modifica')) {
    return 'bg-blue-50 text-blue-600 border-blue-200';
  } else if (acc.includes('login') || acc.includes('acceso') || acc.includes('sesi')) {
    return 'bg-purple-50 text-purple-600 border-purple-200';
  }
  return 'bg-slate-50 text-slate-600 border-slate-200';
}

const cargarLogs = async () => {
  try {
    loading.value = true
    const res = await axios.get('/api/logs')
    logs.value = res.data
  } catch (error) {
    console.error('Error cargando logs:', error)
  } finally {
    loading.value = false
  }
}

const generarPDFAuditoria = async () => {
  if (filteredLogs.value.length === 0) {
    alert('No hay registros para exportar');
    return;
  }

  const doc = new jsPDF('landscape');
  
  const imgLogo = new Image();
  imgLogo.crossOrigin = "Anonymous";
  imgLogo.src = `${useRuntimeConfig().public.apiBase}/uploads/Logo/Logo.png`;
  await new Promise((resolve) => {
    imgLogo.onload = resolve;
    imgLogo.onerror = resolve;
  });
  
  try { doc.addImage(imgLogo, 'PNG', 240, 10, 35, 15); } catch(e) {}
  
  doc.setFontSize(18);
  doc.setTextColor(30, 41, 59);
  doc.setFont('helvetica', 'bold');
  doc.text('REPORTE DE AUDITORÍA DE SISTEMA', 14, 20);
  
  doc.setFontSize(10);
  doc.setTextColor(100, 116, 139);
  doc.setFont('helvetica', 'normal');
  doc.text(`Fecha de Generación: ${new Date().toLocaleString('es-HN')}`, 14, 28);
  doc.text(`Generado por: ${usuarioActual.value} (${rolNombre.value})`, 14, 34);

  const tableColumn = ["ID", "Fecha y Hora", "Usuario", "Módulo", "Acción", "Detalles", "IP"];
  const tableRows = [];

  filteredLogs.value.forEach(log => {
    const logData = [
      log.id,
      new Date(log.fecha_creacion).toLocaleString('es-HN'),
      log.usuario_nombre || 'Sistema',
      log.modulo || 'General',
      log.accion,
      log.detalles || 'Sin detalles',
      log.ip_address || '0.0.0.0'
    ];
    tableRows.push(logData);
  });

  autoTable(doc, {
    head: [tableColumn],
    body: tableRows,
    startY: 42,
    theme: 'grid',
    styles: { fontSize: 8, cellPadding: 3, textColor: [51, 65, 85] },
    headStyles: { fillColor: [30, 41, 59], textColor: [255, 255, 255], fontStyle: 'bold' },
    alternateRowStyles: { fillColor: [248, 250, 252] },
    columnStyles: {
      0: { cellWidth: 15 },
      1: { cellWidth: 35 },
      2: { cellWidth: 35 },
      3: { cellWidth: 30 },
      4: { cellWidth: 30 },
      5: { cellWidth: 'auto' },
      6: { cellWidth: 25 }
    },
    didDrawPage: function (data) {
      const str = "Página " + doc.internal.getNumberOfPages();
      doc.setFontSize(8);
      doc.setTextColor(100);
      const pageSize = doc.internal.pageSize;
      const pageHeight = pageSize.height ? pageSize.height : pageSize.getHeight();
      doc.text(str, data.settings.margin.left, pageHeight - 10);
    }
  });

  const finalY = doc.lastAutoTable.finalY || 42;
  
  if (finalY < doc.internal.pageSize.getHeight() - 40) {
      doc.setFontSize(10);
      doc.setTextColor(30, 41, 59);
      doc.line(40, finalY + 30, 100, finalY + 30);
      doc.text("Firma de Auditoría", 55, finalY + 35);
      
      doc.line(190, finalY + 30, 250, finalY + 30);
      doc.text("Firma de Gerencia", 205, finalY + 35);
  }

  doc.save('Auditoria_Sistema_' + new Date().getTime() + '.pdf');
}

const logout = () => {
  localStorage.clear()
  navigateTo('/login')
}

onMounted(async () => {
  rolID.value = localStorage.getItem('usuarioRol') || 2
  usuarioActual.value = localStorage.getItem('usuarioNombre') || 'Gerad Cole'
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null

  // Solo Super Admin puede ver esto, pero por si acaso validamos
  if (rolID.value != 1) {
    navigateTo('/')
    return
  }

  rolNombre.value = 'Administrador IT'

  try {
    const m = await axios.get(`/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    menuUsuario.value = m.data
  } catch (e) {
    console.error('Error cargando menú', e)
  }

  cargarLogs()
})
</script>