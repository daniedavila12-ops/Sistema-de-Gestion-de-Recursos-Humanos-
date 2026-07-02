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
        <button @click="activeTab = 'incidencias'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'incidencias' ? 'border-rose-500 text-rose-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          🚨 Incidencias Laborales
        </button>
        <button @click="activeTab = 'tiempos'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'tiempos' ? 'border-emerald-500 text-emerald-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          ⏳ Control de Tiempos
        </button>
        <button @click="activeTab = 'legales'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'legales' ? 'border-indigo-500 text-indigo-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          ⚖️ Docs & Legales
        </button>
        <button @click="activeTab = 'despidos'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'despidos' ? 'border-red-500 text-red-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          🚪 Bajas y Despidos
        </button>
        <button @click="activeTab = 'tickets'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'tickets' ? 'border-amber-500 text-amber-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          🎫 Soporte & Tickets
        </button>
        <button @click="activeTab = 'wizard'" :class="['px-6 py-3 font-bold text-xs uppercase tracking-widest whitespace-nowrap border-b-2 transition-colors', activeTab === 'wizard' ? 'border-purple-500 text-purple-600' : 'border-transparent text-slate-500 hover:text-slate-700 hover:border-slate-300']">
          🧙‍♂️ Generador Asistido
        </button>
      </div>

      <!-- TAB: DASHBOARD -->
      <div v-if="activeTab === 'dashboard'" class="space-y-6 animate-in fade-in duration-300">
        <!-- HEADER DASHBOARD -->
        <div class="flex justify-between items-center bg-white p-4 rounded-2xl shadow-sm border border-slate-200">
           <div>
             <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter">Resumen Ejecutivo</h2>
             <p class="text-xs text-slate-500 font-medium">Estadísticas y métricas generales de la plataforma</p>
           </div>
           <button @click="generarPDFDashboard" class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2 whitespace-nowrap group">
              <span class="group-hover:scale-110 transition-transform">📄</span> Crear PDF Dashboard
           </button>
        </div>

        <!-- KPIs Principales e Integrados -->
        <div v-if="loadingStats" class="bg-white rounded-2xl shadow-sm border border-slate-200 p-10 text-center text-slate-400 text-sm italic flex flex-col items-center gap-3">
          <div class="w-6 h-6 border-2 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          Cargando indicadores en tiempo real...
        </div>
        <div v-else class="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
           <!-- Empleados -->
          <div @click="activeTab = 'empleados'" class="bg-gradient-to-br from-blue-500 to-blue-700 p-5 rounded-2xl shadow-lg shadow-blue-500/20 text-white relative overflow-hidden group hover:-translate-y-1 transition-transform cursor-pointer active:scale-95">
            <div class="absolute -right-4 -top-4 text-white/20 text-7xl group-hover:scale-110 transition-transform">👥</div>
            <p class="text-[10px] font-black uppercase tracking-widest text-blue-100 mb-1 relative z-10">Total Empleados</p>
            <p class="text-4xl font-black relative z-10">{{ stats.total || 0 }}</p>
            <div class="mt-2 text-[10px] font-medium text-blue-100 relative z-10 flex justify-between">
               <span>Activos: <strong class="text-white">{{ stats.activos || 0 }}</strong></span>
               <span>Inactivos: <strong class="text-white">{{ stats.inactivos || 0 }}</strong></span>
            </div>
          </div>
          
          <!-- Tickets Ptes. -->
          <div @click="activeTab = 'tickets'" class="bg-gradient-to-br from-amber-400 to-orange-500 p-5 rounded-2xl shadow-lg shadow-orange-500/20 text-white relative overflow-hidden group hover:-translate-y-1 transition-transform cursor-pointer active:scale-95">
            <div class="absolute -right-4 -top-4 text-white/20 text-7xl group-hover:scale-110 transition-transform">🎫</div>
            <p class="text-[10px] font-black uppercase tracking-widest text-orange-100 mb-1 relative z-10">Tickets Ptes.</p>
            <p class="text-4xl font-black relative z-10">{{ stats.tickets || 0 }}</p>
            <div class="mt-2 text-[10px] font-medium text-orange-100 relative z-10">Soporte IT Pendiente</div>
          </div>

          <!-- De Vacaciones -->
          <div @click="activeTab = 'proyecciones'" class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow group relative overflow-hidden cursor-pointer active:scale-95">
            <div class="absolute top-0 right-0 w-16 h-16 bg-emerald-500/5 rounded-bl-full -z-10 group-hover:scale-150 transition-transform"></div>
            <div class="flex items-start justify-between">
              <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-tight">De Vacaciones<br>(Actual)</p>
              <span class="text-2xl opacity-80 group-hover:scale-110 transition-transform">🏖️</span>
            </div>
            <p class="text-3xl font-black text-emerald-600 mt-2">{{ stats.de_vacaciones || 0 }}</p>
          </div>

          <!-- Faltas Mes -->
          <div @click="activeTab = 'asistencia'" class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow group relative overflow-hidden cursor-pointer active:scale-95">
            <div class="absolute top-0 right-0 w-16 h-16 bg-rose-500/5 rounded-bl-full -z-10 group-hover:scale-150 transition-transform"></div>
            <div class="flex items-start justify-between">
              <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-tight">Faltas<br>(Este Mes)</p>
              <span class="text-2xl opacity-80 group-hover:scale-110 transition-transform">⚠️</span>
            </div>
            <p class="text-3xl font-black text-rose-600 mt-2">{{ stats.faltas_mes || 0 }}</p>
          </div>

          <!-- Documentos Legales -->
          <div @click="router.push('/documentos-legales')" class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow group relative overflow-hidden cursor-pointer active:scale-95">
            <div class="absolute top-0 right-0 w-16 h-16 bg-indigo-500/5 rounded-bl-full -z-10 group-hover:scale-150 transition-transform"></div>
            <div class="flex items-start justify-between">
              <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest leading-tight">Docs.<br>Legales</p>
              <span class="text-2xl opacity-80 group-hover:scale-110 transition-transform">⚖️</span>
            </div>
            <p class="text-3xl font-black text-indigo-600 mt-2">{{ stats.doc_legales || 0 }}</p>
          </div>
          
          <!-- Vencimientos -->
          <div @click="activeTab = 'empleados'" class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between hover:shadow-md transition-shadow group relative overflow-hidden cursor-pointer active:scale-95">
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
                <div @click="activeTab = 'empleados'; empleadosVista = 'cumpleanos'" class="flex items-center justify-between p-3 rounded-xl bg-white/10 backdrop-blur border border-white/5 hover:bg-white/20 transition-colors cursor-pointer group">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-purple-500/20 flex items-center justify-center text-purple-300 group-hover:scale-110 transition-transform">🎂</div>
                    <span class="text-xs font-bold text-slate-200">Cumpleaños (Mes)</span>
                  </div>
                  <span class="text-sm font-black text-white bg-purple-500/40 px-2 py-0.5 rounded-lg">{{ stats.cumpleaneros || 0 }}</span>
                </div>
                <div @click="activeTab = 'empleados'; empleadosVista = 'renovaciones'" class="flex items-center justify-between p-3 rounded-xl bg-white/10 backdrop-blur border border-white/5 hover:bg-white/20 transition-colors cursor-pointer group">
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
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4 md:gap-6 mb-6">
          <!-- Género -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[320px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-pink-500"></span>
                 Distribución por Género
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <Doughnut v-if="!loadingEmpleados && chartGeneroData" :data="chartGeneroData" :options="doughnutOptions" />
              </div>
          </div>
          <!-- Edad -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col lg:col-span-2 h-[320px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-orange-500"></span>
                 Distribución por Edad
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <PolarArea v-if="!loadingEmpleados && chartEdadData" :data="chartEdadData" :options="polarOptions" />
              </div>
          </div>
        </div>

        <!-- NEW SECTION: CONTRATOS Y FALTAS -->
        <h3 class="text-md font-black text-slate-800 uppercase tracking-widest mt-8 mb-4 border-b border-slate-200 pb-2">Estado de Contratos y Ausentismo</h3>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 md:gap-6 mb-6">
          <!-- Estado de Contratos -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[320px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-orange-500"></span>
                 Estado de Contratos
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <Bar v-if="chartContratosData" :data="chartContratosData" :options="barOptions" />
              </div>
          </div>
          <!-- Tipos de Faltas -->
          <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col h-[320px]">
             <h2 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-2 flex items-center gap-2">
                 <span class="w-2 h-2 rounded-full bg-rose-500"></span>
                 Tipos de Faltas (Mes)
              </h2>
              <div class="flex-1 relative w-full h-full flex justify-center items-center pb-4">
                <Bar v-if="chartFaltasData" :data="chartFaltasData" :options="barOptions" />
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
            <div class="flex bg-slate-100 p-1 rounded-lg">
              <button @click="empleadosVista = 'general'" :class="['px-3 py-1.5 text-xs font-bold rounded-md transition-colors', empleadosVista === 'general' ? 'bg-white shadow-sm text-blue-600' : 'text-slate-500 hover:text-slate-700']">General</button>
              <button @click="empleadosVista = 'vacaciones'" :class="['px-3 py-1.5 text-xs font-bold rounded-md transition-colors', empleadosVista === 'vacaciones' ? 'bg-white shadow-sm text-emerald-600' : 'text-slate-500 hover:text-slate-700']">Vacaciones</button>
              <button @click="empleadosVista = 'faltas'" :class="['px-3 py-1.5 text-xs font-bold rounded-md transition-colors', empleadosVista === 'faltas' ? 'bg-white shadow-sm text-red-600' : 'text-slate-500 hover:text-slate-700']">Faltas</button>
              <button @click="empleadosVista = 'cumpleanos'" :class="['px-3 py-1.5 text-xs font-bold rounded-md transition-colors', empleadosVista === 'cumpleanos' ? 'bg-white shadow-sm text-purple-600' : 'text-slate-500 hover:text-slate-700']">Cumpleaños</button>
              <button @click="empleadosVista = 'renovaciones'" :class="['px-3 py-1.5 text-xs font-bold rounded-md transition-colors', empleadosVista === 'renovaciones' ? 'bg-white shadow-sm text-orange-600' : 'text-slate-500 hover:text-slate-700']">Renovaciones</button>
            </div>
            <input v-model="searchQuery" type="text" placeholder="Buscar por nombre o código..." class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 w-full md:w-48 focus:border-blue-500 outline-none">
            <select v-model="empleadosEstado" class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 focus:border-blue-500 outline-none">
              <option value="todos">Todos los Estados</option>
              <option value="1">Activos</option>
              <option value="0">Inactivos</option>
            </select>
            <button @click="generarPDFDirectorio" class="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📄</span> Crear PDF Directorio Analítico
            </button>
            <button @click="exportarCSV(empleadosFiltrados, 'Reporte_Empleados')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
        </div>

        <div v-if="loadingEmpleados" class="flex flex-col items-center justify-center py-16">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600 mb-4"></div>
          <span class="text-slate-500 font-medium text-sm">Cargando directorio analítico...</span>
        </div>
        <div v-else class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Código</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Empleado</th>
                <th v-if="empleadosVista === 'general'" class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Identidad</th>
                <th v-if="empleadosVista === 'general'" class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Puesto</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Departamento</th>
                <th v-if="empleadosVista === 'general'" class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Estado</th>
                
                <th v-if="empleadosVista === 'vacaciones'" class="p-3 text-[10px] font-black text-emerald-600 uppercase tracking-widest text-center">Fechas de Vacaciones</th>
                <th v-if="empleadosVista === 'faltas'" class="p-3 text-[10px] font-black text-red-600 uppercase tracking-widest text-center">Total Faltas</th>
                <th v-if="empleadosVista === 'cumpleanos'" class="p-3 text-[10px] font-black text-purple-600 uppercase tracking-widest text-center">Fecha de Nacimiento</th>
                <th v-if="empleadosVista === 'renovaciones'" class="p-3 text-[10px] font-black text-orange-600 uppercase tracking-widest text-center">Vencimiento Contrato</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="emp in empleadosFiltrados" :key="emp.id" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                <td class="p-3 text-xs font-bold text-slate-700">{{ emp.codigo_empleado || 'N/A' }}</td>
                <td class="p-3 text-sm font-bold text-slate-900">{{ emp.nombre }} {{ emp.apellido }}</td>
                <td v-if="empleadosVista === 'general'" class="p-3 text-xs text-slate-600">{{ emp.numero_identidad || 'N/A' }}</td>
                <td v-if="empleadosVista === 'general'" class="p-3 text-xs text-slate-600">{{ emp.puesto || 'N/A' }}</td>
                <td class="p-3 text-xs font-medium text-slate-800">{{ emp.departamento || getNombreDepartamento(emp.departamento_id) }}</td>
                <td v-if="empleadosVista === 'general'" class="p-3 text-center">
                  <span :class="emp.estado == 1 ? 'bg-emerald-100 text-emerald-700' : 'bg-red-100 text-red-700'" class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">
                    {{ emp.estado == 1 ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>

                <td v-if="empleadosVista === 'vacaciones'" class="p-3 text-center text-sm font-black text-slate-700">
                  <div v-if="emp.proxima_vacacion_inicio || emp.proxima_vacacion_fin" class="flex flex-col gap-1 items-center justify-center">
                    <span v-if="emp.proxima_vacacion_inicio" class="bg-emerald-50 text-emerald-700 px-2 py-0.5 rounded-full border border-emerald-100 text-[10px]">Inicio: {{ new Date(emp.proxima_vacacion_inicio).toLocaleDateString('es-HN', {timeZone: 'UTC'}) }}</span>
                    <span v-if="emp.proxima_vacacion_fin" class="bg-orange-50 text-orange-700 px-2 py-0.5 rounded-full border border-orange-100 text-[10px]">Fin: {{ new Date(emp.proxima_vacacion_fin).toLocaleDateString('es-HN', {timeZone: 'UTC'}) }}</span>
                  </div>
                  <span v-else class="text-slate-400 italic font-medium text-xs">Sin programar</span>
                </td>
                <td v-if="empleadosVista === 'faltas'" class="p-3 text-center text-sm font-black">
                  <span :class="emp.total_faltas > 0 ? 'text-red-600 bg-red-50 border-red-100' : 'text-slate-500 bg-slate-50 border-slate-200'" class="px-3 py-1 rounded-full border">
                    {{ emp.total_faltas || 0 }} faltas
                  </span>
                </td>
                <td v-if="empleadosVista === 'cumpleanos'" class="p-3 text-center text-sm font-black text-slate-700">
                  <span class="bg-purple-50 text-purple-700 px-3 py-1 rounded-full border border-purple-100">
                    🎂 {{ emp.fecha_nacimiento ? new Date(emp.fecha_nacimiento).toLocaleDateString('es-HN', { day: 'numeric', month: 'long', timeZone: 'UTC' }) : 'N/A' }}
                  </span>
                </td>
                <td v-if="empleadosVista === 'renovaciones'" class="p-3 text-center text-sm font-black text-slate-700">
                  <span class="bg-orange-50 text-orange-700 px-3 py-1 rounded-full border border-orange-100">
                    📄 {{ emp.contrato_vencimiento ? new Date(emp.contrato_vencimiento).toLocaleDateString('es-HN', { day: 'numeric', month: 'long', timeZone: 'UTC' }) : 'N/A' }}
                  </span>
                </td>
              </tr>
              <tr v-if="empleadosFiltrados.length === 0">
                <td colspan="7" class="p-8">
                  <div class="flex flex-col items-center justify-center text-center">
                    <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                      <span class="text-3xl">🔍</span>
                    </div>
                    <h3 class="text-slate-800 font-black text-lg mb-1">Sin Resultados</h3>
                    <p class="text-slate-500 text-sm max-w-md">No se encontraron empleados que coincidan con "{{ searchQuery }}" o los filtros actuales.</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- TAB: INCIDENCIAS LABORALES -->
      <div v-if="activeTab === 'incidencias'" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 animate-in fade-in duration-300">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter text-rose-600">🚨 Incidencias Laborales</h2>
          <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto items-center">
            <input v-model="searchQuery" type="text" placeholder="Buscar empleado o categoría..." class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 w-full md:w-48 focus:border-blue-500 outline-none">
            <button @click="generarPDFIncidencias" class="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📄</span> Crear PDF Incidencias
            </button>
            <button @click="exportarCSV(incidenciasFiltradas, 'Reporte_Incidencias')" class="px-4 py-2 bg-rose-600 hover:bg-rose-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <div class="bg-slate-50 p-5 rounded-2xl border border-slate-100 h-[300px] flex flex-col items-center">
             <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-4">Gravedad de Incidencias</h3>
             <div class="flex-1 w-full relative">
               <Doughnut v-if="!loadingIncidencias && chartGravedadIncidenciasData" :data="chartGravedadIncidenciasData" :options="doughnutOptions" />
             </div>
          </div>
          <div class="bg-slate-50 p-5 rounded-2xl border border-slate-100 h-[300px] flex flex-col items-center">
             <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-4">Estado de Resolución</h3>
             <div class="flex-1 w-full relative">
               <Pie v-if="!loadingIncidencias && chartEstadoIncidenciasData" :data="chartEstadoIncidenciasData" :options="doughnutOptionsPercent" />
             </div>
          </div>
        </div>
        <div v-if="loadingIncidencias" class="flex flex-col items-center justify-center py-16">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-rose-600 mb-4"></div>
          <span class="text-slate-500 font-medium text-sm">Cargando incidencias laborales...</span>
        </div>
        <div v-else class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Código</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Empleado</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Fecha</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Categoría</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Gravedad</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="inc in incidenciasFiltradas" :key="inc.id" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                <td class="p-3 text-xs font-bold text-slate-500">INC-{{ inc.id }}</td>
                <td class="p-3 text-sm font-bold text-slate-800">{{ inc.empleado_nombre || 'Desconocido' }}</td>
                <td class="p-3 text-xs text-slate-600">{{ inc.fecha_creacion ? new Date(inc.fecha_creacion).toLocaleDateString() : 'N/A' }}</td>
                <td class="p-3 text-xs text-slate-700">{{ inc.categoria }}</td>
                <td class="p-3 text-center">
                  <span :class="{'bg-red-100 text-red-700': inc.prioridad === 'Alta' || inc.prioridad === 'Urgente', 'bg-orange-100 text-orange-700': inc.prioridad === 'Media', 'bg-yellow-100 text-yellow-700': inc.prioridad === 'Baja'}" class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">{{ inc.prioridad || 'Media' }}</span>
                </td>
                <td class="p-3 text-center">
                  <span :class="{'bg-emerald-100 text-emerald-700': inc.estado === 'Cerrado' || inc.estado === 'Resuelto', 'bg-blue-100 text-blue-700': inc.estado !== 'Cerrado' && inc.estado !== 'Resuelto'}" class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">{{ inc.estado }}</span>
                </td>
              </tr>
              <tr v-if="incidenciasFiltradas.length === 0">
                <td colspan="6" class="p-8">
                  <div class="flex flex-col items-center justify-center text-center">
                    <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                      <span class="text-3xl">📭</span>
                    </div>
                    <h3 class="text-slate-800 font-black text-lg mb-1">Sin Incidencias</h3>
                    <p class="text-slate-500 text-sm max-w-md">No se encontraron incidencias que coincidan con "{{ searchQuery }}".</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- TAB: DOCS LEGALES -->
      <div v-if="activeTab === 'legales'" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 animate-in fade-in duration-300">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter text-indigo-600">⚖️ Documentación Legal y Vencimientos</h2>
          <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto items-center">
            <input v-model="searchQuery" type="text" placeholder="Buscar documento o empleado..." class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 w-full md:w-48 focus:border-blue-500 outline-none">
            <select v-model="legalesFiltroEstado" class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 focus:border-blue-500 outline-none">
              <option value="todos">Todos</option>
              <option value="renovar">Por Renovar / Vencer</option>
            </select>
            <button @click="generarPDFLegales" class="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2 whitespace-nowrap">
              <span>📄</span> Crear PDF Legales
            </button>
            <button @click="exportarCSV(legalesFiltrados, 'Reporte_Docs_Legales')" class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
        </div>
        <div v-if="loadingLegales" class="flex flex-col items-center justify-center py-16">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-indigo-600 mb-4"></div>
          <span class="text-slate-500 font-medium text-sm">Cargando documentos legales...</span>
        </div>
        <div v-else class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-slate-50 border-b border-slate-200">
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Documento</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Categoría</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Empleado Asociado</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest">Fecha Expiración</th>
                <th class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="doc in legalesFiltrados" :key="doc.id" class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
                <td class="p-3 text-sm font-bold text-slate-800">{{ doc.titulo }}</td>
                <td class="p-3 text-xs text-slate-600">{{ doc.categoria_nombre }}</td>
                <td class="p-3 text-xs text-slate-700">{{ doc.empleado_nombre ? doc.empleado_nombre + ' ' + (doc.empleado_apellido||'') : 'General' }}</td>
                <td class="p-3 text-xs text-slate-800 font-bold">{{ doc.fecha_expiracion ? new Date(doc.fecha_expiracion).toLocaleDateString() : 'N/A' }}</td>
                <td class="p-3 text-center">
                  <span v-if="doc.dias_restantes !== null && doc.dias_restantes < 0" class="bg-red-100 text-red-700 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">Vencido</span>
                  <span v-else-if="doc.dias_restantes !== null && doc.dias_restantes <= 30" class="bg-orange-100 text-orange-700 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">Por Vencer</span>
                  <span v-else class="bg-emerald-100 text-emerald-700 px-2 py-1 rounded text-[10px] font-bold uppercase tracking-widest">Vigente</span>
                </td>
              </tr>
              <tr v-if="legalesFiltrados.length === 0">
                <td colspan="5" class="p-8">
                  <div class="flex flex-col items-center justify-center text-center">
                    <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                      <span class="text-3xl">📂</span>
                    </div>
                    <h3 class="text-slate-800 font-black text-lg mb-1">Sin Documentos</h3>
                    <p class="text-slate-500 text-sm max-w-md">No se encontraron documentos legales que coincidan con "{{ searchQuery }}".</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- TAB: DESPIDOS -->
      <div v-if="activeTab === 'despidos'" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200 animate-in fade-in duration-300">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter text-red-600">🚪 Información de Bajas y Despidos</h2>
          <p class="text-xs text-slate-500 font-medium">Procedimiento y documentación necesaria para desvinculaciones.</p>
        </div>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Checklist -->
          <div class="bg-slate-50 p-6 rounded-2xl border border-slate-100 hover:shadow-md transition-shadow">
            <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-5 flex items-center gap-2">
              <span class="w-2 h-2 bg-blue-500 rounded-full"></span>
              📋 Checklist de Documentación
            </h3>
            <ul class="space-y-4 text-sm font-medium text-slate-600">
              <li class="flex items-start gap-3 bg-white p-3 rounded-xl border border-slate-100 shadow-sm">
                <span class="text-green-500 text-lg">✅</span> 
                <span><strong>Carta de Despido / Renuncia:</strong> Documento debidamente firmado y sellado.</span>
              </li>
              <li class="flex items-start gap-3 bg-white p-3 rounded-xl border border-slate-100 shadow-sm">
                <span class="text-green-500 text-lg">✅</span> 
                <span><strong>Cálculo de Prestaciones y Finiquito:</strong> Cheque y desglose entregado en tiempo de ley.</span>
              </li>
              <li class="flex items-start gap-3 bg-white p-3 rounded-xl border border-slate-100 shadow-sm">
                <span class="text-green-500 text-lg">✅</span> 
                <span><strong>Constancia de Trabajo:</strong> Firmada por el Depto. de RRHH (Si el empleado lo solicita).</span>
              </li>
              <li class="flex items-start gap-3 bg-white p-3 rounded-xl border border-slate-100 shadow-sm">
                <span class="text-green-500 text-lg">✅</span> 
                <span><strong>Devolución de Equipo:</strong> Laptops, uniformes, llaves, y herramientas asignadas.</span>
              </li>
              <li class="flex items-start gap-3 bg-white p-3 rounded-xl border border-slate-100 shadow-sm">
                <span class="text-green-500 text-lg">✅</span> 
                <span><strong>Baja en IHSS / RAP:</strong> Comprobante de cancelación de seguro y previsión social.</span>
              </li>
            </ul>
          </div>

          <!-- Procedimiento -->
          <div class="bg-slate-50 p-6 rounded-2xl border border-slate-100 hover:shadow-md transition-shadow">
             <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-5 flex items-center gap-2">
              <span class="w-2 h-2 bg-red-500 rounded-full"></span>
              ⚠️ Procedimiento Operativo
            </h3>
             <ol class="space-y-4 text-sm font-medium text-slate-600 relative">
               <div class="absolute left-[13px] top-4 bottom-4 w-0.5 bg-slate-200"></div>
               <li class="flex items-start gap-4 relative z-10">
                 <div class="w-7 h-7 rounded-full bg-slate-800 text-white flex items-center justify-center font-bold text-xs shrink-0 ring-4 ring-slate-50">1</div>
                 <div class="bg-white p-3 rounded-xl border border-slate-100 shadow-sm w-full">
                    <p>Notificar al empleado con la <strong>carta formal</strong> especificando motivos (si es despido justificado).</p>
                 </div>
               </li>
               <li class="flex items-start gap-4 relative z-10">
                 <div class="w-7 h-7 rounded-full bg-slate-800 text-white flex items-center justify-center font-bold text-xs shrink-0 ring-4 ring-slate-50">2</div>
                 <div class="bg-white p-3 rounded-xl border border-slate-100 shadow-sm w-full">
                    <p>Realizar <strong>entrevista de salida</strong> y solicitar devolución de equipo y gafete.</p>
                 </div>
               </li>
               <li class="flex items-start gap-4 relative z-10">
                 <div class="w-7 h-7 rounded-full bg-slate-800 text-white flex items-center justify-center font-bold text-xs shrink-0 ring-4 ring-slate-50">3</div>
                 <div class="bg-white p-3 rounded-xl border border-slate-100 shadow-sm w-full">
                    <p>Tramitar accesos de red: deshabilitar correo corporativo, ERP y credenciales del sistema.</p>
                 </div>
               </li>
               <li class="flex items-start gap-4 relative z-10">
                 <div class="w-7 h-7 rounded-full bg-slate-800 text-white flex items-center justify-center font-bold text-xs shrink-0 ring-4 ring-slate-50">4</div>
                 <div class="bg-white p-3 rounded-xl border border-slate-100 shadow-sm w-full">
                    <p>Actualizar estado a <strong>Inactivo</strong> en RRHH Innova desde el módulo de Empleados.</p>
                 </div>
               </li>
             </ol>
          </div>
        </div>

        <div class="mt-8 flex justify-end gap-3 border-t border-slate-100 pt-6">
           <button @click="router.push('/empleados')" class="px-6 py-3 bg-red-600 text-white rounded-xl font-black uppercase text-xs hover:bg-red-700 transition-colors shadow-lg shadow-red-200 flex items-center gap-2">
              👥 Ir a Inactivar Empleado
           </button>
           <button class="px-6 py-3 bg-slate-800 text-white rounded-xl font-black uppercase text-xs hover:bg-slate-900 transition-colors shadow-lg flex items-center gap-2">
              🖨️ Imprimir Guía
           </button>
        </div>
      </div>

      <!-- TAB: TICKETS -->
      <div v-if="activeTab === 'tickets'" class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter">Análisis de Soporte</h2>
          <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto items-center">
            <input v-model="searchQuery" type="text" placeholder="Buscar ticket, usuario..." class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 w-full md:w-48 focus:border-blue-500 outline-none">
            <select v-model="ticketsFiltroEstado" class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 focus:border-blue-500 outline-none">
              <option value="todos">Todos los Estados</option>
              <option value="pendientes_progreso">Pendientes / Progreso</option>
              <option value="resueltos_cerrados">Resueltos / Cerrados</option>
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
            <button @click="generarPDFTickets" class="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2 whitespace-nowrap">
              <span>📄</span> Crear PDF Tickets
            </button>
            <button @click="exportarCSV(ticketsFiltrados, 'Reporte_Tickets')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
        </div>

        <!-- Resumen General -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div @click="ticketsFiltroEstado = 'todos'" class="cursor-pointer bg-gradient-to-br from-slate-800 to-slate-900 p-5 rounded-2xl shadow-sm text-white flex items-center justify-between transition-transform hover:scale-[1.02]">
            <div>
              <p class="text-[10px] font-black uppercase tracking-widest text-slate-400">Total Tickets</p>
              <p class="text-3xl font-black mt-1">{{ tickets.length }}</p>
            </div>
            <div class="w-12 h-12 bg-white/10 rounded-full flex items-center justify-center text-2xl">📋</div>
          </div>
          <div @click="ticketsFiltroEstado = 'pendientes_progreso'" class="cursor-pointer bg-gradient-to-br from-yellow-400 to-orange-500 p-5 rounded-2xl shadow-sm text-white flex items-center justify-between transition-transform hover:scale-[1.02]">
            <div>
              <p class="text-[10px] font-black uppercase tracking-widest text-yellow-100">Pendientes / Progreso</p>
              <p class="text-3xl font-black mt-1">{{ tickets.filter(t => t.estado === 'Pendiente' || t.estado === 'En Progreso').length }}</p>
            </div>
            <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center text-2xl">⏳</div>
          </div>
          <div @click="ticketsFiltroEstado = 'resueltos_cerrados'" class="cursor-pointer bg-gradient-to-br from-emerald-500 to-teal-600 p-5 rounded-2xl shadow-sm text-white flex items-center justify-between transition-transform hover:scale-[1.02]">
            <div>
              <p class="text-[10px] font-black uppercase tracking-widest text-emerald-100">Resueltos / Cerrados</p>
              <p class="text-3xl font-black mt-1">{{ tickets.filter(t => t.estado === 'Resuelto' || t.estado === 'Cerrado').length }}</p>
            </div>
            <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center text-2xl">✅</div>
          </div>
        </div>

        <!-- Gráficos de Tickets -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
          <div class="bg-slate-50 p-5 rounded-2xl border border-slate-100 h-[300px] flex flex-col items-center">
             <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-4">Tickets por Estado</h3>
             <div class="flex-1 w-full relative">
               <Doughnut v-if="!loadingTickets && chartEstadoTicketsData" :data="chartEstadoTicketsData" :options="doughnutOptions" />
             </div>
          </div>
          <div class="bg-slate-50 p-5 rounded-2xl border border-slate-100 h-[300px] flex flex-col items-center">
             <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-4">Tickets por Prioridad</h3>
             <div class="flex-1 w-full relative">
               <Doughnut v-if="!loadingTickets && chartPrioridadTicketsData" :data="chartPrioridadTicketsData" :options="doughnutOptions" />
             </div>
          </div>
        </div>

        <div v-if="loadingTickets" class="flex flex-col items-center justify-center py-16">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-emerald-600 mb-4"></div>
          <span class="text-slate-500 font-medium text-sm">Cargando tickets...</span>
        </div>
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
                <td class="p-3 text-xs">
                  <div class="flex items-center gap-2">
                    <div class="w-6 h-6 rounded-full bg-slate-200 flex items-center justify-center text-[10px] font-bold text-slate-600">
                      {{ (ticket.creadoPorNombre || ticket.empleado_nombre || '?').charAt(0).toUpperCase() }}
                    </div>
                    <span class="text-slate-700 font-bold">{{ ticket.creadoPorNombre || (ticket.empleado_nombre ? `${ticket.empleado_nombre} ${ticket.empleado_apellido || ''}`.trim() : 'Desconocido') }}</span>
                  </div>
                </td>
                <td class="p-3 text-xs text-slate-500">{{ new Date(ticket.fecha_creacion).toLocaleDateString() }}</td>
              </tr>
              <tr v-if="ticketsFiltrados.length === 0">
                <td colspan="6" class="p-8">
                  <div class="flex flex-col items-center justify-center text-center">
                    <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                      <span class="text-3xl">🎫</span>
                    </div>
                    <h3 class="text-slate-800 font-black text-lg mb-1">Sin Tickets</h3>
                    <p class="text-slate-500 text-sm max-w-md">No se encontraron tickets con los filtros actuales o la búsqueda "{{ searchQuery }}".</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- TAB: CONTROL DE TIEMPOS -->
      <div v-if="activeTab === 'tiempos'" class="space-y-6 animate-in fade-in duration-300">
        
        <!-- ENCABEZADO Y PDF CONTROL DE TIEMPOS -->
        <div class="flex flex-col md:flex-row justify-between items-center bg-white p-6 rounded-2xl shadow-sm border border-slate-200 gap-4">
           <div>
             <h2 class="text-xl font-black text-slate-800 uppercase tracking-tighter text-emerald-600">⏳ Reporte de Control de Tiempos</h2>
             <p class="text-xs text-slate-500 font-medium mt-1">Genera un reporte consolidado con proyecciones, ausentismo y saldos de vacaciones.</p>
           </div>
           <button @click="generarPDFControlTiempos" class="px-5 py-2.5 bg-slate-800 hover:bg-slate-900 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2 whitespace-nowrap">
              <span>📄</span> Crear PDF Control de Tiempos
           </button>
        </div>

        <!-- Proyecciones Vacaciones -->
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
        <div class="flex flex-col md:flex-row justify-between items-center mb-6 gap-4 border-b border-slate-100 pb-4">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tighter">Proyecciones de Vacaciones</h2>
          <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto">
            <button @click="exportarCSV(proyeccionesVacaciones, 'Proyecciones_Vacaciones')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
              <span>📊</span> CSV
            </button>
          </div>
        </div>

        <div v-if="loadingProyecciones" class="flex flex-col items-center justify-center py-16">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-emerald-600 mb-4"></div>
          <span class="text-slate-500 font-medium text-sm">Cargando proyecciones de vacaciones...</span>
        </div>
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
                <td colspan="6" class="p-8">
                  <div class="flex flex-col items-center justify-center text-center">
                    <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                      <span class="text-3xl">✈️</span>
                    </div>
                    <h3 class="text-slate-800 font-black text-lg mb-1">Sin Proyecciones</h3>
                    <p class="text-slate-500 text-sm max-w-md">No hay vacaciones próximas programadas en el sistema.</p>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

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
          <div v-if="loadingAusentismo" class="flex flex-col items-center justify-center py-16">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-rose-600 mb-4"></div>
          <span class="text-slate-500 font-medium text-sm">Cargando ausentismo...</span>
        </div>
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
                  <td colspan="5" class="p-8">
                    <div class="flex flex-col items-center justify-center text-center">
                      <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                        <span class="text-3xl">⚠️</span>
                      </div>
                      <h3 class="text-slate-800 font-black text-lg mb-1">Sin Datos de Ausentismo</h3>
                      <p class="text-slate-500 text-sm max-w-md">No hay registros de ausentismo o faltas para el mes actual.</p>
                    </div>
                  </td>
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
              <input v-model="searchQuery" type="text" placeholder="Buscar empleado..." class="p-2 border border-slate-200 rounded-lg text-sm bg-slate-50 w-full md:w-64 focus:border-blue-500 outline-none">
              <button @click="exportarCSV(saldosFiltrados, 'Saldos_Vacaciones')" class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2">
                <span>📊</span> CSV
              </button>
            </div>
          </div>
          <div v-if="loadingSaldos" class="flex flex-col items-center justify-center py-16">
          <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600 mb-4"></div>
          <span class="text-slate-500 font-medium text-sm">Cargando saldos...</span>
        </div>
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
                  <td colspan="6" class="p-8">
                    <div class="flex flex-col items-center justify-center text-center">
                      <div class="w-16 h-16 bg-slate-50 rounded-full flex items-center justify-center mb-3">
                        <span class="text-3xl">🏖️</span>
                      </div>
                      <h3 class="text-slate-800 font-black text-lg mb-1">Sin Saldos</h3>
                      <p class="text-slate-500 text-sm max-w-md">No se encontraron saldos de vacaciones que coincidan con "{{ searchQuery }}".</p>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- TAB: WIZARD GENERADOR -->
      <div v-if="activeTab === 'wizard'" class="space-y-6 animate-in fade-in duration-300">
        <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
          <div class="flex justify-between items-center mb-6">
            <div>
              <h2 class="text-xl font-black text-slate-800 uppercase tracking-tighter text-purple-600">🧙‍♂️ Generador de Reportes Asistido</h2>
              <p class="text-xs text-slate-500 font-medium mt-1">Crea reportes a medida siguiendo estos sencillos pasos.</p>
            </div>
            <div class="text-2xl font-black text-purple-200">Paso {{ wizardPaso }} / 4</div>
          </div>

          <!-- Progress Bar -->
          <div class="flex items-center justify-between mb-8 relative">
            <div class="absolute left-0 top-1/2 w-full h-1 bg-slate-100 -z-10 rounded-full"></div>
            <div class="absolute left-0 top-1/2 h-1 bg-purple-500 -z-10 rounded-full transition-all duration-300" :style="`width: ${(wizardPaso - 1) * 33.33}%`"></div>
            
            <div v-for="step in 4" :key="step" class="flex flex-col items-center gap-2">
              <div :class="['w-10 h-10 rounded-full flex items-center justify-center font-black text-sm border-4 transition-colors', wizardPaso >= step ? 'bg-purple-600 border-purple-200 text-white shadow-lg' : 'bg-white border-slate-200 text-slate-400']">
                <span v-if="wizardPaso > step">✓</span>
                <span v-else>{{ step }}</span>
              </div>
              <span :class="['text-[10px] font-bold uppercase tracking-widest', wizardPaso >= step ? 'text-purple-700' : 'text-slate-400']">
                {{ ['Categoría', 'Filtros', 'Vista Previa', 'Exportar'][step-1] }}
              </span>
            </div>
          </div>

          <!-- Step 1: Categoría -->
          <div v-if="wizardPaso === 1" class="animate-in slide-in-from-right-4">
            <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-4">¿Qué tipo de información deseas consultar?</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div @click="wizardCategoria = 'empleados'" :class="['p-5 rounded-xl border-2 cursor-pointer transition-all hover:-translate-y-1', wizardCategoria === 'empleados' ? 'border-blue-500 bg-blue-50 shadow-md' : 'border-slate-100 bg-white hover:border-slate-300']">
                <div class="text-3xl mb-2">👥</div>
                <h4 class="font-black text-slate-800 text-sm">Directorio Analítico</h4>
                <p class="text-xs text-slate-500 mt-1">Información de empleados, estado y datos demográficos.</p>
              </div>
              <div @click="wizardCategoria = 'incidencias'" :class="['p-5 rounded-xl border-2 cursor-pointer transition-all hover:-translate-y-1', wizardCategoria === 'incidencias' ? 'border-rose-500 bg-rose-50 shadow-md' : 'border-slate-100 bg-white hover:border-slate-300']">
                <div class="text-3xl mb-2">🚨</div>
                <h4 class="font-black text-slate-800 text-sm">Incidencias Laborales</h4>
                <p class="text-xs text-slate-500 mt-1">Reportes disciplinarios y problemas laborales registrados.</p>
              </div>
              <div @click="wizardCategoria = 'vacaciones'" :class="['p-5 rounded-xl border-2 cursor-pointer transition-all hover:-translate-y-1', wizardCategoria === 'vacaciones' ? 'border-emerald-500 bg-emerald-50 shadow-md' : 'border-slate-100 bg-white hover:border-slate-300']">
                <div class="text-3xl mb-2">🏖️</div>
                <h4 class="font-black text-slate-800 text-sm">Vacaciones y Saldos</h4>
                <p class="text-xs text-slate-500 mt-1">Días acumulados, gozados y saldos pendientes.</p>
              </div>
              <div @click="wizardCategoria = 'tickets'" :class="['p-5 rounded-xl border-2 cursor-pointer transition-all hover:-translate-y-1', wizardCategoria === 'tickets' ? 'border-amber-500 bg-amber-50 shadow-md' : 'border-slate-100 bg-white hover:border-slate-300']">
                <div class="text-3xl mb-2">🎫</div>
                <h4 class="font-black text-slate-800 text-sm">Soporte y Tickets</h4>
                <p class="text-xs text-slate-500 mt-1">Solicitudes de soporte y estado de resolución.</p>
              </div>
            </div>
          </div>

          <!-- Step 2: Filtros -->
          <div v-if="wizardPaso === 2" class="animate-in slide-in-from-right-4 space-y-4">
            <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-4">Configura los filtros de tu reporte</h3>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 bg-slate-50 p-5 rounded-xl border border-slate-100">
              <div>
                <label class="block text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2">Buscar por nombre o código</label>
                <input v-model="wizardFiltros.busqueda" type="text" placeholder="Ej. Juan Pérez..." class="w-full p-3 border border-slate-200 rounded-lg text-sm bg-white focus:border-purple-500 focus:ring-1 focus:ring-purple-500 outline-none">
              </div>
              <div v-if="wizardCategoria === 'empleados'">
                <label class="block text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2">Estado</label>
                <select v-model="wizardFiltros.estado" class="w-full p-3 border border-slate-200 rounded-lg text-sm bg-white focus:border-purple-500 outline-none">
                  <option value="todos">Todos los Estados</option>
                  <option value="1">Activos</option>
                  <option value="0">Inactivos</option>
                </select>
              </div>
              <div v-if="wizardCategoria === 'incidencias' || wizardCategoria === 'tickets'">
                <label class="block text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2">Estado del caso</label>
                <select v-model="wizardFiltros.estado_caso" class="w-full p-3 border border-slate-200 rounded-lg text-sm bg-white focus:border-purple-500 outline-none">
                  <option value="todos">Todos</option>
                  <option value="Abierto">Abierto/Pendiente</option>
                  <option value="Cerrado">Cerrado/Resuelto</option>
                </select>
              </div>
              <div>
                <label class="block text-[10px] font-bold text-slate-500 uppercase tracking-widest mb-2">Filtrar por Departamento</label>
                <select v-model="wizardFiltros.departamento" class="w-full p-3 border border-slate-200 rounded-lg text-sm bg-white focus:border-purple-500 outline-none">
                  <option value="todos">Todos los departamentos</option>
                  <option v-for="d in departamentos" :key="d.id" :value="d.nombre">{{ d.nombre }}</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Step 3: Vista Previa -->
          <div v-if="wizardPaso === 3" class="animate-in slide-in-from-right-4">
            <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-4">Vista Previa de Datos ({{ wizardDatosFiltrados.length }} registros)</h3>
            
            <div class="overflow-x-auto border border-slate-200 rounded-xl max-h-96">
              <table class="w-full text-left border-collapse bg-white">
                <thead class="sticky top-0 bg-slate-50 shadow-sm">
                  <tr>
                    <th v-for="(col, i) in wizardColumnas" :key="i" class="p-3 text-[10px] font-black text-slate-500 uppercase tracking-widest whitespace-nowrap">
                      {{ col.label }}
                    </th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, idx) in wizardDatosFiltrados.slice(0, 50)" :key="idx" class="border-b border-slate-100 hover:bg-slate-50">
                    <td v-for="(col, i) in wizardColumnas" :key="i" class="p-3 text-xs text-slate-700">
                      {{ obtenerValorColumna(row, col.key) }}
                    </td>
                  </tr>
                  <tr v-if="wizardDatosFiltrados.length === 0">
                    <td :colspan="wizardColumnas.length" class="p-8 text-center text-slate-500 font-medium text-sm">
                      No hay registros que coincidan con los filtros aplicados.
                    </td>
                  </tr>
                  <tr v-if="wizardDatosFiltrados.length > 50">
                    <td :colspan="wizardColumnas.length" class="p-4 text-center text-slate-400 italic text-xs bg-slate-50/50">
                      Mostrando los primeros 50 registros de {{ wizardDatosFiltrados.length }}. El reporte completo se generará al exportar.
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Step 4: Exportar -->
          <div v-if="wizardPaso === 4" class="animate-in slide-in-from-right-4">
            <h3 class="text-sm font-black text-slate-800 uppercase tracking-widest mb-4">¡Todo listo! Selecciona el formato de exportación</h3>
            
            <div class="bg-slate-50 p-8 rounded-2xl border border-slate-100 text-center flex flex-col items-center gap-6">
              <div class="text-6xl animate-bounce">🎉</div>
              <div>
                <h4 class="text-lg font-black text-slate-800">Reporte de {{ wizardCategoriaNombre }} Preparado</h4>
                <p class="text-slate-500 text-sm mt-1">Se procesarán {{ wizardDatosFiltrados.length }} registros según tus criterios.</p>
              </div>
              
              <div class="flex flex-col sm:flex-row gap-4 w-full justify-center mt-4">
                <button @click="generarPDFWizard" :disabled="wizardDatosFiltrados.length === 0" class="px-8 py-4 bg-slate-800 hover:bg-slate-900 text-white rounded-xl font-black text-sm uppercase tracking-widest transition-all shadow-lg flex items-center justify-center gap-3 disabled:opacity-50 disabled:cursor-not-allowed group">
                  <span class="text-2xl group-hover:scale-110 transition-transform">📄</span> Descargar PDF
                </button>
                <button @click="exportarCSVWizard" :disabled="wizardDatosFiltrados.length === 0" class="px-8 py-4 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl font-black text-sm uppercase tracking-widest transition-all shadow-lg flex items-center justify-center gap-3 disabled:opacity-50 disabled:cursor-not-allowed group">
                  <span class="text-2xl group-hover:scale-110 transition-transform">📊</span> Descargar CSV
                </button>
              </div>
            </div>
          </div>

          <!-- Controles del Wizard -->
          <div class="flex justify-between items-center mt-8 pt-6 border-t border-slate-100">
            <button @click="wizardAnterior" :disabled="wizardPaso === 1" class="px-6 py-2 border-2 border-slate-200 text-slate-600 hover:bg-slate-50 rounded-lg font-bold text-xs uppercase tracking-widest transition-colors disabled:opacity-30 disabled:cursor-not-allowed">
              ⬅ Anterior
            </button>
            <button v-if="wizardPaso < 4" @click="wizardSiguiente" :disabled="(wizardPaso === 1 && !wizardCategoria)" class="px-6 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-md disabled:opacity-50 disabled:cursor-not-allowed">
              Siguiente ➡
            </button>
            <button v-if="wizardPaso === 4" @click="wizardReiniciar" class="px-6 py-2 border-2 border-purple-200 text-purple-600 hover:bg-purple-50 rounded-lg font-bold text-xs uppercase tracking-widest transition-colors">
              🔄 Crear Nuevo Reporte
            </button>
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
import { Chart as ChartJS, ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title, PointElement, LineElement, RadialLinearScale } from 'chart.js'
import { Doughnut, Bar, Pie, Line, PolarArea } from 'vue-chartjs'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import Swal from 'sweetalert2'

ChartJS.register(ArcElement, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, PointElement, LineElement, RadialLinearScale)

const router = useRouter()
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const menuUsuario = ref([])
const usuarioActual = ref('')
const mobileMenuOpen = ref(false)
const activeTab = ref('dashboard')
const searchQuery = ref('')
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

const polarOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: { position: 'right', labels: { boxWidth: 12, font: { size: 10, family: "'Inter', sans-serif" } } }
  }
}

const chartEstadoData = computed(() => ({
  labels: ['Activos', 'Inactivos'],
  datasets: [{ backgroundColor: ['#10b981', '#ef4444'], borderWidth: 0, data: [stats.value.activos || 0, stats.value.inactivos || 0] }]
}))

const estadoContratos = ref({ activos: 0, por_vencer: 0, vencidos: 0 })
const chartContratosData = computed(() => ({
  labels: ['Activos', 'Por Vencer (30d)', 'Vencidos'],
  datasets: [{ label: 'Contratos', backgroundColor: ['#10b981', '#f59e0b', '#ef4444'], borderRadius: 4, data: [estadoContratos.value.activos || 0, estadoContratos.value.por_vencer || 0, estadoContratos.value.vencidos || 0] }]
}))

const tiposFaltas = ref({ justificadas: 0, injustificadas: 0 })
const chartFaltasData = computed(() => ({
  labels: ['Justificadas', 'Injustificadas'],
  datasets: [{ label: 'Faltas', backgroundColor: ['#10b981', '#ef4444'], borderRadius: 4, data: [tiposFaltas.value.justificadas || 0, tiposFaltas.value.injustificadas || 0] }]
}))

const chartGeneroData = computed(() => {
  const data = empleadosFiltrados.value;
  let masculino = 0;
  let femenino = 0;
  let otro = 0;
  
  data.forEach(e => {
    const gen = (e.genero || '').toLowerCase().trim();
    if (gen === 'masculino' || gen === 'm') masculino++;
    else if (gen === 'femenino' || gen === 'f') femenino++;
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
      label: 'Empleados',
      backgroundColor: ['#f59e0b', '#10b981', '#6366f1', '#8b5cf6', '#cbd5e1'],
      borderRadius: 4,
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
const empleadosVista = ref('general')

const cargarEmpleados = async (isPolling = false) => {
  try {
    if (!isPolling) loadingEmpleados.value = true
    const res = await axios.get('http://localhost:3007/api/stats/empleados-detalles')
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
  if (empleadosVista.value === 'cumpleanos') {
    const currentMonth = new Date().getMonth();
    list = list.filter(e => {
      if (!e.fecha_nacimiento) return false;
      return new Date(e.fecha_nacimiento).getMonth() === currentMonth;
    });
  }
  if (empleadosVista.value === 'renovaciones') {
    list = list.filter(e => e.contrato_vencimiento);
  }
  if (searchQuery.value.trim() !== '') {
    const q = searchQuery.value.toLowerCase()
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
    if (ticketsFiltroEstado.value === 'pendientes_progreso') {
      list = list.filter(t => t.estado === 'Pendiente' || t.estado === 'En Progreso')
    } else if (ticketsFiltroEstado.value === 'resueltos_cerrados') {
      list = list.filter(t => t.estado === 'Resuelto' || t.estado === 'Cerrado')
    } else {
      list = list.filter(t => t.estado === ticketsFiltroEstado.value)
    }
  }
  if (ticketsFiltroPrioridad.value !== 'todos') {
    list = list.filter(t => t.prioridad === ticketsFiltroPrioridad.value)
  }
  if (searchQuery.value.trim() !== '') {
    const q = searchQuery.value.toLowerCase()
    list = list.filter(t => 
      (t.asunto && t.asunto.toLowerCase().includes(q)) || 
      (t.creadoPorNombre && t.creadoPorNombre.toLowerCase().includes(q)) ||
      (t.asignado_usuario_nombre && t.asignado_usuario_nombre.toLowerCase().includes(q)) ||
      (t.empleado_nombre && t.empleado_nombre.toLowerCase().includes(q))
    )
  }
  return list
})

const chartEstadoTicketsData = computed(() => {
  if (ticketsFiltrados.value.length === 0) return null;
  let pendiente = 0, progreso = 0, resuelto = 0, cerrado = 0;
  ticketsFiltrados.value.forEach(t => {
    if (t.estado === 'Pendiente') pendiente++;
    else if (t.estado === 'En Progreso') progreso++;
    else if (t.estado === 'Resuelto') resuelto++;
    else if (t.estado === 'Cerrado') cerrado++;
  });
  return {
    labels: ['Pendiente', 'En Progreso', 'Resuelto', 'Cerrado'],
    datasets: [{ backgroundColor: ['#fde047', '#3b82f6', '#10b981', '#64748b'], borderWidth: 0, data: [pendiente, progreso, resuelto, cerrado] }]
  }
})

const chartPrioridadTicketsData = computed(() => {
  if (ticketsFiltrados.value.length === 0) return null;
  let baja = 0, media = 0, alta = 0, urgente = 0;
  ticketsFiltrados.value.forEach(t => {
    if (t.prioridad === 'Baja') baja++;
    else if (t.prioridad === 'Media') media++;
    else if (t.prioridad === 'Alta') alta++;
    else if (t.prioridad === 'Urgente') urgente++;
  });
  return {
    labels: ['Baja', 'Media', 'Alta', 'Urgente'],
    datasets: [{ backgroundColor: ['#fde047', '#3b82f6', '#f97316', '#ef4444'], borderWidth: 0, data: [baja, media, alta, urgente] }]
  }
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
  if (!searchQuery.value.trim()) return saldosDatos.value
  const q = searchQuery.value.toLowerCase()
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

// --- INCIDENCIAS LABORALES ---
const incidenciasDatos = ref([])
const loadingIncidencias = ref(false)

const cargarIncidencias = async (isPolling = false) => {
  try {
    if (!isPolling) loadingIncidencias.value = true
    const res = await axios.get('http://localhost:3007/api/reportes-incidencia/lista')
    incidenciasDatos.value = res.data
  } catch (e) {
    console.error('Error cargando incidencias:', e)
  } finally {
    loadingIncidencias.value = false
  }
}

const incidenciasFiltradas = computed(() => {
  if (searchQuery.value.trim() === '') return incidenciasDatos.value
  const q = searchQuery.value.toLowerCase()
  return incidenciasDatos.value.filter(i => 
    (i.empleado_nombre && i.empleado_nombre.toLowerCase().includes(q)) ||
    (i.categoria && i.categoria.toLowerCase().includes(q)) ||
    (i.id && String(i.id).includes(q))
  )
})

const chartGravedadIncidenciasData = computed(() => {
  if (incidenciasDatos.value.length === 0) return null;
  let baja = 0, media = 0, alta = 0, urgente = 0;
  incidenciasDatos.value.forEach(i => {
    if (i.prioridad === 'Alta') alta++;
    else if (i.prioridad === 'Media') media++;
    else if (i.prioridad === 'Baja') baja++;
    else if (i.prioridad === 'Urgente') urgente++;
  });
  return {
    labels: ['Baja', 'Media', 'Alta', 'Urgente'],
    datasets: [{ backgroundColor: ['#fde047', '#fb923c', '#ef4444', '#b91c1c'], borderWidth: 0, data: [baja, media, alta, urgente] }]
  }
})

const chartEstadoIncidenciasData = computed(() => {
  if (incidenciasDatos.value.length === 0) return null;
  let abierto = 0, cerrado = 0, proceso = 0;
  incidenciasDatos.value.forEach(i => {
    if (i.estado === 'Cerrado' || i.estado === 'Resuelto') cerrado++;
    else if (i.estado === 'En Progreso') proceso++;
    else abierto++;
  });
  return {
    labels: ['Abierto', 'En Progreso', 'Cerrado/Resuelto'],
    datasets: [{ backgroundColor: ['#ef4444', '#f59e0b', '#10b981'], borderWidth: 0, data: [abierto, proceso, cerrado] }]
  }
})

// --- DOCS LEGALES ---
const legalesDatos = ref([])
const loadingLegales = ref(false)
const legalesFiltroEstado = ref('todos')

const cargarLegales = async (isPolling = false) => {
  try {
    if (!isPolling) loadingLegales.value = true
    const res = await axios.get('http://localhost:3007/api/documentos-legales')
    legalesDatos.value = res.data
  } catch (e) {
    console.error('Error cargando documentos legales:', e)
  } finally {
    loadingLegales.value = false
  }
}

const legalesFiltrados = computed(() => {
  let list = legalesDatos.value;
  if (legalesFiltroEstado.value === 'renovar') {
    list = list.filter(l => l.dias_restantes !== null && l.dias_restantes <= 30);
  }
  if (searchQuery.value.trim() !== '') {
    const q = searchQuery.value.toLowerCase()
    list = list.filter(l => 
      (l.titulo && l.titulo.toLowerCase().includes(q)) ||
      (l.empleado_nombre && l.empleado_nombre.toLowerCase().includes(q)) ||
      (l.empleado_apellido && l.empleado_apellido.toLowerCase().includes(q))
    )
  }
  return list;
})

// --- UTILIDADES ---
const generarPDFDirectorio = async () => {
  if (empleadosFiltrados.value.length === 0) {
    Swal.fire('Aviso', 'No hay empleados para exportar en este filtro.', 'warning');
    return;
  }

  try {
    const doc = new jsPDF();
    
    let tituloReporte = 'DIRECTORIO ANALÍTICO DE EMPLEADOS';
    let headers = [];
    let tableData = [];

    if (empleadosVista.value === 'general') {
      headers = ['Código', 'Nombre Completo', 'Identidad', 'Departamento', 'Puesto', 'Estado'];
      tableData = empleadosFiltrados.value.map(emp => [
        emp.codigo_empleado || 'N/A',
        `${emp.nombre} ${emp.apellido}`.trim(),
        emp.numero_identidad || 'N/A',
        emp.departamento || getNombreDepartamento(emp.departamento_id) || 'N/A',
        emp.puesto || 'N/A',
        emp.estado == 1 ? 'Activo' : 'Inactivo'
      ]);
    } else if (empleadosVista.value === 'vacaciones') {
      tituloReporte = 'REPORTE DE VACACIONES';
      headers = ['Código', 'Empleado', 'Departamento', 'Fechas de Vacaciones'];
      tableData = empleadosFiltrados.value.map(emp => {
        let fechasStr = 'Sin programar';
        if (emp.proxima_vacacion_inicio || emp.proxima_vacacion_fin) {
          const inicio = emp.proxima_vacacion_inicio ? new Date(emp.proxima_vacacion_inicio).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A';
          const fin = emp.proxima_vacacion_fin ? new Date(emp.proxima_vacacion_fin).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A';
          fechasStr = `Inicio: ${inicio}\nFin: ${fin}`;
        }
        return [
          emp.codigo_empleado || 'N/A',
          `${emp.nombre} ${emp.apellido}`.trim(),
          emp.departamento || getNombreDepartamento(emp.departamento_id) || 'N/A',
          fechasStr
        ];
      });
    } else if (empleadosVista.value === 'faltas') {
      tituloReporte = 'REPORTE DE FALTAS DE EMPLEADOS';
      headers = ['Código', 'Empleado', 'Departamento', 'Total Faltas'];
      tableData = empleadosFiltrados.value.map(emp => [
        emp.codigo_empleado || 'N/A',
        `${emp.nombre} ${emp.apellido}`.trim(),
        emp.departamento || getNombreDepartamento(emp.departamento_id) || 'N/A',
        emp.total_faltas ? `${emp.total_faltas} faltas` : '0 faltas'
      ]);
    } else if (empleadosVista.value === 'cumpleanos') {
      tituloReporte = 'REPORTE DE CUMPLEAÑOS DEL MES';
      headers = ['Código', 'Empleado', 'Departamento', 'Fecha de Nacimiento'];
      tableData = empleadosFiltrados.value.map(emp => [
        emp.codigo_empleado || 'N/A',
        `${emp.nombre} ${emp.apellido}`.trim(),
        emp.departamento || getNombreDepartamento(emp.departamento_id) || 'N/A',
        emp.fecha_nacimiento ? new Date(emp.fecha_nacimiento).toLocaleDateString('es-HN', { day: 'numeric', month: 'long', timeZone: 'UTC' }) : 'N/A'
      ]);
    } else if (empleadosVista.value === 'renovaciones') {
      tituloReporte = 'REPORTE DE RENOVACIONES DE CONTRATOS';
      headers = ['Código', 'Empleado', 'Departamento', 'Vencimiento Contrato'];
      tableData = empleadosFiltrados.value.map(emp => [
        emp.codigo_empleado || 'N/A',
        `${emp.nombre} ${emp.apellido}`.trim(),
        emp.departamento || getNombreDepartamento(emp.departamento_id) || 'N/A',
        emp.contrato_vencimiento ? new Date(emp.contrato_vencimiento).toLocaleDateString('es-HN', { day: 'numeric', month: 'long', timeZone: 'UTC' }) : 'N/A'
      ]);
    }

    // Encabezado
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42); // Slate 900
    doc.setFont('helvetica', 'bold');
    doc.text(tituloReporte, 14, 20);
    
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); // Slate 500
    doc.setFont('helvetica', 'normal');
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 28);
    doc.text(`Total de registros mostrados: ${empleadosFiltrados.value.length}`, 14, 33);
    
    // Cargar Logo Superior Derecho
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = 'http://localhost:3007/uploads/Logo/Logo.png';
    await new Promise((resolve) => {
      imgLogo.onload = resolve;
      imgLogo.onerror = resolve;
    });
    try { doc.addImage(imgLogo, 'PNG', 160, 10, 35, 15); } catch(e) {}
    
    // Línea divisoria
    doc.setDrawColor(226, 232, 240); // Slate 200
    doc.setLineWidth(0.5);
    doc.line(14, 38, 196, 38);

    autoTable(doc, {
      startY: 45,
      head: [headers],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [30, 41, 59], textColor: [255, 255, 255], fontStyle: 'bold' },
      alternateRowStyles: { fillColor: [248, 250, 252] },
      styles: { fontSize: 8, cellPadding: 3 },
    });

    // Pie de página (Numeración)
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      const pageHeight = doc.internal.pageSize.height;
      doc.setFontSize(8);
      doc.setTextColor(148, 163, 184); // Slate 400
      doc.text(`Página ${i} de ${totalPages} - INNOVA RRHH`, 196, pageHeight - 10, { align: 'right' });
    }

    doc.save('Directorio_Analitico_Empleados.pdf');
  } catch (error) {
    console.error("Error al generar PDF de Directorio:", error);
    Swal.fire('Error', 'No se pudo generar el PDF', 'error');
  }
}

const generarPDFIncidencias = async () => {
  if (incidenciasDatos.value.length === 0) {
    Swal.fire('Aviso', 'No hay incidencias para exportar.', 'warning');
    return;
  }

  try {
    const doc = new jsPDF();
    
    let tituloReporte = 'REPORTE DE INCIDENCIAS LABORALES';
    let headers = ['Código', 'Empleado', 'Fecha', 'Categoría', 'Prioridad', 'Estado'];
    let tableData = incidenciasDatos.value.map(inc => [
      `INC-${inc.id}`,
      inc.empleado_nombre || 'Desconocido',
      inc.fecha_creacion ? new Date(inc.fecha_creacion).toLocaleDateString() : 'N/A',
      inc.categoria || 'N/A',
      inc.prioridad || 'Media',
      inc.estado || 'Pendiente'
    ]);

    // Encabezado
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42); // Slate 900
    doc.setFont('helvetica', 'bold');
    doc.text(tituloReporte, 14, 20);
    
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); // Slate 500
    doc.setFont('helvetica', 'normal');
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 28);
    doc.text(`Total de registros: ${incidenciasDatos.value.length}`, 14, 33);
    
    // Cargar Logo Superior Derecho
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = 'http://localhost:3007/uploads/Logo/Logo.png';
    await new Promise((resolve) => {
      imgLogo.onload = resolve;
      imgLogo.onerror = resolve;
    });
    try { doc.addImage(imgLogo, 'PNG', 160, 10, 35, 15); } catch(e) {}
    
    // Línea divisoria
    doc.setDrawColor(226, 232, 240); // Slate 200
    doc.setLineWidth(0.5);
    doc.line(14, 38, 196, 38);

    autoTable(doc, {
      startY: 45,
      head: [headers],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [225, 29, 72], textColor: [255, 255, 255], fontStyle: 'bold' }, // Rose 600
      alternateRowStyles: { fillColor: [255, 241, 242] }, // Rose 50
      styles: { fontSize: 8, cellPadding: 3 },
    });

    // Pie de página (Numeración)
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      const pageHeight = doc.internal.pageSize.height;
      doc.setFontSize(8);
      doc.setTextColor(148, 163, 184); // Slate 400
      doc.text(`Página ${i} de ${totalPages} - INNOVA RRHH`, 196, pageHeight - 10, { align: 'right' });
    }

    doc.save('Reporte_Incidencias_Laborales.pdf');
  } catch (error) {
    console.error("Error al generar PDF de Incidencias:", error);
    Swal.fire('Error', 'No se pudo generar el PDF', 'error');
  }
}

