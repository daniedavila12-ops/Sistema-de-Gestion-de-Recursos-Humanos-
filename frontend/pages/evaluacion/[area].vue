<template>
  <div class="min-h-screen bg-slate-50 font-sans p-4 md:p-8 flex justify-center">
    <div class="w-full max-w-5xl">
      <!-- Header -->
      <div class="flex flex-col md:flex-row justify-between items-center mb-8 gap-4 bg-white p-6 rounded-3xl shadow-sm border border-slate-100">
        <div>
          <h2 class="text-2xl font-black text-slate-800 uppercase tracking-tight">
            Evaluación de Desempeño: <span class="text-blue-600">{{ areaFormat }}</span>
          </h2>
          <p class="text-slate-500 font-medium italic mt-1">Seleccione un empleado de su área para evaluar su rendimiento.</p>
        </div>
        <div>
          <button class="bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold px-6 py-3 rounded-xl transition-colors shadow-sm text-sm uppercase tracking-widest" @click="volverInicio">
            Volver
          </button>
        </div>
      </div>

      <!-- Lista de Empleados -->
      <div v-if="!empleadoSeleccionado" class="bg-white rounded-3xl shadow-sm border border-slate-100 p-8">
        <div v-if="loading" class="flex flex-col items-center justify-center py-12">
          <div class="w-10 h-10 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>
          <p class="mt-4 text-slate-500 font-bold">Cargando empleados...</p>
        </div>
        <div v-else-if="empleados.length === 0" class="bg-blue-50 border border-blue-100 text-blue-800 rounded-2xl p-6 text-center font-medium">
          No hay empleados registrados para esta área.
        </div>
        <div v-else class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
          <div v-for="emp in empleados" :key="emp.id" class="bg-slate-50 hover:bg-blue-50 border border-slate-100 hover:border-blue-200 rounded-3xl p-6 text-center transition-all duration-300 transform hover:-translate-y-1 hover:shadow-lg group">
            <div class="mb-4 flex justify-center">
              <img :src="getFotoUrl(emp.foto)" class="rounded-full w-24 h-24 object-cover shadow-md ring-4 ring-white" alt="Foto">
            </div>
            <h5 class="font-black text-slate-800 text-lg leading-tight">{{ emp.nombre }} {{ emp.apellido }}</h5>
            <p class="text-slate-500 text-xs font-bold uppercase tracking-widest mt-2 mb-4">{{ emp.puesto || emp.departamento }}</p>
            <button class="w-full bg-white group-hover:bg-blue-600 text-blue-600 group-hover:text-white border border-blue-200 group-hover:border-blue-600 font-bold py-3 rounded-xl transition-colors shadow-sm text-sm uppercase tracking-wider" @click="seleccionarEmpleado(emp)">
              Evaluar
            </button>
          </div>
        </div>
      </div>

      <!-- Formulario de Evaluación -->
      <div v-else class="bg-white rounded-3xl shadow-lg border border-slate-100 overflow-hidden">
        <div class="bg-slate-800 p-6 flex justify-between items-center text-white">
          <div class="flex items-center gap-4">
            <img :src="getFotoUrl(empleadoSeleccionado.foto)" class="rounded-full w-14 h-14 object-cover shadow-sm ring-2 ring-slate-600" alt="Foto">
            <div>
              <h4 class="text-xl font-black tracking-tight mb-1">{{ empleadoSeleccionado.nombre }} {{ empleadoSeleccionado.apellido }}</h4>
              <p class="text-blue-300 text-xs font-bold uppercase tracking-widest">{{ empleadoSeleccionado.puesto || empleadoSeleccionado.departamento }} | {{ areaFormat }}</p>
            </div>
          </div>
          <button class="bg-slate-700 hover:bg-slate-600 text-white font-bold px-5 py-2 rounded-xl transition-colors text-xs uppercase tracking-widest" @click="empleadoSeleccionado = null">
            Cancelar
          </button>
        </div>
        
        <div class="p-8">
          <form @submit.prevent="guardarEvaluacion">
            <div class="mb-8">
              <h5 class="font-black text-slate-800 uppercase tracking-tight mb-4">Criterios de Evaluación</h5>
              <div class="bg-blue-50 border border-blue-100 text-blue-800 rounded-xl p-4 flex flex-wrap justify-center gap-4 md:gap-8 text-xs font-black uppercase tracking-widest">
                <span>1 = Muy Deficiente</span>
                <span>2 = Deficiente</span>
                <span>3 = Regular</span>
                <span>4 = Bueno</span>
                <span>5 = Excelente</span>
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div v-for="(crit, index) in criterios" :key="index" class="bg-slate-50 rounded-2xl p-5 border border-slate-100">
                <label class="block font-bold text-slate-700 mb-3">{{ crit.nombre }}</label>
                <select v-model="crit.valor" required class="w-full bg-white border border-slate-200 text-slate-700 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent font-medium shadow-sm transition-shadow">
                  <option value="" disabled selected>Seleccione calificación...</option>
                  <option value="1">1 - Muy Deficiente</option>
                  <option value="2">2 - Deficiente</option>
                  <option value="3">3 - Regular</option>
                  <option value="4">4 - Bueno</option>
                  <option value="5">5 - Excelente</option>
                </select>
              </div>
            </div>

            <!-- Resultados en tiempo real -->
            <div v-if="todosCalificados" class="mt-8 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-3xl p-6 shadow-xl flex justify-around items-center animate-in fade-in slide-in-from-bottom-4 duration-300">
              <div class="text-center">
                <span class="block text-[10px] font-black text-blue-200 uppercase tracking-widest mb-1">Promedio</span>
                <h3 class="text-3xl font-black">{{ promedioCalculado }} <span class="text-lg opacity-70">/ 5</span></h3>
              </div>
              <div class="w-px h-12 bg-white/20"></div>
              <div class="text-center">
                <span class="block text-[10px] font-black text-blue-200 uppercase tracking-widest mb-1">Cumplimiento</span>
                <h3 class="text-3xl font-black">{{ porcentajeCalculado }}%</h3>
              </div>
              <div class="w-px h-12 bg-white/20"></div>
              <div class="text-center">
                <span class="block text-[10px] font-black text-blue-200 uppercase tracking-widest mb-1">Nivel Alcanzado</span>
                <h3 class="text-3xl font-black">{{ nivelCalculado }}</h3>
              </div>
            </div>

            <div class="mt-8">
              <label class="block font-black text-slate-800 uppercase tracking-tight mb-3">Observaciones Generales</label>
              <textarea v-model="observaciones" rows="4" placeholder="Escriba comentarios, fortalezas, oportunidades de mejora..." class="w-full bg-slate-50 border border-slate-200 rounded-2xl p-4 focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none font-medium text-slate-700"></textarea>
            </div>

            <div class="mt-8 flex justify-end border-t border-slate-100 pt-6">
              <button type="submit" :disabled="guardando || !todosCalificados" class="bg-blue-600 text-white font-black px-10 py-4 rounded-xl shadow-lg shadow-blue-200 hover:bg-blue-700 transition-all uppercase tracking-widest disabled:opacity-50 flex items-center gap-2">
                <span v-if="guardando" class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></span>
                <span v-else>💾</span>
                Guardar Evaluación
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import Swal from 'sweetalert2';
import axios from 'axios';

