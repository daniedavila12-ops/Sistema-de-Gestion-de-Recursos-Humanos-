<template>
  <div class="min-h-screen bg-gray-100 flex font-sans overflow-x-hidden">
    <!-- SIDEBAR -->
    <aside class="w-64 bg-slate-800 text-white flex flex-col shadow-xl fixed h-full z-10 hidden md:flex">
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

    <!-- MOBILE MENU BUTTON -->
    <button @click="mobileMenuOpen = !mobileMenuOpen" class="md:hidden fixed top-4 right-4 z-50 p-3 bg-slate-800 text-white rounded-lg shadow-lg flex items-center justify-center">
      <span class="text-xl">{{ mobileMenuOpen ? '✖' : '☰' }}</span>
    </button>

    <!-- MOBILE SIDEBAR -->
    <div v-if="mobileMenuOpen" class="fixed inset-0 bg-slate-800 z-40 md:hidden flex flex-col">
      <div class="p-6 text-2xl font-bold border-b border-slate-700 tracking-tight text-blue-400 uppercase">
        RRHH Innova
      </div>
      <nav class="flex-1 p-4 space-y-2 overflow-y-auto">
        <div v-for="(item, index) in menuUsuario" :key="item.ruta || index">
          <div v-if="item.esCabecera" class="text-[10px] font-black text-slate-500 uppercase tracking-widest mt-6 mb-2 px-3">
            {{ item.nombre }}
          </div>
          <NuxtLink v-else :to="item.ruta" @click="mobileMenuOpen = false"
            class="flex items-center gap-3 p-4 rounded-xl hover:bg-slate-700 transition-all duration-200"
            active-class="bg-blue-600 shadow-lg">
            <span class="text-xl">{{ item.icono }}</span>
            <span class="text-sm font-bold">{{ item.nombre }}</span>
          </NuxtLink>
        </div>
      </nav>
      <div class="p-6 border-t border-slate-700 bg-slate-900/50">
         <button @click="logout" class="w-full flex items-center justify-center gap-3 p-4 rounded-xl bg-red-500/20 text-red-400 font-bold text-sm uppercase tracking-widest">
          <span>🚪</span> Cerrar Sesión
        </button>
      </div>
    </div>

    <!-- MAIN CONTENT -->
    <main class="flex-1 md:ml-64 p-4 md:p-6 w-full transition-all printable-area">
      <!-- HEADER -->
      <header class="mb-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white p-5 rounded-2xl shadow-sm border border-slate-200">
        <div>
          <div class="flex items-center gap-3">
             <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase">Módulo de Reportes</h1>
             <div class="flex items-center gap-1.5 px-2.5 py-1 bg-emerald-50 border border-emerald-100 rounded-full animate-pulse">
                <div class="w-2 h-2 rounded-full bg-emerald-500"></div>
                <span class="text-[9px] font-bold text-emerald-600 uppercase tracking-widest">En Vivo</span>
             </div>
          </div>
          <p class="text-slate-500 mt-1 font-medium text-sm">Dashboard Analítico e Integrado en Tiempo Real</p>
        </div>
        <div class="w-full md:w-auto flex flex-col md:flex-row items-center gap-4">
          <button @click="imprimirReporte" class="w-full md:w-auto bg-slate-800 text-white px-5 py-2.5 rounded-lg font-bold uppercase text-xs hover:bg-slate-900 transition-all shadow-sm flex items-center justify-center gap-2 no-print">
            <span>🖨️</span> Exportar a PDF
          </button>
          
          <div class="relative w-full md:w-auto flex justify-end">
            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-6 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors no-print">
              <div v-if="fotoUsuario" class="h-10 w-10 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-slate-100">
                <img :src="`http://localhost:3007${fotoUsuario}`" class="w-full h-full object-cover" />
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
                  <img :src="`http://localhost:3007${fotoUsuario}`" class="w-full h-full object-cover" />
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
      </header>

      <!-- NAVIGATION TABS -->
      <div class="flex border-b border-slate-200 mb-6 overflow-x-auto no-print">
        <button @click="activeTab = 'dashboard'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'dashboard' ? 'border-blue-500 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          📊 Dashboard General
        </button>
        <button @click="activeTab = 'empleados'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'empleados' ? 'border-blue-500 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          👥 Plantilla & Empleados
        </button>
        <button @click="activeTab = 'tickets'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'tickets' ? 'border-blue-500 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          🎫 Soporte & Tickets
        </button>
        <button @click="activeTab = 'proyecciones'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'proyecciones' ? 'border-blue-500 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          📅 Proyecciones Vacaciones
        </button>
        <button @click="activeTab = 'asistencia'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'asistencia' ? 'border-blue-500 text-blue-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          ⏳ Asistencia y Tiempos
        </button>
      </div>

      <!-- TAB: DASHBOARD -->
      <div v-if="activeTab === 'dashboard'" class="space-y-6 animate-in fade-in duration-300">
        <!-- KPIs Principales e Integrados -->
        <div v-if="loadingStats" class="bg-white rounded-2xl shadow-sm border border-slate-200 p-10 text-center text-slate-400 text-sm italic flex flex-col items-center gap-3">
          <div class="w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          Cargando indicadores en tiempo real...
        </div>
        <div v-else class="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
           <!-- Empleados -->
          <div class="bg-gradient-to-br from-blue-500 to-blue-700 p-5 rounded-2xl shadow-lg shadow-blue-500/20 text-white relative overflow-hidden group hover:-translate-y-1 transition-transform">
            <div class="absolute -right-4 -top-4 text-white/20 text-7xl group-hover:scale-110 transition-transform">👥</div>
            <p class="text-[10px] font-black uppercase tracking-widest text-blue-100 mb-1 relative z-10">Total Empleados</p>
            <p class="text-4xl font-black relative z-10">{{ stats.total || 0 }}</p>
            <div class="mt-2 text-[10px] font-medium text-blue-100 relative z-10 flex justify-between">
               <span>Activos: <strong class="text-white">{{ stats.activos || 0 }}</strong></span>
               <span>Inactivos: <strong class="text-white">{{ stats.inactivos || 0 }}</strong></span>
            </div>
          </div>
          
          <!-- Tickets Ptes. -->
          <div class="bg-gradient-to-br from-amber-400 to-orange-500 p-5 rounded-2xl shadow-lg shadow-orange-500/20 text-white relative overflow-hidden group hover:-translate-y-1 transition-transform">
            <div class="absolute -right-4 -top-4 text-white/20 text-7xl group-hover:scale-110 transition-transform">🎫</div>
            <p class="text-[10px] font-black uppercase tracking-widest text-orange-100 mb-1 relative z-10">Tickets Ptes.</p>
            <p class="text-4xl font-black relative z-10">{{ stats.tickets || 0 }}</p>
            <div class="mt-2 text-[10px] font-medium text-orange-100 relative z-10">Soporte IT Pendiente</div>
          </div>

          <!-- De Vacaciones -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow group relative overflow-hidden">
            <div class="absolute top-0 right-0 w-16 h-16 bg-emerald-500/5 rounded-bl-full -z-10 group-hover:scale-150 transition-transform"></div>
            <div class="flex items-start justify-between">
              <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-tight">De Vacaciones<br>(Actual)</p>
              <span class="text-2xl opacity-80 group-hover:scale-110 transition-transform">🏖️</span>
            </div>
            <p class="text-3xl font-black text-emerald-600 mt-2">{{ stats.de_vacaciones || 0 }}</p>
          </div>

          <!-- Faltas Mes -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow group relative overflow-hidden">
            <div class="absolute top-0 right-0 w-16 h-16 bg-rose-500/5 rounded-bl-full -z-10 group-hover:scale-150 transition-transform"></div>
            <div class="flex items-start justify-between">
              <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-tight">Faltas<br>(Este Mes)</p>
              <span class="text-2xl opacity-80 group-hover:scale-110 transition-transform">⚠️</span>
            </div>
            <p class="text-3xl font-black text-rose-600 mt-2">{{ stats.faltas_mes || 0 }}</p>
          </div>

          <!-- Documentos Legales -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow group relative overflow-hidden">
            <div class="absolute top-0 right-0 w-16 h-16 bg-indigo-500/5 rounded-bl-full -z-10 group-hover:scale-150 transition-transform"></div>
            <div class="flex items-start justify-between">
              <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-tight">Docs.<br>Legales</p>
              <span class="text-2xl opacity-80 group-hover:scale-110 transition-transform">⚖️</span>
            </div>
            <p class="text-3xl font-black text-indigo-600 mt-2">{{ stats.doc_legales || 0 }}</p>
          </div>
          
          <!-- Vencimientos -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow group relative overflow-hidden">
             <div class="absolute top-0 right-0 w-16 h-16 bg-purple-500/5 rounded-bl-full -z-10 group-hover:scale-150 transition-transform"></div>
            <div class="flex items-start justify-between">
              <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-tight">Venc. Contrato<br>(30d)</p>
              <span class="text-2xl opacity-80 group-hover:scale-110 transition-transform">📄</span>
            </div>
            <p class="text-3xl font-black text-purple-600 mt-2">{{ stats.vencimientos || 0 }}</p>
          </div>
        </div>

        <!-- CHARTS & ALERTS SECTION -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 md:gap-6 mb-6">
          <!-- Empleados por Departamento (Bar Chart) -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col lg:col-span-2 min-h-[320px]">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-blue-500"></span>
                 Distribución por Departamento
              </h2>
            </div>
            <div class="flex-1 relative w-full h-full flex justify-center items-center">
              <Bar v-if="!loadingDepts && chartDeptData" :data="chartDeptData" :options="barOptions" />
              <span v-else class="text-slate-400 italic text-xs">Cargando distribución...</span>
            </div>
          </div>

          <!-- Alertas y Estado -->
          <div class="flex flex-col gap-4 md:gap-6">
            <!-- Chart 2: Empleados por Estado (Doughnut) -->
            <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[220px]">
              <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
                 Estado de Plantilla
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center">
                <Doughnut v-if="!loadingStats && chartEstadoData" :data="chartEstadoData" :options="doughnutOptions" />
              </div>
            </div>
            
            <!-- Alertas Rápidas -->
            <div class="bg-gradient-to-b from-slate-800 to-slate-900 p-5 rounded-2xl shadow-sm flex flex-col flex-1 relative overflow-hidden">
              <div class="absolute -right-4 -bottom-4 text-white/5 text-8xl">🔔</div>
              <h2 class="text-sm font-black text-white uppercase tracking-widest mb-4 relative z-10 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-red-500 animate-pulse"></span>
                 Avisos Importantes
              </h2>
              <div class="space-y-3 relative z-10">
                <div class="flex items-center justify-between p-3 rounded-xl bg-white/10 backdrop-blur border border-white/5 hover:bg-white/20 transition-colors cursor-pointer group">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-purple-500/20 flex items-center justify-center text-purple-300 group-hover:scale-110 transition-transform">🎂</div>
                    <span class="text-xs font-bold text-slate-200">Cumpleaños (Mes)</span>
                  </div>
                  <span class="text-sm font-black text-white bg-purple-500/40 px-2 py-0.5 rounded-lg">{{ stats.cumpleaneros || 0 }}</span>
                </div>
                <div class="flex items-center justify-between p-3 rounded-xl bg-white/10 backdrop-blur border border-white/5 hover:bg-white/20 transition-colors cursor-pointer group">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-orange-500/20 flex items-center justify-center text-orange-300 group-hover:scale-110 transition-transform">📄</div>
                    <span class="text-xs font-bold text-slate-200">Renovaciones</span>
                  </div>
                  <span class="text-sm font-black text-white bg-orange-500/40 px-2 py-0.5 rounded-lg">{{ stats.vencimientos || 0 }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- NEW CHARTS SECTION: GENDER & AGE -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 mb-6">
          <!-- Género -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[300px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-pink-500"></span>
                 Distribución por Género
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <Doughnut v-if="!loadingEmpleados && chartGeneroData" :data="chartGeneroData" :options="doughnutOptions" />
              </div>
          </div>
          <!-- Edad -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[300px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-orange-500"></span>
                 Distribución por Edad
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <Pie v-if="!loadingEmpleados && chartEdadData" :data="chartEdadData" :options="doughnutOptions" />
              </div>
          </div>
        </div>

        <!-- NEW SECTION: DISTRIBUCIÓN Y PROPORCIONES (ANILLO) -->
        <h3 class="text-md font-black text-slate-800 uppercase tracking-widest mt-8 mb-4 border-b border-slate-200 pb-2">Distribución y Proporciones</h3>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-6 mb-6">
          <!-- Distribución de la Plantilla -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[300px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-blue-500"></span>
                 Distribución de la Plantilla
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <Doughnut v-if="!loadingDepts && chartPlantillaProporcionData" :data="chartPlantillaProporcionData" :options="doughnutOptionsPercent" />
              </div>
          </div>
          <!-- Estado de Contratos -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[300px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-orange-500"></span>
                 Estado de Contratos
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <Doughnut v-if="chartContratosData" :data="chartContratosData" :options="doughnutOptionsPercent" />
              </div>
          </div>
          <!-- Tipos de Faltas -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[300px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-rose-500"></span>
                 Tipos de Faltas (Mes)
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <Doughnut v-if="chartFaltasData" :data="chartFaltasData" :options="doughnutOptionsPercent" />
              </div>
          </div>
        </div>

        <!-- NEW SECTION: TENDENCIAS EN EL TIEMPO (LÍNEAS) -->
        <h3 class="text-md font-black text-slate-800 uppercase tracking-widest mt-8 mb-4 border-b border-slate-200 pb-2">Tendencias en el Tiempo</h3>
        
        <!-- TENDENCIAS DE CONTRATACIÓN (LINE CHART) -->
        <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col mb-6 min-h-[320px]">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest flex items-center gap-2">
               <span class="w-2 h-2 rounded-full bg-indigo-500"></span>
               Tendencias de Contratación (Anual)
            </h2>
          </div>
          <div class="flex-1 relative w-full h-full flex justify-center items-center">
            <Line v-if="!loadingEmpleados && chartTendenciasData" :data="chartTendenciasData" :options="lineOptions" />
            <span v-else class="text-slate-400 italic text-xs">Cargando tendencias...</span>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 mb-6">
          <!-- Tendencia de Ausentismo Histórico -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col min-h-[320px]">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-rose-500"></span>
                 Tendencia de Ausentismo Histórico
              </h2>
            </div>
            <div class="flex-1 relative w-full h-full flex justify-center items-center">
              <Line v-if="chartTendenciaAusentismoData" :data="chartTendenciaAusentismoData" :options="lineOptions" />
              <span v-else class="text-slate-400 italic text-xs">Cargando tendencia...</span>
            </div>
          </div>
          
          <!-- Evolución de Tickets -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col min-h-[320px]">
            <div class="flex justify-between items-center mb-4">
              <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-amber-500"></span>
                 Evolución de Tickets (30 Días)
              </h2>
            </div>
            <div class="flex-1 relative w-full h-full flex justify-center items-center">
              <Line v-if="chartTendenciaTicketsData" :data="chartTendenciaTicketsData" :options="lineOptions" />
              <span v-else class="text-slate-400 italic text-xs">Cargando evolución...</span>
            </div>
          </div>
        </div>
      </div>

      <!-- TAB: EMPLEADOS -->
      <div v-if="activeTab === 'empleados'" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter">Directorio Analítico</h2>
          <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto">
            <input v-model="empleadosFiltro" type="text" placeholder="Buscar por nombre o código..." class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 w-full md:w-64 focus:border-blue-500 outline-none">
            <select v-model="empleadosEstado" class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 focus:border-blue-500 outline-none">
              <option value="todos">Todos los Estados</option>
              <option value="1">Activos</option>
              <option value="0">Inactivos</option>
            </select>
            <button @click="exportarCSV(empleadosFiltrados, 'Reporte_Empleados')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
        </div>

        <div v-if="loadingEmpleados" class="text-center py-10 text-slate-400 italic">Cargando datos de empleados...</div>
        <div v-else class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Código</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Empleado</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Identidad</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Puesto</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Departamento</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="emp in empleadosFiltrados" :key="emp.id" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                <td class="p-3 text-xs font-bold text-slate-700">{{ emp.codigo_empleado || 'N/A' }}</td>
                <td class="p-3 text-sm font-bold text-slate-900">{{ emp.nombre }} {{ emp.apellido }}</td>
                <td class="p-3 text-xs text-slate-600">{{ emp.numero_identidad || 'N/A' }}</td>
                <td class="p-3 text-xs text-slate-600">{{ emp.puesto || 'N/A' }}</td>
                <td class="p-3 text-xs font-medium text-slate-800">{{ getNombreDepartamento(emp.departamento_id) }}</td>
                <td class="p-3 text-center">
                  <span :class="emp.estado == 1 ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'" class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">
                    {{ emp.estado == 1 ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
              </tr>
              <tr v-if="empleadosFiltrados.length === 0">
                <td colspan="6" class="p-6 text-center text-slate-400 italic">No se encontraron empleados con los filtros aplicados.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- TAB: TICKETS -->
      <div v-if="activeTab === 'tickets'" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter">Análisis de Soporte</h2>
          <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto">
            <select v-model="ticketsFiltroEstado" class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 focus:border-blue-500 outline-none">
              <option value="todos">Todos los Estados</option>
              <option value="Pendiente">Pendientes</option>
              <option value="En Progreso">En Progreso</option>
              <option value="Resuelto">Resueltos</option>
              <option value="Cerrado">Cerrados</option>
            </select>
            <select v-model="ticketsFiltroPrioridad" class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 focus:border-blue-500 outline-none">
              <option value="todos">Todas las Prioridades</option>
              <option value="Baja">Baja</option>
              <option value="Media">Media</option>
              <option value="Alta">Alta</option>
              <option value="Urgente">Urgente</option>
            </select>
            <button @click="exportarCSV(ticketsFiltrados, 'Reporte_Tickets')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
        </div>

        <!-- KPIs de Tickets Internos -->
        <div class="grid grid-cols-3 gap-4 mb-6">
          <div class="bg-slate-50 p-4 rounded-xl border border-slate-100 text-center">
            <p class="text-[10px] font-black text-slate-500 uppercase tracking-widest">Total Tickets</p>
            <p class="text-2xl font-black text-slate-800 mt-1">{{ ticketsFiltrados.length }}</p>
          </div>
          <div class="bg-yellow-50 p-4 rounded-xl border border-yellow-100 text-center">
            <p class="text-[10px] font-black text-yellow-700 uppercase tracking-widest">Pendientes / Progreso</p>
            <p class="text-2xl font-black text-yellow-600 mt-1">{{ ticketsFiltrados.filter(t => t.estado === 'Pendiente' || t.estado === 'En Progreso').length }}</p>
          </div>
          <div class="bg-emerald-50 p-4 rounded-xl border border-emerald-100 text-center">
            <p class="text-[10px] font-black text-emerald-700 uppercase tracking-widest">Resueltos / Cerrados</p>
            <p class="text-2xl font-black text-emerald-600 mt-1">{{ ticketsFiltrados.filter(t => t.estado === 'Resuelto' || t.estado === 'Cerrado').length }}</p>
          </div>
        </div>

        <div v-if="loadingTickets" class="text-center py-10 text-slate-400 italic">Cargando datos de tickets...</div>
        <div v-else class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">ID</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Asunto</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Prioridad</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Estado</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Creado Por</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Fecha</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="ticket in ticketsFiltrados" :key="ticket.id" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                <td class="p-3 text-xs font-bold text-slate-500">#{{ ticket.id }}</td>
                <td class="p-3 text-sm font-bold text-slate-800">{{ ticket.asunto }}</td>
                <td class="p-3 text-xs">
                  <span :class="getBadgeClass(ticket.prioridad)" class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">
                    {{ ticket.prioridad }}
                  </span>
                </td>
                <td class="p-3 text-xs">
                  <span :class="getBadgeClass(ticket.estado)" class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">
                    {{ ticket.estado }}
                  </span>
                </td>
                <td class="p-3 text-xs text-slate-600">{{ ticket.creadoPorNombre || 'Desconocido' }}</td>
                <td class="p-3 text-xs text-slate-500">{{ new Date(ticket.fecha_creacion).toLocaleDateString() }}</td>
              </tr>
              <tr v-if="ticketsFiltrados.length === 0">
                <td colspan="6" class="p-6 text-center text-slate-400 italic">No se encontraron tickets con los filtros aplicados.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- TAB: PROYECCIONES VACACIONES -->
      <div v-if="activeTab === 'proyecciones'" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter">Proyecciones de Vacaciones</h2>
          <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto">
            <button @click="exportarCSV(proyeccionesVacaciones, 'Proyecciones_Vacaciones')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
        </div>

        <div v-if="loadingProyecciones" class="text-center py-10 text-slate-400 italic">Cargando proyecciones de vacaciones...</div>
        <div v-else class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Empleado</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Departamento</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Tipo</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Fecha Inicio</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Fecha Regreso</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Días</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="vac in proyeccionesVacaciones" :key="vac.id" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                <td class="p-3 text-sm font-bold text-slate-900">
                   {{ vac.nombre }} {{ vac.apellido }}<br/>
                   <span class="text-xs text-slate-500 font-normal">{{ vac.codigo_empleado || 'N/A' }}</span>
                </td>
                <td class="p-3 text-xs font-medium text-slate-800">{{ vac.departamento || 'N/A' }}</td>
                <td class="p-3 text-xs">
                  <span class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest bg-blue-100 text-blue-700">
                    {{ vac.tipoSolicitud }}
                  </span>
                </td>
                <td class="p-3 text-xs text-slate-600 font-bold">{{ new Date(vac.fechaInicio).toLocaleDateString('es-HN', {timeZone: 'UTC'}) }}</td>
                <td class="p-3 text-xs text-slate-600 font-bold">{{ new Date(vac.fechaRegreso).toLocaleDateString('es-HN', {timeZone: 'UTC'}) }}</td>
                <td class="p-3 text-xs text-slate-600">{{ vac.diasVacaciones }}</td>
              </tr>
              <tr v-if="proyeccionesVacaciones.length === 0">
                <td colspan="6" class="p-6 text-center text-slate-400 italic">No hay vacaciones próximas programadas.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- TAB: ASISTENCIA Y TIEMPOS -->
      <div v-if="activeTab === 'asistencia'" class="space-y-6">
        <!-- Índice de Ausentismo -->
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
          <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
            <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter flex items-center gap-2">
              <span class="text-rose-500">⚠️</span> Índice de Ausentismo (Mes Actual)
            </h2>
            <button @click="exportarCSV(ausentismoDatos, 'Indice_Ausentismo')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
          <div v-if="loadingAusentismo" class="text-center py-10 text-slate-400 italic">Cargando ausentismo...</div>
          <div v-else class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-slate-50 border-b border-slate-200">
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Departamento</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Total Empleados</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Faltas (Mes)</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Días Laborables Esperados</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-right">Índice Ausentismo (%)</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="d in ausentismoDatos" :key="d.departamento" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                  <td class="p-3 text-sm font-bold text-slate-800">{{ d.departamento || 'N/A' }}</td>
                  <td class="p-3 text-sm text-slate-600 text-center">{{ d.total_empleados }}</td>
                  <td class="p-3 text-sm font-black text-rose-600 text-center">{{ d.total_faltas }}</td>
                  <td class="p-3 text-sm text-slate-600 text-center">{{ d.dias_laborables_totales }}</td>
                  <td class="p-3 text-sm font-black text-right" :class="d.indice_ausentismo > 5 ? 'text-rose-600' : 'text-emerald-600'">
                    {{ d.indice_ausentismo }}%
                  </td>
                </tr>
                <tr v-if="ausentismoDatos.length === 0">
                  <td colspan="5" class="p-6 text-center text-slate-400 italic">No hay datos de ausentismo.</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Saldos de Vacaciones -->
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
          <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
            <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter flex items-center gap-2">
              <span class="text-blue-500">🏖️</span> Saldos de Vacaciones
            </h2>
            <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto">
              <input v-model="saldosFiltro" type="text" placeholder="Buscar empleado..." class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 w-full md:w-64 focus:border-blue-500 outline-none">
              <button @click="exportarCSV(saldosFiltrados, 'Saldos_Vacaciones')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
                <span>📊</span> CSV
              </button>
            </div>
          </div>
          <div v-if="loadingSaldos" class="text-center py-10 text-slate-400 italic">Cargando saldos...</div>
          <div v-else class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
              <thead>
                <tr class="bg-slate-50 border-b border-slate-200">
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Empleado</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Departamento</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Acumulados</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Gozados</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Pagados</th>
                  <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Saldo Pendiente</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="s in saldosFiltrados" :key="s.empleado_id" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                  <td class="p-3 text-sm font-bold text-slate-900">
                    {{ s.nombre }}<br>
                    <span class="text-xs text-slate-500 font-normal">{{ s.codigo || 'N/A' }}</span>
                  </td>
                  <td class="p-3 text-xs font-medium text-slate-800">{{ s.departamento || 'N/A' }}</td>
                  <td class="p-3 text-sm text-slate-700 font-bold text-center">{{ s.dias_acumulados }}</td>
                  <td class="p-3 text-sm text-blue-600 font-bold text-center">{{ s.dias_gozados }}</td>
                  <td class="p-3 text-sm text-emerald-600 font-bold text-center">{{ s.dias_pagados }}</td>
                  <td class="p-3 text-sm font-black text-center" :class="s.saldo_pendiente > 0 ? 'text-orange-500' : 'text-slate-500'">
                    {{ s.saldo_pendiente }}
                  </td>
                </tr>
                <tr v-if="saldosFiltrados.length === 0">
                  <td colspan="6" class="p-6 text-center text-slate-400 italic">No hay datos de saldos de vacaciones con los filtros aplicados.</td>
                </tr>
              </tbody>
            </table>
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
                <img :src="`http://localhost:3007${fotoUsuario}`" class="w-full h-full object-cover" />
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
import { ref, onMounted, onUnmounted, computed } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import { Chart as ChartJS, ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title, PointElement, LineElement } from 'chart.js'
import { Doughnut, Bar, Pie, Line } from 'vue-chartjs'

ChartJS.register(ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, PointElement, LineElement)

const router = useRouter()
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const menuUsuario = ref([])
const usuarioActual = ref('')
const mobileMenuOpen = ref(false)
const activeTab = ref('dashboard')
let pollingInterval = null;

// Lógica Modal Perfil
const dropdownPerfilAbierto = ref(false)
const modalAbiertoPerfil = ref(false)
const loadingPassword = ref(false)
const formPassword = ref({ actual: '', nueva: '', confirmar: '' })
const fileInputPerfil = ref(null)
const fotoUsuario = ref(null)

const triggerFileInputPerfil = () => { fileInputPerfil.value.click() }

const uploadFotoPerfil = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const formData = new FormData()
  formData.append('foto', file)
  try {
    const id = localStorage.getItem('usuarioID')
    const res = await axios.post(`http://localhost:3007/api/auth/${id}/foto`, formData, { headers: { 'Content-Type': 'multipart/form-data' } })
    fotoUsuario.value = res.data.fotoUrl
    localStorage.setItem('usuarioFoto', res.data.fotoUrl)
    alert('✅ ' + res.data.mensaje)
  } catch (err) {
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
    const res = await axios.put(`http://localhost:3007/api/auth/${userId}/password`, { actual: formPassword.value.actual, nueva: formPassword.value.nueva })
    alert('✅ ' + res.data.mensaje)
    cerrarModalPerfil()
  } catch (err) {
    alert('❌ ' + (err.response?.data?.error || 'Error al cambiar contraseña'))
  } finally {
    loadingPassword.value = false
  }
}

// --- DATOS GLOBALES ---
const departamentos = ref([])
const cargarDepartamentos = async () => {
  try {
    const res = await axios.get('http://localhost:3007/api/departamentos/lista')
    departamentos.value = res.data
  } catch (error) {
    console.error('Error cargando departamentos:', error)
  }
}

const getNombreDepartamento = (id) => {
  const depto = departamentos.value.find(d => d.id === id)
  return depto ? depto.nombre : 'Desconocido'
}

// --- ESTADÍSTICAS DASHBOARD ---
const stats = ref({})
const loadingStats = ref(true)
const deptStats = ref([])
const loadingDepts = ref(true)

const doughnutOptions = { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'right', labels: { boxWidth: 12, font: { size: 10, family: "'Inter', sans-serif" } } } }, cutout: '60%' }
const doughnutOptionsPercent = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: 'right', labels: { boxWidth: 12, font: { size: 10, family: "'Inter', sans-serif" } } },
    tooltip: {
      callbacks: {
        label: (context) => {
          let label = context.label || '';
          if (label) {
            label += ': ';
          }
          if (context.parsed !== null) {
            let total = context.dataset.data.reduce((a, b) => Number(a) + Number(b), 0);
            let val = Number(context.parsed);
            let perc = total > 0 ? ((val / total) * 100).toFixed(2) : 0;
            label += val + ' (' + perc + '%)';
          }
          return label;
        }
      }
    }
  },
  cutout: '60%'
}
const barOptions = { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false }, tooltip: { callbacks: { label: (context) => ` ${context.raw} Empleados` } } }, scales: { y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 10 } } }, x: { ticks: { font: { size: 10 } } } } }