const generarPDFLegales = async () => {
  if (legalesDatos.value.length === 0) {
    Swal.fire('Aviso', 'No hay documentos legales para exportar.', 'warning');
    return;
  }

  try {
    const doc = new jsPDF();
    const pageHeight = doc.internal.pageSize.height;
    
    // Encabezado
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42); // Slate 900
    doc.setFont('helvetica', 'bold');
    doc.text('REPORTE DE DOCUMENTACIÓN LEGAL', 14, 20);
    
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); // Slate 500
    doc.setFont('helvetica', 'normal');
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 28);
    doc.text(`Total de registros: ${legalesDatos.value.length}`, 14, 33);
    
    // Cargar Logo
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = 'http://localhost:3007/uploads/Logo/Logo.png';
    await new Promise((resolve) => {
      imgLogo.onload = resolve;
      imgLogo.onerror = resolve;
    });
    try { doc.addImage(imgLogo, 'PNG', 160, 10, 35, 15); } catch(e) {}
    
    // Línea divisoria
    doc.setDrawColor(226, 232, 240); // Slate 200
    doc.setLineWidth(0.5);
    doc.line(14, 38, 196, 38);

    let startY = 45;

    let headers = ['Documento', 'Categoría', 'Empleado', 'Expiración', 'Estado'];
    let tableData = legalesDatos.value.map(doc => {
      let estado = 'Vigente';
      if (doc.dias_restantes !== null && doc.dias_restantes < 0) estado = 'Vencido';
      else if (doc.dias_restantes !== null && doc.dias_restantes <= 30) estado = 'Por Vencer';
      
      return [
        doc.titulo || 'N/A',
        doc.categoria_nombre || 'N/A',
        doc.empleado_nombre ? `${doc.empleado_nombre} ${doc.empleado_apellido || ''}`.trim() : 'General',
        doc.fecha_expiracion ? new Date(doc.fecha_expiracion).toLocaleDateString() : 'N/A',
        estado
      ];
    });

    autoTable(doc, {
      startY: startY,
      head: [headers],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [79, 70, 229], textColor: [255, 255, 255], fontStyle: 'bold' }, // Indigo 600
      alternateRowStyles: { fillColor: [238, 242, 255] }, // Indigo 50
      styles: { fontSize: 8, cellPadding: 3 },
    });

    // Paginación
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(148, 163, 184); // Slate 400
      doc.text(`Página ${i} de ${totalPages} - INNOVA RRHH`, 196, pageHeight - 10, { align: 'right' });
    }

    doc.save('Reporte_Docs_Legales.pdf');
  } catch (error) {
    console.error("Error al generar PDF de Legales:", error);
    Swal.fire('Error', 'No se pudo generar el PDF', 'error');
  }
}

