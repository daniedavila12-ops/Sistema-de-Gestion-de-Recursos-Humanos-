<template>
  <div class="min-h-screen flex font-sans" style="background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 50%, #e2e8f0 100%)">
    <!-- SIDEBAR DINÁMICO -->
    <aside class="w-64 bg-slate-800 text-white flex flex-col shadow-xl fixed h-full z-10">
      <div class="p-6 text-2xl font-bold border-b border-slate-700 tracking-tight text-blue-400 uppercase">
        RRHH Innova
      </div>
      <nav class="flex-1 p-4 space-y-1 overflow-y-auto">
        <div v-for="(item, index) in menuUsuario" :key="item.ruta || index">
          <div v-if="item.esCabecera" class="text-[10px] font-black text-slate-500 uppercase tracking-widest mt-6 mb-2 px-3">{{ item.nombre }}</div>
          <NuxtLink v-else :to="item.ruta" class="flex items-center gap-3 p-3 rounded-xl hover:bg-slate-700 transition-all duration-200 group" active-class="bg-blue-600 shadow-lg">
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
    <main class="flex-1 ml-64 p-8 overflow-y-auto">

      <!-- Header -->
      <header class="mb-6 bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
        <div class="px-6 py-4 flex justify-between items-center">
          <div class="flex items-center gap-4">
            <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center shadow-lg shadow-violet-500/20">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></svg>
            </div>
            <div>
              <h1 class="text-lg font-extrabold text-slate-800 tracking-tight leading-none">Módulo de Tickets</h1>
              <p class="text-[11px] text-slate-400 font-medium mt-0.5">Gestiona tus solicitudes y requerimientos</p>
            </div>
          </div>
          <div class="flex items-center gap-4">
            <button @click="abrirModalNuevo" class="flex items-center gap-2 bg-gradient-to-r from-violet-600 to-purple-600 text-white px-4 py-2.5 rounded-xl font-bold text-xs hover:from-violet-700 hover:to-purple-700 transition-all shadow-lg shadow-violet-500/25 uppercase tracking-wide">
              <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" d="M12 4v16m8-8H4"/></svg>
              Nueva Solicitud
            </button>
            <div class="relative">
              <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-4 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors">
                <div v-if="fotoUsuario" class="h-8 w-8 rounded-full overflow-hidden ring-2 ring-slate-100">
                  <img :src="`http://localhost:3007${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-8 w-8 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-sm ring-2 ring-slate-100 uppercase">{{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}</div>
                <div class="flex flex-col text-left">
                  <span class="text-[9px] text-slate-400 font-black uppercase tracking-widest">Sesión</span>
                  <span class="text-[13px] font-extrabold text-slate-800 leading-tight">{{ nombreUsuario || 'Cargando...' }}</span>
                </div>
                <svg class="w-3.5 h-3.5 text-slate-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
              </div>
              <div v-if="dropdownPerfilAbierto" class="absolute right-0 mt-2 w-64 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50">
                <div class="p-4 border-b border-slate-100 bg-slate-50 flex items-center gap-3">
                  <div v-if="fotoUsuario" class="h-10 w-10 rounded-full overflow-hidden ring-2 ring-white shadow-sm shrink-0"><img :src="`http://localhost:3007${fotoUsuario}`" class="w-full h-full object-cover" /></div>
                  <div v-else class="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-lg ring-2 ring-white shadow-sm shrink-0 uppercase">{{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}</div>
                  <div>
                    <p class="font-extrabold text-slate-800 text-sm">{{ nombreUsuario }}</p>
                    <p class="text-[10px] font-bold text-violet-500 uppercase tracking-widest">{{ rolNombre }}</p>
                  </div>
                </div>
                <div class="p-2">
                  <button @click="abrirModalPerfil(); dropdownPerfilAbierto = false" class="w-full text-left flex items-center gap-3 p-3 hover:bg-slate-50 rounded-xl transition-colors group">
                    <span class="text-base group-hover:scale-110 transition-transform">👤</span>
                    <span class="text-sm font-bold text-slate-700">Mi Perfil de Usuario</span>
                  </button>
                  <button @click="logout" class="w-full text-left flex items-center gap-3 p-3 hover:bg-red-50 rounded-xl transition-colors group">
                    <span class="text-base group-hover:scale-110 transition-transform">🚪</span>
                    <span class="text-sm font-bold text-red-600">Cerrar Sesión</span>
                  </button>
                </div>
              </div>
              <div v-if="dropdownPerfilAbierto" @click="dropdownPerfilAbierto = false" class="fixed inset-0 z-40"></div>
            </div>
          </div>
        </div>
      </header>

      <!-- KPI Summary Cards -->
      <div class="grid grid-cols-5 gap-4 mb-6">
        <!-- Tarjeta Pendiente -->
        <div @click="aplicarFiltro('estado-Pendiente')"
             :class="['relative overflow-hidden rounded-2xl p-4 cursor-pointer transition-all duration-300',
                      filtroActivo === 'estado-Pendiente' 
                        ? 'bg-gradient-to-br from-orange-400 to-orange-500 shadow-lg shadow-orange-500/30 scale-[1.02] ring-2 ring-white/50 ring-offset-2 ring-offset-orange-50' 
                        : 'bg-gradient-to-br from-orange-400/90 to-orange-500/90 hover:from-orange-400 hover:to-orange-500 shadow-md']">
          <div class="absolute right-0 top-0 -mt-3 -mr-3 text-white/20 transition-transform group-hover:scale-110">
            <svg class="w-24 h-24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path stroke-linecap="round" d="M12 6v6l4 2"/></svg>
          </div>
          <div class="relative z-10 flex flex-col h-full justify-between">
            <span class="text-[9px] font-extrabold text-white/90 uppercase tracking-widest">Pendiente</span>
            <div class="mt-3">
              <p class="text-3xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.pendiente }}</p>
              <p class="text-[11px] text-white/80 font-semibold mt-1.5">Requieren atención</p>
            </div>
          </div>
        </div>

        <!-- Tarjeta Abierto -->
        <div @click="aplicarFiltro('estado-Abierto')"
             :class="['relative overflow-hidden rounded-2xl p-4 cursor-pointer transition-all duration-300',
                      filtroActivo === 'estado-Abierto' 
                        ? 'bg-gradient-to-br from-fuchsia-500 to-fuchsia-600 shadow-lg shadow-fuchsia-500/30 scale-[1.02] ring-2 ring-white/50 ring-offset-2 ring-offset-fuchsia-50' 
                        : 'bg-gradient-to-br from-fuchsia-500/90 to-fuchsia-600/90 hover:from-fuchsia-500 hover:to-fuchsia-600 shadow-md']">
          <div class="absolute right-0 top-0 -mt-3 -mr-3 text-white/20 transition-transform group-hover:scale-110">
            <svg class="w-24 h-24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/></svg>
          </div>
          <div class="relative z-10 flex flex-col h-full justify-between">
            <span class="text-[9px] font-extrabold text-white/90 uppercase tracking-widest">Abierto</span>
            <div class="mt-3">
              <p class="text-3xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.abierto }}</p>
              <p class="text-[11px] text-white/80 font-semibold mt-1.5">Nuevos tickets</p>
            </div>
          </div>
        </div>

        <!-- Tarjeta En Progreso -->
        <div @click="aplicarFiltro('estado-En Progreso')"
             :class="['relative overflow-hidden rounded-2xl p-4 cursor-pointer transition-all duration-300',
                      filtroActivo === 'estado-En Progreso' 
                        ? 'bg-gradient-to-br from-blue-500 to-blue-600 shadow-lg shadow-blue-500/30 scale-[1.02] ring-2 ring-white/50 ring-offset-2 ring-offset-blue-50' 
                        : 'bg-gradient-to-br from-blue-500/90 to-blue-600/90 hover:from-blue-500 hover:to-blue-600 shadow-md']">
          <div class="absolute right-0 top-0 -mt-3 -mr-3 text-white/20 transition-transform group-hover:scale-110">
            <svg class="w-24 h-24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
          </div>
          <div class="relative z-10 flex flex-col h-full justify-between">
            <span class="text-[9px] font-extrabold text-white/90 uppercase tracking-widest">En Progreso</span>
            <div class="mt-3">
              <p class="text-3xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.enProgreso }}</p>
              <p class="text-[11px] text-white/80 font-semibold mt-1.5">En seguimiento</p>
            </div>
          </div>
        </div>

        <!-- Tarjeta Resueltos -->
        <div @click="aplicarFiltro('estado-Resuelto')"
             :class="['relative overflow-hidden rounded-2xl p-4 cursor-pointer transition-all duration-300',
                      filtroActivo === 'estado-Resuelto' 
                        ? 'bg-gradient-to-br from-emerald-400 to-emerald-500 shadow-lg shadow-emerald-500/30 scale-[1.02] ring-2 ring-white/50 ring-offset-2 ring-offset-emerald-50' 
                        : 'bg-gradient-to-br from-emerald-400/90 to-emerald-500/90 hover:from-emerald-400 hover:to-emerald-500 shadow-md']">
          <div class="absolute right-0 top-0 -mt-3 -mr-3 text-white/20 transition-transform group-hover:scale-110">
            <svg class="w-24 h-24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
          </div>
          <div class="relative z-10 flex flex-col h-full justify-between">
            <span class="text-[9px] font-extrabold text-white/90 uppercase tracking-widest">Resueltos</span>
            <div class="mt-3">
              <p class="text-3xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.resuelto }}</p>
              <p class="text-[11px] text-white/80 font-semibold mt-1.5">Casos cerrados</p>
            </div>
          </div>
        </div>

        <!-- Tarjeta Total -->
        <div @click="aplicarFiltro('todas')"
             :class="['relative overflow-hidden rounded-2xl p-4 cursor-pointer transition-all duration-300',
                      filtroActivo === 'todas' 
                        ? 'bg-gradient-to-br from-indigo-500 to-violet-600 shadow-lg shadow-indigo-500/30 scale-[1.02] ring-2 ring-white/50 ring-offset-2 ring-offset-indigo-50' 
                        : 'bg-gradient-to-br from-indigo-500/90 to-violet-600/90 hover:from-indigo-500 hover:to-violet-600 shadow-md']">
          <div class="absolute right-0 top-0 -mt-3 -mr-3 text-white/20 transition-transform group-hover:scale-110">
            <svg class="w-24 h-24" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
          </div>
          <div class="relative z-10 flex flex-col h-full justify-between">
            <span class="text-[9px] font-extrabold text-white/90 uppercase tracking-widest">Total</span>
            <div class="mt-3">
              <p class="text-3xl font-black text-white tabular-nums leading-none drop-shadow-sm">{{ sidebarCounts.todas }}</p>
              <p class="text-[11px] text-white/80 font-semibold mt-1.5">Tickets totales</p>
            </div>
          </div>
        </div>
      </div>

      <div class="flex gap-6 items-start">
        <!-- Sidebar del Módulo -->
        <TicketsSidebar :counts="sidebarCounts" :activeFilter="filtroActivo" :ticketsList="unfilteredTicketsForCounts" @filter-changed="aplicarFiltro" @categorias-actualizadas="actualizarCategorias" class="shrink-0 w-64 rounded-2xl shadow-sm border border-slate-200/80 overflow-hidden bg-white" />

        <div class="flex-1 flex flex-col gap-6">
          <!-- TABLA DE TICKETS -->
          <div class="bg-white rounded-2xl shadow-sm border border-slate-200/80 overflow-hidden">
            <!-- Toolbar -->
            <div class="p-5 border-b border-slate-100 flex flex-col gap-4">
              <div class="flex justify-between items-center">
                <div class="flex items-center gap-3">
                  <h2 class="text-base font-extrabold text-slate-800 tracking-tight">Historial de Tickets</h2>
                  <span class="text-[10px] font-bold text-slate-400 bg-slate-100 px-2 py-0.5 rounded-md tabular-nums">{{ misTickets.length }} registros</span>
                </div>
                <button @click="fetchTickets" class="w-8 h-8 rounded-lg bg-slate-50 border border-slate-200 flex items-center justify-center text-slate-400 hover:text-violet-500 hover:border-violet-200 hover:bg-violet-50 transition-all" title="Actualizar">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/></svg>
                </button>
              </div>

              <!-- Search & Filters Bar -->
              <div class="flex flex-col md:flex-row gap-3 items-center">
                <div class="flex-1 relative">
                  <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
                  <input v-model="searchTrm" type="text" placeholder="Buscar por tema, empleado, identidad..."
                    class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-violet-400 focus:ring-2 focus:ring-violet-100 text-sm font-medium text-slate-700 transition-all placeholder:text-slate-400">
                </div>
                <div class="flex items-center gap-2">
                  <div class="relative">
                    <select v-model="priorityFilter" class="appearance-none pl-3 pr-8 py-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-violet-400 text-sm font-semibold text-slate-700 transition-all cursor-pointer">
                      <option value="todas">Prioridad</option>
                      <option value="Urgente">Urgente</option>
                      <option value="Alta">Alta</option>
                      <option value="Media">Media</option>
                      <option value="Baja">Baja</option>
                    </select>
                    <svg class="absolute right-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-400 pointer-events-none" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
                  </div>
                  <div class="relative">
                    <select v-model="sortOption" class="appearance-none pl-3 pr-8 py-2.5 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-violet-400 text-sm font-semibold text-slate-700 transition-all cursor-pointer">
                      <option value="reciente">Más reciente</option>
                      <option value="antiguo">Más antiguo</option>
                      <option value="prioridad">Prioridad</option>
                      <option value="actualizado">Actualizado</option>
                    </select>
                    <svg class="absolute right-2.5 top-1/2 -translate-y-1/2 w-3.5 h-3.5 text-slate-400 pointer-events-none" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M19 9l-7 7-7-7"/></svg>
                  </div>
                </div>
              </div>
            </div>

            <!-- Empty State -->
            <div v-if="ticketsPaginados.length === 0" class="flex flex-col items-center justify-center py-24 text-center px-4">
              <div class="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center mb-4 border border-slate-100">
                <svg class="w-7 h-7 text-slate-300" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></svg>
              </div>
              <h3 class="text-slate-700 font-bold text-base mb-1.5">Sin resultados</h3>
              <p class="text-slate-400 text-sm max-w-xs">No se encontraron tickets con los filtros actuales.</p>
            </div>

            <!-- Ticket List -->
            <div class="divide-y divide-slate-100" v-else>
              <TicketCard v-for="ticket in ticketsPaginados" :key="ticket.id" :ticket="ticket" @ver-detalle="verDetalle" @eliminar="eliminarTicket" />
            </div>

            <!-- Paginación -->
            <div class="flex flex-col sm:flex-row justify-between items-center px-5 py-4 bg-slate-50/50 border-t border-slate-100 gap-3" v-if="totalPaginas > 1">
              <span class="text-[11px] font-semibold text-slate-400 tabular-nums">Página {{ paginaActual }} de {{ totalPaginas }} — {{ misTickets.length }} tickets</span>
              <div class="flex items-center gap-1.5">
                <button @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1"
                  class="w-8 h-8 rounded-lg bg-white border border-slate-200 flex items-center justify-center text-slate-400 hover:bg-slate-50 hover:text-slate-600 transition-all text-sm disabled:opacity-40 disabled:cursor-not-allowed">
                  <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path stroke-linecap="round" d="M15 19l-7-7 7-7"/></svg>
                </button>
                <template v-for="pag in totalPaginas" :key="pag">
                  <button @click="cambiarPagina(pag)"
                    :class="['w-8 h-8 rounded-lg text-xs font-bold transition-all', pag === paginaActual ? 'bg-gradient-to-r from-violet-600 to-purple-600 text-white shadow-lg shadow-violet-500/30' : 'bg-white border border-slate-200 text-slate-500 hover:bg-slate-50']">
                    {{ pag }}
                  </button>
                </template>
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

    <!-- Modal Nueva Solicitud -->
    <div v-if="mostrarModal" class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm p-4 overflow-y-auto">
      <div class="bg-white rounded-2xl shadow-2xl border border-slate-100 w-full max-w-lg my-8 overflow-hidden">
        <header class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-gradient-to-r from-violet-600 to-purple-600">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 rounded-xl bg-white/20 flex items-center justify-center">
              <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v3a2 2 0 110 4v3a2 2 0 002 2h14a2 2 0 002-2v-3a2 2 0 110-4V7a2 2 0 00-2-2H5z"/></svg>
            </div>
            <div>
              <h3 class="text-base font-extrabold text-white tracking-tight">Nueva Solicitud</h3>
              <p class="text-violet-200 text-[10px] font-medium">Complete los campos del ticket</p>
            </div>
          </div>
          <button @click="cerrarModal" class="w-8 h-8 rounded-xl bg-white/20 flex items-center justify-center text-white hover:bg-white/30 transition-colors">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
        </header>

        <div class="p-6">
          <form @submit.prevent="crearTicket" class="space-y-4">
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Número de Identidad</label>
              <input v-model="nuevoTicket.identidad" type="text" placeholder="Ej: 0801-1990-12345" required
                class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-violet-400 focus:ring-2 focus:ring-violet-100 text-slate-700 font-medium transition-all text-sm">
            </div>
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Tipo de Solicitud</label>
                <select v-model="nuevoTicket.tipo" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-violet-400 focus:ring-2 focus:ring-violet-100 text-slate-700 font-medium transition-all text-sm">
                  <option v-for="cat in categoriasActivas" :key="cat.id" :value="cat.nombre">{{ cat.nombre }}</option>
                </select>
              </div>
              <div>
                <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Prioridad</label>
                <select v-model="nuevoTicket.prioridad" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-violet-400 focus:ring-2 focus:ring-violet-100 text-slate-700 font-medium transition-all text-sm">
                  <option value="Baja">Baja</option>
                  <option value="Media">Media</option>
                  <option value="Alta">Alta</option>
                  <option value="Urgente">Urgente</option>
                </select>
              </div>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Tema / Asunto</label>
              <input v-model="nuevoTicket.tema" type="text" placeholder="Breve resumen del problema" required
                class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-violet-400 focus:ring-2 focus:ring-violet-100 text-slate-700 font-medium transition-all text-sm">
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Descripción</label>
              <textarea v-model="nuevoTicket.descripcion" rows="4" placeholder="Detalla tu solicitud aquí..." required
                class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl outline-none focus:border-violet-400 focus:ring-2 focus:ring-violet-100 text-slate-700 transition-all text-sm resize-none"></textarea>
            </div>
            <div>
              <label class="block text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1.5">Adjuntar Archivo (Opcional)</label>
              <input type="file" ref="fileInputRef" @change="handleFileUpload"
                class="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-slate-700 text-sm cursor-pointer file:mr-4 file:py-1 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-bold file:bg-violet-50 file:text-violet-600 hover:file:bg-violet-100">
            </div>

            <div class="flex justify-end gap-3 pt-4 border-t border-slate-100">
              <button type="button" @click="cerrarModal" class="px-5 py-2.5 text-slate-500 font-bold text-xs uppercase tracking-wide hover:bg-slate-50 rounded-xl transition-colors">Cancelar</button>
              <button type="submit" :disabled="loading" class="px-6 py-2.5 bg-gradient-to-r from-violet-600 to-purple-600 text-white rounded-xl font-bold uppercase text-xs shadow-lg shadow-violet-500/25 hover:from-violet-700 hover:to-purple-700 transition-all disabled:opacity-50 tracking-wide">
                {{ loading ? 'Enviando...' : 'Enviar Solicitud' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    
    <!-- Modal Ticket Detail -->
    <TicketDetail v-if="selectedTicketId" :id="selectedTicketId" @close="cerrarDetalle" />
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import axios from 'axios'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'
import TicketCard from '~/components/TicketCard.vue'
import TicketDetail from '~/pages/TicketDetail.vue'

const selectedTicketId = ref(null)
const cerrarDetalle = () => {
  selectedTicketId.value = null
  fetchTickets()
}

const router = useRouter()

// Variables de sesión y layout
const nombreUsuario = ref('')
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const fotoUsuario = ref(null)
const menuUsuario = ref([])

// Lógica Modal Perfil
const dropdownPerfilAbierto = ref(false)
const modalAbiertoPerfil = ref(false)
const loadingPassword = ref(false)
const formPassword = ref({ actual: '', nueva: '', confirmar: '' })
const fileInputPerfil = ref(null)

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
    const res = await axios.post(`http://localhost:3007/api/auth/${id}/foto`, formData, {
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
    alert("Las contraseñas nuevas no coinciden")
    return
  }
  try {
    loadingPassword.value = true
    const id = localStorage.getItem('usuarioID')
    const response = await axios.put(`http://localhost:3007/api/auth/${id}/password`, {
      password_actual: formPassword.value.actual,
      password_nueva: formPassword.value.nueva
    })
    alert('✅ ' + response.data.mensaje)
    cerrarModalPerfil()
  } catch (error) {
    console.error(error)
    alert('❌ ' + (error.response?.data?.mensaje || "Error al cambiar contraseña"))
  } finally {
    loadingPassword.value = false
  }
}

// Variables del módulo
const mostrarModal = ref(false)
const loading = ref(false)
const misTickets = ref([])
const todosLosTickets = ref([])
const sidebarCounts = ref({
  todas: 0,
  misEntradas: 0,
  asignado: 0,
  sinAsignacion: 0,
  abierto: 0,
  enProgreso: 0,
  pendiente: 0,
  resuelto: 0,
  cerrado: 0
})

// Variables de Paginación
const paginaActual = ref(1)
const ticketsPorPagina = ref(8)

const ticketsPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * ticketsPorPagina.value
  return misTickets.value.slice(inicio, inicio + ticketsPorPagina.value)
})

