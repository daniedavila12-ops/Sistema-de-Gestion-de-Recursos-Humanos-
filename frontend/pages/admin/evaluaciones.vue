<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <!-- SIDEBAR -->
    <AppSidebar />

    <!-- MAIN CONTENT -->
    <main class="w-full overflow-x-hidden transition-all duration-300 flex-1 md:ml-64 p-8">
      <header class="mb-8 flex justify-between items-center bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div>
          <button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors mr-3 shrink-0">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
          </button>
          <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Dashboard de Evaluaciones</h1>
          <p class="text-slate-500 mt-1 font-medium italic">Resumen Organizacional y Desempeño</p>
        </div>
        <div class="flex gap-3">
          <button @click="exportarPDF" class="flex items-center gap-2 bg-red-50 text-red-600 hover:bg-red-600 hover:text-white px-5 py-2.5 rounded-xl font-bold transition-colors shadow-sm">
            📄 Exportar PDF
          </button>
          <button @click="exportarExcel" class="flex items-center gap-2 bg-green-50 text-green-600 hover:bg-green-600 hover:text-white px-5 py-2.5 rounded-xl font-bold transition-colors shadow-sm">
            📊 Exportar Excel
          </button>
        </div>
      </header>

      <!-- KPIs -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <div class="bg-blue-600 text-white rounded-3xl p-6 shadow-lg shadow-blue-200 flex flex-col justify-between">
          <h6 class="text-blue-100 text-[10px] font-black uppercase tracking-widest mb-2">Total Empleados</h6>
          <h2 class="text-4xl font-black">{{ dashboard.total_empleados || 0 }}</h2>
        </div>
        <div class="bg-emerald-500 text-white rounded-3xl p-6 shadow-lg shadow-emerald-200 flex flex-col justify-between">
          <h6 class="text-emerald-100 text-[10px] font-black uppercase tracking-widest mb-2">Total Evaluados</h6>
          <div class="flex items-end gap-3">
            <h2 class="text-4xl font-black">{{ dashboard.total_evaluados || 0 }}</h2>
            <span v-if="dashboard.total_empleados > 0" class="text-sm font-medium mb-1 opacity-90">
              {{ ((dashboard.total_evaluados / dashboard.total_empleados) * 100).toFixed(1) }}%
            </span>
          </div>
        </div>
        <div class="bg-violet-600 text-white rounded-3xl p-6 shadow-lg shadow-violet-200 flex flex-col justify-between">
          <h6 class="text-violet-100 text-[10px] font-black uppercase tracking-widest mb-2">Promedio General</h6>
          <div class="flex items-end gap-2">
            <h2 class="text-4xl font-black">{{ (dashboard.promedio_general || 0).toFixed(2) }}</h2>
            <span class="text-xl mb-1 opacity-70">/ 5</span>
          </div>
        </div>
        <div class="bg-amber-400 text-amber-900 rounded-3xl p-6 shadow-lg shadow-amber-200 flex flex-col justify-between">
          <h6 class="text-amber-700 text-[10px] font-black uppercase tracking-widest mb-2">Pendientes</h6>
          <h2 class="text-4xl font-black">{{ (dashboard.total_empleados || 0) - (dashboard.total_evaluados || 0) }}</h2>
        </div>
      </div>

      <!-- GRAFICOS -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <!-- Promedio por Área -->
        <div class="lg:col-span-2 bg-white rounded-3xl shadow-sm border border-slate-100 p-6">
          <h5 class="text-lg font-black text-slate-800 mb-6 uppercase tracking-tight">Promedio por Área</h5>
          <div class="relative h-64 w-full">
            <canvas id="chartAreas"></canvas>
          </div>
        </div>

        <!-- Distribución de Niveles -->
        <div class="bg-white rounded-3xl shadow-sm border border-slate-100 p-6 flex flex-col items-center">
          <h5 class="text-lg font-black text-slate-800 mb-6 uppercase tracking-tight w-full text-left">Distribución</h5>
          <div class="relative h-48 w-48 mt-2">
            <canvas id="chartNiveles"></canvas>
          </div>
        </div>
      </div>

      <!-- Rankings e Informe -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Top Empleados -->
        <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden flex flex-col">
          <div class="p-6 border-b border-slate-100 bg-slate-50">
            <h5 class="text-lg font-black text-slate-800 uppercase tracking-tight flex items-center gap-2">
              <span class="text-amber-500">🏆</span> Top Empleados
            </h5>
          </div>
          <div class="flex-1 overflow-x-auto">
            <table class="w-full text-left">
              <thead>
                <tr class="bg-white border-b border-slate-100">
                  <th class="p-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Empleado</th>
                  <th class="p-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Área</th>
                  <th class="p-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Promedio</th>
                  <th class="p-4 text-[10px] font-black text-slate-400 uppercase tracking-widest">Nivel</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(emp, idx) in dashboard.top_empleados" :key="idx" class="border-b border-slate-50 hover:bg-slate-50 transition-colors">
                  <td class="p-4 flex items-center gap-3">
                    <img :src="emp.foto ? `${$config.public.apiBase}/uploads/perfiles/`+emp.foto : 'https://ui-avatars.com/api/?name='+emp.nombre" 
                         class="rounded-full w-8 h-8 object-cover shadow-sm">
                    <span class="font-bold text-slate-700 text-sm">{{ emp.nombre }} {{ emp.apellido }}</span>
                  </td>
                  <td class="p-4 text-sm text-slate-600">{{ emp.area }}</td>
                  <td class="p-4 font-black text-blue-600">{{ emp.promedio }}</td>
                  <td class="p-4">
                    <span class="px-2 py-1 text-[10px] font-black uppercase rounded-full tracking-widest" :class="getBadgeClass(emp.nivel)">
                      {{ emp.nivel }}
                    </span>
                  </td>
                </tr>
                <tr v-if="!dashboard.top_empleados || dashboard.top_empleados.length === 0">
                  <td colspan="4" class="p-8 text-center text-slate-400 italic font-medium">No hay evaluaciones registradas</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Informe Ejecutivo Automático -->
        <div class="bg-slate-50 rounded-3xl shadow-inner border border-slate-200 p-6 flex flex-col">
          <h5 class="text-lg font-black text-slate-800 uppercase tracking-tight flex items-center gap-2 mb-4 border-b border-slate-200 pb-4">
            <span class="text-blue-500">🤖</span> Resumen Ejecutivo Automático
          </h5>
          
          <div v-if="loadingInforme" class="flex flex-col items-center justify-center py-10 flex-1">
            <div class="w-8 h-8 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>
            <p class="mt-4 text-slate-500 font-bold text-sm tracking-wide">Generando análisis inteligente...</p>
          </div>
          
          <div v-else-if="informe" class="flex-1 space-y-5">
            <p class="text-slate-600 text-sm font-medium leading-relaxed italic bg-white p-4 rounded-xl border border-slate-100 shadow-sm">
              {{ informe.resumen }}
            </p>
            
            <div>
              <h6 class="text-[11px] font-black text-emerald-600 uppercase tracking-widest flex items-center gap-2 mb-2">
                <span class="text-lg">▲</span> Fortalezas
              </h6>
              <ul class="space-y-2">
                <li v-for="(f, i) in informe.fortalezas" :key="'f'+i" class="text-sm text-slate-700 bg-emerald-50 px-3 py-2 rounded-lg border border-emerald-100">
                  {{ f }}
                </li>
              </ul>
            </div>

            <div v-if="informe.debilidades && informe.debilidades.length > 0">
              <h6 class="text-[11px] font-black text-red-500 uppercase tracking-widest flex items-center gap-2 mb-2">
                <span class="text-lg">▼</span> Oportunidades de Mejora
              </h6>
              <ul class="space-y-2">
                <li v-for="(d, i) in informe.debilidades" :key="'d'+i" class="text-sm text-slate-700 bg-red-50 px-3 py-2 rounded-lg border border-red-100">
                  {{ d }}
                </li>
              </ul>
            </div>

            <div>
              <h6 class="text-[11px] font-black text-blue-600 uppercase tracking-widest flex items-center gap-2 mb-2 mt-4 border-t border-slate-200 pt-4">
                <span class="text-lg">💡</span> Recomendaciones Estratégicas
              </h6>
              <ul class="space-y-2">
                <li v-for="(r, i) in informe.recomendaciones" :key="'r'+i" class="text-sm font-medium text-slate-800 flex items-start gap-2">
                  <span class="text-blue-500">•</span> {{ r }}
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { useSidebar } from '@/composables/useSidebar'
const { toggleMobileMenu } = useSidebar()
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Chart from 'chart.js/auto';
import { useRouter } from 'vue-router';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import * as XLSX from 'xlsx';