const route = useRoute();
const router = useRouter();

const areaUrl = route.params.area || '';
const areaFormat = computed(() => {
  return areaUrl.charAt(0).toUpperCase() + areaUrl.slice(1);
});

const empleados = ref([]);
const loading = ref(true);
const empleadoSeleccionado = ref(null);
const observaciones = ref('');
const guardando = ref(false);

const criteriosBase = {
  produccion: [
    'Calidad del trabajo', 'Productividad', 'Puntualidad', 'Trabajo en equipo', 
    'Cumplimiento de procesos', 'Seguridad Industrial', 'Uso adecuado de herramientas', 'Orden y limpieza'
  ],
  instalacion: [
    'Calidad de instalación', 'Tiempo de ejecución', 'Atención al cliente', 
    'Uso de herramientas', 'Seguridad', 'Responsabilidad', 'Trabajo en equipo'
  ],
  ventas: [
    'Cumplimiento de metas', 'Atención al cliente', 'Negociación', 'Seguimiento', 
    'Presentación', 'Trabajo en equipo', 'Puntualidad'
  ],
  administracion: [
    'Organización', 'Gestión documental', 'Responsabilidad', 'Comunicación', 'Trabajo en equipo'
  ]
};

const criterios = ref([]);

const cargarCriterios = () => {
  let list = criteriosBase[areaUrl.toLowerCase()] || criteriosBase.administracion; 
  criterios.value = list.map(c => ({ nombre: c, valor: '' }));
};