const totalPaginas = computed(() => Math.ceil(misTickets.value.length / ticketsPorPagina.value) || 1)

const cambiarPagina = (pag) => {
  if (pag >= 1 && pag <= totalPaginas.value) {
    paginaActual.value = pag
  }
}

const nuevoTicket = ref({
  usuario_id: null,
  identidad: '',
  tipo: 'Vacaciones',
  prioridad: 'Media',
  tema: '',
  descripcion: ''
})
const archivoTicket = ref(null)
const fileInputRef = ref(null)

const filtroActivo = ref('todas')
const searchTrm = ref('')
const sortOption = ref('reciente')
const priorityFilter = ref('todas')
const unfilteredTicketsForCounts = ref([])

const categoriasActivas = ref([])

const actualizarCategorias = (categorias) => {
  categoriasActivas.value = categorias.filter(c => c.activa)
  if (categoriasActivas.value.length > 0 && !categoriasActivas.value.find(c => c.nombre === nuevoTicket.value.tipo)) {
    nuevoTicket.value.tipo = categoriasActivas.value[0].nombre
  }
}

watch([searchTrm, sortOption, priorityFilter], () => {
  filtrarTickets()
})

const aplicarFiltro = (filtro) => {
  filtroActivo.value = filtro
  filtrarTickets()
}