const chartEstadoData = computed(() => ({
  labels: ['Activos', 'Inactivos'],
  datasets: [{ backgroundColor: ['#10b981', '#ef4444'], borderWidth: 0, data: [stats.value.activos || 0, stats.value.inactivos || 0] }]
}))

const chartPlantillaProporcionData = computed(() => {
  return {
    labels: deptStats.value.map(d => d.departamento),
    datasets: [{ 
      backgroundColor: ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6', '#6366f1', '#f43f5e', '#84cc16'], 
      borderWidth: 0, 
      data: deptStats.value.map(d => d.cantidad) 
    }]
  }
})

const estadoContratos = ref({ activos: 0, por_vencer: 0, vencidos: 0 })
const chartContratosData = computed(() => ({
  labels: ['Activos', 'Por Vencer (30d)', 'Vencidos'],
  datasets: [{ backgroundColor: ['#10b981', '#f59e0b', '#ef4444'], borderWidth: 0, data: [estadoContratos.value.activos || 0, estadoContratos.value.por_vencer || 0, estadoContratos.value.vencidos || 0] }]
}))

const tiposFaltas = ref({ justificadas: 0, injustificadas: 0 })
const chartFaltasData = computed(() => ({
  labels: ['Justificadas (Médicas/Permisos)', 'Injustificadas'],
  datasets: [{ backgroundColor: ['#10b981', '#ef4444'], borderWidth: 0, data: [tiposFaltas.value.justificadas || 0, tiposFaltas.value.injustificadas || 0] }]
}))

