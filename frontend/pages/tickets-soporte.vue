<template>
  <div class="min-h-screen flex flex-col items-center justify-center bg-slate-900 p-4 font-sans overflow-y-auto py-10">
    
    <div class="bg-white p-10 rounded-3xl shadow-2xl w-full max-w-md border border-white/10 my-8">
      <div class="text-center mb-8">
        <div class="text-4xl mb-4">🎫</div>
        <h2 class="text-3xl font-black text-slate-800 tracking-tighter uppercase">Crear Ticket</h2>
        <p class="text-slate-400 font-bold text-xs mt-2 tracking-widest uppercase opacity-70">Soporte y Categorías</p>
      </div>

      <form @submit.prevent="crearTicket" class="space-y-6">
        <div>
          <div v-for="(idObj, index) in identidades" :key="index" class="mb-4 relative">
            <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Número de Identidad {{ index + 1 }}</label>
            <div class="flex items-center gap-2 relative">
              <div class="relative flex-1">
                <input v-model="idObj.value" @input="e => onIdentidadInput(e, index)" @focus="onIdentidadFocus(index)" @blur="onIdentidadBlur" type="text" required placeholder="Buscar por identidad o nombre..."
                  class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200">
                
                <!-- Dropdown de sugerencias -->
                <div v-if="activeDropdown === index && suggestions[index] && suggestions[index].length > 0" class="absolute z-50 w-full mt-1 bg-white border border-slate-200 rounded-xl shadow-xl max-h-48 overflow-y-auto">
                  <div v-for="emp in suggestions[index]" :key="emp.identidad" @mousedown.prevent="selectEmpleado(emp, index)" class="p-3 hover:bg-slate-50 cursor-pointer border-b border-slate-100 last:border-0 flex items-center gap-3">
                    <div class="h-8 w-8 rounded-full bg-slate-100 overflow-hidden shrink-0 flex items-center justify-center font-bold text-xs text-slate-500">
                      <img v-if="emp.foto" :src="`${$config.public.apiBase}${emp.foto}`" class="w-full h-full object-cover"/>
                      <span v-else>{{ emp.nombre.charAt(0) }}</span>
                    </div>
                    <div>
                      <p class="text-sm font-bold text-slate-800">{{ emp.nombre }} {{ emp.apellido }}</p>
                      <p class="text-xs text-slate-500 font-medium">{{ emp.identidad }}</p>
                    </div>
                  </div>
                </div>
              </div>
              <button v-if="identidades.length > 1" type="button" @click="removeIdentidad(index)" class="p-3 text-red-500 hover:bg-red-50 rounded-xl transition-colors" title="Eliminar">
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
              </button>
            </div>
          </div>
          <button type="button" @click="addIdentidad" class="inline-flex items-center gap-2 px-3 py-1.5 text-xs text-blue-600 font-bold bg-blue-50 border border-blue-100 rounded-lg hover:bg-blue-100 transition-colors">
            <span>+ Agregar otra persona</span>
          </button>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Categoría</label>
            <select v-model="categoria" class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200 appearance-none">
              <option v-for="cat in categoriasLista" :key="cat.id" :value="cat.nombre">{{ cat.nombre }}</option>
            </select>
          </div>
          <div>
            <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Prioridad</label>
            <select v-model="prioridad" class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200 appearance-none">
              <option value="Baja">Baja</option>
              <option value="Media">Media</option>
              <option value="Alta">Alta</option>
              <option value="Urgente">Urgente</option>
              </select>          </div>
        </div>

        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Tema / Asunto</label>
          <input v-model="tema" type="text" required placeholder="Breve resumen"
            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200">
        </div>

        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Descripción</label>
          <textarea v-model="descripcion" required rows="3" placeholder="Detalla tu categoría..."
            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200 resize-none"></textarea>
        </div>

        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Subir Archivo (Opcional)</label>
          <input type="file" ref="fileInputRef" @change="handleFileUpload"
            class="w-full p-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 text-sm focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200 cursor-pointer">
        </div>

        <button type="submit" :disabled="loading"
          class="w-full bg-blue-600 text-white py-4 rounded-2xl font-black text-sm uppercase tracking-widest hover:bg-blue-700 shadow-xl shadow-blue-500/20 active:scale-[0.98] transition-all disabled:bg-slate-300">
          {{ loading ? 'Enviando...' : 'Enviar Ticket' }}
        </button>
      </form>

      <div class="mt-8 text-center">
        <NuxtLink to="/login" class="text-blue-500 hover:text-blue-700 text-xs font-bold uppercase tracking-widest transition-colors">
          ← Volver al Login
        </NuxtLink>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const identidades = ref([{ value: '' }])
