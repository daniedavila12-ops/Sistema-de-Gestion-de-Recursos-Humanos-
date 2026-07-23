<template>
  <div class="min-h-screen flex flex-col items-center justify-center bg-slate-900 p-4 font-sans overflow-y-auto py-10">
    
    <div class="bg-white p-10 rounded-3xl shadow-2xl w-full max-w-md border border-white/10 my-8">
      <div class="text-center mb-8">
        <div class="text-4xl mb-4">⚠️</div>
        <h2 class="text-3xl font-black text-slate-800 tracking-tighter uppercase">Reporte de Incidencia</h2>
        <p class="text-slate-400 font-bold text-xs mt-2 tracking-widest uppercase opacity-70">Reportar Empleado</p>
      </div>

      <form @submit.prevent="crearReporte" class="space-y-6">
        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Tu Nombre (Jefe / Encargado)</label>
          <input v-model="jefe_reporta" type="text" required placeholder="Ej: Juan Pérez"
            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200">
        </div>

        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Identidad del Empleado Reportado</label>
          <div v-for="(id, index) in identidades" :key="index" class="flex gap-2 mb-2">
            <input v-model="identidades[index]" @input="formatIdentidad(index)" type="text" required placeholder="Ej: 0801-1990-12345"
              class="flex-1 px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200">
            <button v-if="identidades.length > 1" type="button" @click="removerIdentidad(index)" class="px-4 bg-red-100 text-red-600 rounded-2xl hover:bg-red-200 transition-colors font-bold text-xl flex items-center justify-center">
              &times;
            </button>
          </div>
          <button type="button" @click="agregarIdentidad" class="text-xs text-blue-600 font-bold hover:text-blue-800 transition-colors uppercase tracking-widest mt-1 inline-block">
            + Agregar otra persona
          </button>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Categoría</label>
            <select v-model="categoria" class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200 appearance-none">
              <option v-for="cat in categorias" :key="cat.id" :value="cat.nombre">{{ cat.nombre }}</option>
            </select>
          </div>
          <div>
            <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Gravedad</label>
            <select v-model="prioridad" class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200 appearance-none">
              <option value="Baja">Baja</option>
              <option value="Media">Media</option>
              <option value="Alta">Alta</option>
              <option value="Urgente">Grave</option>
            </select>
          </div>
        </div>

        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Motivo / Asunto</label>
          <input v-model="tema" type="text" required placeholder="Breve resumen"
            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200">
        </div>

        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Descripción del Incidente</label>
          <textarea v-model="descripcion" required rows="3" placeholder="Detalla lo sucedido..."
            class="w-full px-5 py-4 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200 resize-none"></textarea>
        </div>

        <div>
          <label class="block text-[10px] font-black text-slate-500 uppercase tracking-widest mb-1 pl-1">Evidencia (Opcional)</label>
          <input type="file" ref="fileInputRef" @change="handleFileUpload"
            class="w-full p-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-900 text-sm focus:ring-4 focus:ring-blue-500/10 focus:border-blue-500 outline-none transition-all duration-200 cursor-pointer">
        </div>

        <button type="submit" :disabled="loading"
          class="w-full bg-red-600 text-white py-4 rounded-2xl font-black text-sm uppercase tracking-widest hover:bg-red-700 shadow-xl shadow-red-500/20 active:scale-[0.98] transition-all disabled:bg-slate-300">
          {{ loading ? 'Enviando...' : 'Enviar Reporte' }}
        </button>
      </form>

      <div class="mt-8 text-center">
        <NuxtLink to="/dashboard" class="text-blue-500 hover:text-blue-700 text-xs font-bold uppercase tracking-widest transition-colors">
          ← Volver al Login
        </NuxtLink>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import Swal from 'sweetalert2'

const jefe_reporta = ref('')
const identidades = ref([''])
const categoria = ref('')

const agregarIdentidad = () => identidades.value.push('')
const removerIdentidad = (index) => { if (identidades.value.length > 1) identidades.value.splice(index, 1) }

const formatIdentidad = (index) => {
  let val = identidades.value[index].replace(/\D/g, '')
  if (val.length > 4) val = val.substring(0, 4) + '-' + val.substring(4)
  if (val.length > 9) val = val.substring(0, 9) + '-' + val.substring(9)
  if (val.length > 15) val = val.substring(0, 15)
  identidades.value[index] = val
}
const prioridad = ref('Media')
const tema = ref('')
const descripcion = ref('')
const archivoReporte = ref(null)
const loading = ref(false)
const fileInputRef = ref(null)
const categorias = ref([])

onMounted(async () => {
  try {
    const res = await axios.get('/api/reportes-incidencia/categorias/lista')
    categorias.value = res.data.filter(c => c.activa)
    if (categorias.value.length > 0) {
      categoria.value = categorias.value[0].nombre
    }
  } catch (error) {
    console.error("Error al obtener categorías:", error)
  }
})

const handleFileUpload = (event) => {
  archivoReporte.value = event.target.files[0]
}

const crearReporte = async () => {
  const identidadesValidas = identidades.value.filter(i => i.trim() !== '').join(', ');
  if (!jefe_reporta.value || !identidadesValidas || !tema.value || !descripcion.value) {
    Swal.fire('Error', 'Todos los campos obligatorios deben estar llenos.', 'error');
    return;
  }

  try {
    loading.value = true;
    const formData = new FormData();
    formData.append('jefe_reporta', jefe_reporta.value);
    formData.append('identidad', identidadesValidas);
    formData.append('categoria', categoria.value);
    formData.append('prioridad', prioridad.value);
    formData.append('tema', tema.value);
    formData.append('descripcion', descripcion.value);
    if (archivoReporte.value) {
      formData.append('archivo', archivoReporte.value);
    }

    const res = await axios.post('/api/reportes-incidencia/crear', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    });

    Swal.fire({
      icon: 'success',
      title: 'Reporte Enviado',
      text: res.data.mensaje || 'Tu reporte ha sido enviado con éxito.',
      confirmButtonColor: '#3085d6',
    }).then(() => {
      jefe_reporta.value = '';
      identidades.value = [''];
      tema.value = '';
      descripcion.value = '';
      if (fileInputRef.value) fileInputRef.value.value = '';
      archivoReporte.value = null;
    });

  } catch (error) {
    console.error("Error al enviar reporte:", error);
    Swal.fire('Error', error.response?.data?.error || 'Hubo un error al enviar el reporte. Por favor intenta de nuevo.', 'error');
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.min-h-screen {
  animation: fadeIn 0.5s ease-out;
}
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>