const chartGeneroData = computed(() => {
  const data = empleadosFiltrados.value;
  let masculino = 0;
  let femenino = 0;
  let otro = 0;
  
  data.forEach(e => {
    if (e.genero === 'Masculino') masculino++;
    else if (e.genero === 'Femenino') femenino++;
    else otro++;
  });
  
  return {
    labels: ['Masculino', 'Femenino', 'No especificado'],
    datasets: [{
      backgroundColor: ['#3b82f6', '#ec4899', '#94a3b8'],
      borderWidth: 0,
      data: [masculino, femenino, otro]
    }]
  };
})

const chartEdadData = computed(() => {
  const data = empleadosFiltrados.value;
  let r18_25 = 0;
  let r26_35 = 0;
  let r36_45 = 0;
  let r46_plus = 0;
  let desconocido = 0;
  
  const today = new Date();
  
  data.forEach(e => {
    if (!e.fecha_nacimiento) {
      desconocido++;
      return;
    }
    const birthDate = new Date(e.fecha_nacimiento);
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    if (age >= 18 && age <= 25) r18_25++;
    else if (age >= 26 && age <= 35) r26_35++;
    else if (age >= 36 && age <= 45) r36_45++;
    else if (age > 45) r46_plus++;
    else desconocido++;
  });
  
  return {
    labels: ['18-25', '26-35', '36-45', '46+', 'Desconocido'],
    datasets: [{
      backgroundColor: ['#f59e0b', '#10b981', '#6366f1', '#8b5cf6', '#cbd5e1'],
      borderWidth: 0,
      data: [r18_25, r26_35, r36_45, r46_plus, desconocido]
    }]
  };
})