const categoria = ref('Soporte IT')
const prioridad = ref('Media')
const tema = ref('')
const descripcion = ref('')
const archivoTicket = ref(null)
const loading = ref(false)
const fileInputRef = ref(null)

const categoriasLista = ref([])

onMounted(async () => {
  try {
    const resEmp = await axios.get('/api/empleados/lista')
    empleadosDB.value = resEmp.data || []
  } catch (err) {
    console.error('Error fetching empleados:', err)
  }

  try {
    const res = await axios.get('/api/tickets/categorias/lista')
    categoriasLista.value = res.data.filter(c => c.activa)
    if (categoriasLista.value.length > 0 && !categoriasLista.value.find(c => c.nombre === categoria.value)) {
      categoria.value = categoriasLista.value[0].nombre
    }
  } catch (error) {
    console.error("Error cargando categorías:", error)
  }
})

const handleFileUpload = (event) => {
  archivoTicket.value = event.target.files[0]
}

const addIdentidad = () => {
  identidades.value.push({ value: '' })
}

const removeIdentidad = (index) => {
  identidades.value.splice(index, 1)
}

const empleadosDB = ref([])
const activeDropdown = ref(null)
const suggestions = ref({})

const onIdentidadFocus = (index) => {
  activeDropdown.value = index
}

const onIdentidadBlur = () => {
  activeDropdown.value = null
}

const selectEmpleado = (emp, index) => {
  identidades.value[index].value = emp.identidad
  suggestions.value[index] = []
  activeDropdown.value = null
}

const onIdentidadInput = (event, index) => {
  let val = event.target.value
  
  if (/^[\d-]*$/.test(val)) {
    let cleanVal = val.replace(/\D/g, '')
    if (cleanVal.length > 13) cleanVal = cleanVal.slice(0, 13)
    
    if (cleanVal.length > 8) {
      val = cleanVal.slice(0, 4) + '-' + cleanVal.slice(4, 8) + '-' + cleanVal.slice(8)
    } else if (cleanVal.length > 4) {
      val = cleanVal.slice(0, 4) + '-' + cleanVal.slice(4)
    } else {
      val = cleanVal
    }
  }
  identidades.value[index].value = val
  
  const searchTerm = val.toLowerCase().trim()
  if (searchTerm.length >= 2) {
    suggestions.value[index] = empleadosDB.value.filter(emp => 
      (emp.identidad || '').toLowerCase().includes(searchTerm) ||
      (emp.nombre || '').toLowerCase().includes(searchTerm) ||
      (emp.apellido || '').toLowerCase().includes(searchTerm)
    ).slice(0, 5)
  } else {
    suggestions.value[index] = []
  }
}

const crearTicket = async () => {
  const isIdentidadesValid = identidades.value.every(i => i.value.trim() !== '')
  if (!isIdentidadesValid || !tema.value.trim() || !descripcion.value.trim()) {
    alert("Por favor completa todos los campos requeridos.")
    return
  }

  try {
    loading.value = true
    
    const formData = new FormData()
    formData.append('usuario_id', '') // Nulo ya que es externo
    
    // Unir todas las identidades separadas por coma
    const identidadesString = identidades.value.map(i => i.value.trim()).join(',')
    formData.append('identidad', identidadesString)
    formData.append('tipo', categoria.value)
    formData.append('prioridad', prioridad.value)
    formData.append('tema', tema.value.trim())
    formData.append('descripcion', descripcion.value.trim())
    
    if (archivoTicket.value) {
      formData.append('archivo', archivoTicket.value)
    }

    const res = await axios.post('/api/tickets/crear', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })

    const newTicketId = res.data.ticketId;
    const formattedId = `TKT-${String(newTicketId).padStart(3, '0')}`;
    alert(`✅ Su ticket fue enviado.\n\nPor favor copie este número de ticket para su seguimiento en "Reporte SMS":\n\n📌 ${formattedId}`);
    
    identidades.value = [{ value: '' }]
    tema.value = ''
    descripcion.value = ''
    categoria.value = 'Soporte IT'
    prioridad.value = 'Media'
    archivoTicket.value = null
    if (fileInputRef.value) fileInputRef.value.value = ''
    
    await navigateTo('/login')

  } catch (error) {
    console.error("Error al enviar el ticket:", error)
    alert("❌ Error al enviar el ticket. Inténtalo de nuevo más tarde.")
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.flex {
  animation: pageIn 0.6s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes pageIn {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>
