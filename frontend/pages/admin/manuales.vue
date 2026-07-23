<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <!-- SIDEBAR -->
    <AppSidebar />

    <!-- MAIN CONTENT -->
    <main class="w-full overflow-x-hidden transition-all duration-300 flex-1 md:ml-64 p-8">
      <header class="mb-10 flex flex-col gap-5 bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div class="flex justify-between items-center w-full">
          <button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors mr-3 shrink-0">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
          </button>
          <div>
            <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Gestión de Manuales</h1>
            <p class="text-slate-500 mt-1 font-medium italic">Sube y administra los manuales de la Biblioteca Digital.</p>
          </div>
          <div class="flex items-center gap-4">
            <button @click="abrirModal" class="bg-blue-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-blue-700 transition-all shadow-lg shadow-blue-200 flex items-center gap-2">
              <span>+</span> Subir Manual
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
            placeholder="Buscar manual..." 
            class="w-full p-3 rounded-xl bg-slate-50 border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all placeholder:italic"
          >
        </div>
      </header>

      <!-- Tabla de Manuales -->
      <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-100">
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">ID</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Título</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Categoría</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Tamaño</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Creado Por</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Fecha Creación</th>
                <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="cargando" class="border-b border-slate-50">
                <td colspan="7" class="p-10 text-center text-slate-400 italic">Cargando manuales...</td>
              </tr>
              <tr v-else-if="filteredManuales.length === 0" class="border-b border-slate-50">
                <td colspan="7" class="p-10 text-center text-slate-400 italic">No se encontraron manuales.</td>
              </tr>
              <tr v-for="manual in filteredManuales" :key="manual.id" class="border-b border-slate-50 hover:bg-slate-50 transition-colors">
                <td class="p-5 font-bold text-slate-800">#{{ manual.id }}</td>
                <td class="p-5">
                  <div class="text-sm font-bold text-slate-800">{{ manual.titulo }}</div>
                  <div class="text-xs text-slate-500 truncate max-w-xs">{{ manual.descripcion }}</div>
                </td>
                <td class="p-5">
                  <span class="px-2 py-1 bg-blue-50 text-blue-600 text-[10px] font-black uppercase rounded-full tracking-widest">
                    {{ manual.categoria || 'General' }}
                  </span>
                </td>
                <td class="p-5 text-sm text-slate-600">{{ manual.tamano || 'N/A' }}</td>
                <td class="p-5 text-sm text-slate-600">{{ manual.creadoPorNombre || 'Desconocido' }}</td>
                <td class="p-5 text-sm text-slate-500">{{ new Date(manual.fechaCreacion).toLocaleDateString() }}</td>
                <td class="p-5 text-center flex justify-center gap-2">
                  <button @click="verManual(manual.archivo)" class="bg-green-100 text-green-600 hover:bg-green-600 hover:text-white p-2 rounded-lg text-xs font-bold transition-colors" title="Ver Manual">
                    👁️
                  </button>
                  <button @click="abrirModalEditar(manual)" class="bg-blue-100 text-blue-600 hover:bg-blue-600 hover:text-white p-2 rounded-lg text-xs font-bold transition-colors" title="Editar">
                    ✏️
                  </button>
                  <button @click="eliminarManual(manual.id)" class="bg-red-100 text-red-600 hover:bg-red-600 hover:text-white p-2 rounded-lg text-xs font-bold transition-colors" title="Eliminar">
                    🗑️
                  </button>
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

    <!-- Modal Subir/Editar Manual -->
    <div v-if="mostrarModal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm flex justify-center items-center z-50 p-4">
      <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 w-full max-w-md overflow-hidden">
        <div class="bg-slate-800 p-6 flex justify-between items-center text-white">
          <h2 class="text-xl font-black uppercase tracking-tight">{{ editandoId ? 'Editar Manual' : 'Subir Nuevo Manual' }}</h2>
          <button @click="cerrarModal" class="text-slate-400 hover:text-white text-3xl font-bold leading-none">&times;</button>
        </div>
        
        <div class="p-8">
          <form @submit.prevent="subirManual" class="space-y-4">
            <div>
              <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Título</label>
              <input v-model="form.titulo" type="text" required class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none">
            </div>
            
            <div>
              <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Categoría</label>
              <input v-model="form.categoria" type="text" placeholder="Ej: Legal, Sistemas, RRHH" required class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none">
            </div>
            
            <div>
              <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Descripción</label>
              <textarea v-model="form.descripcion" rows="3" required class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none resize-none"></textarea>
            </div>
            
            <div>
              <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Archivo PDF o Video</label>
              <input type="file" ref="archivoInput" accept=".pdf,video/*" :required="!editandoId" class="w-full text-sm text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-sm file:font-bold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
              <p v-if="editandoId" class="text-xs text-slate-500 mt-1">Opcional. Sube un archivo solo si deseas reemplazar el actual.</p>
            </div>

            <div class="flex justify-end gap-3 pt-4 border-t border-slate-100">
              <button type="button" @click="cerrarModal" class="px-6 py-2.5 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
                Cancelar
              </button>
              <button type="submit" :disabled="subiendo" class="px-6 py-2.5 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-md disabled:opacity-50">
                {{ subiendo ? 'Guardando...' : (editandoId ? 'Actualizar' : 'Guardar') }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useSidebar } from '@/composables/useSidebar'