const chartDeptData = computed(() => {
  return {
    labels: deptStats.value.map(d => d.departamento),
    datasets: [{ label: 'Empleados', backgroundColor: '#3b82f6', borderRadius: 4, data: deptStats.value.map(d => d.cantidad) }]
  }
})

const lineOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        usePointStyle: true,
        boxWidth: 8,
        font: { size: 10, family: "'Inter', sans-serif" }
      }
    },
    tooltip: {
      mode: 'index',
      intersect: false,
    }
  },
  scales: {
    y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 10 } } },
    x: { ticks: { font: { size: 10 } } }
  },
  interaction: {
    mode: 'nearest',
    axis: 'x',
    intersect: false
  }
}

const chartTendenciasData = computed(() => {
  const data = empleadosFiltrados.value;
  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  
  const activosPorMes = Array(12).fill(0);
  const finalizadosPorMes = Array(12).fill(0);
  const renovadosPorMes = Array(12).fill(0);
  
  data.forEach(e => {
    if (e.fecha_inicio) {
      const date = new Date(e.fecha_inicio);
      const month = date.getMonth();
      
      if (e.estado == 1) {
        activosPorMes[month]++;
        if (new Date().getFullYear() - date.getFullYear() > 0) {
           renovadosPorMes[month]++;
        }
      } else {
        finalizadosPorMes[month]++;
      }
    }
  });

  return {
    labels: meses,
    datasets: [
      {
        label: 'Activos',
        borderColor: '#10b981',
        backgroundColor: '#10b981',
        data: activosPorMes,
        tension: 0.4,
        fill: false
      },
      {
        label: 'Finalizados',
        borderColor: '#ef4444',
        backgroundColor: '#ef4444',
        data: finalizadosPorMes,
        tension: 0.4,
        fill: false
      },
      {
        label: 'Renovados',
        borderColor: '#3b82f6',
        backgroundColor: '#3b82f6',
        data: renovadosPorMes,
        tension: 0.4,
        fill: false
      }
    ]
  };
})