const filtrarTickets = () => {
  let data = todosLosTickets.value
  
  const uid = nuevoTicket.value.usuario_id
  
  if (rolID.value != 1) {
    data = data.filter(t => t.asignado_usuario_id == uid)
  }

  // 1. Filtro de Sidebar
  if (filtroActivo.value === 'todas') {
    // se mantiene la data
  } else if (filtroActivo.value === 'misEntradas') {
    data = data.filter(t => t.usuario_id == uid)
  } else if (filtroActivo.value === 'asignado') {
    data = data.filter(t => t.asignado_usuario_id == uid)
  } else if (filtroActivo.value === 'sinAsignacion') {
    data = data.filter(t => !t.asignado_usuario_id && !t.asignado_empleado_id)
  } else if (filtroActivo.value.startsWith('estado-')) {
    const estado = filtroActivo.value.substring(7)
    if (estado === 'Pendiente') {
      data = data.filter(t => !t.estado || t.estado === 'Pendiente')
    } else {
      data = data.filter(t => t.estado === estado)
    }
  } else if (filtroActivo.value.startsWith('categoria-')) {
    const categoria = filtroActivo.value.substring(10)
    data = data.filter(t => t.tipo === categoria || t.Categoria === categoria)
  }

  // 2. Filtro de Prioridad
  if (priorityFilter.value !== 'todas') {
    data = data.filter(t => (t.prioridad || 'Media').toUpperCase() === priorityFilter.value.toUpperCase())
  }

  // 3. Filtro de Búsqueda
  if (searchTrm.value) {
    const term = searchTrm.value.toLowerCase()
    data = data.filter(t => 
      (t.tema || '').toLowerCase().includes(term) ||
      (t.descripcion || '').toLowerCase().includes(term) ||
      (t.empleado_nombre || '').toLowerCase().includes(term) ||
      (t.empleado_apellido || '').toLowerCase().includes(term) ||
      (t.identidad || '').toLowerCase().includes(term) ||
      (t.tipo || '').toLowerCase().includes(term)
    )
  }

  // 4. Ordenamiento
  const isClosed = (estado) => ['Resuelto', 'Cerrado', 'Cancelado', 'Desestimado'].includes(estado)

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

  misTickets.value = data
  paginaActual.value = 1
}