const generarPDFTickets = async () => {
  if (ticketsFiltrados.value.length === 0) {
    Swal.fire('Aviso', 'No hay tickets para exportar con los filtros actuales.', 'warning');
    return;
  }

  try {
    const doc = new jsPDF();
    const pageHeight = doc.internal.pageSize.height;
    
    // Encabezado
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('REPORTE DE SOPORTE Y TICKETS', 14, 20);
    
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139);
    doc.setFont('helvetica', 'normal');
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 28);
    doc.text(`Total de registros: ${ticketsFiltrados.value.length}`, 14, 33);
    
    // Cargar Logo
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = 'http://localhost:3007/uploads/Logo/Logo.png';
    await new Promise((resolve) => {
      imgLogo.onload = resolve;
      imgLogo.onerror = resolve;
    });
    try { doc.addImage(imgLogo, 'PNG', 160, 10, 35, 15); } catch(e) {}
    
    // Línea divisoria
    doc.setDrawColor(226, 232, 240);
    doc.setLineWidth(0.5);
    doc.line(14, 38, 196, 38);

    let startY = 45;

    let headers = ['ID', 'Asunto', 'Prioridad', 'Estado', 'Creado Por', 'Asignado', 'Respuestas', 'Fecha'];
    let tableData = ticketsFiltrados.value.map(ticket => {
      let asignado = ticket.asignado_usuario_nombre || ticket.asignado_empleado_nombre || 'Sin asignar';
      let creador = ticket.creadoPorNombre || (ticket.empleado_nombre ? `${ticket.empleado_nombre} ${ticket.empleado_apellido || ''}`.trim() : 'Desconocido');
      return [
        `#${ticket.id}`,
        ticket.asunto || 'N/A',
        ticket.prioridad || 'N/A',
        ticket.estado || 'N/A',
        creador,
        asignado,
        ticket.respuestas_count ? `${ticket.respuestas_count}` : '0',
        ticket.fecha_creacion ? new Date(ticket.fecha_creacion).toLocaleDateString() : 'N/A'
      ];
    });

    autoTable(doc, {
      startY: startY,
      head: [headers],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [5, 150, 105], textColor: [255, 255, 255], fontStyle: 'bold' }, // Emerald 600
      alternateRowStyles: { fillColor: [236, 253, 245] }, // Emerald 50
      styles: { fontSize: 8, cellPadding: 3 },
    });

    // Paginación
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(148, 163, 184); // Slate 400
      doc.text(`Página ${i} de ${totalPages} - INNOVA RRHH`, 196, pageHeight - 10, { align: 'right' });
    }

    doc.save('Reporte_Tickets.pdf');
  } catch (error) {
    console.error("Error al generar PDF de Tickets:", error);
    Swal.fire('Error', 'No se pudo generar el PDF', 'error');
  }
}