const tendenciaAusentismo = ref([])
const chartTendenciaAusentismoData = computed(() => {
  if (tendenciaAusentismo.value.length === 0) return null;
  const meses = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
  const data = Array(12).fill(0);
  tendenciaAusentismo.value.forEach(row => {
    if (row.mes >= 1 && row.mes <= 12) {
      data[row.mes - 1] = row.cantidad;
    }
  });

  return {
    labels: meses,
    datasets: [
      {
        label: 'Faltas Registradas',
        borderColor: '#f43f5e',
        backgroundColor: '#f43f5e',
        data: data,
        tension: 0.4,
        fill: true,
        backgroundColor: 'rgba(244, 63, 94, 0.1)'
      }
    ]
  };
})

const tendenciaTickets = ref([])
const chartTendenciaTicketsData = computed(() => {
  if (tendenciaTickets.value.length === 0) return null;
  const labels = tendenciaTickets.value.map(row => {
    const d = new Date(row.fecha);
    return d.toLocaleDateString('es-HN', { day: '2-digit', month: 'short' });
  });
  const creados = tendenciaTickets.value.map(row => row.creados);
  const resueltos = tendenciaTickets.value.map(row => row.resueltos);

  return {
    labels: labels,
    datasets: [
      {
        label: 'Tickets Creados',
        borderColor: '#f59e0b',
        backgroundColor: '#f59e0b',
        data: creados,
        tension: 0.4,
        fill: false
      },
      {
        label: 'Tickets Resueltos',
        borderColor: '#10b981',
        backgroundColor: '#10b981',
        data: resueltos,
        tension: 0.4,
        fill: false
      }
    ]
  };
})