const router = useRouter();

// Variables de Layout
const rolID = ref(null);
const rolNombre = ref('Cargando...');
;
const usuarioActual = ref('');

const dashboard = ref({});
const informe = ref(null);
const loadingInforme = ref(true);

const cargarMenu = async () => {
  rolID.value = localStorage.getItem('usuarioRol') || 2;
  usuarioActual.value = localStorage.getItem('usuarioNombre') || 'Usuario';
  
  if (rolID.value == 1) rolNombre.value = 'Administrador IT';
  else if (rolID.value == 2) rolNombre.value = 'Recursos Humanos';
  else rolNombre.value = 'Empleado';

  try {
    const userId = localStorage.getItem('usuarioID');
    const m = await axios.get(`/api/menu/${rolID.value}?usuario_id=${userId}`);
    menuUsuario.value = m.data;
  } catch (e) {
    console.error('Error cargando menú', e);
  }
};

const logout = () => {
  localStorage.clear();
  router.push('/login');
};

const cargarDashboard = async () => {
  try {
    const res = await axios.get('/api/evaluaciones/dashboard');
    dashboard.value = res.data;
    renderCharts();
  } catch (error) {
    console.error("Error cargando dashboard:", error);
  }
};

const cargarInforme = async () => {
  loadingInforme.value = true;
  try {
    const res = await axios.get('/api/evaluaciones/informe');
    informe.value = res.data;
  } catch (error) {
    console.error("Error cargando informe:", error);
  } finally {
    loadingInforme.value = false;
  }
};

