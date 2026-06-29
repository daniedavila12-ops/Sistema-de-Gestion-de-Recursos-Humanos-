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

    <main class="flex-1 ml-64 p-8 flex justify-center">
      <div class="w-full max-w-4xl">
        <header class="mb-8 flex justify-between items-center bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
          <div class="flex items-center gap-4">
            <button @click="volver" class="text-slate-400 hover:text-blue-500 font-bold p-3 bg-slate-50 rounded-xl hover:bg-blue-50 transition-colors">
              <span>←</span> Volver
            </button>
            <div>
              <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Perfil del Empleado</h1>
              <p class="text-slate-500 mt-1 font-medium italic">Detalles de la información registrada.</p>
            </div>
          </div>
        </header>

        <div v-if="loading" class="bg-white rounded-3xl shadow-sm border border-slate-100 p-20 text-center text-slate-400 italic">
          Cargando información del empleado...
        </div>
        
        <div v-else-if="error" class="bg-white rounded-3xl shadow-sm border border-slate-100 p-20 text-center text-red-500 font-bold">
          {{ error }}
        </div>

        <div v-else-if="empleado" class="bg-white rounded-3xl shadow-xl border border-slate-100 overflow-hidden">
          <div class="bg-slate-800 p-10 text-white flex items-center gap-8 relative">
            <div class="relative group shrink-0">
              <div v-if="empleado.foto" class="w-36 h-36 bg-blue-500 rounded-full flex items-center justify-center overflow-hidden shadow-lg border-4 border-slate-700 group-hover:opacity-80 transition-opacity">
                <img :src="`http://localhost:3007${empleado.foto}`" alt="Foto de perfil" class="w-full h-full object-cover" />
              </div>
              <div v-else class="w-36 h-36 bg-blue-500 rounded-full flex items-center justify-center text-6xl font-black shadow-lg border-4 border-slate-700 group-hover:opacity-80 transition-opacity">
                {{ empleado.nombre.charAt(0) }}{{ empleado.apellido.charAt(0) }}
              </div>
              <div class="absolute inset-0 flex flex-col items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity rounded-full gap-2 bg-black/30 backdrop-blur-[1px]">
                <button v-if="empleado.foto" @click="verFoto" class="bg-blue-600/90 hover:bg-blue-600 text-white text-[10px] font-bold px-3 py-1.5 rounded-lg shadow-md transition-colors w-24 flex items-center justify-center gap-1"><span>👁️</span> Ver Foto</button>
                <button @click="triggerFileInput" class="bg-slate-800/90 hover:bg-slate-800 text-white text-[10px] font-bold px-3 py-1.5 rounded-lg shadow-md transition-colors w-24 flex items-center justify-center gap-1"><span>📷</span> Cambiar</button>
              </div>
              <input type="file" ref="fileInput" class="hidden" accept="image/*" @change="uploadFoto" />
            </div>
            <div class="flex-1">
              <h2 class="text-4xl font-black uppercase tracking-tight">{{ empleado.nombre }} {{ empleado.apellido }}</h2>
              <div class="flex gap-4 mt-3">
                <span class="px-4 py-1.5 bg-blue-600 text-[10px] font-black uppercase rounded-full shadow-sm">{{ empleado.tipo_contrato || 'Permanente' }}</span>
                <span v-if="empleado.estado == 1 || empleado.estado === undefined" class="px-4 py-1.5 bg-emerald-500 text-white text-[10px] font-black uppercase rounded-full shadow-sm">Activo</span>
                <span v-else class="px-4 py-1.5 bg-red-500 text-white text-[10px] font-black uppercase rounded-full shadow-sm">Inactivo</span>
                <span v-if="empleado.codigo_empleado" class="text-slate-300 text-sm flex items-center gap-1"><span class="px-2 py-0.5 bg-slate-700 rounded-md font-mono text-[10px] text-blue-300">{{ empleado.codigo_empleado }}</span></span>
                <span class="text-slate-300 text-sm flex items-center gap-1"><span>🆔</span> {{ empleado.identidad }}</span>
              </div>
            </div>
            
            <!-- Botón de Opciones -->
            <div class="absolute top-10 right-10">
              <button @click="toggleOpciones" class="bg-slate-700 text-white hover:bg-slate-600 px-5 py-3 rounded-xl font-bold text-xs uppercase tracking-widest transition-colors flex items-center gap-2 border border-slate-600">
                <span>⚙️</span> Opciones
              </button>
              
              <div v-if="mostrarOpciones" class="absolute right-0 mt-2 w-60 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-20 text-slate-800">
                <div class="px-5 py-2 text-[10px] font-black text-slate-400 uppercase tracking-widest bg-slate-50 border-b border-slate-100">Perfil</div>
                <button @click="irAEditar" class="w-full text-left px-5 py-2.5 text-sm font-bold hover:bg-blue-50 hover:text-blue-600 transition-colors">
                  ✏️ Editar empleado
                </button>
                <button @click="abrirModalContacto" class="w-full text-left px-5 py-2.5 text-sm font-bold hover:bg-blue-50 hover:text-blue-600 transition-colors">
                  ➕ Registrar contacto
                </button>
                <button @click="toggleEstadoEmpleado" class="w-full text-left px-5 py-2.5 text-sm font-bold transition-colors"
                  :class="empleado.estado == 1 || empleado.estado === undefined ? 'text-orange-500 hover:bg-orange-50' : 'text-emerald-500 hover:bg-emerald-50'">
                  {{ empleado.estado == 1 || empleado.estado === undefined ? '⭕ Desactivar' : '✅ Activar' }}
                </button>
                
                <div class="px-5 py-2 text-[10px] font-black text-slate-400 uppercase tracking-widest bg-slate-50 border-y border-slate-100 mt-1">Expediente</div>
                <button @click="abrirModalContrato" class="w-full text-left px-5 py-2.5 text-sm font-bold hover:bg-blue-50 hover:text-blue-600 transition-colors">
                  📄 Registrar contrato
                </button>
                <button @click="abrirModalFalta" class="w-full text-left px-5 py-2.5 text-sm font-bold hover:bg-blue-50 hover:text-blue-600 transition-colors">
                  ➕ Registrar falta
                </button>
                <button @click="abrirModalNota" class="w-full text-left px-5 py-2.5 text-sm font-bold hover:bg-blue-50 hover:text-blue-600 transition-colors">
                  📝 Registrar nota
                </button>
              </div>
            </div>
          </div>

          <div class="p-10 space-y-10">
            <!-- Información Personal -->
            <div>
              <h3 class="text-[12px] font-black text-blue-500 uppercase tracking-[0.2em] mb-6 border-b pb-2">Información Personal</h3>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-y-6 gap-x-10">
                <div>
                  <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Fecha de Nacimiento</p>
                  <p class="font-bold text-slate-800">{{ empleado.fecha_nacimiento ? new Date(empleado.fecha_nacimiento).toLocaleDateString('es-HN') : 'N/A' }}</p>
                </div>
                <div>
                  <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Correo Electrónico</p>
                  <p class="font-bold text-slate-800">{{ empleado.correo || 'N/A' }}</p>
                </div>
                <div>
                  <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Teléfono</p>
                  <p class="font-bold text-slate-800">{{ empleado.telefono || 'N/A' }}</p>
                </div>
                <div class="md:col-span-2">
                  <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Dirección</p>
                  <p class="font-bold text-slate-800">{{ empleado.direccion || 'N/A' }}</p>
                </div>
              </div>
            </div>

            <!-- Información Laboral -->
            <div>
              <h3 class="text-[12px] font-black text-blue-500 uppercase tracking-[0.2em] mb-6 border-b pb-2">Información Laboral</h3>
              <div class="grid grid-cols-1 md:grid-cols-3 gap-y-6 gap-x-10">
                <div>
                  <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Fecha de Inicio</p>
                  <p class="font-bold text-slate-800">{{ empleado.fecha_inicio ? new Date(empleado.fecha_inicio).toLocaleDateString('es-HN') : 'N/A' }}</p>
                </div>
                <div>
                  <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Ciudad</p>
                  <p class="font-bold text-slate-800">{{ empleado.ciudad || 'N/A' }}</p>
                </div>
                <div>
                  <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Ubicación / Piso</p>
                  <p class="font-bold text-slate-800">{{ empleado.ubicacion || 'N/A' }}</p>
                </div>
              </div>
            </div>

            <!-- Contactos de Emergencia -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div v-if="empleado.emergencia_nombre">
                <h3 class="text-[12px] font-black text-orange-500 uppercase tracking-[0.2em] mb-6 border-b pb-2">Contacto de Emergencia 1</h3>
                <div class="grid grid-cols-1 gap-y-4 gap-x-6 bg-orange-50 p-6 rounded-2xl border border-orange-100">
                  <div>
                    <p class="text-[10px] font-black text-orange-400 uppercase mb-1">Nombre</p>
                    <p class="font-bold text-slate-800">{{ empleado.emergencia_nombre }}</p>
                  </div>
                  <div>
                    <p class="text-[10px] font-black text-orange-400 uppercase mb-1">Parentesco</p>
                    <p class="font-bold text-slate-800">{{ empleado.emergencia_parentesco || 'N/A' }}</p>
                  </div>
                  <div>
                    <p class="text-[10px] font-black text-orange-400 uppercase mb-1">Teléfono</p>
                    <p class="font-bold text-slate-800">{{ empleado.emergencia_telefono || 'N/A' }}</p>
                  </div>
                </div>
              </div>

              <div v-if="empleado.emergencia_nombre_2">
                <h3 class="text-[12px] font-black text-orange-500 uppercase tracking-[0.2em] mb-6 border-b pb-2">Contacto de Emergencia 2</h3>
                <div class="grid grid-cols-1 gap-y-4 gap-x-6 bg-orange-50 p-6 rounded-2xl border border-orange-100">
                  <div>
                    <p class="text-[10px] font-black text-orange-400 uppercase mb-1">Nombre</p>
                    <p class="font-bold text-slate-800">{{ empleado.emergencia_nombre_2 }}</p>
                  </div>
                  <div>
                    <p class="text-[10px] font-black text-orange-400 uppercase mb-1">Parentesco</p>
                    <p class="font-bold text-slate-800">{{ empleado.emergencia_parentesco_2 || 'N/A' }}</p>
                  </div>
                  <div>
                    <p class="text-[10px] font-black text-orange-400 uppercase mb-1">Teléfono</p>
                    <p class="font-bold text-slate-800">{{ empleado.emergencia_telefono_2 || 'N/A' }}</p>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- Pestañas de Detalles -->
            <div class="mt-12 pt-8 border-t border-slate-100">
              <div class="flex flex-wrap gap-2 mb-6 border-b border-slate-200 pb-2">
                <button 
                  v-for="tab in ['CONTRATOS', 'VACACIONES', 'FALTAS', 'NOTAS', 'DOCUMENTOS']" 
                  :key="tab"
                  @click="activeTab = tab"
                  class="px-5 py-2.5 rounded-t-xl font-bold text-xs uppercase tracking-widest transition-all border-b-2"
                  :class="activeTab === tab ? 'bg-blue-50 text-blue-600 border-blue-600' : 'text-slate-500 border-transparent hover:text-slate-800 hover:bg-slate-50'"
                >
                  {{ tab }}
                </button>
              </div>
              
              <!-- Contenido de las Pestañas -->
              <div class="bg-slate-50 p-8 rounded-2xl border border-slate-100 min-h-[200px] flex flex-col">
                <div v-if="activeTab === 'CONTRATOS'" class="w-full">
                  <div class="flex justify-between items-center mb-6">
                    <h4 class="text-lg font-black text-slate-800 uppercase tracking-tight">Historial de Contratos</h4>
                    <button @click="abrirModalContrato" class="px-4 py-2 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-sm">
                      ➕ Nuevo Contrato
                    </button>
                  </div>
                  
                  <div v-if="contratos.length === 0" class="bg-white rounded-xl border border-slate-200 p-8 text-center text-slate-400 italic shadow-sm">
                    No hay registros de contratos para este empleado.
                  </div>
                  <div v-else class="space-y-4">
                    <div v-for="contrato in contratos" :key="contrato.id" class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col gap-3">
                      <div class="flex justify-between items-start">
                        <div>
                          <span class="px-3 py-1 bg-slate-100 text-slate-600 text-[10px] font-black uppercase rounded-lg border border-slate-200">{{ contrato.tipoContrato || 'N/A' }}</span>
                          <span :class="contrato.estado === 'Activo' ? 'bg-emerald-100 text-emerald-600 border-emerald-200' : 'bg-red-100 text-red-600 border-red-200'" class="ml-2 px-3 py-1 text-[10px] font-black uppercase rounded-lg border">{{ contrato.estado || 'N/A' }}</span>
                        </div>
                        <div class="flex items-start gap-4">
                          <div class="text-right text-[10px] font-black uppercase tracking-widest text-slate-500 bg-slate-50 p-2 rounded-xl border border-slate-100">
                            <p><span class="text-slate-400">Creado por:</span> <span class="text-slate-700">{{ contrato.creadoPorNombre || 'Admin' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ new Date(contrato.fechaCreacion).toLocaleDateString('es-HN') }}</span></p>
                            <p class="mt-1" v-if="contrato.fechaModificacion && contrato.fechaModificacion !== contrato.fechaCreacion"><span class="text-slate-400">Modificado:</span> <span class="text-slate-700">{{ contrato.modificadoPorNombre || contrato.creadoPorNombre || 's/d' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ new Date(contrato.fechaModificacion).toLocaleDateString('es-HN') }}</span></p>
                          </div>
                          <button @click="editarContrato(contrato)" class="p-2.5 bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white rounded-xl transition-all border border-blue-100 hover:border-blue-600 shadow-sm" title="Editar Contrato">
                            ✏️
                          </button>
                        </div>
                      </div>
                      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-2">
                        <div>
                          <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Fecha Inicio</p>
                          <p class="font-bold text-slate-800 text-sm">{{ contrato.fechaInicio ? new Date(contrato.fechaInicio).toLocaleDateString('es-HN') : 'N/A' }}</p>
                        </div>
                        <div>
                          <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Fecha Final</p>
                          <p class="font-bold text-slate-800 text-sm">{{ contrato.fechaFinal ? new Date(contrato.fechaFinal).toLocaleDateString('es-HN') : 'N/A' }}</p>
                        </div>
                        <div>
                          <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Fecha Salida</p>
                          <p class="font-bold text-slate-800 text-sm">{{ contrato.fechaSalida ? new Date(contrato.fechaSalida).toLocaleDateString('es-HN') : 's/d' }}</p>
                        </div>
                      </div>
                      <div v-if="contrato.observacion" class="mt-2 bg-slate-50 p-3 rounded-lg border border-slate-100">
                        <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Observación</p>
                        <p class="text-sm text-slate-700 italic">{{ contrato.observacion }}</p>
                      </div>
                      <div v-if="contrato.archivo" class="mt-2 flex">
                        <a :href="`http://localhost:3007${contrato.archivo}`" target="_blank" class="flex items-center gap-2 px-4 py-2 bg-slate-800 text-white text-xs font-bold rounded-xl hover:bg-slate-700 transition-colors shadow-sm">
                          <span>📎</span> Ver Documento Adjunto
                        </a>
                      </div>
                    </div>
                  </div>
                </div>
                <div v-else-if="activeTab === 'VACACIONES'" class="w-full">
                  <div class="flex justify-between items-center mb-6">
                    <h4 class="text-lg font-black text-slate-800 uppercase tracking-tight">Historial de Vacaciones</h4>
                    <div class="flex items-center gap-4">
                      <div v-if="vacaciones.length > 0" class="flex items-center gap-2">
                        <label class="text-[10px] font-black text-slate-500 uppercase">Filtrar por Periodo:</label>
                        <select v-model="filtroPeriodoHistorial" class="p-2 border border-slate-200 rounded-lg text-xs bg-slate-50 min-w-[120px]">
                          <option value="">Todos</option>
                          <option v-for="p in periodosHistorialUnicos" :key="p" :value="p">{{ p }}</option>
                        </select>
                      </div>
                      <NuxtLink :to="`/vacaciones?empleadoId=${route.params.id}`" class="px-4 py-2 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-sm">
                        ➕ Registrar Vacaciones
                      </NuxtLink>
                    </div>
                  </div>
                  <div v-if="vacaciones.length === 0" class="bg-white rounded-xl border border-slate-200 p-8 text-center text-slate-400 italic shadow-sm">
                    No hay registros de vacaciones para este empleado.
                  </div>
                  <div v-else-if="vacacionesHistorialFiltrado.length === 0" class="bg-slate-50 rounded-xl border border-slate-200 p-8 text-center text-slate-400 italic shadow-sm">
                    No hay registros para el periodo seleccionado.
                  </div>
                  <div v-else class="space-y-4">
                    <div v-for="v in vacacionesHistorialFiltrado" :key="v.id" class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col gap-3">
                      <div class="flex justify-between items-start">
                        <div class="flex gap-2 items-center">
                          <span class="px-3 py-1 bg-blue-50 text-blue-600 text-[10px] font-black uppercase rounded-lg border border-blue-100">Periodo: {{ v.periodo || 'N/A' }}</span>
                          <span v-if="v.tipoSolicitud" class="px-3 py-1 bg-slate-50 text-slate-600 text-[10px] font-black uppercase rounded-lg border border-slate-200">{{ v.tipoSolicitud }}</span>
                        </div>
                        <div class="flex items-start gap-4">
                          <div class="text-right text-[10px] font-black uppercase tracking-widest text-slate-500 bg-slate-50 p-2 rounded-xl border border-slate-100">
                            <p><span class="text-slate-400">Creado por:</span> <span class="text-slate-700">{{ v.creadoPorNombre || 'Admin' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ v.fechaCreacion ? new Date(v.fechaCreacion).toLocaleDateString('es-HN') : (v.fecha_creacion ? new Date(v.fecha_creacion).toLocaleDateString('es-HN') : 'N/A') }}</span></p>
                            <p class="mt-1" v-if="(v.fechaModificacion || v.fecha_modificacion) && (v.fechaModificacion || v.fecha_modificacion) !== (v.fechaCreacion || v.fecha_creacion)"><span class="text-slate-400">Modificado:</span> <span class="text-slate-700">{{ v.modificadoPorNombre || v.creadoPorNombre || 's/d' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ v.fechaModificacion ? new Date(v.fechaModificacion).toLocaleDateString('es-HN') : new Date(v.fecha_modificacion).toLocaleDateString('es-HN') }}</span></p>
                          </div>
                          <NuxtLink :to="`/vacaciones?empleadoId=${route.params.id}&editar=${v.id}`" class="p-2.5 bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white rounded-xl transition-all border border-blue-100 hover:border-blue-600 shadow-sm flex items-center gap-1" title="Editar Vacaciones">
                            <span>✏️</span>
                          </NuxtLink>
                        </div>
                      </div>
                      
                      <div class="flex flex-col xl:flex-row gap-6 mt-4">
                        <!-- Resumen de Días -->
                        <div class="flex-1 bg-slate-50/80 rounded-2xl p-5 border border-slate-100 flex justify-between items-center shadow-sm">
                          <div class="text-center flex-1">
                            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Disfrutados</p>
                            <p class="font-black text-blue-600 text-2xl">{{ v.tipoSolicitud === 'Adelantadas' ? 0 : Number(v.diasVacaciones || 0) }}</p>
                          </div>
                          <div class="w-px h-10 bg-slate-200"></div>
                          <div class="text-center flex-1">
                            <p class="text-[9px] font-black text-red-400 uppercase tracking-widest mb-1.5">Adelantados</p>
                            <p class="font-black text-red-500 text-2xl">{{ v.tipoSolicitud === 'Adelantadas' ? Number(v.diasVacaciones || 0) : 0 }}</p>
                          </div>
                          <div class="w-px h-10 bg-slate-200"></div>
                          <div class="text-center flex-1">
                            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Pagados</p>
                            <p class="font-black text-emerald-500 text-2xl">{{ Number(v.diasPagados || 0) }}</p>
                          </div>
                          <div class="w-px h-10 bg-slate-200"></div>
                          <div class="text-center flex-1">
                            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-1.5">Pendientes</p>
                            <p class="font-black text-orange-500 text-2xl">{{ Number(v.diasPendientes || 0) }}</p>
                          </div>
                        </div>

                        <!-- Fechas -->
                        <div class="flex-1 grid grid-cols-1 sm:grid-cols-3 gap-3">
                          <div class="flex flex-col bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:border-blue-200 transition-colors">
                            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2 flex items-center gap-1.5"><span class="text-blue-500">▶️</span> Fecha Inicio</p>
                            <p class="font-bold text-slate-700 text-sm">{{ v.fechaInicio ? new Date(v.fechaInicio).toLocaleDateString('es-HN') : 'N/A' }}</p>
                          </div>
                          <div class="flex flex-col bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:border-blue-200 transition-colors">
                            <p class="text-[9px] font-black text-slate-400 uppercase tracking-widest mb-2 flex items-center gap-1.5"><span class="text-slate-500">⏹️</span> Fecha Final</p>
                            <p class="font-bold text-slate-700 text-sm">{{ v.fechaFinal ? new Date(v.fechaFinal).toLocaleDateString('es-HN') : 'N/A' }}</p>
                          </div>
                          <div class="flex flex-col bg-white border border-slate-100 rounded-2xl p-4 shadow-sm hover:border-emerald-200 transition-colors">
                            <p class="text-[9px] font-black text-emerald-500 uppercase tracking-widest mb-2 flex items-center gap-1.5"><span class="text-emerald-500">🔙</span> Fecha Regreso</p>
                            <p class="font-bold text-slate-800 text-sm">{{ v.fechaRegreso ? new Date(v.fechaRegreso).toLocaleDateString('es-HN') : 'N/A' }}</p>
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
                <div v-else-if="activeTab === 'FALTAS'" class="w-full">
                  <div class="flex justify-between items-center mb-6">
                    <h4 class="text-lg font-black text-slate-800 uppercase tracking-tight">Historial de Faltas</h4>
                    <button @click="abrirModalFalta" class="px-4 py-2 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-sm">
                      ➕ Registrar Falta
                    </button>
                  </div>
                  <div v-if="faltas.length === 0" class="bg-white rounded-xl border border-slate-200 p-8 text-center text-slate-400 italic shadow-sm">
                    No hay registros de faltas para este empleado.
                  </div>
                  <div v-else class="space-y-4">
                    <div v-for="falta in faltas" :key="falta.id" class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col gap-3">
                      <div class="flex justify-between items-start">
                        <div class="flex gap-2 items-center">
                          <span class="px-3 py-1 bg-red-50 text-red-600 text-[10px] font-black uppercase rounded-lg border border-red-100">Falta Registrada</span>
                        </div>
                        <div class="flex items-start gap-4">
                          <div class="text-right text-[10px] font-black uppercase tracking-widest text-slate-500 bg-slate-50 p-2 rounded-xl border border-slate-100">
                            <p><span class="text-slate-400">Creado por:</span> <span class="text-slate-700">{{ falta.creadoPorNombre || 'Admin' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ falta.fecha ? new Date(falta.fecha).toLocaleDateString('es-HN', { timeZone: 'UTC' }) : 'N/A' }}</span></p>
                            <p class="mt-1" v-if="(falta.fechaModificacion || falta.fecha_modificacion) && (falta.fechaModificacion || falta.fecha_modificacion) !== (falta.fechaCreacion || falta.fecha_creacion)"><span class="text-slate-400">Modificado:</span> <span class="text-slate-700">{{ falta.modificadoPorNombre || falta.creadoPorNombre || 's/d' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ falta.fechaModificacion ? new Date(falta.fechaModificacion).toLocaleDateString('es-HN') : new Date(falta.fecha_modificacion).toLocaleDateString('es-HN') }}</span></p>
                          </div>
                          <a v-if="falta.documento" :href="`http://localhost:3007${falta.documento}`" target="_blank" class="p-2.5 bg-emerald-50 text-emerald-600 hover:bg-emerald-600 hover:text-white rounded-xl transition-all border border-emerald-100 hover:border-emerald-600 shadow-sm flex items-center gap-1" title="Ver Documento">
                            <span>📄</span>
                          </a>
                          <button @click="editarFalta(falta)" class="p-2.5 bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white rounded-xl transition-all border border-blue-100 hover:border-blue-600 shadow-sm flex items-center gap-1" title="Editar Falta">
                            <span>✏️</span>
                          </button>
                        </div>
                      </div>
                      
                      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-2">
                        <div class="bg-slate-50 p-4 rounded-xl border border-slate-100 shadow-sm">
                          <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Motivo</p>
                          <p class="font-medium text-slate-800">{{ falta.motivo }}</p>
                        </div>
                        <div class="bg-slate-50 p-4 rounded-xl border border-slate-100 shadow-sm">
                          <p class="text-[10px] font-black text-slate-400 uppercase mb-1">Sanción</p>
                          <p class="font-medium text-slate-800">{{ falta.sancion || 'Sin sanción especificada' }}</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div v-else-if="activeTab === 'NOTAS'" class="w-full">
                  <div class="flex justify-between items-center mb-6">
                    <h4 class="text-lg font-black text-slate-800 uppercase tracking-tight">Historial de Notas</h4>
                    <button @click="abrirModalNota" class="px-4 py-2 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-sm">
                      ➕ Registrar Nota
                    </button>
                  </div>
                  <div v-if="notas.length === 0" class="bg-white rounded-xl border border-slate-200 p-8 text-center text-slate-400 italic shadow-sm">
                    No hay registros de notas para este empleado.
                  </div>
                  <div v-else class="space-y-4">
                    <div v-for="nota in notas" :key="nota.id" class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col gap-3">
                      <div class="flex justify-between items-start">
                        <div class="flex gap-2 items-center">
                          <span class="px-3 py-1 bg-yellow-50 text-yellow-600 text-[10px] font-black uppercase rounded-lg border border-yellow-100 max-w-max">{{ nota.asunto }}</span>
                        </div>
                        <div class="flex items-start gap-4">
                          <div class="text-right text-[10px] font-black uppercase tracking-widest text-slate-500 bg-slate-50 p-2 rounded-xl border border-slate-100">
                            <p><span class="text-slate-400">Creado por:</span> <span class="text-slate-700">{{ nota.creadoPorNombre || 'Admin' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ new Date(nota.fechaCreacion).toLocaleDateString('es-HN') }}</span></p>
                            <p class="mt-1" v-if="nota.fechaModificacion && nota.fechaModificacion !== nota.fechaCreacion"><span class="text-slate-400">Modificado por:</span> <span class="text-slate-700">{{ nota.modificadoPorNombre || 'Admin' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ new Date(nota.fechaModificacion).toLocaleDateString('es-HN') }}</span></p>
                          </div>
                          <div class="flex items-center gap-2">
                            <a v-if="nota.documento" :href="`http://localhost:3007${nota.documento}`" target="_blank" class="p-2.5 bg-emerald-50 text-emerald-600 hover:bg-emerald-600 hover:text-white rounded-xl transition-all border border-emerald-100 hover:border-emerald-600 shadow-sm flex items-center gap-1" title="Ver Documento">
                              <span>📄</span>
                            </a>
                            <button @click="editarNota(nota)" class="p-2.5 bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white rounded-xl transition-all border border-blue-100 hover:border-blue-600 shadow-sm flex items-center gap-1" title="Editar Nota">
                              <span>✏️</span>
                            </button>
                            <button @click="eliminarNota(nota.id)" class="p-2.5 bg-red-50 text-red-600 hover:bg-red-600 hover:text-white rounded-xl transition-all border border-red-100 hover:border-red-600 shadow-sm" title="Eliminar Nota">
                              ❌
                            </button>
                          </div>
                        </div>
                      </div>
                      
                      <div class="mt-2 bg-slate-50 p-4 rounded-xl border border-slate-100 shadow-sm">
                        <p class="font-medium text-slate-800 whitespace-pre-line">{{ nota.descripcion }}</p>
                      </div>
                    </div>
                  </div>
                </div>
                <div v-else-if="activeTab === 'DOCUMENTOS'" class="w-full">
                  <div class="flex justify-between items-center mb-6">
                    <h4 class="text-lg font-black text-slate-800 uppercase tracking-tight">Historial de Documentos</h4>
                    <button @click="abrirModalDocumento" class="px-4 py-2 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-sm">
                      ➕ Subir Documento
                    </button>
                  </div>
                  <div v-if="documentos.length === 0" class="bg-white rounded-xl border border-slate-200 p-8 text-center text-slate-400 italic shadow-sm">
                    No hay documentos registrados para este empleado.
                  </div>
                  <div v-else class="space-y-4">
                    <div v-for="doc in documentos" :key="doc.id" class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col gap-3">
                      <div class="flex justify-between items-start">
                        <div class="flex flex-col">
                          <div class="flex gap-2 items-center mb-2">
                            <span class="px-3 py-1 bg-blue-50 text-blue-600 text-[10px] font-black uppercase rounded-lg border border-blue-100">{{ doc.tipo || 'Documento General' }}</span>
                            <span class="px-3 py-1 bg-slate-100 text-slate-600 text-[10px] font-black uppercase rounded-lg border border-slate-200">Fecha: {{ doc.fecha_creacion ? new Date(doc.fecha_creacion).toLocaleDateString('es-HN') : 'N/A' }}</span>
                          </div>
                          <p class="font-bold text-slate-800">{{ doc.titulo || 'Documento sin título' }}</p>
                        </div>
                        
                        <div class="flex items-start gap-4">
                          <div class="text-right text-[10px] font-black uppercase tracking-widest text-slate-500 bg-slate-50 p-2 rounded-xl border border-slate-100">
                            <p><span class="text-slate-400">Creado por:</span> <span class="text-slate-700">{{ doc.creadoPorNombre || 'Admin' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ doc.fechaCreacion ? new Date(doc.fechaCreacion).toLocaleDateString('es-HN') : (doc.fecha_creacion ? new Date(doc.fecha_creacion).toLocaleDateString('es-HN') : 'N/A') }}</span></p>
                            <p class="mt-1" v-if="(doc.fechaModificacion || doc.fecha_modificacion) && (doc.fechaModificacion || doc.fecha_modificacion) !== (doc.fechaCreacion || doc.fecha_creacion)"><span class="text-slate-400">Modificado:</span> <span class="text-slate-700">{{ doc.modificadoPorNombre || doc.creadoPorNombre || 's/d' }}</span> <span class="mx-2 text-slate-300">|</span> <span class="text-slate-400">Fecha:</span> <span class="text-slate-700">{{ doc.fechaModificacion ? new Date(doc.fechaModificacion).toLocaleDateString('es-HN') : new Date(doc.fecha_modificacion).toLocaleDateString('es-HN') }}</span></p>
                          </div>
                          <div class="flex items-center gap-2">
                            <button @click="editarDocumento(doc)" class="p-2.5 bg-blue-50 text-blue-600 hover:bg-blue-600 hover:text-white rounded-xl transition-all border border-blue-100 hover:border-blue-600 shadow-sm" title="Editar Documento">
                              <span>✏️</span>
                            </button>
                            <button @click="eliminarDocumento(doc.id)" class="p-2.5 bg-red-50 text-red-600 hover:bg-red-600 hover:text-white rounded-xl transition-all border border-red-100 hover:border-red-600 shadow-sm" title="Eliminar Documento">
                              ❌
                            </button>
                          </div>
                        </div>
                      </div>
                      
                      <div class="mt-2" v-if="doc.archivo_url">
                        <a :href="`http://localhost:3007${doc.archivo_url}`" target="_blank" class="inline-flex items-center gap-2 px-4 py-2 bg-slate-800 text-white rounded-lg font-bold text-[10px] uppercase tracking-widest hover:bg-slate-700 transition-colors shadow-sm">
                          <span>⬇️</span> Ver / Descargar
                        </a>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>

    <!-- Modal Nuevo Contrato -->
    <div v-if="mostrarModalContrato" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden border border-slate-100">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">{{ isEditingContrato ? 'Editar Contrato' : 'Registrar Contrato' }}</h3>
            <p class="text-xs text-slate-500 font-medium italic mt-1">Datos de CONTRATO</p>
          </div>
          <button @click="cerrarModalContrato" class="text-slate-400 hover:text-red-500 p-2 bg-white rounded-lg shadow-sm border border-slate-200 transition-colors">
            ❌
          </button>
        </header>
        <form @submit.prevent="guardarContrato" class="p-8 space-y-6">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Tipo de Contrato</label>
              <select v-model="formContrato.tipoContrato" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all">
                <option value="Permanente">Permanente</option>
                <option value="Temporal">Temporal</option>
                <option value="Servicios Profesionales">Servicios Profesionales</option>
              </select>
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Estado</label>
              <select v-model="formContrato.estado" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all">
                <option value="Activo">Activo</option>
                <option value="Finalizado">Finalizado</option>
                <option value="Renovado">Renovado</option>
              </select>
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Fecha Inicio</label>
              <input v-model="formContrato.fechaInicio" type="date" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all">
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Fecha Final</label>
              <input v-model="formContrato.fechaFinal" type="date" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all">
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Fecha Salida</label>
              <input v-model="formContrato.fechaSalida" type="date" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all">
            </div>
            <div class="md:col-span-2">
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Documento del Contrato (Opcional)</label>
              <input type="file" ref="archivoContratoInput" accept=".pdf,.doc,.docx,.jpg,.png" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all text-sm">
            </div>
            <div class="md:col-span-2">
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Observación</label>
              <textarea v-model="formContrato.observacion" rows="3" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all placeholder-slate-300" placeholder="Detalles adicionales sobre el contrato..."></textarea>
            </div>
          </div>
          <div class="pt-6 border-t border-slate-100 flex justify-end gap-3">
            <button type="button" @click="cerrarModalContrato" class="px-6 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
              Cancelar
            </button>
            <button type="submit" :disabled="guardandoContrato" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 shadow-md shadow-blue-500/20 transition-all disabled:opacity-50">
              {{ guardandoContrato ? 'Guardando...' : (isEditingContrato ? 'Actualizar' : 'Guardar Contrato') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Nueva Falta -->
    <div v-if="mostrarModalFalta" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden border border-slate-100">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">{{ isEditingFalta ? 'Editar Falta' : 'Registrar Falta' }}</h3>
            <p class="text-xs text-slate-500 font-medium italic mt-1">Historial disciplinario</p>
          </div>
          <button @click="cerrarModalFalta" class="text-slate-400 hover:text-red-500 p-2 bg-white rounded-lg shadow-sm border border-slate-200 transition-colors">
            ❌
          </button>
        </header>
        <form @submit.prevent="guardarFalta" class="p-8 space-y-6">
          <div class="grid grid-cols-1 gap-6">
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Fecha</label>
              <input v-model="formFalta.fecha" type="date" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all">
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Motivo</label>
              <textarea v-model="formFalta.motivo" required rows="3" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all placeholder-slate-300" placeholder="Describa el motivo de la falta..."></textarea>
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Sanción (Opcional)</label>
              <input v-model="formFalta.sancion" type="text" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all placeholder-slate-300" placeholder="Ej. Llamado de atención, Deducción salarial...">
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Documento Registrar Falta (Opcional)</label>
              <input type="file" ref="fileDocumentoFalta" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all" accept=".pdf,.png,.jpg,.jpeg">
            </div>
          </div>
          <div class="pt-6 border-t border-slate-100 flex justify-end gap-3">
            <button type="button" @click="cerrarModalFalta" class="px-6 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
              Cancelar
            </button>
            <button type="submit" :disabled="guardandoFalta" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 shadow-md shadow-blue-500/20 transition-all disabled:opacity-50">
              {{ guardandoFalta ? 'Guardando...' : (isEditingFalta ? 'Actualizar' : 'Guardar Falta') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Registro Contacto -->
    <div v-if="mostrarModalContacto" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-3xl shadow-2xl w-full max-w-2xl overflow-hidden border border-slate-100">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">Registrar Contactos</h3>
            <p class="text-xs text-slate-500 font-medium italic mt-1">Actualice la información de emergencia</p>
          </div>
          <button @click="cerrarModalContacto" class="text-slate-400 hover:text-red-500 p-2 bg-white rounded-lg shadow-sm border border-slate-200 transition-colors">
            ❌
          </button>
        </header>
        <form @submit.prevent="guardarContacto" class="p-8 space-y-6">
          
          <div>
            <h4 class="text-[10px] font-black text-orange-500 uppercase tracking-[0.2em] mb-4 border-b pb-2">Contacto de Emergencia 1</h4>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Parentesco</label>
                <select v-model="formContacto.emergencia_parentesco" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all text-sm">
                  <option value="" disabled>Seleccione...</option>
                  <option value="Padre">Padre</option>
                  <option value="Madre">Madre</option>
                  <option value="Conyuge">Conyuge</option>
                  <option value="Hermano(a)">Hermano(a)</option>
                  <option value="Tio(a)">Tio(a)</option>
                  <option value="Otro(a)">Otro(a)</option>
                </select>
              </div>
              <div>
                <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Nombre Completo</label>
                <input v-model="formContacto.emergencia_nombre" type="text" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all text-sm">
              </div>
              <div>
                <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Teléfono</label>
                <input v-model="formContacto.emergencia_telefono" type="text" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all text-sm">
              </div>
            </div>
          </div>

          <div>
            <h4 class="text-[10px] font-black text-orange-500 uppercase tracking-[0.2em] mb-4 border-b pb-2">Contacto de Emergencia 2 (Opcional)</h4>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div>
                <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Parentesco</label>
                <select v-model="formContacto.emergencia_parentesco_2" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all text-sm">
                  <option value="" disabled>Seleccione...</option>
                  <option value="Padre">Padre</option>
                  <option value="Madre">Madre</option>
                  <option value="Conyuge">Conyuge</option>
                  <option value="Hermano(a)">Hermano(a)</option>
                  <option value="Tio(a)">Tio(a)</option>
                  <option value="Otro(a)">Otro(a)</option>
                </select>
              </div>
              <div>
                <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Nombre Completo</label>
                <input v-model="formContacto.emergencia_nombre_2" type="text" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all text-sm">
              </div>
              <div>
                <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Teléfono</label>
                <input v-model="formContacto.emergencia_telefono_2" type="text" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all text-sm">
              </div>
            </div>
          </div>

          <div class="pt-6 border-t border-slate-100 flex justify-end gap-3">
            <button type="button" @click="cerrarModalContacto" class="px-6 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
              Cancelar
            </button>
            <button type="submit" :disabled="guardandoContacto" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 shadow-md shadow-blue-500/20 transition-all disabled:opacity-50">
              {{ guardandoContacto ? 'Guardando...' : 'Guardar Contactos' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Nueva Nota -->
    <div v-if="mostrarModalNota" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden border border-slate-100">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">{{ isEditingNota ? 'Editar Nota' : 'Registrar Nota' }}</h3>
            <p class="text-xs text-slate-500 font-medium italic mt-1">Anotaciones del empleado</p>
          </div>
          <button @click="cerrarModalNota" class="text-slate-400 hover:text-red-500 p-2 bg-white rounded-lg shadow-sm border border-slate-200 transition-colors">
            ❌
          </button>
        </header>
        <form @submit.prevent="guardarNota" class="p-8 space-y-6">
          <div class="grid grid-cols-1 gap-6">
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Asunto</label>
              <input v-model="formNota.asunto" type="text" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all placeholder-slate-300" placeholder="Ej. Llamado de atención, Felicitación...">
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Descripción</label>
              <textarea v-model="formNota.descripcion" required rows="5" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all placeholder-slate-300" placeholder="Detalle de la nota..."></textarea>
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Documento de Nota (Opcional)</label>
              <input type="file" ref="fileDocumentoNota" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all" accept=".pdf,.png,.jpg,.jpeg">
            </div>
          </div>
          <div class="pt-6 border-t border-slate-100 flex justify-end gap-3">
            <button type="button" @click="cerrarModalNota" class="px-6 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
              Cancelar
            </button>
            <button type="submit" :disabled="guardandoNota" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 shadow-md shadow-blue-500/20 transition-all disabled:opacity-50">
              {{ guardandoNota ? 'Guardando...' : (isEditingNota ? 'Actualizar' : 'Guardar Nota') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Nuevo Documento -->
    <div v-if="mostrarModalDocumento" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden border border-slate-100">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">{{ isEditingDocumento ? 'Editar Documento' : 'Subir Documento' }}</h3>
            <p class="text-xs text-slate-500 font-medium italic mt-1">Expediente del empleado</p>
          </div>
          <button @click="cerrarModalDocumento" class="text-slate-400 hover:text-red-500 p-2 bg-white rounded-lg shadow-sm border border-slate-200 transition-colors">
            ❌
          </button>
        </header>
        <form @submit.prevent="guardarDocumento" class="p-8 space-y-6">
          <div class="grid grid-cols-1 gap-6">
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Título de Documento</label>
              <input v-model="formDocumento.titulo" type="text" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all placeholder-slate-300" placeholder="Ej. Copia de Identidad, Certificado Médico...">
            </div>
            <div>
              <div class="flex justify-between items-center mb-2 ml-1">
                <label class="block text-[10px] font-black text-slate-400 uppercase">Tipo de Documento</label>
                <button type="button" @click="mostrarModalTipos = true" class="text-[10px] font-black text-blue-600 hover:text-blue-800 uppercase tracking-widest bg-blue-50 px-2 py-0.5 rounded-lg transition-colors">
                  ⚙️ Gestionar Tipos
                </button>
              </div>
              <select v-model="formDocumento.tipo" required class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all">
                <option value="">Selecciona un tipo...</option>
                <option v-for="t in tiposDocumentos" :key="t.id" :value="t.nombre">{{ t.nombre }}</option>
              </select>
            </div>
            <div>
              <label class="block text-[10px] font-black text-slate-400 uppercase mb-2 ml-1">Buscar archivo</label>
              <input type="file" ref="archivoDocumentoInput" accept=".pdf,.doc,.docx,.jpg,.png" :required="!isEditingDocumento" class="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl text-slate-800 outline-none focus:border-blue-500 transition-all text-sm">
            </div>
          </div>
          <div class="pt-6 border-t border-slate-100 flex justify-end gap-3">
            <button type="button" @click="cerrarModalDocumento" class="px-6 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
              Cancelar
            </button>
            <button type="submit" :disabled="guardandoDocumento" class="px-8 py-3 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 shadow-md shadow-blue-500/20 transition-all disabled:opacity-50">
              {{ guardandoDocumento ? 'Guardando...' : (isEditingDocumento ? 'Actualizar' : 'Guardar Documento') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Gestión de Tipos de Documento -->
    <div v-if="mostrarModalTipos" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center z-[60] p-4">
      <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md overflow-hidden border border-slate-100">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">Tipos de Documento</h3>
            <p class="text-xs text-slate-500 font-medium italic mt-1">Gestionar categorías</p>
          </div>
          <button @click="mostrarModalTipos = false" class="text-slate-400 hover:text-red-500 p-2 bg-white rounded-lg shadow-sm border border-slate-200 transition-colors">
            ❌
          </button>
        </header>
        
        <div class="p-6 space-y-6">
          <form @submit.prevent="agregarTipoDocumento" class="flex gap-3">
            <input v-model="nuevoTipoDoc" type="text" required placeholder="Nuevo tipo de documento..." class="flex-1 px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm outline-none focus:border-blue-500 transition-all">
            <button type="submit" :disabled="guardandoTipoDoc" class="px-5 py-2 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 shadow-sm transition-all disabled:opacity-50">
              Agregar
            </button>
          </form>

          <div class="max-h-60 overflow-y-auto pr-2 space-y-2">
            <div v-for="tipo in tiposDocumentos" :key="tipo.id" class="flex justify-between items-center p-3 bg-slate-50 rounded-xl border border-slate-100">
              <span class="font-bold text-sm text-slate-700">{{ tipo.nombre }}</span>
              <button @click="eliminarTipoDocumento(tipo.id)" class="text-red-500 hover:text-red-700 p-1.5 hover:bg-red-50 rounded-lg transition-colors" title="Eliminar">
                🗑️
              </button>
            </div>
            <div v-if="tiposDocumentos.length === 0" class="text-center text-sm text-slate-400 py-4 italic">
              No hay tipos de documento registrados.
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Ver Foto -->
    <div v-if="mostrarModalFoto" class="fixed inset-0 bg-slate-900/90 backdrop-blur-sm flex items-center justify-center z-[60] p-4" @click="cerrarModalFoto">
      <div class="relative max-w-4xl max-h-screen flex items-center justify-center" @click.stop>
        <button @click="cerrarModalFoto" class="absolute -top-12 right-0 text-white hover:text-red-400 text-3xl font-bold transition-colors">
          ❌
        </button>
        <img :src="`http://localhost:3007${empleado.foto}`" alt="Foto de perfil en grande" class="max-w-full max-h-[85vh] rounded-2xl shadow-2xl object-contain border-4 border-white/20" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

const route = useRoute()
const router = useRouter()
const empleado = ref(null)
const loading = ref(true)
const error = ref('')
const fileInput = ref(null)
const activeTab = ref('CONTRATOS')

const mostrarModalFoto = ref(false)

const verFoto = () => {
  if (empleado.value && empleado.value.foto) {
    mostrarModalFoto.value = true
  }
}

const cerrarModalFoto = () => {
  mostrarModalFoto.value = false
}

const rolID = ref(null)
const rolNombre = ref('Cargando...')
const menuUsuario = ref([])

const mostrarOpciones = ref(false)

const contratos = ref([])
const vacaciones = ref([])

const filtroPeriodoHistorial = ref('');

const periodosHistorialUnicos = computed(() => {
  if (!vacaciones.value) return [];
  const periodos = new Set(vacaciones.value.map(v => v.periodo).filter(Boolean));
  return Array.from(periodos).sort((a, b) => b.localeCompare(a));
});

const vacacionesHistorialFiltrado = computed(() => {
  if (!filtroPeriodoHistorial.value) return vacaciones.value;
  return vacaciones.value.filter(v => v.periodo === filtroPeriodoHistorial.value);
});

const faltas = ref([])
const documentos = ref([])
const notas = ref([])

const mostrarModalNota = ref(false)
const guardandoNota = ref(false)
const isEditingNota = ref(false)
const formNota = ref({
  id: null,
  asunto: '',
  descripcion: ''
})

const mostrarModalContrato = ref(false)
const guardandoContrato = ref(false)
const isEditingContrato = ref(false)
const formContrato = ref({
  id: null,
  tipoContrato: 'Permanente',
  estado: 'Activo',
  fechaInicio: '',
  fechaFinal: '',
  fechaSalida: '',
  observacion: ''
})

const mostrarModalFalta = ref(false)
const guardandoFalta = ref(false)
const isEditingFalta = ref(false)
const formFalta = ref({
  id: null,
  fecha: new Date().toISOString().split('T')[0],
  motivo: '',
  sancion: ''
})

const mostrarModalDocumento = ref(false)
const guardandoDocumento = ref(false)
const isEditingDocumento = ref(false)
const archivoDocumentoInput = ref(null)
const formDocumento = ref({
  id: null,
  titulo: '',
  tipo: 'Documento General'
})

const mostrarModalContacto = ref(false)
const guardandoContacto = ref(false)
const formContacto = ref({
  emergencia_parentesco: '',
  emergencia_nombre: '',
  emergencia_telefono: '',
  emergencia_parentesco_2: '',
  emergencia_nombre_2: '',
  emergencia_telefono_2: ''
})

const abrirModalContacto = () => {
  formContacto.value = {
    emergencia_parentesco: empleado.value.emergencia_parentesco || '',
    emergencia_nombre: empleado.value.emergencia_nombre || '',
    emergencia_telefono: empleado.value.emergencia_telefono || '',
    emergencia_parentesco_2: empleado.value.emergencia_parentesco_2 || '',
    emergencia_nombre_2: empleado.value.emergencia_nombre_2 || '',
    emergencia_telefono_2: empleado.value.emergencia_telefono_2 || ''
  }
  mostrarModalContacto.value = true
  mostrarOpciones.value = false
}

const cerrarModalContacto = () => {
  mostrarModalContacto.value = false
}

const guardarContacto = async () => {
  try {
    guardandoContacto.value = true
    
    // El backend espera todos los campos, así que combinamos con los existentes
    const payload = { 
      ...empleado.value, 
      ...formContacto.value 
    }
    
    // Ajustar fechas al formato YYYY-MM-DD para el payload si existen
    if (payload.fecha_nacimiento) payload.fecha_nacimiento = payload.fecha_nacimiento.split('T')[0]
    if (payload.fecha_inicio) payload.fecha_inicio = payload.fecha_inicio.split('T')[0]

    await axios.put(`http://localhost:3007/api/empleados/${route.params.id}`, payload)
    
    // Actualizar el estado local
    empleado.value = { ...empleado.value, ...formContacto.value }
    
    alert('✅ Contactos actualizados correctamente')
    cerrarModalContacto()
  } catch (err) {
    console.error("Error al guardar contactos:", err)
    alert('❌ ' + (err.response?.data?.mensaje || 'Error al guardar los contactos'))
  } finally {
    guardandoContacto.value = false
  }
}

const archivoContratoInput = ref(null)

const cargarContratos = async () => {
  try {
    const res = await axios.get(`http://localhost:3007/api/empleados/${route.params.id}/contratos`)
    contratos.value = res.data
  } catch (err) {
    console.error("Error al cargar contratos:", err)
  }
}

const cargarVacaciones = async () => {
  try {
    const res = await axios.get(`http://localhost:3007/api/vacaciones/empleado/${route.params.id}`)
    const records = res.data;
    
    let empFechaInicio = empleado.value?.fecha_inicio;
    
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
    
    vacaciones.value = records;
  } catch (err) {
    console.error("Error al cargar vacaciones:", err)
  }
}

const eliminarVacacion = async (id) => {
  if (confirm('¿Está seguro de que desea eliminar este registro de vacaciones?')) {
    try {
      await axios.delete(`http://localhost:3007/api/vacaciones/${id}`)
      alert('✅ Registro de vacaciones eliminado correctamente')
      await cargarVacaciones()
    } catch (err) {
      console.error("Error al eliminar vacaciones:", err)
      alert('❌ Error al eliminar las vacaciones')
    }
  }
}

const abrirModalContrato = () => {
  isEditingContrato.value = false
  formContrato.value = {
    id: null,
    tipoContrato: 'Permanente',
    estado: 'Activo',
    fechaInicio: '',
    fechaFinal: '',
    fechaSalida: '',
    observacion: ''
  }
  if (archivoContratoInput.value) archivoContratoInput.value.value = ''
  mostrarModalContrato.value = true
  mostrarOpciones.value = false
}

const editarContrato = (contrato) => {
  isEditingContrato.value = true
  formContrato.value = {
    id: contrato.id,
    tipoContrato: contrato.tipoContrato || 'Permanente',
    estado: contrato.estado || 'Activo',
    fechaInicio: contrato.fechaInicio ? contrato.fechaInicio.split('T')[0] : '',
    fechaFinal: contrato.fechaFinal ? contrato.fechaFinal.split('T')[0] : '',
    fechaSalida: contrato.fechaSalida ? contrato.fechaSalida.split('T')[0] : '',
    observacion: contrato.observacion || ''
  }
  if (archivoContratoInput.value) archivoContratoInput.value.value = ''
  mostrarModalContrato.value = true
}

const cerrarModalContrato = () => {
  mostrarModalContrato.value = false
}

const guardarContrato = async () => {
  try {
    guardandoContrato.value = true
    
    const formData = new FormData()
    formData.append('tipoContrato', formContrato.value.tipoContrato)
    formData.append('estado', formContrato.value.estado)
    formData.append('fechaInicio', formContrato.value.fechaInicio)
    formData.append('fechaFinal', formContrato.value.fechaFinal)
    formData.append('fechaSalida', formContrato.value.fechaSalida)
    formData.append('observacion', formContrato.value.observacion)
    
    if (archivoContratoInput.value && archivoContratoInput.value.files[0]) {
      formData.append('archivo', archivoContratoInput.value.files[0])
    }

    if (isEditingContrato.value) {
      formData.append('modificadoPor', localStorage.getItem('usuarioID') || 1)
      await axios.put(`http://localhost:3007/api/empleados/${route.params.id}/contratos/${formContrato.value.id}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      alert('✅ Contrato actualizado correctamente')
    } else {
      formData.append('creadoPor', localStorage.getItem('usuarioID') || 1)
      await axios.post(`http://localhost:3007/api/empleados/${route.params.id}/contratos`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      alert('✅ Contrato registrado correctamente')
    }
    
    cerrarModalContrato()
    await cargarContratos()
  } catch (err) {
    console.error("Error al guardar contrato:", err)
    alert('❌ ' + (err.response?.data?.mensaje || 'Error al guardar el contrato'))
  } finally {
    guardandoContrato.value = false
  }
}

const cargarNotas = async () => {
  try {
    const res = await axios.get(`http://localhost:3007/api/notas/empleado/${route.params.id}`)
    notas.value = res.data
  } catch (err) {
    console.error("Error al cargar notas:", err)
  }
}

const fileDocumentoNota = ref(null)

const abrirModalNota = () => {
  isEditingNota.value = false
  formNota.value = {
    id: null,
    asunto: '',
    descripcion: ''
  }
  if (fileDocumentoNota.value) fileDocumentoNota.value.value = ''
  mostrarModalNota.value = true
  mostrarOpciones.value = false
}

const editarNota = (nota) => {
  isEditingNota.value = true
  formNota.value = {
    id: nota.id,
    asunto: nota.asunto || '',
    descripcion: nota.descripcion || ''
  }
  if (fileDocumentoNota.value) fileDocumentoNota.value.value = ''
  mostrarModalNota.value = true
}

const cerrarModalNota = () => {
  mostrarModalNota.value = false
}

const guardarNota = async () => {
  try {
    guardandoNota.value = true
    
    const formData = new FormData()
    formData.append('empleado_id', route.params.id)
    formData.append('asunto', formNota.value.asunto)
    formData.append('descripcion', formNota.value.descripcion)

    if (fileDocumentoNota.value && fileDocumentoNota.value.files[0]) {
      formData.append('documento', fileDocumentoNota.value.files[0])
    }

    if (isEditingNota.value) {
      formData.append('modificadoPor', localStorage.getItem('usuarioID') || 1)
      await axios.put(`http://localhost:3007/api/notas/${formNota.value.id}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      alert('✅ Nota actualizada correctamente')
    } else {
      formData.append('creadoPor', localStorage.getItem('usuarioID') || 1)
      await axios.post(`http://localhost:3007/api/notas/registrar`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      alert('✅ Nota registrada correctamente')
    }
    
    cerrarModalNota()
    await cargarNotas()
  } catch (err) {
    console.error("Error al guardar nota:", err)
    alert('❌ ' + (err.response?.data?.mensaje || err.response?.data?.error || 'Error al guardar la nota'))
  } finally {
    guardandoNota.value = false
  }
}

const eliminarNota = async (id) => {
  if (confirm('¿Está seguro de que desea eliminar esta nota?')) {
    try {
      await axios.delete(`http://localhost:3007/api/notas/${id}`)
      alert('✅ Nota eliminada correctamente')
      await cargarNotas()
    } catch (err) {
      console.error("Error al eliminar nota:", err)
      alert('❌ Error al eliminar la nota')
    }
  }
}

const cargarFaltas = async () => {
  try {
    const res = await axios.get(`http://localhost:3007/api/faltas/empleado/${route.params.id}`)
    faltas.value = res.data
  } catch (err) {
    console.error("Error al cargar faltas:", err)
  }
}

const fileDocumentoFalta = ref(null)

const abrirModalFalta = () => {
  isEditingFalta.value = false
  formFalta.value = {
    id: null,
    fecha: new Date().toISOString().split('T')[0],
    motivo: '',
    sancion: ''
  }
  if (fileDocumentoFalta.value) fileDocumentoFalta.value.value = ''
  mostrarModalFalta.value = true
  mostrarOpciones.value = false
}

const editarFalta = (falta) => {
  isEditingFalta.value = true
  formFalta.value = {
    id: falta.id,
    fecha: falta.fecha ? falta.fecha.split('T')[0] : '',
    motivo: falta.motivo || '',
    sancion: falta.sancion || ''
  }
  if (fileDocumentoFalta.value) fileDocumentoFalta.value.value = ''
  mostrarModalFalta.value = true
}

const cerrarModalFalta = () => {
  mostrarModalFalta.value = false
}

const guardarFalta = async () => {
  try {
    guardandoFalta.value = true
    
    const formData = new FormData()
    formData.append('empleado_id', route.params.id)
    formData.append('fecha', formFalta.value.fecha)
    formData.append('motivo', formFalta.value.motivo)
    formData.append('sancion', formFalta.value.sancion || '')

    if (fileDocumentoFalta.value && fileDocumentoFalta.value.files[0]) {
      formData.append('documento', fileDocumentoFalta.value.files[0])
    }

    if (isEditingFalta.value) {
      formData.append('modificadoPor', localStorage.getItem('usuarioID') || 1)
      await axios.put(`http://localhost:3007/api/faltas/${formFalta.value.id}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      alert('✅ Falta actualizada correctamente')
    } else {
      formData.append('creadoPor', localStorage.getItem('usuarioID') || 1)
      await axios.post(`http://localhost:3007/api/faltas/registrar`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
      alert('✅ Falta registrada correctamente')
    }
    
    cerrarModalFalta()
    await cargarFaltas()
  } catch (err) {
    console.error("Error al guardar falta:", err)
    alert('❌ ' + (err.response?.data?.mensaje || err.response?.data?.error || 'Error al guardar la falta'))
  } finally {
    guardandoFalta.value = false
  }
}

const toggleOpciones = () => {
  mostrarOpciones.value = !mostrarOpciones.value
}

const cargarDocumentos = async () => {
  try {
    const res = await axios.get(`http://localhost:3007/api/documentos/empleado/${route.params.id}`)
    documentos.value = res.data
  } catch (err) {
    console.error("Error al cargar documentos:", err)
  }
}

const abrirModalDocumento = () => {
  isEditingDocumento.value = false
  formDocumento.value = {
    id: null,
    titulo: '',
    tipo: 'Documento General'
  }
  if (archivoDocumentoInput.value) archivoDocumentoInput.value.value = ''
  mostrarModalDocumento.value = true
  mostrarOpciones.value = false
}

const editarDocumento = (doc) => {
  isEditingDocumento.value = true
  formDocumento.value = {
    id: doc.id,
    titulo: doc.titulo || '',
    tipo: doc.tipo || 'Documento General'
  }
  if (archivoDocumentoInput.value) archivoDocumentoInput.value.value = ''
  mostrarModalDocumento.value = true
}

const cerrarModalDocumento = () => {
  mostrarModalDocumento.value = false
}

const guardarDocumento = async () => {
  if (!archivoDocumentoInput.value || !archivoDocumentoInput.value.files[0]) {
    alert("Por favor, seleccione un archivo.");
    return;
  }

  try {
    guardandoDocumento.value = true
    const formData = new FormData()
    formData.append('empleado_id', route.params.id)
    formData.append('titulo', formDocumento.value.titulo)
    formData.append('tipo', formDocumento.value.tipo)
    formData.append('archivo', archivoDocumentoInput.value.files[0])
    formData.append('creadoPor', localStorage.getItem('usuarioID') || 1)
    formData.append('modificadoPor', localStorage.getItem('usuarioID') || 1)

    await axios.post(`http://localhost:3007/api/documentos/registrar`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' }
    })
    
    alert('✅ Documento registrado correctamente')
    cerrarModalDocumento()
    await cargarDocumentos()
  } catch (err) {
    console.error("Error al guardar documento:", err)
    alert('❌ Error al guardar el documento')
  } finally {
    guardandoDocumento.value = false
  }
}

const eliminarDocumento = async (id) => {
  if (confirm('¿Está seguro de que desea eliminar este documento?')) {
    try {
      await axios.delete(`http://localhost:3007/api/documentos/${id}`)
      alert('✅ Documento eliminado correctamente')
      await cargarDocumentos()
    } catch (err) {
      console.error("Error al eliminar documento:", err)
      alert('❌ Error al eliminar el documento')
    }
  }
}

const volver = () => {
  router.push('/empleados')
}

const irAEditar = () => {
  router.push(`/empleados/editar/${route.params.id}`)
}

const toggleEstadoEmpleado = async () => {
  const isActivo = empleado.value.estado == 1 || empleado.value.estado === undefined;
  const accion = isActivo ? 'desactivar' : 'activar';
  const mensajeConfirmacion = isActivo 
    ? '¿Está seguro de que desea desactivar este empleado?' 
    : '¿Está seguro de que desea activar este empleado?';

  if (confirm(mensajeConfirmacion)) {
    try {
      await axios.put(`http://localhost:3007/api/empleados/${route.params.id}/${accion}`)
      alert(`✅ Empleado ${isActivo ? 'desactivado' : 'activado'} correctamente`)
      // Actualizar el estado local para reflejar el cambio inmediatamente
      empleado.value.estado = isActivo ? 0 : 1;
    } catch (e) {
      console.error(`Error al ${accion}:`, e)
      alert(`❌ ` + (e.response?.data?.mensaje || `Error al ${accion} el empleado`))
    }
  }
}

const logout = () => {
  localStorage.clear()
  navigateTo('/login')
}

const triggerFileInput = () => {
  fileInput.value.click()
}

const uploadFoto = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  const formData = new FormData()
  formData.append('foto', file)

  try {
    const id = route.params.id
    const res = await axios.post(`http://localhost:3007/api/empleados/${id}/foto`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    
    // Update the local state with the new photo URL
    empleado.value.foto = res.data.fotoUrl
    alert('✅ ' + res.data.mensaje)
  } catch (err) {
    console.error("Error al subir la foto:", err)
    alert('❌ Error al subir la foto')
  }
}

const tiposDocumentos = ref([])
const mostrarModalTipos = ref(false)
const nuevoTipoDoc = ref('')
const guardandoTipoDoc = ref(false)

const cargarTiposDocumentos = async () => {
  try {
    const res = await axios.get('http://localhost:3007/api/documentos/tipos/lista')
    tiposDocumentos.value = res.data
  } catch (err) {
    console.error('Error al cargar tipos de documentos:', err)
  }
}

const agregarTipoDocumento = async () => {
  if (!nuevoTipoDoc.value.trim()) return
  try {
    guardandoTipoDoc.value = true
    await axios.post('http://localhost:3007/api/documentos/tipos', { nombre: nuevoTipoDoc.value.trim() })
    nuevoTipoDoc.value = ''
    await cargarTiposDocumentos()
  } catch (err) {
    alert('❌ ' + (err.response?.data?.error || 'Error al agregar tipo de documento'))
  } finally {
    guardandoTipoDoc.value = false
  }
}

const eliminarTipoDocumento = async (id) => {
  if (confirm('¿Está seguro de que desea eliminar este tipo de documento?')) {
    try {
      await axios.delete(`http://localhost:3007/api/documentos/tipos/${id}`)
      await cargarTiposDocumentos()
    } catch (err) {
      alert('❌ ' + (err.response?.data?.error || 'Error al eliminar tipo de documento'))
    }
  }
}

onMounted(async () => {
  rolID.value = localStorage.getItem('usuarioRol') || 2
  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }

  try {
    const m = await axios.get(`http://localhost:3007/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    menuUsuario.value = m.data
  } catch (e) {
    console.error('Error cargando menú', e)
  }

  try {
    const id = route.params.id
    const res = await axios.get(`http://localhost:3007/api/empleados/${id}`)
    empleado.value = res.data
    
    // Cargar información relacionada
    await cargarContratos()
    await cargarVacaciones()
    await cargarFaltas()
    await cargarNotas()
    await cargarDocumentos()
    await cargarTiposDocumentos()
  } catch (err) {
    console.error("Error al cargar el empleado:", err)
    error.value = err.response?.data?.mensaje || 'No se pudo cargar la información del empleado.'
  } finally {
    loading.value = false
  }
})
</script>