const cargarStats = async (isPolling = false) => {
  try {
    if (!isPolling) loadingStats.value = true
    const res = await axios.get('http://localhost:3007/api/stats/resumen')
    stats.value = res.data
  } catch (error) { console.error('Error cargando estadísticas', error) } 
  finally { loadingStats.value = false }
}

const cargarDepartamentosStats = async (isPolling = false) => {
  try {
    if (!isPolling) loadingDepts.value = true
    const res = await axios.get('http://localhost:3007/api/stats/empleados-por-departamento')
    deptStats.value = res.data
  } catch (error) { console.error('Error cargando stats de departamentos', error) } 
  finally { loadingDepts.value = false }
}

const cargarEstadoContratos = async (isPolling = false) => {
  try {
    const res = await axios.get('http://localhost:3007/api/stats/contratos-estado')
    estadoContratos.value = res.data
  } catch (e) {
    console.error('Error cargando estado de contratos:', e)
  }
}

const cargarTiposFaltas = async (isPolling = false) => {
  try {
    const res = await axios.get('http://localhost:3007/api/stats/tipos-faltas')
    tiposFaltas.value = res.data
  } catch (e) {
    console.error('Error cargando tipos de faltas:', e)
  }
}

const cargarTendenciaAusentismo = async (isPolling = false) => {
  try {
    const res = await axios.get('http://localhost:3007/api/stats/tendencia-ausentismo')
    tendenciaAusentismo.value = res.data
  } catch (e) {
    console.error('Error cargando tendencia ausentismo:', e)
  }
}