const generarPDFDashboard = async () => {
  try {
    const doc = new jsPDF();
    const pageHeight = doc.internal.pageSize.height;
    
    // Función para añadir Logo
    const loadLogo = () => {
      return new Promise((resolve) => {
        const img = new Image();
        img.crossOrigin = "Anonymous";
        img.src = 'http://localhost:3007/uploads/Logo/Logo.png';
        img.onload = () => resolve(img);
        img.onerror = () => resolve(null);
      });
    };

    const logoImg = await loadLogo();
    if (logoImg) {
      doc.addImage(logoImg, 'PNG', 14, 15, 25, 25);
    }
    
    // Encabezado
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42); // Slate 900
    doc.setFont('helvetica', 'bold');
    doc.text('REPORTE: DASHBOARD GENERAL', logoImg ? 45 : 14, 25);
    
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); // Slate 500
    doc.setFont('helvetica', 'normal');
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, logoImg ? 45 : 14, 32);

    // Línea divisoria
    doc.setDrawColor(226, 232, 240);
    doc.setLineWidth(0.5);
    doc.line(14, 45, 196, 45);

    let startY = 55;

    // Título de Métricas
    doc.setFontSize(12);
    doc.setTextColor(37, 99, 235); // Blue 600
    doc.setFont('helvetica', 'bold');
    doc.text('Métricas Clave de RRHH', 14, startY);
    startY += 8;

    // Preparar datos para AutoTable
    const kpiData = [
      ['Total de Empleados Registrados', stats.value.total || 0],
      ['Empleados Activos', stats.value.activos || 0],
      ['Empleados Inactivos', stats.value.inactivos || 0],
      ['Personal de Vacaciones', stats.value.de_vacaciones || 0],
      ['Faltas Acumuladas (Mes Actual)', stats.value.faltas_mes || 0],
      ['Documentos Legales Registrados', stats.value.doc_legales || 0],
      ['Contratos por Vencer (30 días)', stats.value.vencimientos || 0],
      ['Tickets de Soporte Pendientes', stats.value.tickets || 0]
    ];

    autoTable(doc, {
      startY: startY,
      head: [['Métrica / Indicador', 'Valor Registrado']],
      body: kpiData,
      theme: 'grid',
      headStyles: { fillColor: [37, 99, 235], textColor: [255, 255, 255], fontStyle: 'bold' }, // Blue 600
      alternateRowStyles: { fillColor: [239, 246, 255] }, // Blue 50
      styles: { fontSize: 10, cellPadding: 5 },
      columnStyles: {
        0: { fontStyle: 'bold' },
        1: { halign: 'center', fontStyle: 'bold', textColor: [15, 23, 42] }
      }
    });

    startY = doc.lastAutoTable.finalY + 15;

    // Distribución por Departamento
    doc.setFontSize(12);
    doc.setTextColor(37, 99, 235); // Blue 600
    doc.setFont('helvetica', 'bold');
    doc.text('Distribución por Departamento', 14, startY);
    startY += 8;

    const deptsData = deptStats.value.map(d => [d.departamento, d.cantidad]);

    autoTable(doc, {
      startY: startY,
      head: [['Departamento', 'Cantidad de Empleados']],
      body: deptsData,
      theme: 'grid',
      headStyles: { fillColor: [15, 23, 42], textColor: [255, 255, 255], fontStyle: 'bold' }, // Slate 900
      alternateRowStyles: { fillColor: [248, 250, 252] }, // Slate 50
      styles: { fontSize: 9, cellPadding: 4 },
      columnStyles: {
        1: { halign: 'center' }
      }
    });

    startY = doc.lastAutoTable.finalY + 15;
    if (startY > pageHeight - 40) { doc.addPage(); startY = 20; }

    // Resumen de Incidencias Laborales
    doc.setFontSize(12);
    doc.setTextColor(37, 99, 235); // Blue 600
    doc.setFont('helvetica', 'bold');
    doc.text('Últimas Incidencias Laborales Registradas', 14, startY);
    startY += 8;

    let tableDataInc = incidenciasDatos.value.slice(0, 15).map(inc => [
      `INC-${inc.id}`,
      inc.empleado_nombre || 'Desconocido',
      inc.fecha_creacion ? new Date(inc.fecha_creacion).toLocaleDateString('es-HN') : 'N/A',
      inc.categoria || 'N/A',
      inc.prioridad || 'Media',
      inc.estado || 'Pendiente'
    ]);
    if (tableDataInc.length === 0) tableDataInc = [['No hay incidencias registradas.', '', '', '', '', '']];

    autoTable(doc, {
      startY: startY,
      head: [['Código', 'Empleado', 'Fecha', 'Categoría', 'Prioridad', 'Estado']],
      body: tableDataInc,
      theme: 'grid',
      headStyles: { fillColor: [225, 29, 72], textColor: [255, 255, 255], fontStyle: 'bold' }, // Rose 600
      alternateRowStyles: { fillColor: [255, 241, 242] }, // Rose 50
      styles: { fontSize: 8, cellPadding: 3 }
    });

    // Paginación
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(148, 163, 184); // Slate 400
      doc.text(`Página ${i} de ${totalPages} - INNOVA RRHH`, 196, pageHeight - 10, { align: 'right' });
    }

    doc.save('Reporte_Ejecutivo_Dashboard.pdf');
  } catch (error) {
    console.error("Error al generar PDF de Dashboard:", error);
    Swal.fire('Error', 'No se pudo generar el PDF del Dashboard', 'error');
  }
}

