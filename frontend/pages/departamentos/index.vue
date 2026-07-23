<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <AppSidebar />

    <main class="w-full overflow-x-hidden transition-all duration-300 flex-1 md:ml-64 p-8">
      <header class="mb-10 flex flex-col gap-5 bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div class="flex justify-between items-center w-full">
          <button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors mr-3 shrink-0">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
          </button>
          <div>
            <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Departamentos</h1>
            <p class="text-slate-500 mt-1 font-medium italic">Gestión de departamentos de la empresa.</p>
          </div>
          <div class="flex items-center gap-4">
            <button v-if="hasPermission('Departamentos', 'puedeCrear')" @click="abrirModalCrear" class="bg-green-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-green-700 transition-all shadow-lg shadow-green-200 flex items-center gap-2">
              <span>+</span> Crear Nuevo
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
        <div class="w-full">
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="Buscar departamento..." 
            class="w-full p-3 rounded-xl bg-slate-50 border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all placeholder:italic"
          >
        </div>
      </header>

      <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
        <table class="w-full text-left">
          <thead>
            <tr class="bg-slate-50 border-b border-slate-100">
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Departamento</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Estado</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Creado Por</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Fecha de Creación</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Modificado Por</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Última Modificación</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading" class="border-b border-slate-50">
              <td colspan="7" class="p-10 text-center text-slate-400 italic">Cargando departamentos...</td>
            </tr>
            <tr v-else-if="filteredDepartamentos.length === 0" class="border-b border-slate-50">
              <td colspan="7" class="p-10 text-center text-slate-400 italic">No se encontraron departamentos.</td>
            </tr>
            <tr v-else v-for="dept in filteredDepartamentos" :key="dept.id" class="border-b border-slate-50 hover:bg-slate-50 transition-colors">
              <td class="p-5 font-bold text-slate-800">{{ dept.nombre }}</td>
              <td class="p-5">
                <span :class="dept.estado ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600'" class="px-3 py-1 text-[10px] font-black uppercase rounded-full">
                  {{ dept.estado ? 'Activo' : 'Inactivo' }}
                </span>
              </td>
              <td class="p-5 text-sm text-slate-600">{{ dept.creado_por || 'N/A' }}</td>
              <td class="p-5 text-sm text-slate-500">{{ dept.fecha_creacion ? new Date(dept.fecha_creacion).toLocaleDateString('es-HN') : 'N/A' }}</td>
              <td class="p-5 text-sm text-slate-600">{{ dept.modificado_por || 'N/A' }}</td>
              <td class="p-5 text-sm text-slate-500">{{ dept.ultima_modificacion ? new Date(dept.ultima_modificacion).toLocaleDateString('es-HN') : 'N/A' }}</td>
              <td class="p-5 text-center flex justify-center gap-2">
                <button v-if="hasPermission('Departamentos', 'puedeEditar')" @click="abrirModalEditar(dept)" class="bg-blue-100 text-blue-600 hover:bg-blue-600 hover:text-white p-2 rounded-lg text-xs font-bold transition-colors" title="Editar">
                  ✏️
                </button>
                <button v-if="hasPermission('Departamentos', 'puedeEditar')" @click="toggleEstado(dept)" :class="dept.estado ? 'bg-red-100 text-red-600 hover:bg-red-600 hover:text-white' : 'bg-green-100 text-green-600 hover:bg-green-600 hover:text-white'" class="p-2 rounded-lg text-xs font-bold transition-colors" :title="dept.estado ? 'Desactivar' : 'Activar'">
                  {{ dept.estado ? '🛑' : '✅' }}
                </button>
                <button v-if="hasPermission('Departamentos', 'puedeEliminar')" @click="eliminarDepartamento(dept)" class="bg-red-100 text-red-600 hover:bg-red-600 hover:text-white p-2 rounded-lg text-xs font-bold transition-colors" title="Eliminar">
                  🗑️
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Modal Crear/Editar -->
      <div v-if="mostrarModal" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
        <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 w-full max-w-lg overflow-hidden">
          <div class="bg-slate-800 p-6 flex justify-between items-center text-white">
            <h2 class="text-xl font-black uppercase tracking-tight">{{ esEdicion ? 'Editar Departamento' : 'Crear Departamento' }}</h2>
            <button @click="cerrarModal" class="text-slate-400 hover:text-white text-3xl font-bold leading-none">&times;</button>
          </div>
          
          <div class="p-8">
            <form @submit.prevent="guardarDepartamento" class="space-y-5">
              <div>
                <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Nombre del Departamento</label>
                <input type="text" v-model="form.nombre" required class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none" placeholder="Ej. Recursos Humanos">
              </div>
              
              <div>
                <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Descripción</label>
                <textarea v-model="form.descripcion" rows="3" class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none resize-none" placeholder="Opcional..."></textarea>
              </div>

              <div class="flex justify-end gap-3 pt-4 border-t border-slate-100">
                <button type="button" @click="cerrarModal" class="px-6 py-2.5 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
                  Cancelar
                </button>
                <button type="submit" class="px-6 py-2.5 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-md">
                  {{ esEdicion ? 'Actualizar' : 'Guardar' }}
                </button>
              </div>
            </form>
          </div>
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
import { useSidebar } from '@/composables/useSidebar'
const { toggleMobileMenu } = useSidebar()
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { usePermisos } from '~/composables/usePermisos'

