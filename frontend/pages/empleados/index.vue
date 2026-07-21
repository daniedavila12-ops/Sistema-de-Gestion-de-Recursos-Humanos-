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
          <button v-else-if="item.ruta === '/empleados/nuevo'" @click="abrirModalNuevo"
             class="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-slate-700 transition-all duration-200 group">
            <span class="text-xl group-hover:scale-110 transition-transform">{{ item.icono }}</span>
            <span class="text-sm font-medium">{{ item.nombre }}</span>
          </button>

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
            <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Lista de Empleados</h1>
            <p class="text-slate-500 mt-1 font-medium italic">Personal registrado en la plataforma.</p>
          </div>
          <div class="flex items-center gap-6">
            <button v-if="puedeCrearNuevoEmpleado" @click="abrirModalNuevo" class="bg-green-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-green-700 transition-all shadow-lg shadow-green-200">
              + Nuevo Empleado
            </button>
            <div class="relative">
              <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-6 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors">
                <div v-if="fotoUsuario" class="h-10 w-10 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-slate-100">
                  <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
                </div>
                <div v-else class="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-lg ring-2 ring-slate-100 uppercase">
                  {{ nombreUsuario ? nombreUsuario.charAt(0) : 'U' }}
                </div>
                <div class="flex flex-col">
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
        <div class="flex flex-wrap gap-4 items-center w-full">
          <div class="flex-1 min-w-[250px]">
            <input 
              v-model="searchQuery" 
              type="text" 
              placeholder="Buscar por nombre, apellido o identidad..." 
              class="w-full p-3 rounded-xl bg-slate-50 border border-slate-200 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all placeholder:italic"
            >
          </div>
          <div class="flex items-center gap-2">
            <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest">Departamento:</span>
            <select v-model="departmentFilter" class="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 outline-none focus:border-blue-500 text-sm font-medium text-slate-700 transition-colors cursor-pointer max-w-[150px]">
              <option value="todos">Todos</option>
              <option v-for="dep in departamentos" :key="dep.id" :value="dep.id">
                {{ dep.nombre }}
              </option>
            </select>
            <span class="text-[10px] font-black text-slate-400 uppercase tracking-widest ml-2">Estado:</span>
            <select v-model="statusFilter" class="bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 outline-none focus:border-blue-500 text-sm font-medium text-slate-700 transition-colors cursor-pointer">
              <option value="todos">Todos</option>
              <option value="activos">Activos</option>
              <option value="inactivos">Inactivos</option>
            </select>
          </div>
        </div>
      </header>

      <div class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden">
        <table class="w-full text-left">
          <thead>
            <tr class="bg-slate-50 border-b border-slate-100">
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Empleado / Código</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Nombre Completo</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Identidad</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Correo</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Contrato</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Departamento</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Ubicación / Piso</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Fecha Ingreso</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="!listaEmpleados || listaEmpleados.length === 0">
              <td colspan="9" class="p-20 text-center text-slate-400 italic">
                No hay empleados registrados o no se pudo conectar con el servidor.
              </td>
            </tr>
            <tr v-else-if="filteredEmpleados.length === 0">
              <td colspan="9" class="p-20 text-center text-slate-400 italic">
                No se encontraron resultados para la búsqueda.
              </td>
            </tr>
            <tr v-else v-for="emp in filteredEmpleados" :key="emp.id" class="border-b border-slate-50 hover:bg-slate-50 transition-colors">
              <td class="p-5 flex items-center gap-3">
                <div class="h-10 w-10 rounded-full overflow-hidden border border-slate-200 shrink-0 bg-slate-100 flex items-center justify-center">
                  <img v-if="emp.foto" :src="`${$config.public.apiBase}${emp.foto}`" alt="Foto" class="w-full h-full object-cover" />
                  <span v-else class="text-slate-400 font-bold text-sm">{{ emp.nombre.charAt(0) }}</span>
                </div>
                <div class="font-bold text-slate-800 text-sm">
                  {{ emp.codigo_empleado || 'N/A' }}
                </div>
              </td>
              <td class="p-5 font-bold text-slate-800">
                <NuxtLink v-if="hasPermission('Perfil del Empleado', 'puedeVer') || hasPermission('Perfil del Empleado', 'puedeVer') === undefined" :to="`/empleados/${emp.id}`" class="hover:text-blue-600 hover:underline transition-colors cursor-pointer">
                  {{ emp.nombre }} {{ emp.apellido }}
                </NuxtLink>
                <span v-else>{{ emp.nombre }} {{ emp.apellido }}</span>
              </td>
              <td class="p-5 text-sm text-slate-600">
                {{ emp.identidad }}
              </td>
              <td class="p-5 text-sm text-slate-600">
                {{ emp.correo || 'N/A' }}
              </td>
              <td class="p-5">
                <span class="px-3 py-1 bg-blue-50 text-blue-600 text-[10px] font-black uppercase rounded-full">
                  {{ emp.tipo_contrato || 'Permanente' }}
                </span>
              </td>
              <td class="p-5 text-sm text-slate-600">
                {{ obtenerNombreDepartamento(emp.departamento_id) }}
              </td>
              <td class="p-5 text-sm text-slate-600">
                {{ emp.ubicacion || 'N/A' }}
              </td>
              <td class="p-5 text-sm text-slate-500">
                {{ emp.fecha_inicio ? new Date(emp.fecha_inicio).toLocaleDateString('es-HN') : 'N/A' }}
              </td>
              <td class="p-5 text-center flex justify-center gap-2">
                <NuxtLink v-if="hasPermission('Perfil del Empleado', 'puedeVer') || hasPermission('Perfil del Empleado', 'puedeVer') === undefined" :to="`/empleados/${emp.id}`" class="inline-block bg-blue-100 text-blue-600 hover:bg-blue-600 hover:text-white px-4 py-2 rounded-lg text-xs font-bold transition-colors">
                  Ver Detalle
                </NuxtLink>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </main>

    <!-- Modal Nuevo Empleado -->
    <div v-if="mostrarModalNuevo" class="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-md p-4 overflow-y-auto">
      <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 w-full max-w-7xl my-8 flex flex-col max-h-[90vh]">
        <header class="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50 rounded-t-3xl shrink-0">
          <div>
            <h3 class="text-xl font-black text-slate-800 uppercase tracking-tight">Nuevo Empleado</h3>
            <p class="text-xs text-slate-500 font-medium italic mt-1">Complete la ficha de información del colaborador.</p>
          </div>
          <div class="flex gap-3">
            <button @click="cerrarModalNuevo" type="button" class="px-5 py-2 text-slate-500 hover:text-red-500 font-bold text-xs uppercase tracking-widest transition flex items-center gap-2 bg-white border border-slate-200 rounded-xl hover:bg-red-50">
              <span>❌</span> Cancelar
            </button>
            <button form="form-modal-empleado" type="submit" :disabled="loadingGuardar" class="px-6 py-2 bg-blue-600 text-white rounded-xl font-black uppercase text-xs tracking-[0.2em] hover:bg-blue-700 shadow-md shadow-blue-500/20 transition-all disabled:opacity-50 flex items-center gap-2">
              <span>💾</span> {{ loadingGuardar ? 'Guardando...' : 'Guardar' }}
            </button>
          </div>
        </header>

        <div class="p-6 overflow-y-auto">
          <form id="form-modal-empleado" @submit.prevent="guardarEmpleado" class="flex flex-col gap-6">
            <!-- Row 1: Personal & Laboral -->
            <div class="flex flex-col lg:flex-row gap-6">
              <!-- Personal -->
              <div class="flex-[2] bg-slate-50/50 p-6 rounded-2xl border border-slate-100">
                <h2 class="text-[10px] font-black text-blue-500 uppercase tracking-[0.2em] mb-4 border-b border-slate-200 pb-2">1. Información Personal</h2>
                <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
                  <div v-for="field in camposPersonales" :key="field.id">
                    <label class="block text-[9px] font-black text-slate-400 uppercase mb-1.5 ml-1">{{ field.label }}</label>
                    <div class="relative">
                      <input v-if="field.mask" v-model="form[field.id]" :type="field.type" :placeholder="field.placeholder" required v-maska :data-maska="field.mask"
                        :class="[ 'w-full px-3 py-2.5 text-sm bg-white border rounded-xl text-slate-800 focus:ring-2 focus:ring-blue-500/20 outline-none transition-all shadow-sm', (field.id === 'codigo_empleado' && errorCodigo) || (field.id === 'identidad' && errorIdentidad) ? 'border-red-500 focus:border-red-500' : 'border-slate-200 focus:border-blue-500' ]">
                      <input v-else v-model="form[field.id]" :type="field.type" :placeholder="field.placeholder" required
                        :class="[ 'w-full px-3 py-2.5 text-sm bg-white border rounded-xl text-slate-800 focus:ring-2 focus:ring-blue-500/20 outline-none transition-all shadow-sm', (field.id === 'codigo_empleado' && errorCodigo) || (field.id === 'identidad' && errorIdentidad) ? 'border-red-500 focus:border-red-500' : 'border-slate-200 focus:border-blue-500' ]">
                      
                      <div v-if="field.id === 'codigo_empleado' && errorCodigo" class="text-red-500 text-[10px] font-bold mt-1">{{ errorCodigo }}</div>
                      <div v-if="field.id === 'identidad' && errorIdentidad" class="text-red-500 text-[10px] font-bold mt-1">{{ errorIdentidad }}</div>
                    </div>
                  </div>
                  <div>
                    <label class="block text-[9px] font-black text-slate-400 uppercase mb-1.5 ml-1">Género</label>
                    <select v-model="form.genero" class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 outline-none focus:border-blue-500 transition-all shadow-sm">
                      <option value="Masculino">Masculino</option>
                      <option value="Femenino">Femenino</option>
                    </select>
                  </div>
                  <div class="xl:col-span-4 mt-1">
                    <label class="block text-[9px] font-black text-slate-400 uppercase mb-1.5 ml-1">Dirección Exacta</label>
                    <input v-model="form.direccion" type="text" required class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all shadow-sm" placeholder="Ingrese la dirección completa..." />
                  </div>
                </div>
              </div>

              <!-- Laboral -->
              <div class="flex-1 bg-slate-50/50 p-6 rounded-2xl border border-slate-100">
                <h2 class="text-[10px] font-black text-indigo-500 uppercase tracking-[0.2em] mb-4 border-b border-slate-200 pb-2">2. Información Laboral</h2>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label class="block text-[9px] font-black text-slate-400 uppercase mb-1.5 ml-1">Tipo de Contrato</label>
                    <select v-model="form.tipo_contrato" class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 outline-none focus:border-indigo-500 transition-all shadow-sm">
                      <option value="Permanente">Permanente</option>
                      <option value="Temporal">Temporal</option>
                      <option value="Servicios Profesionales">Servicios Profesionales</option>
                    </select>
                  </div>
                  <div>
                    <label class="block text-[9px] font-black text-slate-400 uppercase mb-1.5 ml-1">Departamento</label>
                    <select v-model="form.departamento_id" class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 outline-none focus:border-indigo-500 transition-all shadow-sm" required>
                      <option value="">Seleccione</option>
                      <option v-for="dep in departamentos" :key="dep.id" :value="dep.id">
                        {{ dep.nombre }}
                      </option>
                    </select>
                  </div>
                  <div v-for="field in camposLaborales" :key="field.id" :class="field.id === 'ubicacion' ? 'sm:col-span-2' : ''">
                    <label class="block text-[9px] font-black text-slate-400 uppercase mb-1.5 ml-1">{{ field.label }}</label>
                    <input v-model="form[field.id]" :type="field.type" required
                      class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500 outline-none transition-all shadow-sm">
                  </div>
                </div>
              </div>
            </div>

            <!-- Row 2: Emergencia -->
            <div class="flex flex-col lg:flex-row gap-6">
              <div class="flex-1 bg-orange-50/30 p-6 rounded-2xl border border-orange-100/50">
                <h2 class="text-[10px] font-black text-orange-500 uppercase tracking-[0.2em] mb-4 border-b border-orange-200/50 pb-2">3. Contacto de Emergencia 1</h2>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <div v-for="field in camposEmergencia" :key="field.id">
                    <label class="block text-[9px] font-black text-orange-400 uppercase mb-1.5 ml-1">{{ field.label }}</label>
                    <select v-if="field.type === 'select'" v-model="form[field.id]" required class="w-full px-3 py-2.5 text-sm bg-white border border-orange-200/50 rounded-xl text-slate-800 focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 outline-none transition-all shadow-sm">
                      <option value="" disabled>Seleccione...</option>
                      <option v-for="opt in field.options" :key="opt" :value="opt">{{ opt }}</option>
                    </select>
                    <input v-else-if="field.mask" v-model="form[field.id]" :type="field.type" :placeholder="field.placeholder" required v-maska :data-maska="field.mask"
                      class="w-full px-3 py-2.5 text-sm bg-white border border-orange-200/50 rounded-xl text-slate-800 focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 outline-none transition-all shadow-sm">
                    <input v-else v-model="form[field.id]" :type="field.type" :placeholder="field.placeholder" required
                      class="w-full px-3 py-2.5 text-sm bg-white border border-orange-200/50 rounded-xl text-slate-800 focus:ring-2 focus:ring-orange-500/20 focus:border-orange-500 outline-none transition-all shadow-sm">
                  </div>
                </div>
              </div>
              
              <div class="flex-1 bg-slate-50/50 p-6 rounded-2xl border border-slate-100">
                <h2 class="text-[10px] font-black text-slate-500 uppercase tracking-[0.2em] mb-4 border-b border-slate-200 pb-2">4. Contacto de Emergencia 2 <span class="text-slate-400 lowercase italic tracking-normal">(Opcional)</span></h2>
                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                  <div v-for="field in camposEmergencia2" :key="field.id">
                    <label class="block text-[9px] font-black text-slate-400 uppercase mb-1.5 ml-1">{{ field.label }}</label>
                    <select v-if="field.type === 'select'" v-model="form[field.id]" class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 focus:ring-2 focus:ring-slate-500/20 focus:border-slate-500 outline-none transition-all shadow-sm">
                      <option value="" disabled>Seleccione...</option>
                      <option v-for="opt in field.options" :key="opt" :value="opt">{{ opt }}</option>
                    </select>
                    <input v-else-if="field.mask" v-model="form[field.id]" :type="field.type" :placeholder="field.placeholder" v-maska :data-maska="field.mask"
                      class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 focus:ring-2 focus:ring-slate-500/20 focus:border-slate-500 outline-none transition-all shadow-sm">
                    <input v-else v-model="form[field.id]" :type="field.type" :placeholder="field.placeholder"
                      class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 focus:ring-2 focus:ring-slate-500/20 focus:border-slate-500 outline-none transition-all shadow-sm">
                  </div>
                </div>
              </div>
            </div>
          </form>
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
  </div>