const { toggleMobileMenu } = useSidebar()
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

const config = useRuntimeConfig()

// Variables globales/usuario
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const usuarioActual = ref('')

// Variables del módulo
const manuales = ref([])
const cargando = ref(true)
const searchQuery = ref('')
const mostrarModal = ref(false)
const subiendo = ref(false)
const archivoInput = ref(null)
const editandoId = ref(null)

const form = ref({
  titulo: '',
  categoria: '',
  descripcion: ''
})

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

const filteredManuales = computed(() => {
  if (!searchQuery.value) return manuales.value;
  const lowerCaseQuery = searchQuery.value.toLowerCase();
  return manuales.value.filter(m => 
    m.titulo.toLowerCase().includes(lowerCaseQuery) || 
    (m.descripcion && m.descripcion.toLowerCase().includes(lowerCaseQuery)) ||
    (m.categoria && m.categoria.toLowerCase().includes(lowerCaseQuery))
  );
})

const cargarManuales = async () => {
  cargando.value = true
  try {
    const res = await fetch(`${config.public.apiBase}/api/biblioteca`)
    if (res.ok) {
      manuales.value = await res.json()
    }
  } catch (error) {
    console.error('Error cargando manuales:', error)
  } finally {
    cargando.value = false
  }
}

onMounted(async () => {
  // Inicialización de usuario y sidebar
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
    const userId = localStorage.getItem('usuarioID');
    const m = await axios.get(`/api/menu/${rolID.value}?usuario_id=${userId}`)
    menuUsuario.value = m.data
  } catch (e) {
    console.error('Error cargando menú', e)
  }

  // Cargar datos
  cargarManuales()
})

const logout = () => {
  localStorage.clear()
  navigateTo('/login')
}

const abrirModal = () => {
  editandoId.value = null
  form.value = { titulo: '', categoria: '', descripcion: '' }
  if (archivoInput.value) archivoInput.value.value = ''
  mostrarModal.value = true
}

const abrirModalEditar = (manual) => {
  editandoId.value = manual.id
  form.value = {
    titulo: manual.titulo,
    categoria: manual.categoria,
    descripcion: manual.descripcion
  }
  if (archivoInput.value) archivoInput.value.value = ''
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
}

const subirManual = async () => {
  const file = archivoInput.value?.files[0]
  if (!editandoId.value && !file) return alert('Por favor selecciona un archivo PDF o Video')

  subiendo.value = true
  
  const userId = localStorage.getItem('usuarioID') || 1

  const formData = new FormData()
  formData.append('titulo', form.value.titulo)
  formData.append('categoria', form.value.categoria)
  formData.append('descripcion', form.value.descripcion)
  
  if (editandoId.value) {
    formData.append('modificadoPor', userId)
  } else {
    formData.append('creadoPor', userId)
  }

  if (file) {
    formData.append('archivo', file)
  }

  const url = editandoId.value 
    ? `${config.public.apiBase}/api/biblioteca/${editandoId.value}` 
    : `${config.public.apiBase}/api/biblioteca/subir`
    
  const method = editandoId.value ? 'PUT' : 'POST'

  try {
    const res = await fetch(url, {
      method: method,
      body: formData
    })
    
    if (res.ok) {
      alert(editandoId.value ? '✅ Manual actualizado con éxito' : '✅ Manual subido con éxito')
      cerrarModal()
      cargarManuales() // Recargar lista
    } else {
      const errorData = await res.json()
      alert(`❌ Error al guardar manual: ${errorData.error}`)
    }
  } catch (error) {
    console.error('Error:', error)
    alert('❌ Error de conexión al guardar el manual')
  } finally {
    subiendo.value = false
  }
}

const eliminarManual = async (id) => {
  if (!confirm('¿Estás seguro de que deseas eliminar este manual? Esta acción no se puede deshacer.')) return

  try {
    const res = await fetch(`${config.public.apiBase}/api/biblioteca/${id}`, {
      method: 'DELETE',
    })
    
    if (res.ok) {
      manuales.value = manuales.value.filter(m => m.id !== id)
      alert('✅ Manual eliminado con éxito')
    } else {
      alert('❌ Error al eliminar manual')
    }
  } catch (error) {
    console.error('Error:', error)
    alert('❌ Error de conexión al eliminar el manual')
  }
}

const verManual = (url) => {
  if (url) {
    window.open(`${config.public.apiBase}${url}`, '_blank');
  } else {
    alert('Este manual no tiene un archivo adjunto.');
  }
}
</script>