const { getPermisos, hasPermission } = usePermisos()
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const usuarioActual = ref('')

const departamentos = ref([])
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

const mostrarModal = ref(false)
const esEdicion = ref(false)
const form = ref({ id: null, nombre: '', descripcion: '' })

const filteredDepartamentos = computed(() => {
  let result = [...departamentos.value].sort((a, b) => a.nombre.localeCompare(b.nombre));
  
  if (!searchQuery.value) return result;
  
  const lowerCaseQuery = searchQuery.value.toLowerCase();
  return result.filter(d => 
    d.nombre.toLowerCase().includes(lowerCaseQuery) || 
    (d.descripcion && d.descripcion.toLowerCase().includes(lowerCaseQuery))
  );
})

const cargarDepartamentos = async () => {
  try {
    loading.value = true
    const res = await axios.get('/api/departamentos/lista')
    departamentos.value = res.data
  } catch (error) {
    console.error('Error cargando departamentos', error)
  } finally {
    loading.value = false
  }
}

const abrirModalCrear = () => {
  esEdicion.value = false
  form.value = { id: null, nombre: '', descripcion: '' }
  mostrarModal.value = true
}

const abrirModalEditar = (dept) => {
  esEdicion.value = true
  form.value = { id: dept.id, nombre: dept.nombre, descripcion: dept.descripcion }
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
}

const guardarDepartamento = async () => {
  try {
    const payload = {
      nombre: form.value.nombre,
      descripcion: form.value.descripcion,
      creado_por: usuarioActual.value,
      modificado_por: usuarioActual.value
    }

    if (esEdicion.value) {
      await axios.put(`/api/departamentos/editar/${form.value.id}`, payload)
      alert('✅ Departamento actualizado exitosamente')
    } else {
      await axios.post('/api/departamentos/crear', payload)
      alert('✅ Departamento creado exitosamente')
    }
    cerrarModal()
    cargarDepartamentos()
  } catch (error) {
    console.error('Error al guardar', error)
    alert('❌ Error al guardar el departamento')
  }
}

const toggleEstado = async (dept) => {
  const nuevoEstado = dept.estado ? 0 : 1
  const accion = dept.estado ? 'desactivar' : 'activar'
  if (!confirm(`¿Está seguro que desea ${accion} el departamento ${dept.nombre}?`)) return

  try {
    await axios.put(`/api/departamentos/estado/${dept.id}`, {
      estado: nuevoEstado,
      modificado_por: usuarioActual.value
    })
    cargarDepartamentos()
  } catch (error) {
    console.error('Error al cambiar estado', error)
    alert('❌ Error al cambiar el estado')
  }
}

const eliminarDepartamento = async (dept) => {
  if (!confirm(`¿Está seguro que desea eliminar el departamento "${dept.nombre}"? Esta acción no se puede deshacer.`)) return

  try {
    const res = await axios.delete(`/api/departamentos/eliminar/${dept.id}`)
    alert('✅ ' + (res.data.mensaje || 'Departamento eliminado correctamente'))
    cargarDepartamentos()
  } catch (error) {
    console.error('Error al eliminar departamento', error)
    alert('❌ ' + (error.response?.data?.error || 'Error al eliminar el departamento'))
  }
}

const logout = () => {
  localStorage.clear()
  navigateTo('/dashboard')
}

onMounted(async () => {
  rolID.value = localStorage.getItem('usuarioRol') || 2
  usuarioActual.value = localStorage.getItem('usuarioNombre') || 'Gerad Cole'
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null

  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }

  try {
    const m = await axios.get(`/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    menuUsuario.value = m.data
  } catch (e) {
    console.error('Error cargando menú', e)
  }

  const usuarioID = localStorage.getItem('usuarioID');
  await getPermisos(rolID.value, usuarioID);

  cargarDepartamentos()
})
</script>