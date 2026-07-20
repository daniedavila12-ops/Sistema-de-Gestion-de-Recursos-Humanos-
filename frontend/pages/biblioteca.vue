<template>
  <div class="min-h-screen bg-slate-900 p-8 font-sans">
    <div class="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-start md:items-center mb-12 gap-6">
      <div>
        <NuxtLink to="/login" class="text-blue-400 text-xs font-bold uppercase tracking-widest hover:underline flex items-center gap-2 mb-6">
          ⬅️ Volver al Login
        </NuxtLink>
        <h1 class="text-5xl font-black text-white tracking-tighter uppercase">Biblioteca <span class="text-blue-500">Digital</span></h1>
        <p class="text-slate-400 mt-2 font-medium italic">Consulta y descarga manuales de procedimientos y normativas.</p>
      </div>
      <div class="bg-slate-800 p-4 rounded-3xl border border-white/5 flex items-center justify-center">
        <span class="text-3xl">📚</span>
      </div>
    </div>

    <div class="max-w-6xl mx-auto mb-10">
      <input v-model="search" type="text" placeholder="Buscar manual por nombre o categoría..." 
        class="w-full bg-slate-800 border border-white/10 p-5 rounded-2xl text-white outline-none focus:border-blue-500 transition-all shadow-2xl">
    </div>

    <div v-if="cargando" class="text-center py-20 text-slate-500">
      <p class="text-xl italic font-medium">Cargando biblioteca...</p>
    </div>

    <div v-else class="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="manual in manualesFiltrados" :key="manual.id" 
        class="bg-white rounded-3xl overflow-hidden shadow-xl group hover:translate-y-[-5px] transition-all duration-300">
        <div class="h-3 bg-blue-600"></div>
        <div class="p-8">
          <div class="flex justify-between items-start mb-4">
            <span class="px-3 py-1 bg-blue-50 text-blue-600 text-[10px] font-black uppercase rounded-full tracking-widest">
              {{ manual.categoria || 'General' }}
            </span>
            <span class="text-slate-400 text-xs font-bold">{{ manual.tamano || 'Desconocido' }}</span>
          </div>
          <h3 class="text-xl font-black text-slate-800 mb-2">{{ manual.titulo }}</h3>
          <p class="text-slate-500 text-sm leading-relaxed mb-6 italic">{{ manual.descripcion }}</p>
          
          <button @click="abrirArchivo(manual)" 
            class="w-full py-4 bg-slate-900 text-white rounded-2xl font-bold uppercase text-xs tracking-widest hover:bg-blue-600 transition-colors flex items-center justify-center gap-3">
            <span v-if="esVideo(manual.archivo)">▶️</span>
            <span v-else>📥</span> 
            {{ esVideo(manual.archivo) ? 'Ver Video' : 'Descargar PDF' }}
          </button>
        </div>
      </div>
    </div>

    <div v-if="!cargando && manualesFiltrados.length === 0" class="text-center py-20 text-slate-500">
      <p class="text-xl italic font-medium">No se encontraron manuales con ese criterio.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const search = ref('')
const listaManuales = ref([])
const cargando = ref(true)
const config = useRuntimeConfig()

const cargarManuales = async () => {
  try {
    const res = await fetch(`${config.public.apiBase}/api/biblioteca`)
    if (res.ok) {
      listaManuales.value = await res.json()
    }
  } catch (error) {
    console.error('Error cargando biblioteca:', error)
  } finally {
    cargando.value = false
  }
}

onMounted(() => {
  cargarManuales()
})

const manualesFiltrados = computed(() => {
  return listaManuales.value.filter(m => 
    m.titulo.toLowerCase().includes(search.value.toLowerCase()) || 
    (m.categoria && m.categoria.toLowerCase().includes(search.value.toLowerCase()))
  )
})

const esVideo = (archivo) => {
  if (!archivo) return false;
  return archivo.match(/\.(mp4|webm|ogg|mov)$/i);
}

const abrirArchivo = (manual) => {
  if (manual.archivo) {
    window.open(`${config.public.apiBase}${manual.archivo}`, '_blank');
  } else {
    alert("Archivo no disponible.");
  }
}
</script>