const cargarEmpleados = async () => {
  loading.value = true;
  try {
    const res = await axios.get(`http://localhost:3007/api/evaluaciones/area/${areaUrl}`);
    empleados.value = res.data;
  } catch (error) {
    console.error(error);
    Swal.fire('Error', 'No se pudieron cargar los empleados del área', 'error');
  } finally {
    loading.value = false;
  }
};

onMounted(() => {
  cargarCriterios();
  cargarEmpleados();
});

const seleccionarEmpleado = (emp) => {
  empleadoSeleccionado.value = emp;
  observaciones.value = '';
  criterios.value.forEach(c => c.valor = '');
};

const getFotoUrl = (foto) => {
  if (foto) return `http://localhost:3007/uploads/perfiles/${foto}`;
  return 'https://ui-avatars.com/api/?name=Empleado&background=0D8ABC&color=fff';
};

const volverInicio = () => {
  router.push('/');
};

const todosCalificados = computed(() => {
  return criterios.value.every(c => c.valor !== '');
});

const promedioCalculado = computed(() => {
  if (!todosCalificados.value) return 0;
  let sum = criterios.value.reduce((acc, c) => acc + parseInt(c.valor), 0);
  return (sum / criterios.value.length).toFixed(2);
});

const porcentajeCalculado = computed(() => {
  return ((promedioCalculado.value / 5) * 100).toFixed(2);
});

const nivelCalculado = computed(() => {
  const p = parseFloat(promedioCalculado.value);
  if (p >= 4.5) return 'Excelente';
  if (p >= 3.5) return 'Bueno';
  if (p >= 2.5) return 'Regular';
  if (p >= 1.5) return 'Deficiente';
  return 'Muy Deficiente';
});

const guardarEvaluacion = async () => {
  if (!todosCalificados.value) return;
  
  guardando.value = true;
  try {
    const storedUser = localStorage.getItem('usuario');
    let eval_id = 1; 
    let eval_nombre = 'Jefe';
    if(storedUser) {
      const u = JSON.parse(storedUser);
      eval_id = u.id || 1;
      eval_nombre = u.nombre || localStorage.getItem('usuarioNombre');
    }

    const payload = {
      empleado_id: empleadoSeleccionado.value.id,
      evaluador_id: eval_id,
      evaluador_nombre: eval_nombre,
      area: areaFormat.value,
      observaciones: observaciones.value,
      respuestas: criterios.value.map(c => ({ criterio: c.nombre, calificacion: c.valor }))
    };

    const res = await axios.post('http://localhost:3007/api/evaluaciones', payload);
    
    Swal.fire({
      title: '¡Evaluación Guardada!',
      html: `Promedio: <b>${res.data.promedio}</b> <br> Nivel: <b>${res.data.nivel}</b>`,
      icon: 'success',
      confirmButtonColor: '#3b82f6'
    });

    empleadoSeleccionado.value = null; 
  } catch (error) {
    console.error(error);
    Swal.fire('Error', 'Ocurrió un problema al guardar la evaluación', 'error');
  } finally {
    guardando.value = false;
  }
};
</script>