const generarPDFControlTiempos = async () => {
  try {
    const doc = new jsPDF();
    const pageHeight = doc.internal.pageSize.height;
    
    // Encabezado
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42); // Slate 900
    doc.setFont('helvetica', 'bold');
    doc.text('REPORTE CONSOLIDADO: CONTROL DE TIEMPOS', 14, 20);
    
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); // Slate 500
    doc.setFont('helvetica', 'normal');
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 28);
    
    // Cargar Logo
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = 'http://localhost:3007/uploads/Logo/Logo.png';
    await new Promise((resolve) => {
      imgLogo.onload = resolve;
      imgLogo.onerror = resolve;
    });
    try { doc.addImage(imgLogo, 'PNG', 160, 10, 35, 15); } catch(e) {}
    
    // Línea divisoria
    doc.setDrawColor(226, 232, 240); // Slate 200
    doc.setLineWidth(0.5);
    doc.line(14, 38, 196, 38);

    let startY = 45;

    // 1. Proyecciones Vacaciones
    doc.setFontSize(12);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('1. Proyecciones de Vacaciones', 14, startY);
    startY += 5;

    let dataProy = proyeccionesVacaciones.value.map(v => [
      `${v.nombre} ${v.apellido}`,
      v.departamento || 'N/A',
      v.tipoSolicitud || 'N/A',
      v.fechaInicio ? new Date(v.fechaInicio).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A',
      v.fechaRegreso ? new Date(v.fechaRegreso).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A'
    ]);
    if (dataProy.length === 0) dataProy = [['No hay proyecciones.', '', '', '', '']];

    autoTable(doc, {
      startY: startY,
      head: [['Empleado', 'Departamento', 'Tipo', 'Inicio', 'Regreso']],
      body: dataProy,
      theme: 'grid',
      headStyles: { fillColor: [16, 185, 129], textColor: [255, 255, 255], fontStyle: 'bold' },
      styles: { fontSize: 8, cellPadding: 3 },
    });
    
    startY = doc.lastAutoTable.finalY + 15;
    if (startY > pageHeight - 40) { doc.addPage(); startY = 20; }

    // 2. Índice de Ausentismo
    doc.setFontSize(12);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('2. Índice de Ausentismo (Mes Actual)', 14, startY);
    startY += 5;

    let dataAus = ausentismoDatos.value.map(d => [
      d.departamento || 'N/A',
      d.total_empleados || 0,
      d.total_faltas || 0,
      d.dias_laborables_totales || 0,
      `${d.indice_ausentismo}%`
    ]);
    if (dataAus.length === 0) dataAus = [['No hay datos.', '', '', '', '']];

    autoTable(doc, {
      startY: startY,
      head: [['Departamento', 'Empleados', 'Faltas', 'Días Laborables', 'Índice (%)']],
      body: dataAus,
      theme: 'grid',
      headStyles: { fillColor: [225, 29, 72], textColor: [255, 255, 255], fontStyle: 'bold' },
      styles: { fontSize: 8, cellPadding: 3 },
    });

    startY = doc.lastAutoTable.finalY + 15;
    if (startY > pageHeight - 40) { doc.addPage(); startY = 20; }

    // 3. Saldos de Vacaciones
    doc.setFontSize(12);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('3. Saldos de Vacaciones', 14, startY);
    startY += 5;

    let dataSaldos = saldosDatos.value.map(s => [
      s.nombre || 'N/A',
      s.departamento || 'N/A',
      s.dias_acumulados || 0,
      s.dias_gozados || 0,
      s.dias_pagados || 0,
      s.saldo_pendiente || 0
    ]);
    if (dataSaldos.length === 0) dataSaldos = [['No hay datos.', '', '', '', '', '']];

    autoTable(doc, {
      startY: startY,
      head: [['Empleado', 'Departamento', 'Acumulados', 'Gozados', 'Pagados', 'Pendiente']],
      body: dataSaldos,
      theme: 'grid',
      headStyles: { fillColor: [59, 130, 246], textColor: [255, 255, 255], fontStyle: 'bold' },
      styles: { fontSize: 8, cellPadding: 3 },
    });

    // Paginación
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(148, 163, 184); // Slate 400
      doc.text(`Página ${i} de ${totalPages} - INNOVA RRHH`, 196, pageHeight - 10, { align: 'right' });
    }

    doc.save('Reporte_Control_Tiempos.pdf');
  } catch (error) {
    console.error("Error al generar PDF de Control de Tiempos:", error);
    Swal.fire('Error', 'No se pudo generar el PDF', 'error');
  }
}

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