const cargarTendenciaTickets = async (isPolling = false) => {
  try {
    const res = await axios.get('http://localhost:3007/api/stats/tendencia-tickets')
    tendenciaTickets.value = res.data
  } catch (e) {
    console.error('Error cargando tendencia tickets:', e)
  }
}

// --- EMPLEADOS REPORTE ---
const empleados = ref([])
const loadingEmpleados = ref(false)
const empleadosFiltro = ref('')
const empleadosEstado = ref('todos')

const cargarEmpleados = async (isPolling = false) => {
  try {
    if (!isPolling) loadingEmpleados.value = true
    const res = await axios.get('http://localhost:3007/api/empleados/lista')
    empleados.value = res.data
  } catch (e) {
    console.error('Error cargando empleados:', e)
  } finally {
    loadingEmpleados.value = false
  }
}

const empleadosFiltrados = computed(() => {
  let list = empleados.value
  if (empleadosEstado.value !== 'todos') {
    list = list.filter(e => e.estado == empleadosEstado.value)
  }
  if (empleadosFiltro.value.trim() !== '') {
    const q = empleadosFiltro.value.toLowerCase()
    list = list.filter(e => 
      (e.nombre && e.nombre.toLowerCase().includes(q)) || 
      (e.apellido && e.apellido.toLowerCase().includes(q)) ||
      (e.codigo_empleado && e.codigo_empleado.toLowerCase().includes(q))
    )
  }
  return list
})

// --- TICKETS REPORTE ---
const tickets = ref([])
const loadingTickets = ref(false)
const ticketsFiltroEstado = ref('todos')
const ticketsFiltroPrioridad = ref('todos')

const cargarTickets = async (isPolling = false) => {
  try {
    if (!isPolling) loadingTickets.value = true
    const res = await axios.get('http://localhost:3007/api/tickets/lista')
    tickets.value = res.data
  } catch (e) {
    console.error('Error cargando tickets:', e)
  } finally {
    loadingTickets.value = false
  }
}