const handleFileUpload = (event) => {
  archivoTicket.value = event.target.files[0]
}

const abrirModalNuevo = () => {
  if (!nuevoTicket.value.tipo && categoriasActivas.value.length > 0) {
    nuevoTicket.value.tipo = categoriasActivas.value[0].nombre
  }
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
  nuevoTicket.value.identidad = ''
  nuevoTicket.value.descripcion = ''
  nuevoTicket.value.tipo = categoriasActivas.value.length > 0 ? categoriasActivas.value[0].nombre : ''
  nuevoTicket.value.tema = ''
  nuevoTicket.value.prioridad = 'Media'
  archivoTicket.value = null
  if (fileInputRef.value) fileInputRef.value.value = ''
}

const verDetalle = (id) => {
  selectedTicketId.value = id
}

const eliminarTicket = async (id) => {
  const result = await Swal.fire({
    title: '¿Estás seguro?',
    text: "El ticket será eliminado permanentemente de la base de datos.",
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#8b5cf6', // violet-500
    cancelButtonColor: '#ef4444',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    customClass: {
      popup: 'rounded-2xl',
      confirmButton: 'rounded-xl',
      cancelButton: 'rounded-xl'
    }
  });

  if (result.isConfirmed) {
    try {
      await axios.delete(`http://localhost:3007/api/tickets/${id}`);
      
      Swal.fire({
        title: 'Eliminado',
        text: 'El ticket ha sido eliminado correctamente.',
        icon: 'success',
        confirmButtonColor: '#8b5cf6',
        customClass: {
          popup: 'rounded-2xl',
          confirmButton: 'rounded-xl'
        }
      });
      
      await fetchTickets();
    } catch (error) {
      console.error("Error al eliminar ticket:", error);
      Swal.fire({
        title: 'Error',
        text: 'Hubo un problema al intentar eliminar el ticket.',
        icon: 'error',
        confirmButtonColor: '#8b5cf6',
        customClass: {
          popup: 'rounded-2xl',
          confirmButton: 'rounded-xl'
        }
      });
    }
  }
}