// --- WIZARD GENERADOR DE REPORTES ---
const wizardPaso = ref(1)
const wizardCategoria = ref('') // 'empleados', 'incidencias', 'vacaciones', 'tickets'
const wizardFiltros = ref({
  busqueda: '',
  estado: 'todos',
  estado_caso: 'todos',
  departamento: 'todos'
})

const wizardCategoriaNombre = computed(() => {
  const cats = {
    'empleados': 'Directorio Analítico',
    'incidencias': 'Incidencias Laborales',
    'vacaciones': 'Vacaciones y Saldos',
    'tickets': 'Soporte y Tickets'
  }
  return cats[wizardCategoria.value] || 'Personalizado'
})

const wizardDatosBrutos = computed(() => {
  if (wizardCategoria.value === 'empleados') return empleados.value
  if (wizardCategoria.value === 'incidencias') return incidencias.value
  if (wizardCategoria.value === 'vacaciones') return saldosDatos.value || []
  if (wizardCategoria.value === 'tickets') return tickets.value
  return []
})

const wizardDatosFiltrados = computed(() => {
  let list = wizardDatosBrutos.value
  const q = wizardFiltros.value.busqueda.toLowerCase().trim()
  
  if (q !== '') {
    list = list.filter(item => {
      const vals = Object.values(item).map(v => String(v).toLowerCase())
      return vals.some(v => v.includes(q))
    })
  }
  
  if (wizardFiltros.value.departamento !== 'todos') {
    list = list.filter(item => {
      const depto = item.departamento || getNombreDepartamento(item.departamento_id)
      return depto === wizardFiltros.value.departamento
    })
  }

  if (wizardCategoria.value === 'empleados' && wizardFiltros.value.estado !== 'todos') {
    list = list.filter(item => item.estado == wizardFiltros.value.estado)
  }

  if ((wizardCategoria.value === 'incidencias' || wizardCategoria.value === 'tickets') && wizardFiltros.value.estado_caso !== 'todos') {
    if (wizardFiltros.value.estado_caso === 'Abierto') {
      list = list.filter(item => item.estado !== 'Cerrado' && item.estado !== 'Resuelto')
    } else if (wizardFiltros.value.estado_caso === 'Cerrado') {
      list = list.filter(item => item.estado === 'Cerrado' || item.estado === 'Resuelto')
    }
  }

  return list
})

