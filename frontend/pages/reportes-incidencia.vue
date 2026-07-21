<template>
  <div class="min-h-screen bg-[#f1f5f9] flex font-sans">
    <!-- SIDEBAR DINÁMICO -->
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

    <!-- CONTENIDO PRINCIPAL -->
    <main class="flex-1 ml-64 p-6 overflow-y-auto">
      <!-- HEADER -->
      <header class="mb-6 flex justify-between items-center bg-white px-6 py-4 rounded-2xl shadow-sm border border-slate-100">
        <div>
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-red-500 to-rose-600 flex items-center justify-center shadow-lg shadow-red-500/25">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/></svg>
            </div>
            <div>
              <h1 class="text-xl font-black text-slate-800 tracking-tight">Incidencias Laborales</h1>
              <p class="text-slate-400 text-xs font-medium mt-0.5">Gestión de faltas, incidentes y reportes del personal</p>
            </div>
          </div>
        </div>
        <div class="flex items-center gap-3">
          <button @click="abrirModalNuevo"
            class="flex items-center gap-2 bg-gradient-to-r from-red-500 to-rose-600 text-white px-5 py-2.5 rounded-xl font-bold text-xs uppercase tracking-wider hover:shadow-lg hover:shadow-red-500/25 hover:-translate-y-0.5 transition-all duration-200">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" d="M12 5v14m-7-7h14"/></svg>
            Nuevo Reporte
          </button>

          <div class="relative w-full md:w-auto flex justify-end">
            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-4 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors no-print">
              <div v-if="fotoUsuario" class="h-9 w-9 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-slate-100">
                <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
              </div>
              <div v-else class="h-9 w-9 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-sm ring-2 ring-slate-100 uppercase">
                {{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}
              </div>
              <div class="flex flex-col text-left">
                <span class="text-[9px] text-slate-400 font-bold uppercase tracking-widest">Sesión</span>
                <span class="text-sm font-bold text-slate-800 leading-tight">{{ nombreUsuario || 'Cargando...' }}</span>
              </div>
              <svg class="w-3.5 h-3.5 text-slate-400 transition-transform" :class="{'rotate-180': dropdownPerfilAbierto}" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
            </div>

            <!-- Dropdown Menu -->
            <div v-if="dropdownPerfilAbierto" class="absolute right-0 mt-14 w-64 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50 animate-in slide-in-from-top-2 duration-200 no-print">
              <div class="p-5 border-b border-slate-100 bg-slate-50 flex items-center gap-4">
                <div v-if="fotoUsuario" class="h-12 w-12 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-white shadow-sm shrink-0">
                  <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-12 w-12 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-xl ring-2 ring-white shadow-sm shrink-0 uppercase">
                  {{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}
                </div>
                <div>
                  <p class="font-black text-slate-800 text-sm leading-tight">{{ nombreUsuario || 'Cargando...' }}</p>
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
            <div v-if="dropdownPerfilAbierto" @click="dropdownPerfilAbierto = false" class="fixed inset-0 z-40"></div>
          </div>
        </div>
      </header>

      <!-- KPI Summary Cards — Premium Vibrant Style -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">

        <!-- Tarjeta Pendientes -->
        <div @click="aplicarFiltro('estado-Pendiente')"
             class="group relative rounded-2xl p-4 cursor-pointer transition-all duration-300 overflow-hidden bg-gradient-to-br from-amber-400 to-orange-500"
             :class="filtroActivo === 'estado-Pendiente' ? 'shadow-lg shadow-orange-500/40 scale-[1.02] ring-2 ring-white/50 ring-offset-1 ring-offset-orange-50' : 'shadow-sm hover:shadow-lg hover:shadow-orange-500/20 hover:-translate-y-0.5'"
        >
          <div class="absolute right-0 top-0 -mr-6 -mt-6 w-24 h-24 rounded-full bg-white/20 blur-xl transition-transform group-hover:scale-150"></div>
          <div class="absolute right-2 bottom-2 text-white/20 transition-transform duration-500 group-hover:scale-110 group-hover:rotate-12">
            <svg class="w-12 h-12" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path stroke-linecap="round" d="M12 6v6l4 2"/></svg>
          </div>
          
          <div class="relative z-10 flex flex-col h-full justify-between">
            <div class="flex justify-between items-start">
              <div class="flex flex-col gap-1">
                <h3 class="text-white/90 uppercase text-[9px] font-extrabold tracking-widest">Pendientes</h3>
                <span v-if="filtroActivo === 'estado-Pendiente'" class="bg-white/20 text-white text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded-full backdrop-blur-md border border-white/20 shadow-sm w-max">Activo</span>
              </div>
              <span class="text-sm p-1.5 rounded-xl backdrop-blur-sm shadow-sm bg-white/20 text-white">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path stroke-linecap="round" d="M12 6v6l4 2"/></svg>
              </span>
            </div>
            <div class="mt-2">
              <p class="text-2xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.pendiente }}</p>
              <p class="text-[9px] text-white/80 font-bold mt-1">Requieren atención</p>
            </div>
          </div>
        </div>

        <!-- Tarjeta En Proceso -->
        <div @click="aplicarFiltro('estado-En Proceso')"
             class="group relative rounded-2xl p-4 cursor-pointer transition-all duration-300 overflow-hidden bg-gradient-to-br from-blue-500 to-indigo-600"
             :class="filtroActivo === 'estado-En Proceso' ? 'shadow-lg shadow-blue-500/40 scale-[1.02] ring-2 ring-white/50 ring-offset-1 ring-offset-blue-50' : 'shadow-sm hover:shadow-lg hover:shadow-blue-500/20 hover:-translate-y-0.5'"
        >
          <div class="absolute right-0 top-0 -mr-6 -mt-6 w-24 h-24 rounded-full bg-white/20 blur-xl transition-transform group-hover:scale-150"></div>
          <div class="absolute right-2 bottom-2 text-white/20 transition-transform duration-500 group-hover:scale-110 group-hover:rotate-12">
            <svg class="w-12 h-12" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
          </div>
          
          <div class="relative z-10 flex flex-col h-full justify-between">
            <div class="flex justify-between items-start">
              <div class="flex flex-col gap-1">
                <h3 class="text-white/90 uppercase text-[9px] font-extrabold tracking-widest">En Proceso</h3>
                <span v-if="filtroActivo === 'estado-En Proceso'" class="bg-white/20 text-white text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded-full backdrop-blur-md border border-white/20 shadow-sm w-max">Activo</span>
              </div>
              <span class="text-sm p-1.5 rounded-xl backdrop-blur-sm shadow-sm bg-white/20 text-white">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
              </span>
            </div>
            <div class="mt-2">
              <p class="text-2xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.enProceso }}</p>
              <p class="text-[9px] text-white/80 font-bold mt-1">En seguimiento</p>
            </div>
          </div>
        </div>

        <!-- Tarjeta Resueltos -->
        <div @click="aplicarFiltro('estado-Resuelto')"
             class="group relative rounded-2xl p-4 cursor-pointer transition-all duration-300 overflow-hidden bg-gradient-to-br from-emerald-400 to-teal-500"
             :class="filtroActivo === 'estado-Resuelto' ? 'shadow-lg shadow-emerald-500/40 scale-[1.02] ring-2 ring-white/50 ring-offset-1 ring-offset-emerald-50' : 'shadow-sm hover:shadow-lg hover:shadow-emerald-500/20 hover:-translate-y-0.5'"
        >
          <div class="absolute right-0 top-0 -mr-6 -mt-6 w-24 h-24 rounded-full bg-white/20 blur-xl transition-transform group-hover:scale-150"></div>
          <div class="absolute right-2 bottom-2 text-white/20 transition-transform duration-500 group-hover:scale-110 group-hover:rotate-12">
            <svg class="w-12 h-12" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
          </div>
          
          <div class="relative z-10 flex flex-col h-full justify-between">
            <div class="flex justify-between items-start">
              <div class="flex flex-col gap-1">
                <h3 class="text-white/90 uppercase text-[9px] font-extrabold tracking-widest">Resueltos</h3>
                <span v-if="filtroActivo === 'estado-Resuelto'" class="bg-white/20 text-white text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded-full backdrop-blur-md border border-white/20 shadow-sm w-max">Cerrado</span>
              </div>
              <span class="text-sm p-1.5 rounded-xl backdrop-blur-sm shadow-sm bg-white/20 text-white">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
              </span>
            </div>
            <div class="mt-2">
              <p class="text-2xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.resuelto }}</p>
              <p class="text-[9px] text-white/80 font-bold mt-1">Casos cerrados</p>
            </div>
          </div>
        </div>

        <!-- Tarjeta Total -->
        <div @click="aplicarFiltro('todas')"
             class="group relative rounded-2xl p-4 cursor-pointer transition-all duration-300 overflow-hidden bg-gradient-to-br from-violet-500 to-fuchsia-600"
             :class="filtroActivo === 'todas' ? 'shadow-lg shadow-violet-500/40 scale-[1.02] ring-2 ring-white/50 ring-offset-1 ring-offset-violet-50' : 'shadow-sm hover:shadow-lg hover:shadow-violet-500/20 hover:-translate-y-0.5'"
        >
          <div class="absolute right-0 top-0 -mr-6 -mt-6 w-24 h-24 rounded-full bg-white/20 blur-xl transition-transform group-hover:scale-150"></div>
          <div class="absolute right-2 bottom-2 text-white/20 transition-transform duration-500 group-hover:scale-110 group-hover:rotate-12">
            <svg class="w-12 h-12" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
          </div>
          
          <div class="relative z-10 flex flex-col h-full justify-between">
            <div class="flex justify-between items-start">
              <div class="flex flex-col gap-1">
                <h3 class="text-white/90 uppercase text-[9px] font-extrabold tracking-widest">Total Reportes</h3>
                <span v-if="filtroActivo === 'todas'" class="bg-white/20 text-white text-[9px] font-black uppercase tracking-widest px-2 py-0.5 rounded-full backdrop-blur-md border border-white/20 shadow-sm w-max">Total</span>
              </div>
              <span class="text-sm p-1.5 rounded-xl backdrop-blur-sm shadow-sm bg-white/20 text-white">
                <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
              </span>
            </div>
            <div class="mt-2">
              <p class="text-2xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.todas }}</p>
              <p class="text-[9px] text-white/80 font-bold mt-1">Registro histórico</p>
            </div>
          </div>
        </div>

      </div>

      <div class="flex gap-6 items-start">
        <!-- Sidebar del Módulo -->
        <ReportesSidebar :counts="sidebarCounts" :activeFilter="filtroActivo" :reportesList="unfilteredReportesForCounts" @filter-changed="aplicarFiltro" @categorias-actualizadas="actualizarCategorias" class="shrink-0 rounded-2xl shadow-sm border border-slate-200/80 overflow-hidden" style="height: auto;" />

        <div class="flex-1 flex flex-col gap-6">
          <!-- TABLA DE REPORTES -->
          <div class="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
            <!-- Toolbar -->
            <div class="px-5 pt-4 pb-0 border-b border-slate-100">
              <div class="flex justify-between items-center mb-4">
                <div class="flex items-center gap-3">
                  <h2 class="text-sm font-black text-slate-800 tracking-tight uppercase">Historial de Reportes</h2>
                  <span class="text-[10px] font-bold text-white bg-red-500 px-2 py-0.5 rounded-full tabular-nums shadow-sm shadow-red-200">{{ misReportes.length }}</span>
                </div>
                <div class="flex items-center gap-2">
                  <button @click="generarPDF" :disabled="misReportes.length === 0" class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 disabled:opacity-40 text-slate-700 font-bold text-[11px] uppercase tracking-wider transition-all" title="Exportar a PDF">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                    PDF
                  </button>
                  <button @click="fetchReportes" class="w-7 h-7 rounded-lg bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-400 hover:text-red-500 hover:border-red-200 hover:bg-red-50 transition-all" title="Actualizar">
                    <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                  </button>
                </div>
              </div>
              
              <!-- Search & Filters Bar -->
              <div class="flex gap-2 items-center pb-4">
                <!-- Search -->
                <div class="flex-1 relative group">
                  <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-300 group-focus-within:text-red-400 transition-colors" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path stroke-linecap="round" d="M21 21l-4.35-4.35"/></svg>
                  <input v-model="searchTrm" type="text" placeholder="Buscar por tema, empleado, identidad..."
                    class="w-full pl-9 pr-4 py-2 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-red-300 focus:ring-2 focus:ring-red-500/10 text-sm font-medium text-slate-700 transition-all placeholder:text-slate-400">
                </div>
                
                <!-- Priority Filter -->
                <div class="relative">
                  <select v-model="priorityFilter" class="appearance-none bg-slate-50 border border-slate-200 rounded-xl pl-3 pr-7 py-2 outline-none focus:border-red-300 text-sm font-medium text-slate-600 transition-all cursor-pointer">
                    <option value="todas">Prioridad</option>
                    <option value="Urgente">Urgente</option>
                    <option value="Alta">Alta</option>
                    <option value="Media">Media</option>
                    <option value="Baja">Baja</option>
                  </select>
                  <svg class="absolute right-2 top-1/2 -translate-y-1/2 w-3 h-3 text-slate-400 pointer-events-none" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
                </div>

                <!-- Sort -->
                <div class="relative">
                  <select v-model="sortOption" class="appearance-none bg-slate-50 border border-slate-200 rounded-xl pl-3 pr-7 py-2 outline-none focus:border-red-300 text-sm font-medium text-slate-600 transition-all cursor-pointer">
                    <option value="reciente">Más reciente</option>
                    <option value="antiguo">Más antiguo</option>
                    <option value="prioridad">Por prioridad</option>
                    <option value="actualizado">Actualizado</option>
                  </select>
                  <svg class="absolute right-2 top-1/2 -translate-y-1/2 w-3 h-3 text-slate-400 pointer-events-none" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
                </div>
              </div>
            </div>
            
            <!-- Loading -->
            <div v-if="loadingFetch" class="flex flex-col items-center justify-center py-24">
              <div class="relative">
                <div class="animate-spin rounded-full h-10 w-10 border-2 border-slate-200 border-t-red-500"></div>
              </div>
              <span class="text-slate-400 font-semibold text-xs tracking-widest uppercase mt-5">Cargando reportes...</span>
            </div>

            <!-- Empty State -->
            <div v-else-if="reportesPaginados.length === 0" class="flex flex-col items-center justify-center py-24 text-center px-4">
              <div class="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mb-4 border border-slate-100">
                <svg class="w-7 h-7 text-slate-300" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z"/></svg>
              </div>
              <h3 class="text-slate-700 font-bold text-base mb-1.5">Sin resultados</h3>
              <p class="text-slate-400 text-sm max-w-xs leading-relaxed">No se encontraron reportes con los filtros actuales<span v-if="searchTrm"> o la búsqueda "{{ searchTrm }}"</span>.</p>
            </div>

            <!-- Report Rows -->
            <div v-else>
              <div v-for="reporte in reportesPaginados" :key="reporte.id"
                class="px-5 py-4 hover:bg-slate-50/60 transition-all duration-200 cursor-pointer group relative border-b border-slate-50 last:border-0"
                :class="(reporte.prioridad || '').toUpperCase() === 'URGENTE' ? 'border-l-[3px] border-l-red-400' : 'border-l-[3px] border-l-transparent'"
                @click="verDetalle(reporte.id)">
                <div class="flex items-start gap-4">

                  <!-- Avatar Asignado -->
                  <div class="shrink-0 mt-0.5">
                    <div class="h-9 w-9 rounded-xl overflow-hidden border border-slate-200 shadow-sm" :title="`Asignado: ${reporte.asignado_usuario_nombre || 'Sin asignar'}`">
                      <img v-if="reporte.asignado_usuario_foto" :src="`${$config.public.apiBase}${reporte.asignado_usuario_foto}`" class="w-full h-full object-cover" />
                      <div v-else class="w-full h-full bg-gradient-to-br from-slate-100 to-slate-200 flex items-center justify-center text-slate-400 font-bold text-[10px] uppercase">
                        {{ (reporte.asignado_usuario_nombre || '?').charAt(0) }}
                      </div>
                    </div>
                  </div>

                  <!-- Content -->
                  <div class="flex-1 min-w-0">
                    <div class="flex items-center gap-2 mb-1.5 flex-wrap">
                      <span class="text-[11px] font-bold text-slate-400 tabular-nums">#INC-{{ String(reporte.id).padStart(3, '0') }}</span>
                      <span :class="['inline-flex items-center gap-1 px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wide', prioridadClass(reporte.prioridad)]">
                        <span class="w-1.5 h-1.5 rounded-full flex-shrink-0" :class="[(reporte.prioridad || '').toUpperCase() === 'URGENTE' ? 'animate-ping' : '', prioridadDotClass(reporte.prioridad)]"></span>
                        {{ reporte.prioridad || 'Media' }}
                      </span>
                      <span :class="['inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-bold uppercase tracking-wide', claseEstado(reporte.estado)]">
                        {{ reporte.estado || 'Pendiente' }}
                      </span>
                    </div>
                    <h3 class="text-slate-800 font-semibold text-[14px] leading-snug group-hover:text-red-600 transition-colors truncate mb-1">
                      {{ reporte.tema || 'Sin tema' }}
                    </h3>
                    <div class="flex items-center gap-2 mb-1 mt-1">
                      <div class="flex -space-x-2 shrink-0">
                        <div v-for="emp in (reporte.empleados_detalles || [{nombre: reporte.empleado_nombre, foto: reporte.empleado_foto}])" :key="emp.identidad || Math.random()" 
                             class="w-6 h-6 rounded-full overflow-hidden border-2 border-white bg-slate-100 flex items-center justify-center font-bold text-slate-500 text-[9px] shadow-sm relative z-10" 
                             :title="emp.nombre">
                          <img v-if="emp.foto" :src="`${$config.public.apiBase}${emp.foto}`" class="w-full h-full object-cover" />
                          <span v-else>{{ emp.nombre ? emp.nombre.charAt(0) : '?' }}</span>
                        </div>
                      </div>
                      <p class="text-slate-400 text-xs leading-relaxed line-clamp-1">
                        <span class="font-medium text-slate-500">{{ reporte.empleado_nombre || 'Desconocido' }} {{ reporte.empleado_apellido || '' }}</span>
                        <span class="mx-1.5 text-slate-300">·</span>
                        {{ reporte.descripcion }}
                      </p>
                    </div>
                  </div>

                  <!-- Meta Right -->
                  <div class="shrink-0 flex flex-col items-end gap-2 text-right">
                    <span class="text-[11px] text-slate-400 font-medium tabular-nums whitespace-nowrap" :title="formatearFecha(reporte.fecha_creacion)">{{ tiempoRelativo(reporte.fecha_creacion) }}</span>
                    <div class="flex items-center gap-3 text-[11px] text-slate-400">
                      <span class="flex items-center gap-1" :title="reporte.categoria || 'General'">
                        <svg class="w-3 h-3 text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"/></svg>
                        {{ reporte.categoria || 'General' }}
                      </span>
                      <span class="flex items-center gap-1">
                        <svg class="w-3 h-3 text-slate-300" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"/></svg>
                        {{ reporte.respuestas_count || 0 }}
                      </span>
                      <button v-if="permisosModulo.puedeEliminar" @click.stop="eliminarReporte(reporte.id)" class="opacity-0 group-hover:opacity-100 p-1 text-slate-400 hover:text-red-500 hover:bg-red-50 transition-all rounded-md" title="Eliminar">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
                      </button>
                    </div>
                  </div>

                </div>
              </div>
            </div>
            
            <!-- Paginación -->
            <div class="flex flex-col sm:flex-row justify-between items-center px-5 py-4 bg-slate-50/50 border-t border-slate-100 gap-3" v-if="totalPaginas > 1">
              <span class="text-[11px] font-semibold text-slate-400 tabular-nums">Página {{ paginaActual }} de {{ totalPaginas }} — {{ misReportes.length }} reportes</span>
              <div class="flex items-center gap-1.5">
                <button @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1" 
                  class="w-8 h-8 rounded-lg bg-white border border-slate-200 flex items-center justify-center text-slate-400 hover:bg-slate-50 hover:text-slate-600 transition-all text-sm disabled:opacity-40 disabled:cursor-not-allowed">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" d="M15 19l-7-7 7-7"/></svg>
                </button>
                
                <button v-for="pag in paginasVisibles" :key="pag" @click="pag !== '...' && cambiarPagina(pag)"
                  :disabled="pag === '...'"
                  :class="['w-8 h-8 rounded-lg text-xs font-bold transition-all', 
                    pag === paginaActual ? 'bg-gradient-to-r from-red-500 to-rose-600 text-white shadow-md shadow-red-500/20' : 
                    pag === '...' ? 'text-slate-400 cursor-default' :
                    'bg-white border border-slate-200 text-slate-500 hover:bg-slate-50']">
                  {{ pag }}
                </button>

                <button @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas" 
                  class="w-8 h-8 rounded-lg bg-white border border-slate-200 flex items-center justify-center text-slate-400 hover:bg-slate-50 hover:text-slate-600 transition-all text-sm disabled:opacity-40 disabled:cursor-not-allowed">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" d="M9 5l7 7-7 7"/></svg>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Modal Perfil -->
      <div v-if="modalAbiertoPerfil" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex justify-center items-center p-4">
        <div class="bg-white w-full max-w-md overflow-hidden rounded-2xl shadow-2xl animate-in fade-in zoom-in duration-200">
          <div class="p-6 border-b bg-white flex justify-between items-center">
            <h2 class="text-xl font-extrabold text-slate-800 tracking-tight flex items-center gap-2">
              <span class="text-lg">👤</span> Perfil de Usuario
            </h2>
            <button @click="cerrarModalPerfil" class="w-8 h-8 rounded-lg bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-400 hover:text-red-500 hover:border-red-200 hover:bg-red-50 transition-all">
              <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>

          <form @submit.prevent="cambiarPassword" class="p-8 space-y-6">
            <div class="mb-6 flex flex-col items-center">
              <div class="relative group cursor-pointer" @click="triggerFileInputPerfil">
                <div v-if="fotoUsuario" class="h-20 w-20 rounded-full flex items-center justify-center overflow-hidden ring-4 ring-slate-100 shadow-lg mb-4">
                  <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-20 w-20 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-3xl ring-4 ring-slate-100 uppercase mb-4 shadow-lg">
                  {{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}
                </div>
                <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity rounded-full bg-black/50 mb-4">
                  <span class="text-white text-[10px] font-bold px-2 py-1 text-center">Cambiar<br>Foto</span>
                </div>
                <input type="file" ref="fileInputPerfil" class="hidden" accept="image/*" @change="uploadFotoPerfil" />
              </div>
              <h3 class="text-xl font-black text-slate-900">{{ nombreUsuario }}</h3>
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

    <!-- Modal Nuevo Reporte -->
    <div v-if="mostrarModal" class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 overflow-y-auto animate-in fade-in duration-200">
      <div class="bg-white rounded-2xl shadow-2xl border border-slate-100 w-full max-w-lg my-8 transform transition-all animate-in zoom-in-95">
        <header class="p-5 border-b border-slate-100 flex justify-between items-center bg-gradient-to-r from-red-50/80 to-white rounded-t-2xl">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-gradient-to-br from-red-500 to-rose-600 flex items-center justify-center shadow-lg shadow-red-500/20">
              <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"/></svg>
            </div>
            <div>
              <h3 class="text-lg font-extrabold text-slate-800 tracking-tight">Nuevo Reporte</h3>
              <p class="text-[10px] text-slate-400 font-medium">Registrar incidencia laboral</p>
            </div>
          </div>
          <button @click="cerrarModal" class="w-8 h-8 bg-white border border-slate-200 rounded-lg flex items-center justify-center text-slate-400 hover:text-red-500 hover:border-red-200 hover:bg-red-50 transition-all">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
        </header>

        <div class="p-6">
          <form @submit.prevent="crearReporte" class="space-y-5">
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5 pl-0.5">Número de Identidad (Reportado)</label>
              <div v-for="(id, index) in nuevoReporte.identidades" :key="index" class="flex gap-2 mb-2">
                <input :value="nuevoReporte.identidades[index]" type="text" placeholder="Ej: 0801-1990-12345" required
                  @input="e => formatIdentidad(e, index)" maxlength="15"
                  class="flex-1 p-3.5 bg-slate-50/80 border border-slate-200 rounded-xl outline-none focus:border-red-400 focus:ring-3 focus:ring-red-500/10 text-slate-800 font-semibold text-sm transition-all placeholder:text-slate-400">
                <button v-if="nuevoReporte.identidades.length > 1" type="button" @click="nuevoReporte.identidades.splice(index, 1)" class="px-3 bg-slate-100 text-red-500 rounded-xl hover:bg-red-50 transition-colors font-bold flex items-center justify-center">
                  &times;
                </button>
              </div>
              <button type="button" @click="nuevoReporte.identidades.push('')" class="text-[10px] text-blue-500 font-bold hover:text-blue-600 transition-colors uppercase tracking-widest mt-1">
                + Agregar otra persona
              </button>
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5 pl-0.5">Categoría</label>
                <div class="relative">
                  <select v-model="nuevoReporte.categoria" class="appearance-none w-full p-3.5 bg-slate-50/80 border border-slate-200 rounded-xl outline-none focus:border-red-400 focus:ring-3 focus:ring-red-500/10 text-slate-800 font-semibold text-sm transition-all cursor-pointer pr-9">
                    <option v-for="cat in categoriasActivas" :key="cat.id" :value="cat.nombre">{{ cat.nombre }}</option>
                  </select>
                  <svg class="absolute right-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-400 pointer-events-none" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
                </div>
              </div>
              <div>
                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5 pl-0.5">Prioridad</label>
                <div class="relative">
                  <select v-model="nuevoReporte.prioridad" class="appearance-none w-full p-3.5 bg-slate-50/80 border border-slate-200 rounded-xl outline-none focus:border-red-400 focus:ring-3 focus:ring-red-500/10 text-slate-800 font-semibold text-sm transition-all cursor-pointer pr-9">
                    <option value="Baja">Baja</option>
                    <option value="Media">Media</option>
                    <option value="Alta">Alta</option>
                    <option value="Urgente">Urgente</option>
                  </select>
                  <svg class="absolute right-3 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-400 pointer-events-none" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
                </div>
              </div>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5 pl-0.5">Tema / Asunto</label>
              <input v-model="nuevoReporte.tema" type="text" placeholder="Breve resumen de la incidencia" required
                class="w-full p-3.5 bg-slate-50/80 border border-slate-200 rounded-xl outline-none focus:border-red-400 focus:ring-3 focus:ring-red-500/10 text-slate-800 font-semibold text-sm transition-all placeholder:text-slate-400">
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5 pl-0.5">Descripción Detallada</label>
              <textarea v-model="nuevoReporte.descripcion" class="w-full p-3.5 bg-slate-50/80 border border-slate-200 rounded-xl outline-none focus:border-red-400 focus:ring-3 focus:ring-red-500/10 text-slate-800 text-sm transition-all resize-none placeholder:text-slate-400" rows="3" placeholder="Detalla la incidencia aquí..." required></textarea>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1.5 pl-0.5">Evidencia (Opcional)</label>
              <div class="relative">
                <input type="file" ref="fileInputRef" @change="handleFileUpload"
                  class="w-full p-3 bg-slate-50/80 border border-slate-200 rounded-xl outline-none focus:border-red-400 text-slate-600 font-medium text-sm transition-all cursor-pointer file:mr-3 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-[10px] file:font-bold file:uppercase file:tracking-wider file:bg-slate-200 file:text-slate-700 hover:file:bg-slate-300 file:transition-colors file:cursor-pointer">
              </div>
            </div>
            
            <div class="flex justify-end gap-3 pt-5 border-t border-slate-100">
              <button type="button" @click="cerrarModal" class="px-5 py-3 text-slate-400 hover:bg-slate-50 rounded-xl font-bold uppercase tracking-wider text-xs transition-colors">Cancelar</button>
              <button type="submit" :disabled="loading" class="px-7 py-3 bg-gradient-to-r from-red-500 to-rose-600 text-white rounded-xl font-bold uppercase tracking-wider text-xs shadow-lg shadow-red-500/20 hover:shadow-xl hover:shadow-red-500/30 hover:-translate-y-0.5 transition-all disabled:opacity-50 disabled:hover:translate-y-0">
                {{ loading ? 'Enviando...' : 'Crear Reporte' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <!-- Modal Detalle Reporte -->
    <TicketDetailReportesIncidencia v-if="selectedTicketId" :id="selectedTicketId" @close="cerrarDetalle" />
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import { useRouter, useRoute } from 'vue-router'
import jsPDF from 'jspdf'
import 'jspdf-autotable'
import Swal from 'sweetalert2'
import TicketDetailReportesIncidencia from '~/pages/TicketDetailReportesIncidencia.vue'
import { io } from 'socket.io-client'

let socketInstance = null

const selectedTicketId = ref(null)

const router = useRouter()
const route = useRoute()

const cerrarDetalle = () => {
  selectedTicketId.value = null
  fetchReportes()
  router.replace({ query: {} })
}

// Variables de sesión y layout
const nombreUsuario = ref('')
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const fotoUsuario = ref(null)
const usuarioActualId = ref(null)
const menuUsuario = ref([])
const dropdownPerfilAbierto = ref(false)
const modalAbiertoPerfil = ref(false)

const formPassword = ref({ actual: '', nueva: '', confirmar: '' })
const loadingPassword = ref(false)
const fileInputPerfil = ref(null)

const permisosModulo = ref({ puedeVer: 1, puedeCrear: 1, puedeEditar: 1, puedeEliminar: 1 })

const triggerFileInputPerfil = () => { fileInputPerfil.value.click() }
const uploadFotoPerfil = async (event) => {
  const file = event.target.files[0]
  if (!file) return
  const formData = new FormData()
  formData.append('foto', file)
  try {
    const res = await axios.post(`/api/auth/${usuarioActualId.value}/foto`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
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
    const res = await axios.put(`/api/auth/${usuarioActualId.value}/password`, {
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

// Variables del Módulo Reportes
const mostrarModal = ref(false)
const loading = ref(false)
const loadingFetch = ref(true)
const misReportes = ref([])
const todosLosReportes = ref([])

const unfilteredReportesForCounts = ref([])

const categoriasActivas = ref([])

const actualizarCategorias = (categorias) => {
  categoriasActivas.value = categorias.filter(c => c.activa)
  if (categoriasActivas.value.length > 0 && !categoriasActivas.value.find(c => c.nombre === nuevoReporte.value.categoria)) {
    nuevoReporte.value.categoria = categoriasActivas.value[0].nombre
  }
}

const sidebarCounts = ref({
  todas: 0,
  misEntradas: 0,
  asignado: 0,
  sinAsignacion: 0,
  pendiente: 0,
  enProceso: 0,
  resuelto: 0,
  cancelado: 0
})

const paginaActual = ref(1)
const ticketsPorPagina = ref(8)

const reportesPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * ticketsPorPagina.value
  return misReportes.value.slice(inicio, inicio + ticketsPorPagina.value)
})

const totalPaginas = computed(() => Math.ceil(misReportes.value.length / ticketsPorPagina.value) || 1)

const paginasVisibles = computed(() => {
  const total = totalPaginas.value
  const actual = paginaActual.value
  if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1)
  
  const pages = []
  pages.push(1)
  if (actual > 3) pages.push('...')
  for (let i = Math.max(2, actual - 1); i <= Math.min(total - 1, actual + 1); i++) {
    pages.push(i)
  }
  if (actual < total - 2) pages.push('...')
  pages.push(total)
  return pages
})

const cambiarPagina = (pag) => {
  if (pag >= 1 && pag <= totalPaginas.value) {
    paginaActual.value = pag
  }
}

const nuevoReporte = ref({
  identidades: [''],
  categoria: '',
  prioridad: 'Media',
  tema: '',
  descripcion: ''
})
const archivoReporte = ref(null)
const fileInputRef = ref(null)

const formatIdentidad = (event, index) => {
  let val = event.target.value.replace(/\D/g, '')
  if (val.length > 13) val = val.slice(0, 13)
  
  if (val.length > 8) {
    val = val.slice(0, 4) + '-' + val.slice(4, 8) + '-' + val.slice(8)
  } else if (val.length > 4) {
    val = val.slice(0, 4) + '-' + val.slice(4)
  }
  
  nuevoReporte.value.identidades[index] = val
}

const filtroActivo = ref('todas')
const searchTrm = ref('')
const sortOption = ref('reciente')
const priorityFilter = ref('todas')

watch([searchTrm, sortOption, priorityFilter], () => {
  filtrarReportes()
})

const aplicarFiltro = (filtro) => {
  filtroActivo.value = filtro
  filtrarReportes()
}

const obtenerConteoCategoria = (cat) => {
  let data = todosLosReportes.value
  if (rolID.value != 1 && rolID.value != 2) {
    data = data.filter(r => r.jefe_reporta === nombreUsuario.value || r.asignado_usuario_id == usuarioActualId.value)
  }
  return data.filter(r => r.categoria === cat).length
}

const filtrarReportes = () => {
  let data = todosLosReportes.value

  if (rolID.value !== 1 && rolID.value !== 2) {
    data = data.filter(r => r.jefe_reporta === nombreUsuario.value || r.asignado_usuario_id === usuarioActualId.value)
  }

  if (filtroActivo.value === 'todas') {
    //
  } else if (filtroActivo.value === 'misEntradas') {
    data = data.filter(r => r.jefe_reporta === nombreUsuario.value)
  } else if (filtroActivo.value === 'asignado') {
    data = data.filter(r => r.asignado_usuario_id === usuarioActualId.value)
  } else if (filtroActivo.value === 'sinAsignacion') {
    data = data.filter(r => !r.asignado_usuario_id)
  } else if (filtroActivo.value.startsWith('estado-')) {
    const est = filtroActivo.value.substring(7)
    if (est === 'Pendiente') {
      data = data.filter(r => !r.estado || r.estado === 'Pendiente')
    } else if (est === 'Cancelado') {
      data = data.filter(r => r.estado === 'Cancelado' || r.estado === 'Desestimado')
    } else {
      data = data.filter(r => r.estado === est)
    }
  } else if (filtroActivo.value.startsWith('categoria-')) {
    const cat = filtroActivo.value.substring(10)
    data = data.filter(r => r.categoria === cat)
  }

  if (priorityFilter.value !== 'todas') {
    data = data.filter(r => (r.prioridad || 'Media').toUpperCase() === priorityFilter.value.toUpperCase())
  }

  if (searchTrm.value) {
    const term = searchTrm.value.toLowerCase()
    data = data.filter(r => 
      (r.tema || '').toLowerCase().includes(term) ||
      (r.descripcion || '').toLowerCase().includes(term) ||
      (r.empleado_nombre || '').toLowerCase().includes(term) ||
      (r.empleado_apellido || '').toLowerCase().includes(term) ||
      (r.identidad || '').toLowerCase().includes(term) ||
      (r.jefe_reporta || '').toLowerCase().includes(term)
    )
  }

  const isClosed = (estado) => ['Resuelto', 'Cancelado', 'Desestimado', 'Cerrado'].includes(estado)

  data = data.sort((a, b) => {
    const aClosed = isClosed(a.estado)
    const bClosed = isClosed(b.estado)

    if (aClosed && !bClosed) return 1
    if (!aClosed && bClosed) return -1

    if (sortOption.value === 'reciente') {
      return new Date(b.fecha_creacion) - new Date(a.fecha_creacion)
    } else if (sortOption.value === 'antiguo') {
      return new Date(a.fecha_creacion) - new Date(b.fecha_creacion)
    } else if (sortOption.value === 'prioridad') {
       const pWeights = { 'URGENTE': 4, 'ALTA': 3, 'MEDIA': 2, 'BAJA': 1 }
       const pA = pWeights[(a.prioridad || 'Media').toUpperCase()] || 0
       const pB = pWeights[(b.prioridad || 'Media').toUpperCase()] || 0
       return pB - pA
    } else if (sortOption.value === 'actualizado') {
       const dA = new Date(a.updated_at || a.fecha_creacion)
       const dB = new Date(b.updated_at || b.fecha_creacion)
       return dB - dA
    }
    return 0
  })

  misReportes.value = data
  paginaActual.value = 1
}

const handleFileUpload = (event) => {
  archivoReporte.value = event.target.files[0]
}

const abrirModalNuevo = () => {
  if (!nuevoReporte.value.categoria && categoriasActivas.value.length > 0) {
    nuevoReporte.value.categoria = categoriasActivas.value[0].nombre
  }
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
  nuevoReporte.value = {
    identidades: [''],
    categoria: categoriasActivas.value.length > 0 ? categoriasActivas.value[0].nombre : '',
    prioridad: 'Media',
    tema: '',
    descripcion: ''
  }
  archivoReporte.value = null
  if (fileInputRef.value) fileInputRef.value.value = ''
}

const verDetalle = (id) => {
  selectedTicketId.value = id
}

const fetchReportes = async () => {
  try {
    loadingFetch.value = true
    const response = await axios.get('/api/reportes-incidencia/lista')
    let data = response.data

    try {
      const empRes = await axios.get('/api/empleados/lista')
      const empleados = empRes.data
      data = data.map(r => {
        if (!r.empleado_nombre && r.identidad) {
          const ids = r.identidad.split(',').map(i => i.trim())
          const emps = empleados.filter(e => ids.includes(e.identidad))
          if (emps.length > 0) {
            r.empleado_nombre = emps.map(e => e.nombre).join(', ')
            r.empleado_apellido = emps.map(e => e.apellido).join(', ')
            r.empleados_detalles = emps
          }
        }
        return r
      })
    } catch (err) {
      console.error("Error al cargar empleados para nombres en lista:", err)
    }

    todosLosReportes.value = data

    let countsData = data
    if (rolID.value !== 1 && rolID.value !== 2) {
      countsData = data.filter(r => r.jefe_reporta === nombreUsuario.value || r.asignado_usuario_id === usuarioActualId.value)
    }

    unfilteredReportesForCounts.value = countsData

    sidebarCounts.value = {
      todas: countsData.length,
      misEntradas: countsData.filter(r => r.jefe_reporta === nombreUsuario.value).length,
      asignado: countsData.filter(r => r.asignado_usuario_id === usuarioActualId.value).length,
      sinAsignacion: countsData.filter(r => !r.asignado_usuario_id).length,
      pendiente: countsData.filter(r => !r.estado || r.estado === 'Pendiente').length,
      enProceso: countsData.filter(r => r.estado === 'En Proceso').length,
      resuelto: countsData.filter(r => r.estado === 'Resuelto').length,
      cancelado: countsData.filter(r => r.estado === 'Cancelado' || r.estado === 'Desestimado').length
    }

    filtrarReportes()
  } catch (error) { 
    console.error("Error al cargar reportes:", error) 
  } finally {
    loadingFetch.value = false
  }
}

const crearReporte = async () => {
  if (!nuevoReporte.value.descripcion.trim() || !nuevoReporte.value.tema.trim()) {
    alert("Por favor ingrese un tema y una descripción.")
    return
  }
  
  try {
    loading.value = true
    
    const formData = new FormData()
    formData.append('jefe_reporta', nombreUsuario.value)
    const identidadesValidas = nuevoReporte.value.identidades.filter(i => i.trim() !== '').join(', ')
    formData.append('identidad', identidadesValidas)
    formData.append('categoria', nuevoReporte.value.categoria)
    formData.append('prioridad', nuevoReporte.value.prioridad)
    formData.append('tema', nuevoReporte.value.tema)
    formData.append('descripcion', nuevoReporte.value.descripcion)
    
    if (archivoReporte.value) {
      formData.append('archivo', archivoReporte.value)
    }

    await axios.post('/api/reportes-incidencia/crear', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    
    cerrarModal()
    await fetchReportes()
    alert("✅ Reporte enviado con éxito")
  } catch (error) { 
    console.error(error)
    alert("❌ Error al enviar el reporte") 
  } finally {
    loading.value = false
  }
}

const eliminarReporte = async (id) => {
  const result = await Swal.fire({
    title: '¿Eliminar reporte?',
    text: "Esta acción no se puede deshacer.",
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ef4444',
    cancelButtonColor: '#94a3b8',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    customClass: {
      popup: 'rounded-2xl border border-slate-100',
      title: 'text-lg font-black text-slate-800',
      htmlContainer: 'text-sm font-medium text-slate-500',
      confirmButton: 'rounded-xl text-xs font-bold px-5 py-2.5 shadow-lg shadow-red-500/30 uppercase tracking-wide',
      cancelButton: 'rounded-xl text-xs font-bold px-5 py-2.5 uppercase tracking-wide'
    }
  });

  if (result.isConfirmed) {
    try {
      await axios.delete(`/api/reportes-incidencia/${id}`);
      await fetchReportes();
      Swal.fire({
        title: 'Eliminado',
        text: 'El reporte ha sido eliminado correctamente.',
        icon: 'success',
        timer: 2000,
        showConfirmButton: false,
        customClass: {
          popup: 'rounded-2xl border border-slate-100',
          title: 'text-lg font-black text-slate-800',
          htmlContainer: 'text-sm font-medium text-slate-500'
        }
      });
    } catch (error) {
      console.error(error);
      Swal.fire('Error', 'No se pudo eliminar el reporte.', 'error');
    }
  }
}

const claseEstado = (estado) => {
  const e = estado || 'Pendiente'
  if (e === 'En Proceso') return 'bg-blue-50 text-blue-600 border border-blue-100'
  if (e === 'Pendiente') return 'bg-amber-50 text-amber-600 border border-amber-100'
  if (e === 'Resuelto') return 'bg-emerald-50 text-emerald-600 border border-emerald-100'
  if (e === 'Cancelado' || e === 'Desestimado') return 'bg-slate-50 text-slate-500 border border-slate-200'
  return 'bg-slate-50 text-slate-500 border border-slate-200'
}

const prioridadClass = (prioridad) => {
  const p = (prioridad || 'Media').toUpperCase()
  if (p === 'URGENTE') return 'text-red-600 bg-red-50 border border-red-100'
  if (p === 'ALTA') return 'text-orange-600 bg-orange-50 border border-orange-100'
  if (p === 'BAJA') return 'text-emerald-600 bg-emerald-50 border border-emerald-100'
  return 'text-amber-600 bg-amber-50 border border-amber-100' // Media
}

const prioridadDotClass = (prioridad) => {
  const p = (prioridad || 'Media').toUpperCase()
  if (p === 'URGENTE') return 'bg-red-500'
  if (p === 'ALTA') return 'bg-orange-500'
  if (p === 'BAJA') return 'bg-emerald-500'
  return 'bg-amber-500'
}

const tiempoRelativo = (fechaStr) => {
  if (!fechaStr) return '-'
  const ahora = new Date()
  const fecha = new Date(fechaStr)
  const diffMs = ahora - fecha
  const diffMin = Math.floor(diffMs / 60000)
  const diffHrs = Math.floor(diffMin / 60)
  const diffDays = Math.floor(diffHrs / 24)
  if (diffMin < 2) return 'Ahora mismo'
  if (diffMin < 60) return `Hace ${diffMin} min`
  if (diffHrs < 24) return `Hace ${diffHrs}h`
  if (diffDays < 7) return `Hace ${diffDays}d`
  return formatearFecha(fechaStr)
}

const formatearFecha = (fechaStr) => {
  if (!fechaStr) return '-'
  return new Date(fechaStr).toLocaleDateString('es-HN', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

const generarPDF = async () => {
  const doc = new jsPDF('landscape')

  // Cargar logo
  const imgLogo = new Image();
  imgLogo.crossOrigin = 'Anonymous';
  imgLogo.src = `${useRuntimeConfig().public.apiBase}/uploads/Logo/Logo.png`;
  await new Promise((resolve) => { imgLogo.onload = resolve; imgLogo.onerror = resolve; });

  doc.setFontSize(20)
  doc.setTextColor(220, 38, 38)
  doc.setFont('helvetica', 'bold')
  doc.text('REPORTES DE INCIDENCIAS LABORALES', 14, 20)
  
  doc.setFontSize(9)
  doc.setTextColor(100, 116, 139)
  doc.setFont('helvetica', 'normal')
  doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 28)
  doc.text(`Filtro: ${filtroActivo.value === 'todas' ? 'Todos los registros' : filtroActivo.value}  |  Total: ${misReportes.value.length} reportes`, 14, 33)

  try { doc.addImage(imgLogo, 'PNG', 240, 12, 35, 15); } catch(e) {}

  doc.setDrawColor(220, 38, 38);
  doc.setLineWidth(0.5);
  doc.line(14, 37, 283, 37);

  const headers = [['#', 'Prioridad', 'Estado', 'Empleado Reportado', 'Tema', 'Categoría', 'Reportado Por', 'Asignado A', 'Fecha']]
  const data = misReportes.value.map(r => [
    `#INC-${String(r.id).padStart(3, '0')}`,
    (r.prioridad || 'Media').toUpperCase(),
    (r.estado || 'Pendiente').toUpperCase(),
    `${r.empleado_nombre || ''} ${r.empleado_apellido || ''}`.trim() || 'Desconocido',
    r.tema || 'Sin tema',
    r.categoria || 'General',
    r.jefe_reporta || '-',
    r.asignado_usuario_nombre || 'Sin asignar',
    formatearFecha(r.fecha_creacion)
  ])

  doc.autoTable({
    startY: 42,
    head: headers,
    body: data,
    theme: 'grid',
    headStyles: {
      fillColor: [220, 38, 38],
      textColor: [255, 255, 255],
      fontStyle: 'bold',
      halign: 'center',
      fontSize: 8
    },
    bodyStyles: { fontSize: 7.5, cellPadding: 3 },
    columnStyles: {
      4: { halign: 'left', cellWidth: 45 },
      3: { cellWidth: 35 },
    },
    alternateRowStyles: { fillColor: [248, 250, 252] },
    didParseCell: (data) => {
      if (data.section === 'body' && data.column.index === 1) {
        const val = (data.cell.raw || '').toUpperCase();
        if (val === 'URGENTE') data.cell.styles.textColor = [220, 38, 38];
        else if (val === 'ALTA') data.cell.styles.textColor = [234, 88, 12];
        else if (val === 'BAJA') data.cell.styles.textColor = [5, 150, 105];
      }
      if (data.section === 'body' && data.column.index === 2) {
        const val = (data.cell.raw || '').toUpperCase();
        if (val === 'PENDIENTE') data.cell.styles.textColor = [217, 119, 6];
        else if (val === 'EN PROCESO') data.cell.styles.textColor = [37, 99, 235];
        else if (val === 'RESUELTO') data.cell.styles.textColor = [5, 150, 105];
      }
    }
  })

  // Footer with page numbers
  const totalPages = doc.internal.getNumberOfPages();
  for (let i = 1; i <= totalPages; i++) {
    doc.setPage(i);
    doc.setFontSize(7);
    doc.setTextColor(100, 116, 139);
    doc.text(`Página ${i} de ${totalPages}  —  INNOVA RRHH`, 148.5, doc.internal.pageSize.height - 8, { align: 'center' });
  }

  doc.save(`Reportes_Incidencias_${new Date().toISOString().split('T')[0]}.pdf`)
}

onMounted(async () => {
  if (route.query.id) {
    selectedTicketId.value = parseInt(route.query.id, 10)
  }

  const uId = localStorage.getItem('usuarioID');
  usuarioActualId.value = uId ? parseInt(uId, 10) : null;
  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Invitado'
  const rol = localStorage.getItem('usuarioRol');
  rolID.value = rol ? parseInt(rol, 10) : 3;
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null

  if (rolID.value === 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value === 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }
  
  try {
    const resPermisos = await axios.get(`/api/roles/${rolID.value}/permisos`)
    const moduloActual = resPermisos.data.find(p => p.modulo_nombre.toLowerCase().includes('reporte') || p.modulo_nombre.toLowerCase().includes('incidencia'))
    if (moduloActual) {
      permisosModulo.value = moduloActual
    }
  } catch (e) {
    console.error("Error al cargar permisos", e)
  }

  try {
    const m = await axios.get(`/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    menuUsuario.value = m.data
  } catch(e) {
    console.error("Error al cargar menú", e)
  }

  await fetchReportes()

  // Socket.io for real-time updates
  socketInstance = io(useRuntimeConfig().public.apiBase)
  socketInstance.on('reportes_actualizados', () => {
    fetchReportes()
  })
})

onUnmounted(() => {
  if (socketInstance) {
    socketInstance.disconnect()
  }
})

watch(() => route.query.id, (newId) => {
  if (newId) {
    selectedTicketId.value = parseInt(newId, 10)
  }
})

const logout = () => { 
  localStorage.clear()
  navigateTo('/login') 
}
</script>