const fetchTickets = async () => {
  try {
    const response = await axios.get('http://localhost:3007/api/tickets/lista')
    const data = response.data
    todosLosTickets.value = data

    const uid = nuevoTicket.value.usuario_id;
    let countsData = data;
    if (rolID.value != 1) {
      countsData = data.filter(t => t.asignado_usuario_id == uid);
    }
    
    unfilteredTicketsForCounts.value = countsData

    sidebarCounts.value = {
      todas: countsData.length,
      misEntradas: countsData.filter(t => t.usuario_id == uid).length,
      asignado: countsData.filter(t => t.asignado_usuario_id == uid).length,
      sinAsignacion: countsData.filter(t => !t.asignado_usuario_id && !t.asignado_empleado_id).length,
      abierto: countsData.filter(t => t.estado === 'Abierto').length,
      enProgreso: countsData.filter(t => t.estado === 'En Progreso').length,
      pendiente: countsData.filter(t => (!t.estado || t.estado === 'Pendiente')).length,
      resuelto: countsData.filter(t => t.estado === 'Resuelto').length,
      cerrado: countsData.filter(t => t.estado === 'Cerrado').length
    }

    filtrarTickets()
  } catch (error) { 
    console.error("Error al cargar tickets:", error) 
  }
}

const crearTicket = async () => {
  if (!nuevoTicket.value.descripcion.trim() || !nuevoTicket.value.tema.trim()) {
    alert("Por favor ingrese un tema y una descripción.")
    return
  }
  
  try {
    loading.value = true
    
    const formData = new FormData()
    formData.append('usuario_id', nuevoTicket.value.usuario_id || '')
    formData.append('identidad', nuevoTicket.value.identidad)
    formData.append('tipo', nuevoTicket.value.tipo)
    formData.append('prioridad', nuevoTicket.value.prioridad)
    formData.append('tema', nuevoTicket.value.tema)
    formData.append('descripcion', nuevoTicket.value.descripcion)
    
    if (archivoTicket.value) {
      formData.append('archivo', archivoTicket.value)
    }

    await axios.post('http://localhost:3007/api/tickets/crear', formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    
    cerrarModal()
    await fetchTickets()
    alert("✅ Ticket enviado con éxito")
  } catch (error) { 
    console.error(error)
    alert("❌ Error al enviar el ticket") 
  } finally {
    loading.value = false
  }
}

const claseEstado = (estado) => {
  const e = estado || 'Pendiente'
  if (e === 'Abierto') return 'bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-blue-200'
  if (e === 'En Progreso') return 'bg-purple-100 text-purple-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-purple-200'
  if (e === 'Pendiente') return 'bg-yellow-100 text-yellow-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-yellow-200'
  if (e === 'Resuelto') return 'bg-green-100 text-green-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-green-200'
  if (e === 'Cerrado') return 'bg-gray-100 text-gray-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-gray-200'
  return 'bg-slate-100 text-slate-700 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest border border-slate-200'
}

const clasePrioridad = (prioridad) => {
  const p = prioridad || 'Media'
  if (p === 'Urgente') return 'text-red-700 font-black'
  if (p === 'Alta') return 'text-red-600 font-bold'
  if (p === 'Baja') return 'text-green-600 font-bold'
  return 'text-yellow-600 font-bold'
}

const formatearFecha = (fechaStr) => {
  if (!fechaStr) return '-'
  return new Date(fechaStr).toLocaleDateString('es-HN', {
    year: 'numeric', month: 'short', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

onMounted(async () => {
  // Inicializar variables de sesión
  const uId = localStorage.getItem('usuarioID')
  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Invitado'
  rolID.value = localStorage.getItem('usuarioRol') || 3
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null
  
  nuevoTicket.value.usuario_id = uId

  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }
  
  try {
    // Cargar menú dinámico
    const m = await axios.get(`http://localhost:3007/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    menuUsuario.value = m.data
  } catch(e) {
    console.error("Error al cargar menú", e)
  }

  // Cargar tickets
  await fetchTickets()
})

const logout = () => { 
  localStorage.clear()
  navigateTo('/login') 
}
</script>