const wizardColumnas = computed(() => {
  if (wizardCategoria.value === 'empleados') {
    return [
      { key: 'codigo_empleado', label: 'Código' },
      { key: 'nombre_completo', label: 'Empleado' },
      { key: 'departamento', label: 'Departamento' },
      { key: 'estado_str', label: 'Estado' }
    ]
  }
  if (wizardCategoria.value === 'incidencias') {
    return [
      { key: 'id', label: 'ID' },
      { key: 'empleado_nombre', label: 'Empleado' },
      { key: 'categoria', label: 'Categoría' },
      { key: 'prioridad', label: 'Prioridad' },
      { key: 'estado', label: 'Estado' }
    ]
  }
  if (wizardCategoria.value === 'vacaciones') {
    return [
      { key: 'nombre', label: 'Empleado' },
      { key: 'departamento', label: 'Departamento' },
      { key: 'dias_acumulados', label: 'Acumulados' },
      { key: 'saldo_pendiente', label: 'Saldo Pendiente' }
    ]
  }
  if (wizardCategoria.value === 'tickets') {
    return [
      { key: 'id', label: 'ID' },
      { key: 'asunto', label: 'Asunto' },
      { key: 'prioridad', label: 'Prioridad' },
      { key: 'estado', label: 'Estado' }
    ]
  }
  return []
})