</template>

<script setup>
import { ref, onMounted, computed, onUnmounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import { io } from 'socket.io-client'
import { vMaska } from 'maska/vue'
import { usePermisos } from '~/composables/usePermisos'

const router = useRouter()
const route = useRoute()
const { getPermisos, hasPermission } = usePermisos()

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

const listaEmpleados = ref([])
const searchQuery = ref('')
const statusFilter = ref('todos')
const departmentFilter = ref('todos')
const mostrarModalNuevo = ref(false)
const loadingGuardar = ref(false)
const departamentos = ref([])
const nombreUsuario = ref('')
const fotoUsuario = ref(null)
const puedeCrearNuevoEmpleado = ref(false)

const rolID = ref(null)
const rolNombre = ref('Cargando...')
const menuUsuario = ref([])

const logout = () => { localStorage.clear(); navigateTo('/login') }

const obtenerNombreDepartamento = (id) => {
  if (!id) return 'N/A'
  const dep = departamentos.value.find(d => d.id === id)
  return dep ? dep.nombre : 'N/A'
}

const form = ref({
  codigo_empleado: '', identidad: '', nombre: '', apellido: '', fecha_nacimiento: '',
  correo: '', telefono: '', direccion: '',
  tipo_contrato: 'Permanente', fecha_inicio: '', ciudad: '', ubicacion: '', departamento_id: '',
  emergencia_parentesco: '', emergencia_nombre: '', emergencia_telefono: '',
  emergencia_parentesco_2: '', emergencia_nombre_2: '', emergencia_telefono_2: ''
})

const camposPersonales = [
  { id: 'codigo_empleado', label: 'Código Empleado', type: 'text', placeholder: 'Ej: EMP-001' },
  { id: 'identidad', label: 'Identidad', type: 'text', placeholder: '0000-0000-00000', mask: '####-####-#####' },
  { id: 'nombre', label: 'Nombres', type: 'text', placeholder: 'Ej: Juan Alberto' },
  { id: 'apellido', label: 'Apellidos', type: 'text', placeholder: 'Ej: Perez Flores' },
  { id: 'fecha_nacimiento', label: 'F. Nacimiento', type: 'date' },
  { id: 'correo', label: 'Correo Personal', type: 'email', placeholder: 'empleado@correo.com' },
  { id: 'telefono', label: 'Teléfono', type: 'text', placeholder: '+504 0000-0000', mask: '+504 ####-####' }
]

const camposLaborales = [
  { id: 'fecha_inicio', label: 'Fecha de Inicio', type: 'date' },
  { id: 'ciudad', label: 'Ciudad', type: 'text' },
  { id: 'ubicacion', label: 'Ubicación / Piso', type: 'text' }
]

const camposEmergencia = [
  { id: 'emergencia_parentesco', label: 'Parentesco', type: 'select', options: ['Padre', 'Madre', 'Conyuge', 'Hermano(a)', 'Tio(a)', 'Otro (a)'] },
  { id: 'emergencia_nombre', label: 'Nombre Completo', type: 'text' },
  { id: 'emergencia_telefono', label: 'Teléfono Emergencia', type: 'text', mask: '+504 ####-####' }
]

const camposEmergencia2 = [
  { id: 'emergencia_parentesco_2', label: 'Parentesco', type: 'select', options: ['Padre', 'Madre', 'Conyuge', 'Hermano(a)', 'Tio(a)', 'Otro (a)'] },
  { id: 'emergencia_nombre_2', label: 'Nombre Completo', type: 'text' },
  { id: 'emergencia_telefono_2', label: 'Teléfono Emergencia', type: 'text', mask: '+504 ####-####' }
]

const errorCodigo = ref(null)
const errorIdentidad = ref(null)
let timeoutCodigo = null
let timeoutIdentidad = null

watch(() => form.value.codigo_empleado, (newVal) => {
  errorCodigo.value = null
  if (timeoutCodigo) clearTimeout(timeoutCodigo)
  if (!newVal || newVal.trim() === '') return
  
  timeoutCodigo = setTimeout(async () => {
    try {
      const { data } = await axios.get(`/api/empleados/validar-codigo/${newVal.trim()}`)
      if (data.existe) errorCodigo.value = 'Este código ya está en uso'
    } catch (e) {
      console.error(e)
    }
  }, 600)
})

watch(() => form.value.identidad, (newVal) => {
  errorIdentidad.value = null
  if (timeoutIdentidad) clearTimeout(timeoutIdentidad)
  if (!newVal || newVal.trim() === '') return
  
  timeoutIdentidad = setTimeout(async () => {
    try {
      const { data } = await axios.get(`/api/empleados/validar-identidad/${newVal.trim()}`)
      if (data.existe) errorIdentidad.value = 'Este número de identidad ya está registrado'
    } catch (e) {
      console.error(e)
    }
  }, 600)
})

const filteredEmpleados = computed(() => {
  let empleados = listaEmpleados.value;

  if (statusFilter.value === 'activos') {
    empleados = empleados.filter(emp => emp.estado === 'Activo' || emp.estado === 1 || emp.estado === true);
  } else if (statusFilter.value === 'inactivos') {
    empleados = empleados.filter(emp => emp.estado === 'Inactivo' || emp.estado === 0 || emp.estado === false);
  }

  if (departmentFilter.value !== 'todos') {
    empleados = empleados.filter(emp => emp.departamento_id === departmentFilter.value);
  }

  if (!searchQuery.value) return empleados;
  
  const lowerCaseQuery = searchQuery.value.toLowerCase();
  return empleados.filter(emp => {
    const fullName = `${emp.nombre} ${emp.apellido}`.toLowerCase();
    const identity = emp.identidad?.toLowerCase() || '';
    const code = emp.codigo_empleado?.toLowerCase() || '';
    return fullName.includes(lowerCaseQuery) || identity.includes(lowerCaseQuery) || code.includes(lowerCaseQuery);
  });
})

const cargarEmpleados = async () => {
  try {
    const res = await axios.get('/api/empleados/lista', {
      headers: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Expires': '0',
      }
    })
    listaEmpleados.value = res.data
  } catch (error) {
    console.error("Error cargando los empleados:", error)
  }
}

