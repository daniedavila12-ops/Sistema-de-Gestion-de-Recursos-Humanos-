<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
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

    <main class="flex-1 ml-64 p-8">
      <header class="mb-10 flex flex-col gap-5 bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div class="flex justify-between items-center w-full">
          <div>
            <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Registrar Vacaciones</h1>
            <p class="text-slate-500 mt-1 font-medium italic">Gestión de vacaciones para los empleados.</p>
          </div>
          <div class="flex items-center gap-6">
            <button v-if="!empleadoSeleccionado" @click="generarPDFVacacionesGlobal" class="bg-indigo-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-indigo-700 transition-all shadow-lg shadow-indigo-200 flex items-center gap-2">
              <span>📄</span> Reportes Vacaciones
            </button>
            <div class="relative">
              <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-6 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors">
                <div v-if="fotoUsuario" class="h-10 w-10 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-slate-100">
                <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
              </div>
              <div v-else class="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-lg ring-2 ring-slate-100 uppercase">
                {{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}
              </div>
              <div class="flex flex-col text-right pr-2">
                <span class="text-[10px] text-slate-400 font-black uppercase tracking-widest">Usuario Activo</span>
                <span class="text-base font-black text-slate-900 leading-tight">{{ nombreUsuario || 'Cargando...' }}</span>
              </div>
            </div>

            <!-- Dropdown Menu -->
            <div v-if="dropdownPerfilAbierto" class="absolute right-0 mt-2 w-64 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50 animate-in slide-in-from-top-2 duration-200">
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
            <!-- Overlay invisible para cerrar el dropdown si se hace click fuera -->
            <div v-if="dropdownPerfilAbierto" @click="dropdownPerfilAbierto = false" class="fixed inset-0 z-40"></div>
          </div>
          </div>
        </div>
      </header>

      <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden p-8">
          <div class="mb-6">
            <label class="block text-xs font-black text-slate-500 uppercase mb-2">Seleccionar Empleado</label>
            
            <div v-if="empleadoSeleccionado" class="flex items-center justify-between p-4 bg-blue-50 border border-blue-200 rounded-xl shadow-sm">
              <div class="flex flex-col items-center gap-3">
                <div v-if="empleadoSeleccionado.foto" @click="modalVerFoto = true" class="relative group cursor-pointer mb-1">
                  <div class="h-24 w-24 rounded-full flex items-center justify-center overflow-hidden ring-4 ring-slate-100 shadow-lg bg-white shrink-0">
                    <img :src="`${$config.public.apiBase}${empleadoSeleccionado.foto}`" class="w-full h-full object-cover" />
                  </div>
                  <div class="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity rounded-full bg-black/50">
                    <span class="text-white text-[10px] font-bold px-2 py-1 text-center">Ver<br>Foto</span>
                  </div>
                </div>
                <div v-else class="relative group cursor-default mb-1">
                  <div class="h-24 w-24 rounded-full bg-white flex items-center justify-center text-blue-400 font-black text-4xl ring-4 ring-slate-100 uppercase shadow-lg shrink-0">
                    {{ empleadoSeleccionado.nombre.charAt(0) }}
                  </div>
                </div>
                <div class="text-center">
                  <p class="text-sm font-bold text-blue-900">{{ empleadoSeleccionado.nombre }} {{ empleadoSeleccionado.apellido }}</p>
                  <p class="text-xs text-blue-700 mt-0.5">{{ empleadoSeleccionado.identidad }} <span v-if="empleadoSeleccionado.codigo_empleado">| Código: {{ empleadoSeleccionado.codigo_empleado }}</span></p>
                </div>
              </div>
              <button @click="limpiarSeleccion" class="px-4 py-2 bg-white text-blue-600 border border-blue-200 rounded-lg text-xs font-bold uppercase hover:bg-blue-600 hover:text-white transition-colors shadow-sm">
                Cambiar Empleado
              </button>
            </div>

            <div v-else class="flex flex-col gap-3">
              <input 
                v-model="searchQuery" 
                type="text" 
                placeholder="Buscar por nombre, apellido o identidad..." 
                class="w-full p-3 rounded-xl bg-slate-50 border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all placeholder:italic shadow-sm"
              >
              <div class="bg-white border border-slate-200 rounded-xl shadow-sm max-h-96 overflow-y-auto">
                <div v-if="empleadosFiltrados.length === 0" class="p-6 text-center text-slate-400 text-sm italic">
                  No se encontraron resultados
                </div>
                <div v-else class="divide-y divide-slate-100">
                  <button 
                    v-for="emp in empleadosFiltrados" 
                    :key="emp.id" 
                    @click="seleccionarEmpleadoBusqueda(emp)"
                    class="w-full text-left p-4 hover:bg-slate-50 transition-colors flex justify-between items-center group"
                    type="button"
                  >
                    <div class="flex items-center gap-4">
                      <div class="h-10 w-10 rounded-full overflow-hidden border border-slate-200 shrink-0 bg-slate-100 flex items-center justify-center">
                        <img v-if="emp.foto" :src="`${$config.public.apiBase}${emp.foto}`" alt="Foto" class="w-full h-full object-cover" />
                        <span v-else class="text-slate-400 font-bold text-sm">{{ emp.nombre.charAt(0) }}</span>
                      </div>
                      <div>
                        <p class="font-bold text-slate-800 group-hover:text-blue-600 transition-colors">{{ emp.nombre }} {{ emp.apellido }}</p>
                        <p class="text-xs text-slate-500 mt-1">{{ emp.identidad }} <span v-if="emp.codigo_empleado">| Código: {{ emp.codigo_empleado }}</span></p>
                      </div>
                    </div>
                    <div class="flex items-center gap-4 text-right">
                      <div class="hidden sm:block">
                        <p class="text-[10px] font-black text-slate-400 uppercase tracking-widest mb-0.5">Ubicación / Piso</p>
                        <p class="text-xs font-bold text-slate-700">{{ emp.ubicacion || 'N/A' }}</p>
                      </div>
                      <span class="text-blue-500 opacity-0 group-hover:opacity-100 transition-opacity text-xl font-bold ml-2">
                        →
                      </span>
                    </div>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div v-if="empleadoSeleccionado">
            <h3 class="text-[12px] font-black text-blue-500 uppercase tracking-[0.2em] mb-4 border-b pb-2">Datos de Empleado</h3>
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-8 bg-slate-50 p-4 rounded-xl border border-slate-100">
              <div>
                <p class="text-[10px] font-black text-slate-400 uppercase">Empleado</p>
                <p class="font-bold text-slate-800 truncate" :title="`${empleadoSeleccionado.nombre} ${empleadoSeleccionado.apellido}`">
                  {{ empleadoSeleccionado.nombre }} {{ empleadoSeleccionado.apellido }}
                </p>
              </div>
              <div>
                <p class="text-[10px] font-black text-slate-400 uppercase">Fecha de Ingreso</p>
                <p class="font-bold text-slate-800">{{ empleadoSeleccionado.fecha_inicio ? new Date(empleadoSeleccionado.fecha_inicio).toLocaleDateString('es-HN') : 'N/A' }}</p>
              </div>
              <div>
                <p class="text-[10px] font-black text-slate-400 uppercase">Años de laborar</p>
                <p class="font-bold text-slate-800">{{ aniosLaboradosCalculados }}</p>
              </div>
              <div>
                <p class="text-[10px] font-black text-slate-400 uppercase">Días Correspondientes</p>
                <p class="font-bold text-slate-800">{{ diasCorrespondientesCalculados }}</p>
              </div>
              <div>
                <p class="text-[10px] font-black text-slate-400 uppercase">Días Pendientes Acumulados</p>
                <p class="font-bold text-orange-500 text-lg">{{ diasPendientesAcumuladosTotales }}</p>
              </div>
            </div>

            <h3 class="text-[12px] font-black text-blue-500 uppercase tracking-[0.2em] mb-4 border-b pb-2">Datos de Vacaciones</h3>
            <form @submit.prevent="guardarVacaciones" class="space-y-4">
              <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
                <div>
                  <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Fecha Solicitud</label>
                  <input type="date" v-model="formVacaciones.fechaSolicitud" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" required>
                </div>
                <div>
                  <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Tipo Solicitud</label>
                  <select v-model="formVacaciones.tipoSolicitud" @change="(!isContinuandoAdelantadas && !isContinuandoNormal) ? formVacaciones.periodo = '' : null" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" required>
                    <option value="">Seleccione...</option>
                    <template v-if="isContinuandoAdelantadas">
                      <option value="Adelantadas">Adelantadas</option>
                      <option value="Normal">Normal</option>
                      <option value="Pagadas">Pagadas</option>
                    </template>
                    <template v-else-if="isContinuandoNormal">
                      <option value="Normal">Normal</option>
                      <option value="Pagadas">Pagadas</option>
                    </template>
                    <template v-else>
                      <option value="Normal">Normal</option>
                      <option v-if="isAdelantadasDisponible" value="Adelantadas">Adelantadas</option>
                      <option value="Pagadas">Pagadas</option>
                      <option value="Permiso Especial">Permiso Especial</option>
                    </template>
                  </select>
                </div>
                <div>
                  <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Periodo</label>
                  <select v-model="formVacaciones.periodo" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" required>
                    <option value="">Seleccione...</option>
                    <option v-if="formVacaciones.periodo && (isEditing || isContinuandoNormal || isContinuandoAdelantadas) && !periodosDisponibles.includes(formVacaciones.periodo)" :value="formVacaciones.periodo">{{ formVacaciones.periodo }}</option>
                    <option v-for="p in periodosDisponibles" :key="p" :value="p">{{ p }}</option>
                  </select>
                </div>
                
                <template v-if="formVacaciones.periodo">
                  <div v-if="formVacaciones.tipoSolicitud === 'Permiso Especial'">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Tipo de Permiso</label>
                    <div class="flex gap-2">
                      <select v-model="formVacaciones.tipoPermiso" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" required>
                        <option value="">Seleccione...</option>
                        <option v-for="tipo in tiposPermisoDisponibles" :key="tipo.id" :value="tipo.nombre">{{ tipo.nombre }}</option>
                      </select>
                      <button v-if="hasPermission('Vacaciones', 'puedeCrear')" type="button" @click="showModalTiposPermiso = true" class="px-3 py-2 bg-slate-200 text-slate-600 rounded-lg hover:bg-slate-300 transition shrink-0" title="Gestionar Tipos de Permiso">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                      </button>
                    </div>
                    <div v-if="formVacaciones.tipoPermiso === 'Otro'" class="mt-2">
                      <input type="text" v-model="nuevoTipoPermiso" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" placeholder="Especifique el tipo de permiso..." required>
                    </div>
                  </div>
                  <div v-if="formVacaciones.tipoSolicitud !== 'Normal' && formVacaciones.tipoSolicitud !== 'Permiso Especial'">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Días Correspondientes (Periodo)</label>
                    <input type="number" v-model="formVacaciones.diasCorrespondientes" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50 disabled:bg-slate-100 disabled:text-slate-500" required :disabled="formVacaciones.tipoSolicitud === 'Pagadas' || formVacaciones.tipoSolicitud === 'Adelantadas'" min="0" step="0.5">
                  </div>
                  <div v-if="formVacaciones.tipoSolicitud !== 'Pagadas'">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">{{ formVacaciones.tipoSolicitud === 'Permiso Especial' ? 'Días a Tomar' : 'Días Vacaciones (A tomar)' }}</label>
                    <input type="number" v-model="formVacaciones.diasVacaciones" @keydown="e => { if(!/^[0-9.]$/.test(e.key) && !['Backspace', 'ArrowLeft', 'ArrowRight', 'Tab', 'Delete'].includes(e.key)) e.preventDefault() }" :max="formVacaciones.tipoSolicitud === 'Permiso Especial' ? 4 : (formVacaciones.tipoSolicitud === 'Normal' || formVacaciones.tipoSolicitud === 'Adelantadas' ? formVacaciones.diasCorrespondientes : '')" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" :required="formVacaciones.tipoSolicitud !== 'Pagadas'" min="0.5" step="0.5">
                  </div>
                  <div v-if="formVacaciones.tipoSolicitud === 'Pagadas'">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Días Pagados</label>
                    <input type="number" v-model="formVacaciones.diasPagados" @keydown="e => { if(!/^[0-9.]$/.test(e.key) && !['Backspace', 'ArrowLeft', 'ArrowRight', 'Tab', 'Delete'].includes(e.key)) e.preventDefault() }" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" required min="0" step="0.5">
                  </div>
                  
                  <div v-if="formVacaciones.tipoSolicitud !== 'Permiso Especial'">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Días Pendientes</label>
                    <input type="number" v-model="formVacaciones.diasPendientes" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50 disabled:bg-slate-100 disabled:text-slate-500" required :disabled="formVacaciones.tipoSolicitud === 'Normal' || formVacaciones.tipoSolicitud === 'Pagadas' || formVacaciones.tipoSolicitud === 'Adelantadas'" step="0.5">
                  </div>
                  <div v-if="formVacaciones.tipoSolicitud !== 'Pagadas'">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Fecha Inicio</label>
                    <input type="date" v-model="formVacaciones.fechaInicio" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" :required="formVacaciones.tipoSolicitud !== 'Pagadas'">
                  </div>
                  <div v-if="formVacaciones.tipoSolicitud !== 'Pagadas'">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Fecha Final</label>
                    <input type="date" v-model="formVacaciones.fechaFinal" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" :required="formVacaciones.tipoSolicitud !== 'Pagadas'">
                  </div>
                  
                  <div v-if="formVacaciones.tipoSolicitud !== 'Pagadas'">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Fecha de Regreso</label>
                    <input type="date" v-model="formVacaciones.fechaRegreso" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" :required="formVacaciones.tipoSolicitud !== 'Pagadas'">
                  </div>
                  <div class="md:col-span-2">
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Autorizado Por</label>
                    <input type="text" v-model="formVacaciones.autorizadoPor" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50" required placeholder="Nombre de quien autoriza">
                  </div>
                </template>
              </div>
              
              <template v-if="formVacaciones.periodo">
                <div class="mt-4 flex flex-col gap-5">
                  <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Observaciones</label>
                    <textarea v-model="formVacaciones.observaciones" rows="3" class="w-full p-2.5 border border-slate-200 rounded-lg text-sm bg-slate-50 resize-none" placeholder="Opcional..."></textarea>
                  </div>
                  <div>
                    <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">
                      {{ formVacaciones.tipoSolicitud === 'Permiso Especial' ? 'Documentación requerida (acta, constancia, certificado)' : 'Documento Vacaciones (Opcional)' }}
                    </label>
                    <input type="file" ref="fileDocumento" class="w-full p-2 border border-slate-200 rounded-lg text-sm bg-slate-50" accept=".pdf,.png,.jpg,.jpeg">
                  </div>
                </div>
                
                <div class="flex justify-end mt-8 pt-6 border-t border-slate-100 gap-3">
                  <button v-if="isEditing" type="button" @click="cancelarEdicion" class="px-6 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold text-sm uppercase tracking-widest hover:bg-slate-200 transition-colors shadow-sm">
                    Cancelar
                  </button>
                  <button v-if="(isEditing && hasPermission('Vacaciones', 'puedeEditar')) || (!isEditing && hasPermission('Vacaciones', 'puedeCrear'))" type="submit" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-bold text-sm uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-lg">
                    {{ isEditing ? 'Actualizar' : 'Guardar' }}
                  </button>
                </div>
              </template>
            </form>

            <div class="mt-12 pt-8 border-t border-slate-100">
              <div class="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 border-b pb-2 gap-4">
                <h3 class="text-[12px] font-black text-blue-500 uppercase tracking-[0.2em]">Historial de Vacaciones</h3>
                <div v-if="vacacionesEmpleado.length > 0" class="flex items-center gap-2">
                  <label class="text-[10px] font-black text-slate-500 uppercase">Filtrar por Periodo:</label>
                  <select v-model="filtroPeriodoHistorial" class="p-2 border border-slate-200 rounded-lg text-xs bg-slate-50 min-w-[120px]">
                    <option value="">Todos</option>
                    <option v-for="p in periodosHistorialUnicos" :key="p" :value="p">{{ p }}</option>
                  </select>
                  <button @click="generarPDFHistorial" type="button" class="px-4 py-2 bg-slate-800 hover:bg-slate-900 text-white rounded-lg font-bold text-xs uppercase tracking-widest transition-colors shadow-sm flex items-center justify-center gap-2 ml-2">
                    <span>📄</span> PDF Historial
                  </button>
                </div>
              </div>
              <div v-if="vacacionesEmpleado.length === 0" class="bg-slate-50 rounded-xl border border-slate-200 p-8 text-center text-slate-400 italic shadow-sm">
                No hay registros de vacaciones anteriores para este empleado.
              </div>
              <div v-else-if="vacacionesHistorialFiltrado.length === 0" class="bg-slate-50 rounded-xl border border-slate-200 p-8 text-center text-slate-400 italic shadow-sm">
                No hay registros para el periodo seleccionado.
              </div>
              <div v-else class="space-y-4">
                <div v-for="v in vacacionesHistorialFiltrado" :key="v.id" class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col gap-3">
                  <div class="flex justify-between items-start">
                    <div class="flex gap-2 items-center">
                      <span class="px-3 py-1 bg-blue-50 text-blue-600 text-[10px] font-black uppercase rounded-lg border border-blue-100">Periodo: {{ v.periodo || 'N/A' }}</span>
                      <span v-if="v.tipoSolicitud" :class="v.tipoSolicitud === 'Adelantadas' ? 'bg-red-50 text-red-600 border-red-200' : 'bg-slate-50 text-slate-600 border-slate-200'" class="px-3 py-1 text-[10px] font-black uppercase rounded-lg border">{{ v.tipoSolicitud }}</span>
                      <span v-if="v.tipoSolicitud === 'Permiso Especial' && v.tipoPermiso" class="px-3 py-1 bg-purple-50 text-purple-600 text-[10px] font-black uppercase rounded-lg border border-purple-200">{{ v.tipoPermiso }}</span>
                    </div>
                    <div class="flex items-start gap-4">
                      <div class="text-right text-[10px] font-black uppercase tracking-widest text-slate-500 bg-slate-50 p-2 rounded-xl border border-slate-100">
                        <p><span class="text-slate-400">Creado por:</span> <span class="text-slate-700">{{ v.creadoPorNombre || 'Admin' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ v.fechaCreacion ? new Date(v.fechaCreacion).toLocaleDateString('es-HN') : (v.fecha_creacion ? new Date(v.fecha_creacion).toLocaleDateString('es-HN') : 'N/A') }}</span></p>
                        <p class="mt-1" v-if="(v.fechaModificacion || v.fecha_modificacion) && (v.fechaModificacion || v.fecha_modificacion) !== (v.fechaCreacion || v.fecha_creacion)"><span class="text-slate-400">Modificado:</span> <span class="text-slate-700">{{ v.modificadoPorNombre || v.creadoPorNombre || 's/d' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ v.fechaModificacion ? new Date(v.fechaModificacion).toLocaleDateString('es-HN') : new Date(v.fecha_modificacion).toLocaleDateString('es-HN') }}</span></p>
                      </div>
                      <button v-if="hasPermission('Vacaciones', 'puedeCrear') && esUltimoRegistroPeriodo(v) && Number(v.diasPendientes) > 0" @click="continuarVacaciones(v)" class="p-2.5 bg-indigo-50 text-indigo-600 hover:bg-indigo-600 hover:text-white rounded-xl transition-all border border-indigo-100 hover:border-indigo-600 shadow-sm flex items-center gap-1" title="Continuar tomando vacaciones de este periodo">
                        <span>➕</span> Continuar
                      </button>
                      <a v-if="v.documento" :href="`${useRuntimeConfig().public.apiBase}${v.documento}`" target="_blank" class="p-2.5 bg-emerald-50 text-emerald-600 hover:bg-emerald-600 hover:text-white rounded-xl transition-all border border-emerald-100 hover:border-emerald-600 shadow-sm flex items-center gap-1" title="Ver Documento">
                        <span>📄</span>
                      </a>
                      <button v-if="hasPermission('Vacaciones', 'puedeEditar')" @click="editarVacacion(v)" class="p-2.5 bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white rounded-xl transition-all border border-blue-100 hover:border-blue-600 shadow-sm flex items-center gap-1" title="Editar Vacaciones">
                        <span>✏️</span>
                      </button>
                      <button v-if="hasPermission('Vacaciones', 'puedeEliminar')" @click="eliminarVacacion(v.id)" class="p-2.5 bg-red-50 text-red-600 hover:bg-red-600 hover:text-white rounded-xl transition-all border border-red-100 hover:border-red-600 shadow-sm flex items-center gap-1" title="Eliminar Vacaciones">
                        <span>🗑️</span>
                      </button>
                    </div>
                  </div>
                  
                  <div class="flex flex-col xl:flex-row gap-6 mt-4">
                    <!-- Resumen de Días -->
                    <div class="flex-1 bg-slate-50/80 rounded-2xl p-5 border border-slate-100 flex justify-between items-center shadow-sm">
                      <div class="text-center flex-1">
                        <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Corresp.</p>
                        <p class="font-black text-indigo-500 text-2xl">{{ Number(v.diasCorrespondientes || 0) }}</p>
                      </div>
                      <div class="w-px h-10 bg-slate-200 hidden sm:block"></div>
                      <div class="text-center flex-1">
                        <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Disfrutados</p>
                        <p class="font-black text-blue-600 text-2xl">{{ v.tipoSolicitud === 'Adelantadas' ? 0 : Number(v.diasVacaciones || 0) }}</p>
                      </div>
                      <div class="w-px h-10 bg-slate-200 hidden sm:block"></div>
                      <div class="text-center flex-1">
                        <p class="text-[9px] font-black text-red-400 uppercase tracking-widest mb-1.5">Adelantados</p>
                        <p class="font-black text-red-500 text-2xl">{{ v.tipoSolicitud === 'Adelantadas' ? Number(v.diasVacaciones || 0) : 0 }}</p>
                      </div>
                      <div class="w-px h-10 bg-slate-200 hidden sm:block"></div>
                      <div class="text-center flex-1">
                        <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Pagados</p>
                        <p class="font-black text-emerald-500 text-2xl">{{ Number(v.diasPagados || 0) }}</p>
                      </div>
                      <div class="w-px h-10 bg-slate-200 hidden sm:block"></div>
                      <div class="text-center flex-1">
                        <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Pendientes</p>
                        <p class="font-black text-orange-500 text-2xl">{{ Number(v.diasPendientes || 0) }}</p>
                      </div>
                    </div>

                    <!-- Fechas -->
                    <div class="flex-1 grid grid-cols-2 sm:grid-cols-4 gap-3">
                      <div class="flex flex-col bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:border-indigo-200 transition-colors">
                        <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2 flex items-center gap-1.5"><span class="text-indigo-500">📅</span> Solicitud</p>
                        <p class="font-bold text-slate-700 text-xs">{{ v.fechaSolicitud ? new Date(v.fechaSolicitud).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A' }}</p>
                      </div>
                      <div class="flex flex-col bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:border-blue-200 transition-colors">
                        <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2 flex items-center gap-1.5"><span class="text-blue-500">▶️</span> Inicio</p>
                        <p class="font-bold text-slate-700 text-xs">{{ v.fechaInicio ? new Date(v.fechaInicio).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A' }}</p>
                      </div>
                      <div class="flex flex-col bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:border-blue-200 transition-colors">
                        <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2 flex items-center gap-1.5"><span class="text-slate-500">⏹️</span> Final</p>
                        <p class="font-bold text-slate-700 text-xs">{{ v.fechaFinal ? new Date(v.fechaFinal).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A' }}</p>
                      </div>
                      <div class="flex flex-col bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:border-emerald-200 transition-colors">
                        <p class="text-[9px] font-black text-emerald-500 uppercase tracking-widest mb-2 flex items-center gap-1.5"><span class="text-emerald-500">🔙</span> Regreso</p>
                        <p class="font-bold text-slate-800 text-xs">{{ v.fechaRegreso ? new Date(v.fechaRegreso).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A' }}</p>
                      </div>
                    </div>
                  </div>

                  <div v-if="v.observaciones" class="mt-2 bg-yellow-50/50 p-4 rounded-xl border border-yellow-100/50">
                    <p class="text-[10px] font-black text-yellow-600 uppercase mb-1">Observaciones</p>
                    <p class="text-sm text-slate-700 font-medium italic">{{ v.observaciones }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div v-else class="text-center text-slate-400 italic py-10">
            Seleccione un empleado de la lista para registrar sus vacaciones.
          </div>
        </div>
    </main>

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
                <img :src="`${useRuntimeConfig().public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
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

    <!-- Modal Ver Foto Empleado -->
    <div v-if="modalVerFoto && empleadoSeleccionado" class="fixed inset-0 bg-slate-900/80 backdrop-blur-sm z-50 flex justify-center items-center p-4">
      <div class="bg-white max-w-2xl w-full overflow-hidden rounded-3xl shadow-2xl animate-in fade-in zoom-in duration-200">
        <div class="p-4 border-b bg-white flex justify-between items-center">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tight">Fotografía de {{ empleadoSeleccionado.nombre }}</h2>
          <button @click="modalVerFoto = false" class="text-slate-400 hover:text-red-500 transition text-3xl leading-none">&times;</button>
        </div>
        <div class="p-4 flex justify-center bg-slate-100">
          <img :src="`${useRuntimeConfig().public.apiBase}${empleadoSeleccionado.foto}`" alt="Foto Empleado" class="max-h-[70vh] rounded-xl object-contain shadow-sm" />
        </div>
      </div>
    </div>

    <!-- Modal Tipos de Permiso -->
    <div v-if="showModalTiposPermiso" class="fixed inset-0 bg-slate-900/80 backdrop-blur-sm z-50 flex justify-center items-center p-4">
      <div class="bg-white max-w-md w-full rounded-3xl shadow-2xl overflow-hidden flex flex-col max-h-[80vh] animate-in fade-in zoom-in duration-200">
        <div class="p-4 border-b bg-white flex justify-between items-center shrink-0">
          <h2 class="text-lg font-black text-slate-800 uppercase tracking-tight">Tipos de Permiso</h2>
          <button @click="showModalTiposPermiso = false" class="text-slate-400 hover:text-red-500 transition text-3xl leading-none">&times;</button>
        </div>
        <div class="p-4 overflow-y-auto flex-1 bg-slate-50">
          <div class="mb-4 flex gap-2">
            <input v-model="nuevoTipoNombre" type="text" placeholder="Nuevo tipo de permiso..." class="flex-1 p-2 border border-slate-200 rounded-lg text-sm" @keyup.enter="agregarTipoPermiso">
            <button @click="agregarTipoPermiso" class="px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-bold uppercase disabled:opacity-50" :disabled="!nuevoTipoNombre.trim() || loadingTipos">Agregar</button>
          </div>
          <div class="space-y-2">
            <div v-for="tipo in tiposPermisoDisponibles" :key="tipo.id" class="flex items-center justify-between p-3 bg-white border border-slate-200 rounded-xl">
              <template v-if="tipoEditando && tipoEditando.id === tipo.id">
                <input v-model="tipoEditando.nombre" type="text" class="flex-1 p-1.5 border border-blue-300 rounded text-sm mr-2 focus:outline-none focus:border-blue-500" @keyup.enter="guardarEdicionTipo(tipo.id)">
                <div class="flex gap-1">
                  <button @click="guardarEdicionTipo(tipo.id)" class="p-1.5 text-green-600 hover:bg-green-50 rounded" title="Guardar">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
                  </button>
                  <button @click="tipoEditando = null" class="p-1.5 text-slate-400 hover:bg-slate-100 rounded" title="Cancelar">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                  </button>
                </div>
              </template>
              <template v-else>
                <span class="text-sm text-slate-700 font-medium">{{ tipo.nombre }}</span>
                <div class="flex gap-1">
                  <button @click="iniciarEdicionTipo(tipo)" class="p-1.5 text-blue-500 hover:bg-blue-50 rounded transition" title="Editar">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"></path></svg>
                  </button>
                  <button @click="eliminarTipoPermiso(tipo.id)" class="p-1.5 text-red-500 hover:bg-red-50 rounded transition" title="Eliminar">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path></svg>
                  </button>
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'
import { io } from 'socket.io-client'
import { usePermisos } from '~/composables/usePermisos'

const { getPermisos, hasPermission } = usePermisos()
const router = useRouter()
let socketInstance = null
const route = useRoute()

// Lógica Modal Perfil
const dropdownPerfilAbierto = ref(false)
const modalAbiertoPerfil = ref(false)
const modalVerFoto = ref(false)
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

const rolID = ref(null)
const rolNombre = ref('Cargando...')
const nombreUsuario = ref('Gerad Cole')
const menuUsuario = ref([])

const listaEmpleados = ref([])
const empleadoSeleccionado = ref(null)
const vacacionesEmpleado = ref([])

const isEditing = ref(false)
const vacacionEditId = ref(null)
const isContinuandoAdelantadas = ref(false)
const isContinuandoNormal = ref(false)

const isAdelantadasDisponible = computed(() => {
  if (!empleadoSeleccionado.value || !empleadoSeleccionado.value.fecha_inicio) return false;
  const inicioStr = empleadoSeleccionado.value.fecha_inicio.includes('T') 
    ? empleadoSeleccionado.value.fecha_inicio.split('T')[0] 
    : empleadoSeleccionado.value.fecha_inicio;
  const inicio = new Date(inicioStr + 'T00:00:00');
  const anioInicio = inicio.getFullYear();
  
  const hoy = new Date();
  let aniosLaboradosReales = hoy.getFullYear() - inicio.getFullYear();
  const m = hoy.getMonth() - inicio.getMonth();
  if (m < 0 || (m === 0 && hoy.getDate() < inicio.getDate())) {
    aniosLaboradosReales--;
  }
  
  const periodoAnioInicio = anioInicio + Math.max(0, aniosLaboradosReales);
  const periodoAdelantado = `${periodoAnioInicio}-${periodoAnioInicio + 1}`;
  
  const isRegistrado = vacacionesEmpleado.value?.some(v => v.periodo === periodoAdelantado && (!isEditing.value || v.id !== vacacionEditId.value));
  return !isRegistrado;
});

const esUltimoRegistroPeriodo = (v) => {
  if (!vacacionesEmpleado.value) return false;
  const delPeriodo = vacacionesEmpleado.value.filter(vac => vac.periodo === v.periodo);
  if (delPeriodo.length === 0) return false;
  const maxId = Math.max(...delPeriodo.map(vac => Number(vac.id)));
  return Number(v.id) === maxId;
}

const continuarVacaciones = (v) => {
  cancelarEdicion();
  formVacaciones.value.periodo = v.periodo;
  if (v.tipoSolicitud === 'Adelantadas') {
    formVacaciones.value.tipoSolicitud = 'Adelantadas';
    isContinuandoAdelantadas.value = true;
    isContinuandoNormal.value = false;
  } else if (v.tipoSolicitud === 'Normal' || v.tipoSolicitud === 'Pagadas') {
    formVacaciones.value.tipoSolicitud = v.tipoSolicitud;
    isContinuandoAdelantadas.value = false;
    isContinuandoNormal.value = true;
  } else {
    formVacaciones.value.tipoSolicitud = 'Normal';
    isContinuandoAdelantadas.value = false;
    isContinuandoNormal.value = false;
  }
  window.scrollTo({ top: 0, behavior: 'smooth' });

  // Ejecutar después de que los watchers del 'periodo' actualicen el formulario
  setTimeout(() => {
    formVacaciones.value.diasCorrespondientes = v.diasPendientes;
    calcularDiasPendientes();
  }, 50);
}
const aniosLaboradosCalculados = computed(() => {
  if (!empleadoSeleccionado.value || !empleadoSeleccionado.value.fecha_inicio) return 0;
  const inicioStr = empleadoSeleccionado.value.fecha_inicio.includes('T') 
    ? empleadoSeleccionado.value.fecha_inicio.split('T')[0] 
    : empleadoSeleccionado.value.fecha_inicio;
  const inicio = new Date(inicioStr + 'T00:00:00');
  
  if (formVacaciones.value.periodo) {
    const anioFin = parseInt(formVacaciones.value.periodo.split('-')[1]);
    return Math.max(0, anioFin - inicio.getFullYear());
  } else {
    const hoy = new Date();
    let anios = hoy.getFullYear() - inicio.getFullYear();
    const m = hoy.getMonth() - inicio.getMonth();
    if (m < 0 || (m === 0 && hoy.getDate() < inicio.getDate())) {
      anios--;
    }
    return Math.max(0, anios);
  }
});

const diasCorrespondientesCalculados = computed(() => {
  const anios = aniosLaboradosCalculados.value;
  if (anios >= 4) return 20;
  if (anios === 3) return 15;
  if (anios === 2) return 12;
  if (anios === 1) return 10;
  return 0;
});

const diasPendientesAcumuladosTotales = computed(() => {
  if (!empleadoSeleccionado.value || !empleadoSeleccionado.value.fecha_inicio) return 0;
  const inicioStr = empleadoSeleccionado.value.fecha_inicio.includes('T') 
    ? empleadoSeleccionado.value.fecha_inicio.split('T')[0] 
    : empleadoSeleccionado.value.fecha_inicio;
  const inicio = new Date(inicioStr + 'T00:00:00');
  const anioInicio = inicio.getFullYear();
  
  const hoy = new Date();
  let aniosLaboradosReales = hoy.getFullYear() - inicio.getFullYear();
  const m = hoy.getMonth() - inicio.getMonth();
  if (m < 0 || (m === 0 && hoy.getDate() < inicio.getDate())) {
    aniosLaboradosReales--;
  }
  
  let totalCorrespondientesAcumulados = 0;
  let periodosProcesados = new Set();
  
  // 1. Sumar los días correspondientes de todos los años COMPLETADOS (después de 1 año)
  for (let i = 0; i < aniosLaboradosReales; i++) {
     const periodoAnioInicio = anioInicio + i;
     const periodo = `${periodoAnioInicio}-${periodoAnioInicio + 1}`;
     periodosProcesados.add(periodo);
     
     const vacacionesPeriodo = vacacionesEmpleado.value?.filter(v => v.periodo === periodo) || [];
     if (vacacionesPeriodo.length > 0) {
         // El registro más antiguo tiene el total original de días correspondientes
         const vacacionOriginal = [...vacacionesPeriodo].sort((a, b) => a.id - b.id)[0];
         totalCorrespondientesAcumulados += Number(vacacionOriginal.diasCorrespondientes);
     } else {
         const anios = i + 1;
         if (anios >= 4) totalCorrespondientesAcumulados += 20;
         else if (anios === 3) totalCorrespondientesAcumulados += 15;
         else if (anios === 2) totalCorrespondientesAcumulados += 12;
         else if (anios === 1) totalCorrespondientesAcumulados += 10;
     }
  }

  // 2. Sumar periodos adicionales que estén en la BD (ej. adelantadas futuras)
  if (vacacionesEmpleado.value) {
      vacacionesEmpleado.value.forEach(vacacion => {
          if (vacacion.periodo && !periodosProcesados.has(vacacion.periodo)) {
              periodosProcesados.add(vacacion.periodo);
          }
      });
  }

  // 3. Restar todos los días tomados, EXCLUYENDO el registro que se está editando actualmente
  let totalDiasTomadosYPagados = 0;
  if (vacacionesEmpleado.value && vacacionesEmpleado.value.length > 0) {
    totalDiasTomadosYPagados = vacacionesEmpleado.value.reduce((total, vacacion) => {
      // Si estamos editando este registro, no restamos sus días tomados del acumulado base
      if (isEditing.value && vacacion.id === vacacionEditId.value) {
        return total;
      }
      let aRestar = 0;
      if (vacacion.tipoSolicitud === 'Pagadas') {
        aRestar = (Number(vacacion.diasVacaciones) || 0) + (Number(vacacion.diasPagados) || 0);
      } else if (vacacion.tipoSolicitud !== 'Permiso Especial') {
        aRestar = (Number(vacacion.diasVacaciones) || 0);
      }
      return total + aRestar; 
      }, 0);  }

  const resultado = totalCorrespondientesAcumulados - totalDiasTomadosYPagados;
  return resultado < 0 ? 0 : resultado;
});

const periodosDisponibles = computed(() => {
  if (!empleadoSeleccionado.value || !empleadoSeleccionado.value.fecha_inicio) return [];
  if (isContinuandoNormal.value || isContinuandoAdelantadas.value) return [];
  const inicioStr = empleadoSeleccionado.value.fecha_inicio.includes('T') 
    ? empleadoSeleccionado.value.fecha_inicio.split('T')[0] 
    : empleadoSeleccionado.value.fecha_inicio;
  const inicio = new Date(inicioStr + 'T00:00:00');
  const anioInicio = inicio.getFullYear();
  const anioActual = new Date().getFullYear();
  const periodos = [];
  
  if (formVacaciones.value.tipoSolicitud === 'Adelantadas') {
    const hoy = new Date();
    let aniosLaboradosReales = hoy.getFullYear() - inicio.getFullYear();
    const m = hoy.getMonth() - inicio.getMonth();
    if (m < 0 || (m === 0 && hoy.getDate() < inicio.getDate())) {
      aniosLaboradosReales--;
    }
    const periodoAnioInicio = anioInicio + Math.max(0, aniosLaboradosReales);
    const periodoAdelantado = `${periodoAnioInicio}-${periodoAnioInicio + 1}`;
    const isRegistrado = vacacionesEmpleado.value?.some(v => v.periodo === periodoAdelantado && (!isEditing.value || v.id !== vacacionEditId.value));
    if (!isRegistrado) {
      periodos.push(periodoAdelantado);
    }
  } else if (formVacaciones.value.tipoSolicitud === 'Normal' || formVacaciones.value.tipoSolicitud === 'Pagadas') {
    const hoy = new Date();
    let aniosLaboradosReales = hoy.getFullYear() - inicio.getFullYear();
    const m = hoy.getMonth() - inicio.getMonth();
    if (m < 0 || (m === 0 && hoy.getDate() < inicio.getDate())) {
      aniosLaboradosReales--;
    }
    
    for (let i = 0; i < aniosLaboradosReales; i++) {
      const periodoAnioInicio = anioInicio + i;
      const periodo = `${periodoAnioInicio}-${periodoAnioInicio + 1}`;
      const isRegistrado = vacacionesEmpleado.value?.some(v => v.periodo === periodo && (!isEditing.value || v.id !== vacacionEditId.value));
      if (!isRegistrado) {
        periodos.push(periodo);
      }
    }
  } else if (formVacaciones.value.tipoSolicitud === 'Permiso Especial') {
    for (let i = anioInicio; i <= anioActual; i++) {
      const periodo = `${i}-${i + 1}`;
      periodos.push(periodo);
    }
  } else {
    for (let i = anioInicio; i <= anioActual; i++) {
      const periodo = `${i}-${i + 1}`;
      const isRegistrado = vacacionesEmpleado.value?.some(v => v.periodo === periodo && (!isEditing.value || v.id !== vacacionEditId.value));
      if (!isRegistrado) {
        periodos.push(periodo);
      }
    }
  }
  
  return periodos.reverse();
});

const filtroPeriodoHistorial = ref('');

const periodosHistorialUnicos = computed(() => {
  if (!vacacionesEmpleado.value) return [];
  const periodos = new Set(vacacionesEmpleado.value.map(v => v.periodo).filter(Boolean));
  return Array.from(periodos).sort((a, b) => b.localeCompare(a));
});

const vacacionesHistorialFiltrado = computed(() => {
  if (!filtroPeriodoHistorial.value) return vacacionesEmpleado.value;
  return vacacionesEmpleado.value.filter(v => v.periodo === filtroPeriodoHistorial.value);
});

const searchQuery = ref('')
const empleadosFiltrados = computed(() => {
  // Filtrar solo empleados activos
  const empleadosActivos = listaEmpleados.value.filter(emp => emp.estado === 'Activo' || emp.estado === 1 || emp.estado === true);

  if (!searchQuery.value) return empleadosActivos;
  
  const lowerCaseQuery = searchQuery.value.toLowerCase();
  return empleadosActivos.filter(emp => {
    const fullName = `${emp.nombre} ${emp.apellido}`.toLowerCase();
    const identity = emp.identidad?.toLowerCase() || '';
    const code = emp.codigo_empleado?.toLowerCase() || '';
    return fullName.includes(lowerCaseQuery) || identity.includes(lowerCaseQuery) || code.includes(lowerCaseQuery);
  });
})

const formVacaciones = ref({
  fechaSolicitud: new Date().toISOString().split('T')[0],
  tipoSolicitud: '',
  tipoPermiso: '',
  periodo: '',
  diasCorrespondientes: 0,
  diasVacaciones: 0,
  diasPagados: 0,
  diasPendientes: 0,
  fechaInicio: '',
  fechaFinal: '',
  fechaRegreso: '',
  observaciones: '',
  autorizadoPor: '',
  diasCorrespondientesEmpleado: 14 // Se actualizará dinámicamente
})

const tiposPermisoDisponibles = ref([]);
const nuevoTipoPermiso = ref('');

const showModalTiposPermiso = ref(false);
const nuevoTipoNombre = ref('');
const tipoEditando = ref(null);
const loadingTipos = ref(false);

const cargarTiposPermiso = async () => {
  try {
    const res = await axios.get('/api/vacaciones/tipos-permiso');
    tiposPermisoDisponibles.value = res.data;
  } catch (error) {
    console.error('Error cargando tipos de permiso:', error);
  }
}

const agregarTipoPermiso = async () => {
  if (!nuevoTipoNombre.value.trim() || loadingTipos.value) return;
  try {
    loadingTipos.value = true;
    await axios.post('/api/vacaciones/tipos-permiso', { nombre: nuevoTipoNombre.value.trim() });
    nuevoTipoNombre.value = '';
    await cargarTiposPermiso();
  } catch (error) {
    alert(error.response?.data?.error || 'Error al agregar el tipo de permiso');
  } finally {
    loadingTipos.value = false;
  }
}

const iniciarEdicionTipo = (tipo) => {
  tipoEditando.value = { ...tipo };
}

const guardarEdicionTipo = async (id) => {
  if (!tipoEditando.value.nombre.trim()) return;
  try {
    loadingTipos.value = true;
    await axios.put(`/api/vacaciones/tipos-permiso/${id}`, { nombre: tipoEditando.value.nombre.trim() });
    
    // Si estaba seleccionado este tipo en el form, lo actualizamos al nuevo nombre
    const tipoAnterior = tiposPermisoDisponibles.value.find(t => t.id === id);
    if (tipoAnterior && formVacaciones.value.tipoPermiso === tipoAnterior.nombre) {
      formVacaciones.value.tipoPermiso = tipoEditando.value.nombre.trim();
    }
    
    tipoEditando.value = null;
    await cargarTiposPermiso();
  } catch (error) {
    alert(error.response?.data?.error || 'Error al editar el tipo de permiso');
  } finally {
    loadingTipos.value = false;
  }
}

const eliminarTipoPermiso = async (id) => {
  if (!confirm('¿Está seguro de eliminar este tipo de permiso?')) return;
  try {
    loadingTipos.value = true;
    const tipoAEliminar = tiposPermisoDisponibles.value.find(t => t.id === id);
    
    await axios.delete(`/api/vacaciones/tipos-permiso/${id}`);
    
    // Si estaba seleccionado en el form, lo limpiamos
    if (tipoAEliminar && formVacaciones.value.tipoPermiso === tipoAEliminar.nombre) {
      formVacaciones.value.tipoPermiso = '';
    }
    
    await cargarTiposPermiso();
  } catch (error) {
    alert(error.response?.data?.error || 'Error al eliminar el tipo de permiso');
  } finally {
    loadingTipos.value = false;
  }
}

const calcularDiasPendientes = () => {
  const correspondientes = Number(formVacaciones.value.diasCorrespondientes) || 0;
  const tomados = Number(formVacaciones.value.diasVacaciones) || 0;
  const pagados = Number(formVacaciones.value.diasPagados) || 0;
  
  let pendientes;
  if (formVacaciones.value.tipoSolicitud === 'Pagadas') {
    pendientes = correspondientes - pagados - tomados;
    if (pendientes < 0) {
      pendientes = diasPendientesAcumuladosTotales.value - pagados - tomados;
    }
  } else {
    pendientes = correspondientes - tomados;
    if (pendientes < 0) {
      pendientes = diasPendientesAcumuladosTotales.value - tomados;
    }
  }
  
  formVacaciones.value.diasPendientes = pendientes;
}

watch([() => formVacaciones.value.fechaInicio, () => formVacaciones.value.diasVacaciones], ([inicio, dias]) => {
  if (inicio && dias > 0) {
    const dInicio = new Date(inicio + 'T00:00:00');
    let diasContados = 0;
    let fechaActual = new Date(dInicio);

    // Si el día de inicio es domingo (no hábil), avanzamos un día para empezar a contar
    if (fechaActual.getDay() === 0) {
        fechaActual.setDate(fechaActual.getDate() + 1);
    }
    
    // Contar los días para fechaFinal
    while (diasContados < dias) {
      if (fechaActual.getDay() !== 0) { // 0 es Domingo
        diasContados++;
      }
      if (diasContados < dias) {
        fechaActual.setDate(fechaActual.getDate() + 1);
      }
    }
    
    formVacaciones.value.fechaFinal = fechaActual.toISOString().split('T')[0];

    // Calcular fechaRegreso (siguiente día hábil después de la fechaFinal)
    let fRegreso = new Date(fechaActual);
    fRegreso.setDate(fRegreso.getDate() + 1);
    while (fRegreso.getDay() === 0) { // Si es domingo, sumar uno
      fRegreso.setDate(fRegreso.getDate() + 1);
    }
    formVacaciones.value.fechaRegreso = fRegreso.toISOString().split('T')[0];
    
    if (formVacaciones.value.tipoSolicitud === 'Permiso Especial' || formVacaciones.value.tipoSolicitud === 'Normal' || formVacaciones.value.tipoSolicitud === 'Adelantadas') {
      formVacaciones.value.diasPagados = 0;
    } else if (formVacaciones.value.tipoSolicitud !== 'Pagadas') {
      formVacaciones.value.diasPagados = dias;
    }
    calcularDiasPendientes();
  } else if (!inicio) {
    formVacaciones.value.fechaFinal = '';
    formVacaciones.value.fechaRegreso = '';
    if (formVacaciones.value.tipoSolicitud === 'Permiso Especial' || formVacaciones.value.tipoSolicitud === 'Normal' || formVacaciones.value.tipoSolicitud === 'Adelantadas') {
      formVacaciones.value.diasPagados = 0;
    } else if (formVacaciones.value.tipoSolicitud !== 'Pagadas') {
      formVacaciones.value.diasPagados = dias || 0;
    }
    calcularDiasPendientes();
  }
})

watch(() => formVacaciones.value.diasVacaciones, (newVal) => {
  if (newVal < 0) {
    formVacaciones.value.diasVacaciones = 0;
    return;
  }
  
  const val = Number(newVal);
  const correspondientes = Number(formVacaciones.value.diasCorrespondientes);

  if (formVacaciones.value.tipoSolicitud === 'Permiso Especial') {
    if (val > 4) {
      formVacaciones.value.diasVacaciones = 4;
    }
    formVacaciones.value.diasPagados = 0;
  } else if (formVacaciones.value.tipoSolicitud === 'Normal') {
    if (val > correspondientes) {
      formVacaciones.value.diasVacaciones = correspondientes;
    }
    formVacaciones.value.diasPagados = 0;
  } else if (formVacaciones.value.tipoSolicitud === 'Adelantadas') {
    if (val > correspondientes) {
      formVacaciones.value.diasVacaciones = correspondientes;
    }
    formVacaciones.value.diasPagados = 0;
  } else {
    formVacaciones.value.diasPagados = val;
  }
})

watch(() => formVacaciones.value.diasPagados, (newVal) => {
  if (newVal < 0) {
    formVacaciones.value.diasPagados = 0;
    return;
  }
  if (formVacaciones.value.tipoSolicitud === 'Pagadas') {
    if (newVal > formVacaciones.value.diasCorrespondientes) {
      formVacaciones.value.diasPagados = formVacaciones.value.diasCorrespondientes;
    }
  }
})

watch(() => formVacaciones.value.tipoSolicitud, (newVal) => {
  if (newVal === 'Permiso Especial') {
    formVacaciones.value.diasPagados = 0;
    if (formVacaciones.value.diasVacaciones > 4) {
      formVacaciones.value.diasVacaciones = 4;
    }
  } else if (newVal === 'Normal' || newVal === 'Adelantadas') {
    formVacaciones.value.diasPagados = 0;
  } else {
    formVacaciones.value.diasPagados = formVacaciones.value.diasVacaciones;
  }
})

watch([() => formVacaciones.value.diasCorrespondientes, () => formVacaciones.value.diasVacaciones, () => formVacaciones.value.diasPagados], () => {
  calcularDiasPendientes();
})

watch(() => formVacaciones.value.periodo, () => {
  if (!isEditing.value) {
    formVacaciones.value.diasCorrespondientes = diasCorrespondientesCalculados.value;
    calcularDiasPendientes();
  }
})

const cargarVacaciones = async (id) => {
  try {
    const res = await axios.get(`/api/vacaciones/empleado/${id}`)
    const records = res.data;
    
    let empFechaInicio = empleadoSeleccionado.value?.fecha_inicio;
    
    // Recalcular días pendientes dinámicamente para el historial basado en los registros actuales
    const periodos = {};
    const reversedRecords = [...records].sort((a, b) => a.id - b.id);
    
    reversedRecords.forEach(v => {
        if (periodos[v.periodo] === undefined) {
            let base = 0;
            if (empFechaInicio && v.periodo && v.periodo.includes('-')) {
                const inicioStr = empFechaInicio.includes('T') ? empFechaInicio.split('T')[0] : empFechaInicio;
                const anioInicioEmp = new Date(inicioStr + 'T00:00:00').getFullYear();
                const anioPeriodo = parseInt(v.periodo.split('-')[0]);
                const anios = anioPeriodo - anioInicioEmp + 1;
                if (anios >= 4) base = 20;
                else if (anios === 3) base = 15;
                else if (anios === 2) base = 12;
                else if (anios === 1) base = 10;
            }
            if (base === 0 || v.tipoSolicitud === 'Permiso Especial') {
                base = Number(v.diasCorrespondientes) || 0;
            }
            periodos[v.periodo] = base;
            v.diasCorrespondientes = base;
        } else {
            v.diasCorrespondientes = periodos[v.periodo];
        }
        
        let aRestar = 0;
        if (v.tipoSolicitud === 'Pagadas') {
            aRestar = (Number(v.diasVacaciones) || 0) + (Number(v.diasPagados) || 0);
        } else if (v.tipoSolicitud !== 'Permiso Especial') {
            aRestar = (Number(v.diasVacaciones) || 0);
        }
        
        v.diasPendientes = v.diasCorrespondientes - aRestar;
        periodos[v.periodo] = v.diasPendientes;
    });
    
    vacacionesEmpleado.value = records;
  } catch (error) {
    console.error('Error al cargar historial de vacaciones:', error)
  }
}

watch(empleadoSeleccionado, async (nuevoEmpleado) => {
  if (nuevoEmpleado) {
    try {
      const resContratos = await axios.get(`/api/empleados/${nuevoEmpleado.id}/contratos`);
      const contratos = resContratos.data;
      if (contratos && contratos.length > 0) {
        // Find the oldest contract by sorting ascending
        const firstContrato = [...contratos].sort((a, b) => new Date(a.fechaInicio) - new Date(b.fechaInicio))[0];
        if (firstContrato && firstContrato.fechaInicio) {
          nuevoEmpleado.fecha_inicio = firstContrato.fechaInicio;
        }
      }
    } catch (e) {
      console.error("Error cargando contratos del empleado para fecha de ingreso", e);
    }
    
    // Inicializar los días correspondientes según los años de servicio del empleado seleccionado
    formVacaciones.value.diasCorrespondientesEmpleado = diasCorrespondientesCalculados.value;
    
    // Si no estamos editando (es un registro nuevo), autollenar el campo 'Días Correspondientes (Periodo)'
    if (!isEditing.value) {
      formVacaciones.value.diasCorrespondientes = diasCorrespondientesCalculados.value;
      calcularDiasPendientes();
    }

    await cargarVacaciones(nuevoEmpleado.id)
    if (route.query.editar) {
      const vId = Number(route.query.editar)
      const foundV = vacacionesEmpleado.value.find(v => v.id === vId)
      if (foundV) {
        editarVacacion(foundV)
        // Limpiamos la URL para no volver a entrar si cambia de empleado
        router.replace({ query: { empleadoId: route.query.empleadoId } })
      }
    }
  } else {
    vacacionesEmpleado.value = []
  }
})

const logout = () => {
  localStorage.clear()
  navigateTo('/login')
}

const editarVacacion = (v) => {
  isEditing.value = true
  vacacionEditId.value = v.id
  formVacaciones.value = {
    fechaSolicitud: v.fechaSolicitud ? new Date(v.fechaSolicitud).toISOString().split('T')[0] : '',
    tipoSolicitud: v.tipoSolicitud || '',
    tipoPermiso: v.tipoPermiso || '',
    periodo: v.periodo || '',
    diasCorrespondientes: v.diasCorrespondientes || 0,
    diasVacaciones: v.diasVacaciones || 0,
    diasPagados: v.diasPagados || 0,
    diasPendientes: v.diasPendientes || 0,
    fechaInicio: v.fechaInicio ? new Date(v.fechaInicio).toISOString().split('T')[0] : '',
    fechaFinal: v.fechaFinal ? new Date(v.fechaFinal).toISOString().split('T')[0] : '',
    fechaRegreso: v.fechaRegreso ? new Date(v.fechaRegreso).toISOString().split('T')[0] : '',
    observaciones: v.observaciones || '',
    autorizadoPor: v.autorizadoPor || '',
    diasCorrespondientesEmpleado: v.diasCorrespondientesEmpleado || 14
  }
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const cancelarEdicion = () => {
  isEditing.value = false
  vacacionEditId.value = null
  isContinuandoAdelantadas.value = false
  isContinuandoNormal.value = false
  nuevoTipoPermiso.value = ''
  formVacaciones.value = {
    fechaSolicitud: new Date().toISOString().split('T')[0],
    tipoSolicitud: '',
    tipoPermiso: '',
    periodo: '',
    diasCorrespondientes: 0,
    diasVacaciones: 0,
    diasPagados: 0,
    diasPendientes: 0,
    fechaInicio: '',
    fechaFinal: '',
    fechaRegreso: '',
    observaciones: '',
    autorizadoPor: '',
    diasCorrespondientesEmpleado: 14
  }
}

const seleccionarEmpleadoBusqueda = (emp) => {
  empleadoSeleccionado.value = emp;
  searchQuery.value = '';
}

const limpiarSeleccion = () => {
  empleadoSeleccionado.value = null;
  searchQuery.value = '';
  cancelarEdicion();
  router.replace({ query: {} });
}

const fileDocumento = ref(null)

const guardarVacaciones = async () => {
  if (!empleadoSeleccionado.value) {
    alert('❌ Debe seleccionar un empleado')
    return
  }

  // Validar fecha repetida
  if (formVacaciones.value.fechaInicio) {
    const fechaExiste = vacacionesEmpleado.value.some(v => {
      // Ignorar el registro actual si estamos editando
      if (isEditing.value && v.id === vacacionEditId.value) return false;
      
      const vFechaInicio = v.fechaInicio ? new Date(v.fechaInicio).toISOString().split('T')[0] : null;
      return vFechaInicio === formVacaciones.value.fechaInicio;
    });

    if (fechaExiste) {
      alert('¡ Esta Fecha ya fue seleccionada porfavor  ingrese una fecha correcta');
      return;
    }
  }

  if (formVacaciones.value.tipoSolicitud === 'Pagadas') {
    if (Number(formVacaciones.value.diasPagados) < 0) {
      alert('❌ Los Días Pagados no pueden ser negativos.');
      return;
    }
    if (Number(formVacaciones.value.diasPagados) > Number(formVacaciones.value.diasCorrespondientes)) {
      alert('❌ Los Días Pagados no pueden ser mayores a los Días Correspondientes (Periodo).');
      return;
    }
  } else if (formVacaciones.value.diasPendientes < 0 && formVacaciones.value.tipoSolicitud !== 'Permiso Especial') {
    alert('❌ No Cuenta con dias Pendiente o Acumulados, porfavor Solicite Vacaciones adelantadas si le corresponde.')
    return
  }

  try {
    const formData = new FormData();
    formData.append('empleado_id', empleadoSeleccionado.value.id);
    formData.append('fechaIngreso', empleadoSeleccionado.value.fecha_inicio || '');
    formData.append('aniosLaborados', empleadoSeleccionado.value.fecha_inicio ? Math.max(0, new Date().getFullYear() - new Date(empleadoSeleccionado.value.fecha_inicio).getFullYear()) : 0);
    formData.append('diasCorrespondientesEmpleado', formVacaciones.value.diasCorrespondientesEmpleado);
    formData.append('fechaSolicitud', formVacaciones.value.fechaSolicitud);
    formData.append('tipoSolicitud', formVacaciones.value.tipoSolicitud);
    if (formVacaciones.value.tipoPermiso) {
      if (formVacaciones.value.tipoPermiso === 'Otro' && nuevoTipoPermiso.value) {
        formData.append('tipoPermiso', nuevoTipoPermiso.value);
      } else {
        formData.append('tipoPermiso', formVacaciones.value.tipoPermiso);
      }
    }
    formData.append('periodo', formVacaciones.value.periodo);
    formData.append('diasCorrespondientes', formVacaciones.value.diasCorrespondientes);
    formData.append('diasVacaciones', formVacaciones.value.diasVacaciones);
    formData.append('diasPagados', formVacaciones.value.diasPagados);
    formData.append('diasPendientes', formVacaciones.value.diasPendientes);
    if (formVacaciones.value.fechaInicio) formData.append('fechaInicio', formVacaciones.value.fechaInicio);
    if (formVacaciones.value.fechaFinal) formData.append('fechaFinal', formVacaciones.value.fechaFinal);
    if (formVacaciones.value.fechaRegreso) formData.append('fechaRegreso', formVacaciones.value.fechaRegreso);
    formData.append('observaciones', formVacaciones.value.observaciones || '');
    formData.append('autorizadoPor', formVacaciones.value.autorizadoPor || '');
    formData.append('usuario_id', localStorage.getItem('usuarioID'));

    if (fileDocumento.value && fileDocumento.value.files[0]) {
      formData.append('documento', fileDocumento.value.files[0]);
    }

    if (isEditing.value) {
      await axios.put(`/api/vacaciones/${vacacionEditId.value}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      alert('✅ Vacaciones actualizadas correctamente')
    } else {
      await axios.post('/api/vacaciones/registrar', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      if (formVacaciones.value.tipoSolicitud === 'Permiso Especial') {
        alert('✅ Permiso Especial guardado con Exito');
      } else {
        alert('✅ Vacaciones registradas correctamente en la Base de Datos');
      }
    }
    
    await cargarTiposPermiso()
    await cargarVacaciones(empleadoSeleccionado.value.id)
    cancelarEdicion()
    if (fileDocumento.value) fileDocumento.value.value = ''; // Reset file input
  } catch (error) {
    console.error('Error al registrar/actualizar vacaciones:', error)
    alert('❌ Error al procesar las vacaciones: ' + (error.response?.data?.error || error.message))
  }
}

const eliminarVacacion = async (id) => {
  if (confirm('¿Estás seguro de que deseas eliminar este registro de vacaciones?')) {
    try {
      await axios.delete(`/api/vacaciones/${id}`);
      alert('✅ Registro de vacaciones eliminado correctamente');
      if (empleadoSeleccionado.value) {
        await cargarVacaciones(empleadoSeleccionado.value.id);
      }
    } catch (error) {
      console.error('Error al eliminar vacaciones:', error);
      alert('❌ Error al eliminar el registro de vacaciones');
    }
  }
}

const generarPDFHistorial = async () => {
  if (!empleadoSeleccionado.value || vacacionesHistorialFiltrado.value.length === 0) {
    alert('No hay registros en el historial para exportar.');
    return;
  }

  try {
    const doc = new jsPDF('landscape');
    
    let startX = 14;

    // Intentar cargar y agregar la foto del empleado
    if (empleadoSeleccionado.value.foto) {
      const imgFoto = new Image();
      imgFoto.crossOrigin = "Anonymous";
      imgFoto.src = `${useRuntimeConfig().public.apiBase}${empleadoSeleccionado.value.foto}`;
      
      await new Promise((resolve) => {
        imgFoto.onload = resolve;
        imgFoto.onerror = resolve; // Si falla, continuamos
      });
      
      try {
        const ext = imgFoto.src.toUpperCase().includes('.PNG') ? 'PNG' : 'JPEG';
        // Dibujar la foto
        doc.addImage(imgFoto, ext, 14, 12, 22, 22);
        
        // Agregar un borde sutil alrededor de la foto para darle un toque más profesional
        doc.setDrawColor(203, 213, 225); // Slate 300
        doc.setLineWidth(0.5);
        doc.rect(14, 12, 22, 22);
        
        startX = 42; // Desplazar el texto a la derecha de la foto
      } catch(e) {
        console.warn('No se pudo cargar la foto del empleado al PDF');
      }
    }

    // Encabezado
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42); // Slate 900
    doc.setFont('helvetica', 'bold');
    doc.text('HISTORIAL DE VACACIONES', startX, 20);
    
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); // Slate 500
    doc.setFont('helvetica', 'normal');
    doc.text(`Empleado: ${empleadoSeleccionado.value.nombre} ${empleadoSeleccionado.value.apellido} | Identidad: ${empleadoSeleccionado.value.identidad}`, startX, 28);
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, startX, 33);
    
    // Cargar Logo Superior Derecho
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = `${useRuntimeConfig().public.apiBase}/uploads/Logo/Logo.png`;
    await new Promise((resolve) => {
      imgLogo.onload = resolve;
      imgLogo.onerror = resolve;
    });
    try { doc.addImage(imgLogo, 'PNG', 240, 10, 35, 15); } catch(e) {}
    
    // Línea divisoria
    doc.setDrawColor(226, 232, 240); // Slate 200
    doc.setLineWidth(0.5);
    doc.line(14, 38, 280, 38);

    // Preparar datos para la tabla
    const tableData = vacacionesHistorialFiltrado.value.map(v => [
      v.periodo || 'N/A',
      v.tipoSolicitud || 'N/A',
      Number(v.diasCorrespondientes || 0),
      v.tipoSolicitud === 'Adelantadas' ? 0 : Number(v.diasVacaciones || 0),
      v.tipoSolicitud === 'Adelantadas' ? Number(v.diasVacaciones || 0) : 0,
      Number(v.diasPagados || 0),
      Number(v.diasPendientes || 0),
      v.fechaInicio ? new Date(v.fechaInicio).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A',
      v.fechaFinal ? new Date(v.fechaFinal).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A',
      v.fechaRegreso ? new Date(v.fechaRegreso).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A',
    ]);

    autoTable(doc, {
      startY: 45,
      head: [['Periodo', 'Tipo Solicitud', 'D. Corresp.', 'D. Disfrutados', 'D. Adelan.', 'D. Pagados', 'D. Pendientes', 'Fecha Inicio', 'Fecha Final', 'Fecha Regreso']],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [30, 41, 59], textColor: [255, 255, 255], fontStyle: 'bold' },
      alternateRowStyles: { fillColor: [248, 250, 252] },
      styles: { fontSize: 8, cellPadding: 3 },
    });

    doc.save(`Historial_Vacaciones_${empleadoSeleccionado.value.nombre}_${empleadoSeleccionado.value.apellido}.pdf`);
  } catch (error) {
    console.error('Error generando PDF:', error);
    alert('Hubo un error al generar el PDF.');
  }
};

const generarPDFVacacionesGlobal = async () => {
  try {
    const doc = new jsPDF('landscape');
    
    // Encabezado
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42); 
    doc.setFont('helvetica', 'bold');
    doc.text('REPORTE GLOBAL DE EMPLEADOS Y VACACIONES BASE', 14, 20);
    
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139); 
    doc.setFont('helvetica', 'normal');
    doc.text(`Generado el: ${new Date().toLocaleString('es-HN')}`, 14, 28);
    
    // Cargar Logo Superior Derecho
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = `${useRuntimeConfig().public.apiBase}/uploads/Logo/Logo.png`;
    await new Promise((resolve) => {
      imgLogo.onload = resolve;
      imgLogo.onerror = resolve;
    });
    try { doc.addImage(imgLogo, 'PNG', 240, 10, 35, 15); } catch(e) {}
    
    // Línea divisoria
    doc.setDrawColor(226, 232, 240);
    doc.setLineWidth(0.5);
    doc.line(14, 38, 280, 38);

    // Preparar datos para la tabla
    const tableData = listaEmpleados.value.map(emp => {
      // Calculamos años laborados
      const inicioStr = emp.fecha_inicio ? (emp.fecha_inicio.includes('T') ? emp.fecha_inicio.split('T')[0] : emp.fecha_inicio) : null;
      const inicio = inicioStr ? new Date(inicioStr + 'T00:00:00') : new Date();
      const hoy = new Date();
      let anios = hoy.getFullYear() - inicio.getFullYear();
      const m = hoy.getMonth() - inicio.getMonth();
      if (m < 0 || (m === 0 && hoy.getDate() < inicio.getDate())) {
        anios--;
      }
      anios = Math.max(0, anios);
      
      let diasCorrespondientes = 0;
      if (anios >= 4) diasCorrespondientes = 20;
      else if (anios === 3) diasCorrespondientes = 15;
      else if (anios === 2) diasCorrespondientes = 12;
      else if (anios === 1) diasCorrespondientes = 10;
      
      return [
        emp.codigo_empleado || 'N/A',
        `${emp.nombre} ${emp.apellido}`,
        emp.identidad || 'N/A',
        emp.fecha_inicio ? new Date(inicio).toLocaleDateString('es-HN', {timeZone: 'UTC'}) : 'N/A',
        emp.ubicacion || 'N/A',
        `${anios} años`,
        `${diasCorrespondientes} días`
      ];
    });

    autoTable(doc, {
      startY: 45,
      head: [['Código', 'Empleado', 'Identidad', 'Fecha Ingreso', 'Ubicación/Piso', 'Antigüedad', 'Días Base por Año']],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [79, 70, 229], textColor: [255, 255, 255], fontStyle: 'bold' },
      alternateRowStyles: { fillColor: [248, 250, 252] },
      styles: { fontSize: 9, cellPadding: 4 },
    });

    doc.save(`Reporte_Global_Vacaciones_${new Date().toISOString().split('T')[0]}.pdf`);
  } catch (error) {
    console.error('Error generando PDF general:', error);
    alert('Hubo un error al generar el PDF global.');
  }
};

onMounted(async () => {

  // Socket.io
  socketInstance = io(useRuntimeConfig().public.apiBase)
  socketInstance.on('refresh_empleado_detalle', (updatedId) => {
    if (empleadoSeleccionado.value && empleadoSeleccionado.value.id == updatedId) {
      cargarVacacionesEmpleado(updatedId)
    }
  })

  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Gerad Cole'
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null
  rolID.value = localStorage.getItem('usuarioRol') || 2
  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }

  await cargarTiposPermiso();

  try {
    const m = await axios.get(`/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    menuUsuario.value = m.data
  } catch (e) {
    console.error('Error cargando menú', e)
  }

  const usuarioID = localStorage.getItem('usuarioID');
  await getPermisos(rolID.value, usuarioID);

  try {
    const res = await axios.get('/api/empleados/lista', {
      headers: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Expires': '0',
      }
    })
    listaEmpleados.value = res.data

    if (route.query.empleadoId) {
      const empId = Number(route.query.empleadoId)
      const foundEmp = listaEmpleados.value.find(e => e.id === empId)
      if (foundEmp) {
        empleadoSeleccionado.value = foundEmp
      }
    }
  } catch (error) {
    console.error("Error cargando los empleados:", error)
  }
})

onUnmounted(() => {
  if (socketInstance) {
    socketInstance.disconnect()
  }
})

</script>