const ticketsFiltrados = computed(() => {
  let list = tickets.value
  if (ticketsFiltroEstado.value !== 'todos') {
    list = list.filter(t => t.estado === ticketsFiltroEstado.value)
  }
  if (ticketsFiltroPrioridad.value !== 'todos') {
    list = list.filter(t => t.prioridad === ticketsFiltroPrioridad.value)
  }
  return list
})

// --- PROYECCIONES VACACIONES ---
const proyeccionesVacaciones = ref([])
const loadingProyecciones = ref(false)

const cargarProyecciones = async (isPolling = false) => {
  try {
    if (!isPolling) loadingProyecciones.value = true
    const res = await axios.get('http://localhost:3007/api/vacaciones/proximas')
    proyeccionesVacaciones.value = res.data
  } catch (e) {
    console.error('Error cargando proyecciones:', e)
  } finally {
    loadingProyecciones.value = false
  }
}

// --- ASISTENCIA Y TIEMPOS ---
const ausentismoDatos = ref([])
const loadingAusentismo = ref(false)
const saldosDatos = ref([])
const loadingSaldos = ref(false)
const saldosFiltro = ref('')

const cargarAusentismo = async (isPolling = false) => {
  try {
    if (!isPolling) loadingAusentismo.value = true
    const res = await axios.get('http://localhost:3007/api/stats/ausentismo')
    ausentismoDatos.value = res.data
  } catch (e) {
    console.error('Error cargando ausentismo:', e)
  } finally {
    loadingAusentismo.value = false
  }
}

const cargarSaldos = async (isPolling = false) => {
  try {
    if (!isPolling) loadingSaldos.value = true
    const res = await axios.get('http://localhost:3007/api/stats/saldos-vacaciones')
    saldosDatos.value = res.data
  } catch (e) {
    console.error('Error cargando saldos de vacaciones:', e)
  } finally {
    loadingSaldos.value = false
  }
}

const saldosFiltrados = computed(() => {
  if (!saldosFiltro.value.trim()) return saldosDatos.value
  const q = saldosFiltro.value.toLowerCase()
  return saldosDatos.value.filter(s => 
    s.nombre.toLowerCase().includes(q) || 
    (s.codigo && s.codigo.toLowerCase().includes(q))
  )
})

const getBadgeClass = (val) => {
  const map = {
    'Baja': 'bg-slate-100 text-slate-600',
    'Media': 'bg-blue-100 text-blue-700',
    'Alta': 'bg-orange-100 text-orange-700',
    'Urgente': 'bg-red-100 text-red-700',
    'Pendiente': 'bg-yellow-100 text-yellow-700',
    'En Progreso': 'bg-blue-100 text-blue-700',
    'Resuelto': 'bg-emerald-100 text-emerald-700',
    'Cerrado': 'bg-slate-200 text-slate-700'
  }
  return map[val] || 'bg-gray-100 text-gray-700'
}

// --- UTILIDADES ---
const exportarCSV = (dataList, filename) => {
  if (!dataList || dataList.length === 0) {
    alert("No hay datos para exportar")
    return
  }
  
  // Extraer las llaves para el header del CSV de la primera fila
  const keys = Object.keys(dataList[0]).filter(k => k !== 'foto' && k !== 'archivo' && !k.includes('password'))
  
  let csvContent = keys.join(',') + '\n'
  
  dataList.forEach(row => {
    let values = keys.map(k => {
      let val = row[k] === null || row[k] === undefined ? '' : row[k]
      // Si es un ID de departamento en empleados, intentamos resolver el nombre
      if (k === 'departamento_id') val = getNombreDepartamento(val)
      if (k === 'estado' && typeof val === 'number') val = val === 1 ? 'Activo' : 'Inactivo'
      
      // Sanitizar el valor por si tiene comas
      val = String(val).replace(/"/g, '""')
      if (val.search(/("|,|\n)/g) >= 0) {
        val = `"${val}"`
      }
      return val
    })
    csvContent += values.join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.setAttribute('href', url)
  link.setAttribute('download', `${filename}_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

const imprimirReporte = () => {
  window.print();
}

const logout = () => {
  localStorage.clear()
  router.push('/login')
}

onMounted(async () => {
  rolID.value = localStorage.getItem('usuarioRol') || 2
  usuarioActual.value = localStorage.getItem('usuarioNombre') || 'Usuario Sistema'
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null

  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }

  try {
    const m = await axios.get(`http://localhost:3007/api/menu/${rolID.value}`)
    menuUsuario.value = m.data
  } catch (e) {
    console.error('Error cargando menú', e)
  }

  // Cargar todos los datos iniciales
  await cargarDepartamentos()
  cargarStats(false)
  cargarDepartamentosStats(false)
  cargarEstadoContratos(false)
  cargarTiposFaltas(false)
  cargarTendenciaAusentismo(false)
  cargarTendenciaTickets(false)
  cargarEmpleados(false)
  cargarTickets(false)
  cargarProyecciones(false)
  cargarAusentismo(false)
  cargarSaldos(false)

  // Iniciar Polling en tiempo real (cada 15 segundos)
  pollingInterval = setInterval(() => {
    cargarStats(true)
    cargarDepartamentosStats(true)
    cargarEstadoContratos(true)
    cargarTiposFaltas(true)
    cargarTendenciaAusentismo(true)
    cargarTendenciaTickets(true)
    cargarEmpleados(true)
    cargarTickets(true)
    cargarProyecciones(true)
    cargarAusentismo(true)
    cargarSaldos(true)
  }, 15000)
})

onUnmounted(() => {
  if (pollingInterval) clearInterval(pollingInterval)
})
</script>

<style>
@media print {
  .no-print {
    display: none !important;
  }
  .printable-area {
    margin: 0 !important;
    padding: 0 !important;
    width: 100% !important;
  }
  aside, button {
    display: none !important;
  }
  body {
    background: white;
  }
}
</style>