const renderCharts = () => {
  const chartAreasCanvas = document.getElementById('chartAreas');
  const chartNivelesCanvas = document.getElementById('chartNiveles');
  
  if(window.myChartAreas) window.myChartAreas.destroy();
  if(window.myChartNiveles) window.myChartNiveles.destroy();

  const areasData = dashboard.value.por_area || [];
  if (chartAreasCanvas && areasData.length > 0) {
    window.myChartAreas = new Chart(chartAreasCanvas, {
      type: 'bar',
      data: {
        labels: areasData.map(d => d.area),
        datasets: [{
          label: 'Promedio (1-5)',
          data: areasData.map(d => parseFloat(d.promedio)),
          backgroundColor: '#3b82f6',
          borderRadius: 8,
          borderSkipped: false
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { beginAtZero: true, max: 5, grid: { color: '#f1f5f9' } },
          x: { grid: { display: false } }
        },
        plugins: {
          legend: { display: false }
        }
      }
    });
  }

  const nivelesData = dashboard.value.por_nivel || [];
  if (chartNivelesCanvas && nivelesData.length > 0) {
    window.myChartNiveles = new Chart(chartNivelesCanvas, {
      type: 'doughnut',
      data: {
        labels: nivelesData.map(d => d.nivel),
        datasets: [{
          data: nivelesData.map(d => d.cantidad),
          backgroundColor: ['#10b981', '#3b82f6', '#f59e0b', '#f97316', '#ef4444'],
          borderWidth: 0,
          hoverOffset: 4
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom', labels: { usePointStyle: true, padding: 20, font: { size: 10 } } }
        },
        cutout: '75%'
      }
    });
  }
};

const getBadgeClass = (nivel) => {
  switch (nivel) {
    case 'Excelente': return 'bg-emerald-100 text-emerald-700';
    case 'Bueno': return 'bg-blue-100 text-blue-700';
    case 'Regular': return 'bg-amber-100 text-amber-700';
    case 'Deficiente': return 'bg-orange-100 text-orange-700';
    case 'Muy Deficiente': return 'bg-red-100 text-red-700';
    default: return 'bg-slate-100 text-slate-700';
  }
};

const exportarPDF = () => {
  if (!dashboard.value.top_empleados || dashboard.value.top_empleados.length === 0) {
    alert("No hay datos para exportar.");
    return;
  }
  const doc = new jsPDF();
  doc.text("Resumen Organizacional - Evaluaciones", 14, 20);
  
  const headers = [["Empleado", "Área", "Promedio", "Nivel"]];
  const data = dashboard.value.top_empleados.map(emp => [
    `${emp.nombre} ${emp.apellido}`,
    emp.area,
    emp.promedio,
    emp.nivel
  ]);

  autoTable(doc, {
    startY: 30,
    head: headers,
    body: data,
    theme: 'striped',
    headStyles: { fillColor: [59, 130, 246] }
  });

  doc.save("Reporte_Evaluaciones.pdf");
};

const exportarExcel = () => {
  if (!dashboard.value.top_empleados || dashboard.value.top_empleados.length === 0) {
    alert("No hay datos para exportar.");
    return;
  }
  const data = dashboard.value.top_empleados.map(emp => ({
    Empleado: `${emp.nombre} ${emp.apellido}`,
    Área: emp.area,
    Promedio: emp.promedio,
    Nivel: emp.nivel
  }));
  
  const worksheet = XLSX.utils.json_to_sheet(data);
  const workbook = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(workbook, worksheet, "Evaluaciones");
  XLSX.writeFile(workbook, "Reporte_Evaluaciones.xlsx");
};

onMounted(() => {
  cargarMenu();
  cargarDashboard();
  cargarInforme();
});
</script>