const obtenerValorColumna = (row, key) => {
  if (key === 'nombre_completo') return `${row.nombre || ''} ${row.apellido || ''}`.trim()
  if (key === 'departamento' && !row.departamento) return getNombreDepartamento(row.departamento_id)
  if (key === 'estado_str') return row.estado == 1 ? 'Activo' : 'Inactivo'
  return row[key] !== null && row[key] !== undefined ? row[key] : 'N/A'
}

const wizardSiguiente = () => { if (wizardPaso.value < 4) wizardPaso.value++ }
const wizardAnterior = () => { if (wizardPaso.value > 1) wizardPaso.value-- }
const wizardReiniciar = () => {
  wizardPaso.value = 1
  wizardCategoria.value = ''
  wizardFiltros.value = { busqueda: '', estado: 'todos', estado_caso: 'todos', departamento: 'todos' }
}

const generarPDFWizard = () => {
  try {
    const doc = new jsPDF()
    const pageWidth = doc.internal.pageSize.width
    const pageHeight = doc.internal.pageSize.height
    let startY = 30

    // Header
    doc.setFillColor(15, 23, 42)
    doc.rect(0, 0, pageWidth, 20, 'F')
    doc.setTextColor(255, 255, 255)
    doc.setFontSize(16)
    doc.setFont('helvetica', 'bold')
    doc.text('INNOVA RRHH', 14, 14)
    
    doc.setTextColor(203, 213, 225)
    doc.setFontSize(10)
    doc.text(`Reporte: ${wizardCategoriaNombre.value}`, pageWidth - 14, 14, { align: 'right' })

    // Info
    doc.setTextColor(15, 23, 42)
    doc.setFontSize(14)
    doc.text('Generador de Reportes Asistido', 14, startY)
    startY += 8
    doc.setFontSize(10)
    doc.setTextColor(71, 85, 105)
    doc.text(`Total Registros: ${wizardDatosFiltrados.value.length}`, 14, startY)
    startY += 4
    doc.text(`Fecha de emisión: ${new Date().toLocaleString()}`, 14, startY)
    startY += 10

    const heads = [wizardColumnas.value.map(c => c.label)]
    const body = wizardDatosFiltrados.value.map(row => wizardColumnas.value.map(col => obtenerValorColumna(row, col.key)))

    autoTable(doc, {
      startY: startY,
      head: heads,
      body: body,
      theme: 'grid',
      headStyles: { fillColor: [147, 51, 234], textColor: [255, 255, 255], fontStyle: 'bold' },
      styles: { fontSize: 8, cellPadding: 3 },
      alternateRowStyles: { fillColor: [248, 250, 252] }
    })

    const totalPages = doc.internal.getNumberOfPages()
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i)
      doc.setFontSize(8)
      doc.setTextColor(148, 163, 184)
      doc.text(`Página ${i} de ${totalPages} - INNOVA RRHH`, 196, pageHeight - 10, { align: 'right' })
    }

    doc.save(`Reporte_Wizard_${wizardCategoria.value}_${new Date().toISOString().split('T')[0]}.pdf`)
    Swal.fire('¡Éxito!', 'El reporte PDF se ha generado correctamente.', 'success')
  } catch (error) {
    console.error('Error generando PDF Wizard', error)
    Swal.fire('Error', 'Hubo un error al generar el PDF', 'error')
  }
}

const exportarCSVWizard = () => {
  exportarCSV(wizardDatosFiltrados.value, `Reporte_Wizard_${wizardCategoria.value}`)
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
    const usuarioID = localStorage.getItem('usuarioID')
    const urlMenu = usuarioID 
      ? `http://localhost:3007/api/menu/${rolID.value}?usuario_id=${usuarioID}`
      : `http://localhost:3007/api/menu/${rolID.value}`
    const m = await axios.get(urlMenu)
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
  cargarIncidencias(false)
  cargarLegales(false)

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
    cargarIncidencias(true)
    cargarLegales(true)
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