const abrirModalNuevo = () => {
  form.value = {
    codigo_empleado: '', identidad: '', nombre: '', apellido: '', fecha_nacimiento: '',
    correo: '', telefono: '', direccion: '',
    genero: 'Masculino',
    tipo_contrato: 'Permanente', fecha_inicio: '', ciudad: '', ubicacion: '',
    emergencia_parentesco: '', emergencia_nombre: '', emergencia_telefono: '',
    emergencia_parentesco_2: '', emergencia_nombre_2: '', emergencia_telefono_2: ''
  }
  mostrarModalNuevo.value = true
}

const cerrarModalNuevo = () => {
  mostrarModalNuevo.value = false
}

const guardarEmpleado = async () => {
  if (errorCodigo.value || errorIdentidad.value) {
    alert('❌ Por favor, corrija los errores en el formulario')
    return
  }
  try {
    loadingGuardar.value = true
    const res = await axios.post('/api/empleados/crear', form.value)
    
    alert('✅ ' + res.data.mensaje)
    
    cerrarModalNuevo()
    await cargarEmpleados()
    
  } catch (e) {
    alert('❌ ' + (e.response?.data?.mensaje || 'Error al guardar'))
  } finally {
    loadingGuardar.value = false
  }
}

const eliminarEmpleado = async (id) => {
  if (confirm('¿Estás seguro que deseas eliminar este empleado? Esta acción no se puede deshacer.')) {
    try {
      const res = await axios.delete(`/api/empleados/${id}`)
      alert('✅ Empleado eliminado correctamente')
      await cargarEmpleados()
    } catch (error) {
      alert('❌ Error al eliminar el empleado: ' + (error.response?.data?.error || error.message))
    }
  }
}

onMounted(async () => {
  if (route.query.nuevo === 'true') {
    abrirModalNuevo()
    router.replace('/empleados')
  }

  nombreUsuario.value = localStorage.getItem('usuarioNombre') || 'Invitado'
  fotoUsuario.value = localStorage.getItem('usuarioFoto') || null
  rolID.value = localStorage.getItem('usuarioRol') || 2
  
  if (rolID.value == 1) {
    rolNombre.value = 'Administrador IT'
  } else if (rolID.value == 2) {
    rolNombre.value = 'Recursos Humanos'
  } else {
    rolNombre.value = 'Empleado'
  }
  
  try {
    const m = await axios.get(`/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    menuUsuario.value = m.data
  } catch (err) {
    console.error("Error cargando menu", err)
  }

  try {
    const usuarioID = localStorage.getItem('usuarioID');
    await getPermisos(rolID.value, usuarioID);
    
    // Check either Empleados -> puedeCrear OR +Nuevo Empleado -> puedeVer
    if (hasPermission('Empleados', 'puedeCrear') || hasPermission('+Nuevo Empleado', 'puedeVer') || hasPermission('+Nuevo Empleado', 'puedeCrear')) {
      puedeCrearNuevoEmpleado.value = true;
    }
  } catch (err) {
    console.error("Error cargando permisos", err);
  }

  if (route.query.status) {
    statusFilter.value = route.query.status
  }

  await cargarEmpleados()
  try {
    const res = await axios.get('/api/departamentos/lista')
    departamentos.value = res.data.sort((a, b) => a.nombre.localeCompare(b.nombre))
  } catch (error) {
    console.error("Error cargando departamentos:", error)
  }

  // Socket.io for real-time updates
  socketInstance = io(useRuntimeConfig().public.apiBase)
  socketInstance.on('nueva_notificacion', () => {
    cargarEmpleados()
  })
  socketInstance.on('refresh_empleados', () => {
    cargarEmpleados()
  })
})

let socketInstance = null

onUnmounted(() => {
  if (socketInstance) {
    socketInstance.disconnect()
  }
})
</script>