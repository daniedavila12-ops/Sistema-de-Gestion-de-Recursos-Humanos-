<template>
  <div class="min-h-screen bg-gray-100 flex font-sans">
    <!-- SIDEBAR -->
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
    <main class="flex-1 ml-64 p-8">
      <header class="mb-6 flex flex-col gap-5 bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div class="flex justify-between items-center w-full">
          <div>
            <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Administración de Accesos</h1>
            <p class="text-slate-500 mt-1 font-medium italic">Gestión integral de usuarios, roles y permisos del sistema.</p>
          </div>
          <div class="flex items-center gap-4">
             <button v-if="activeTab === 'usuarios'" @click="abrirModalUsuario()" class="bg-blue-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-blue-700 transition-all shadow-lg shadow-blue-200 flex items-center gap-2">
              <span>+</span> Crear Usuario
            </button>
            <button v-if="activeTab === 'roles'" @click="abrirModalRol()" class="bg-purple-600 text-white px-6 py-3 rounded-xl font-black uppercase text-xs hover:bg-purple-700 transition-all shadow-lg shadow-purple-200 flex items-center gap-2">
              <span>+</span> Crear Rol
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
        </div>

        <!-- TABS -->
        <div class="flex gap-4 border-b border-slate-100 pb-2 mt-2">
          <button @click="activeTab = 'usuarios'" :class="activeTab === 'usuarios' ? 'text-blue-600 border-b-2 border-blue-600 font-black' : 'text-slate-400 font-bold hover:text-slate-600'" class="px-4 py-2 uppercase text-xs tracking-widest transition-all">
            👥 Usuarios
          </button>
          <button @click="activeTab = 'roles'" :class="activeTab === 'roles' ? 'text-purple-600 border-b-2 border-purple-600 font-black' : 'text-slate-400 font-bold hover:text-slate-600'" class="px-4 py-2 uppercase text-xs tracking-widest transition-all">
            🛡️ Roles y Permisos
          </button>
        </div>
      </header>

      <!-- TAB USUARIOS -->
      <div v-if="activeTab === 'usuarios'" class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden mb-8">
        <table class="w-full text-left">
          <thead>
            <tr class="bg-slate-50 border-b border-slate-100">
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Usuario</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Email</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Rol</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Incidentes Pendientes</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Estado</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Último Login</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loadingUsuarios" class="border-b border-slate-50">
              <td colspan="7" class="p-10 text-center text-slate-400 italic">Cargando usuarios...</td>
            </tr>
            <tr v-else-if="usuarios.length === 0" class="border-b border-slate-50">
              <td colspan="7" class="p-10 text-center text-slate-400 italic">No se encontraron usuarios.</td>
            </tr>
            <tr v-else v-for="usuario in usuarios" :key="usuario.id" class="border-b border-slate-50 hover:bg-slate-50 transition-colors">
              <td class="p-5">
                <div class="flex items-center gap-3">
                  <div v-if="usuario.foto" class="h-10 w-10 shrink-0 rounded-full overflow-hidden border border-slate-200 shadow-sm">
                    <img :src="`http://localhost:3007${usuario.foto}`" class="w-full h-full object-cover" />
                  </div>
                  <div v-else class="h-10 w-10 shrink-0 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 font-bold uppercase border border-slate-200 shadow-sm">
                    {{ usuario.nombre.charAt(0) }}
                  </div>
                  <button @click="verPermisosUsuario(usuario)" class="hover:text-blue-600 hover:underline text-left flex flex-col transition-colors font-bold text-slate-800" title="Ver Permisos del Rol">
                    <span>{{ usuario.nombre }}</span>
                    <span class="text-[9px] font-normal text-slate-400 mt-0.5 flex items-center gap-1"><span>🛡️</span> Ver Permisos</span>
                  </button>
                </div>
              </td>
              <td class="p-5 text-sm text-slate-600">{{ usuario.email }}</td>
              <td class="p-5 text-sm">
                <span class="px-3 py-1 bg-purple-50 text-purple-600 text-[10px] font-black uppercase rounded-full">
                  {{ usuario.rol_nombre || 'Sin Rol' }}
                </span>
              </td>
              <td class="p-5 text-sm text-center">
                <span v-if="usuario.incidentes_pendientes > 0" class="px-3 py-1 bg-red-50 text-red-600 text-[10px] font-black uppercase rounded-full shadow-sm">
                  {{ usuario.incidentes_pendientes }} Pendiente{{ usuario.incidentes_pendientes !== 1 ? 's' : '' }}
                </span>
                <span v-else class="text-slate-400 text-xs font-medium">0</span>
              </td>
              <td class="p-5">
                <span :class="usuario.estado ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-600'" class="px-3 py-1 text-[10px] font-black uppercase rounded-full">
                  {{ usuario.estado ? 'Activo' : 'Inactivo' }}
                </span>
              </td>
              <td class="p-5 text-sm text-slate-500">{{ usuario.ultimoLogin ? new Date(usuario.ultimoLogin).toLocaleString('es-HN') : 'Nunca' }}</td>
              <td class="p-5 text-center flex justify-center gap-2">
                <button @click="abrirModalUsuario(usuario)" class="bg-blue-100 text-blue-600 hover:bg-blue-600 hover:text-white p-2 rounded-lg text-xs font-bold transition-colors" title="Editar">
                  ✏️
                </button>
                <button @click="toggleEstado(usuario)" :class="usuario.estado ? 'bg-red-100 text-red-600 hover:bg-red-600 hover:text-white' : 'bg-green-100 text-green-600 hover:bg-green-600 hover:text-white'" class="p-2 rounded-lg text-xs font-bold transition-colors" :title="usuario.estado ? 'Desactivar' : 'Activar'">
                  {{ usuario.estado ? '🛑' : '✅' }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- TAB ROLES -->
      <div v-if="activeTab === 'roles'" class="bg-white rounded-3xl shadow-sm border border-slate-100 overflow-hidden mb-8">
        <table class="w-full text-left">
          <thead>
            <tr class="bg-slate-50 border-b border-slate-100">
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">ID</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest">Nombre del Rol</th>
              <th class="p-5 text-[10px] font-black text-slate-400 uppercase tracking-widest text-center">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loadingRoles" class="border-b border-slate-50">
              <td colspan="3" class="p-10 text-center text-slate-400 italic">Cargando roles...</td>
            </tr>
            <tr v-else-if="roles.length === 0" class="border-b border-slate-50">
              <td colspan="3" class="p-10 text-center text-slate-400 italic">No se encontraron roles.</td>
            </tr>
            <tr v-else v-for="rol in roles" :key="rol.id" class="border-b border-slate-50 hover:bg-slate-50 transition-colors">
              <td class="p-5 text-sm text-slate-600 font-bold">{{ rol.id }}</td>
              <td class="p-5 font-bold text-slate-800">{{ rol.nombre }}</td>
              <td class="p-5 text-center flex justify-center gap-2">
                <button @click="abrirModalRol(rol)" class="bg-blue-100 text-blue-600 hover:bg-blue-600 hover:text-white p-2 rounded-lg text-xs font-bold transition-colors" title="Editar Nombre">
                  ✏️
                </button>
                <button @click="abrirModalPermisos(rol)" class="bg-purple-100 text-purple-600 hover:bg-purple-600 hover:text-white px-4 py-2 rounded-lg text-xs font-bold transition-colors flex items-center gap-2">
                  <span>🛡️</span> Permisos
                </button>
                <button @click="eliminarRol(rol)" class="bg-red-100 text-red-600 hover:bg-red-600 hover:text-white p-2 rounded-lg text-xs font-bold transition-colors" title="Eliminar">
                  🗑️
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Modal Crear/Editar Usuario -->
      <div v-if="mostrarModalUsuario" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
        <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 w-full max-w-lg overflow-hidden">
          <div class="bg-slate-800 p-6 flex justify-between items-center text-white">
            <h2 class="text-xl font-black uppercase tracking-tight">{{ esEdicionUsuario ? 'Editar Usuario' : 'Crear Usuario' }}</h2>
            <button @click="cerrarModalUsuario" class="text-slate-400 hover:text-white text-3xl font-bold leading-none">&times;</button>
          </div>
          
          <div class="p-8">
            <form @submit.prevent="guardarUsuario" class="space-y-5">
              <div>
                <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Nombre Completo</label>
                <input type="text" v-model="formUsuario.nombre" required class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none" placeholder="Ej. Juan Pérez">
              </div>
              
              <div>
                <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Correo Electrónico</label>
                <input type="email" v-model="formUsuario.email" required class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none" placeholder="correo@empresa.com">
              </div>

              <div>
                <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Contraseña <span v-if="esEdicionUsuario" class="text-xs lowercase font-normal text-slate-400">(Dejar en blanco para no cambiar)</span></label>
                <input type="password" v-model="formUsuario.password" :required="!esEdicionUsuario" class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none" placeholder="******">
              </div>

              <div>
                <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Rol del Sistema</label>
                <select v-model="formUsuario.rol_id" required class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none">
                  <option value="" disabled>Seleccione un rol...</option>
                  <option v-for="rol in roles" :key="rol.id" :value="rol.id">{{ rol.nombre }}</option>
                </select>
              </div>

              <div v-if="esEdicionUsuario" class="flex items-center gap-2 mt-2">
                <input type="checkbox" id="estadoUsuario" v-model="formUsuario.estado" class="w-4 h-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                <label for="estadoUsuario" class="text-sm font-medium text-slate-700">Usuario Activo</label>
              </div>

              <div class="flex justify-end gap-3 pt-4 border-t border-slate-100">
                <button type="button" @click="cerrarModalUsuario" class="px-6 py-2.5 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
                  Cancelar
                </button>
                <button type="submit" class="px-6 py-2.5 bg-blue-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-blue-700 transition-colors shadow-md">
                  {{ esEdicionUsuario ? 'Actualizar' : 'Guardar' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Modal Crear/Editar Rol -->
      <div v-if="mostrarModalRol" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
        <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 w-full max-w-md overflow-hidden">
          <div class="bg-slate-800 p-6 flex justify-between items-center text-white">
            <h2 class="text-xl font-black uppercase tracking-tight">{{ esEdicionRol ? 'Editar Rol' : 'Crear Rol' }}</h2>
            <button @click="cerrarModalRol" class="text-slate-400 hover:text-white text-3xl font-bold leading-none">&times;</button>
          </div>
          
          <div class="p-8">
            <form @submit.prevent="guardarRol" class="space-y-5">
              <div>
                <label class="block text-[10px] font-black text-slate-500 uppercase mb-1">Nombre del Rol</label>
                <input type="text" v-model="formRol.nombre" required class="w-full p-3 border border-slate-200 rounded-xl text-sm bg-slate-50 focus:ring-2 focus:ring-blue-500 outline-none" placeholder="Ej. Administrador">
              </div>

              <div class="flex justify-end gap-3 pt-4 border-t border-slate-100">
                <button type="button" @click="cerrarModalRol" class="px-6 py-2.5 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
                  Cancelar
                </button>
                <button type="submit" class="px-6 py-2.5 bg-purple-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-purple-700 transition-colors shadow-md">
                  {{ esEdicionRol ? 'Actualizar' : 'Guardar' }}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>

      <!-- Modal Gestión de Permisos -->
      <div v-if="mostrarModalPermisos" class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
        <div class="bg-white rounded-3xl shadow-2xl border border-slate-100 w-full max-w-4xl overflow-hidden flex flex-col max-h-[90vh]">
          <div class="bg-purple-800 p-6 flex justify-between items-center text-white shrink-0">
            <div>
              <h2 class="text-xl font-black uppercase tracking-tight">Permisos del Rol</h2>
              <p class="text-purple-200 text-sm mt-1">Configurando accesos para: <span class="font-bold">{{ rolSeleccionado?.nombre }}</span></p>
            </div>
            <button @click="cerrarModalPermisos" class="text-purple-300 hover:text-white text-3xl font-bold leading-none">&times;</button>
          </div>
          
          <div class="p-6 overflow-y-auto flex-1 bg-slate-50">
            <div v-if="loadingPermisos" class="text-center p-10 text-slate-500 italic">
              Cargando permisos...
            </div>
            <table v-else class="w-full text-left bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden">
              <thead>
                <tr class="bg-slate-100 border-b border-slate-200">
                  <th class="p-4 text-[10px] font-black text-slate-500 uppercase tracking-widest">Módulo</th>
                  <th class="p-4 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">TODOS</th>
                  <th class="p-4 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Ver</th>
                  <th class="p-4 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Crear</th>
                  <th class="p-4 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Editar</th>
                  <th class="p-4 text-[10px] font-black text-slate-500 uppercase tracking-widest text-center">Eliminar</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(permiso, index) in permisosForm" :key="permiso.modulo_id" class="border-b border-slate-100 hover:bg-slate-50">
                  <td class="p-4 font-bold text-slate-700">
                    <span v-if="permiso.modulo_nombre === 'Cumpleañeros'">🎂 </span>
                    {{ permiso.modulo_nombre }}
                  </td>
                  <td class="p-4 text-center">
                    <input type="checkbox" :checked="todosSeleccionados(permiso)" @change="toggleTodos(permiso, $event.target.checked)" class="w-5 h-5 text-purple-600 rounded focus:ring-purple-500 cursor-pointer">
                  </td>
                  <td class="p-4 text-center">
                    <input type="checkbox" v-model="permiso.puedeVer" :true-value="1" :false-value="0" @change="onPuedeVerChange(permiso)" class="w-5 h-5 text-purple-600 rounded focus:ring-purple-500 cursor-pointer">
                  </td>
                  <td class="p-4 text-center">
                    <input type="checkbox" v-model="permiso.puedeCrear" :true-value="1" :false-value="0" @change="onPuedeAccionChange(permiso)" class="w-5 h-5 text-purple-600 rounded focus:ring-purple-500 cursor-pointer">
                  </td>
                  <td class="p-4 text-center">
                    <input type="checkbox" v-model="permiso.puedeEditar" :true-value="1" :false-value="0" @change="onPuedeAccionChange(permiso)" class="w-5 h-5 text-purple-600 rounded focus:ring-purple-500 cursor-pointer">
                  </td>
                  <td class="p-4 text-center">
                    <input type="checkbox" v-model="permiso.puedeEliminar" :true-value="1" :false-value="0" @change="onPuedeAccionChange(permiso)" class="w-5 h-5 text-purple-600 rounded focus:ring-purple-500 cursor-pointer">
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="p-6 bg-white border-t border-slate-100 flex justify-end gap-3 shrink-0">
            <button @click="cerrarModalPermisos" class="px-6 py-2.5 bg-slate-100 text-slate-600 rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-slate-200 transition-colors">
              Cancelar
            </button>
            <button @click="guardarPermisos" class="px-6 py-2.5 bg-purple-600 text-white rounded-xl font-bold text-xs uppercase tracking-widest hover:bg-purple-700 transition-colors shadow-md">
              Guardar Permisos
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
import { ref, onMounted } from 'vue'
import axios from 'axios'

const rolID = ref(null)
const rolNombre = ref('Cargando...')
const menuUsuario = ref([])
const usuarioActual = ref('')

// Lógica Modal Perfil
const dropdownPerfilAbierto = ref(false)
const modalAbiertoPerfil = ref(false)
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
    alert('❌ Las contraseñas nuevas no coinciden')
    return
  }
  try {
    loadingPassword.value = true
    const userId = localStorage.getItem('usuarioID')
    const res = await axios.put(`http://localhost:3007/api/auth/${userId}/password`, {
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

const activeTab = ref('usuarios')

// ESTADO - USUARIOS
const usuarios = ref([])
const loadingUsuarios = ref(true)
const mostrarModalUsuario = ref(false)
const esEdicionUsuario = ref(false)
const formUsuario = ref({ id: null, nombre: '', email: '', password: '', rol_id: '', estado: true })

// ESTADO - ROLES
const roles = ref([])
const loadingRoles = ref(true)
const mostrarModalRol = ref(false)
const esEdicionRol = ref(false)
const formRol = ref({ id: null, nombre: '' })

// ESTADO - PERMISOS
const mostrarModalPermisos = ref(false)
const loadingPermisos = ref(false)
const rolSeleccionado = ref(null)
const permisosForm = ref([])

const cargarUsuarios = async () => {
  try {
    loadingUsuarios.value = true
    const res = await axios.get('http://localhost:3007/api/usuarios')
    usuarios.value = res.data
  } catch (error) {
    console.error('Error cargando usuarios', error)
  } finally {
    loadingUsuarios.value = false
  }
}

const cargarRoles = async () => {
  try {
    loadingRoles.value = true
    const res = await axios.get('http://localhost:3007/api/roles')
    roles.value = res.data
  } catch (error) {
    console.error('Error cargando roles', error)
  } finally {
    loadingRoles.value = false
  }
}

// LOGICA USUARIOS
const abrirModalUsuario = (usuario = null) => {
  if (usuario) {
    esEdicionUsuario.value = true
    formUsuario.value = { 
      id: usuario.id, 
      nombre: usuario.nombre, 
      email: usuario.email, 
      password: '', // No cargamos el hash
      rol_id: usuario.rol_id,
      estado: usuario.estado === 1 || usuario.estado === true
    }
  } else {
    esEdicionUsuario.value = false
    formUsuario.value = { id: null, nombre: '', email: '', password: '', rol_id: '', estado: true }
  }
  mostrarModalUsuario.value = true
}

const verPermisosUsuario = (usuario) => {
  if (!usuario.rol_id) {
    alert('Este usuario no tiene un rol asignado.');
    return;
  }
  const rol = roles.value.find(r => r.id === usuario.rol_id);
  if (rol) {
    abrirModalPermisos(rol);
  } else {
    abrirModalPermisos({ id: usuario.rol_id, nombre: usuario.rol_nombre || 'Rol Desconocido' });
  }
}

const cerrarModalUsuario = () => {
  mostrarModalUsuario.value = false
}

const guardarUsuario = async () => {
  try {
    const payload = {
      nombre: formUsuario.value.nombre,
      email: formUsuario.value.email,
      rol_id: formUsuario.value.rol_id,
      estado: formUsuario.value.estado ? 1 : 0
    }

    if (formUsuario.value.password) {
      payload.password = formUsuario.value.password
    }

    if (esEdicionUsuario.value) {
      await axios.put(`http://localhost:3007/api/usuarios/${formUsuario.value.id}`, payload)
      alert('✅ Usuario actualizado exitosamente')
    } else {
      await axios.post('http://localhost:3007/api/usuarios', payload)
      alert('✅ Usuario creado exitosamente')
    }
    cerrarModalUsuario()
    cargarUsuarios()
  } catch (error) {
    console.error('Error al guardar usuario', error)
    alert('❌ Error al guardar el usuario: ' + (error.response?.data?.mensaje || error.message))
  }
}

const toggleEstado = async (usuario) => {
  const nuevoEstado = usuario.estado ? 0 : 1
  const accion = usuario.estado ? 'desactivar' : 'activar'
  
  if (!confirm(`¿Está seguro que desea ${accion} al usuario ${usuario.nombre}?`)) return

  try {
    await axios.put(`http://localhost:3007/api/usuarios/${usuario.id}/estado`, {
      estado: nuevoEstado
    })
    cargarUsuarios()
  } catch (error) {
    console.error('Error al cambiar estado', error)
    alert('❌ Error al cambiar el estado')
  }
}

// LOGICA ROLES
const abrirModalRol = (rol = null) => {
  if (rol) {
    esEdicionRol.value = true
    formRol.value = { id: rol.id, nombre: rol.nombre }
  } else {
    esEdicionRol.value = false
    formRol.value = { id: null, nombre: '' }
  }
  mostrarModalRol.value = true
}

const cerrarModalRol = () => {
  mostrarModalRol.value = false
}

const guardarRol = async () => {
  try {
    if (esEdicionRol.value) {
      await axios.put(`http://localhost:3007/api/roles/${formRol.value.id}`, { nombre: formRol.value.nombre })
      alert('✅ Rol actualizado exitosamente')
    } else {
      await axios.post('http://localhost:3007/api/roles', { nombre: formRol.value.nombre })
      alert('✅ Rol creado exitosamente')
    }
    cerrarModalRol()
    cargarRoles()
  } catch (error) {
    console.error('Error al guardar rol', error)
    alert('❌ Error al guardar el rol')
  }
}

const eliminarRol = async (rol) => {
  if (!confirm(`¿Está seguro que desea eliminar el rol "${rol.nombre}"? Esta acción puede afectar a los usuarios con este rol.`)) return

  try {
    await axios.delete(`http://localhost:3007/api/roles/${rol.id}`)
    alert('✅ Rol eliminado correctamente')
    cargarRoles()
  } catch (error) {
    console.error('Error al eliminar rol', error)
    alert('❌ Error al eliminar el rol')
  }
}

// LÓGICA PERMISOS
const abrirModalPermisos = async (rol) => {
  rolSeleccionado.value = rol
  mostrarModalPermisos.value = true
  loadingPermisos.value = true
  
  try {
    // 1. Intentamos obtener todos los módulos del sistema
    const modulosRes = await axios.get('http://localhost:3007/api/modulos').catch(() => ({ data: [] }))
    // 2. Obtenemos los permisos registrados para el rol
    const res = await axios.get(`http://localhost:3007/api/roles/${rol.id}/permisos`)
    
    let modulosList = modulosRes.data && modulosRes.data.length > 0 ? modulosRes.data : [];

    // Fallback estático con todos los módulos requeridos si la API falla
    if (modulosList.length === 0) {
      modulosList = [
        { id: 1, nombre: 'Dashboard' },
        { id: 2, nombre: 'Empleados' },
        { id: 3, nombre: 'Vacaciones' },
        { id: 4, nombre: 'Departamentos' },
        { id: 5, nombre: 'Reportes' },
        { id: 6, nombre: 'Roles y Permisos' },
        { id: 7, nombre: 'Control de Usuarios' },
        { id: 8, nombre: 'Tickets' },
        { id: 9, nombre: 'Documentos' },
        { id: 10, nombre: 'Faltas' },
        { id: 11, nombre: 'Gestión de Manuales' },
        { id: 12, nombre: 'Reportes de Incidencia' },
        { id: 13, nombre: 'Módulo de Reportes' },
        { id: 14, nombre: 'Archivero Legal' },
        { id: 15, nombre: 'Logs de Sistema' },
        { id: 24, nombre: 'Campanita de Notificaciones' },
        { id: 25, nombre: 'Reclutamiento' }
      ];
    }

    // Cruzar datos para que SIEMPRE aparezcan todos los módulos
    permisosForm.value = modulosList.map(modulo => {
      const p = res.data.find(perm => perm.modulo_id === modulo.id) || {}
      return {
        modulo_id: modulo.id,
        modulo_nombre: modulo.nombre,
        puedeVer: p.puedeVer || 0,
        puedeCrear: p.puedeCrear || 0,
        puedeEditar: p.puedeEditar || 0,
        puedeEliminar: p.puedeEliminar || 0
      }
    });
  } catch (error) {
    console.error('Error al cargar permisos', error)
    alert('❌ Error al cargar los permisos')
  } finally {
    loadingPermisos.value = false
  }
}

const cerrarModalPermisos = () => {
  mostrarModalPermisos.value = false
  rolSeleccionado.value = null
  permisosForm.value = []
}

const todosSeleccionados = (permiso) => {
  return permiso.puedeVer === 1 && permiso.puedeCrear === 1 && permiso.puedeEditar === 1 && permiso.puedeEliminar === 1;
}

const toggleTodos = (permiso, valor) => {
  const val = valor ? 1 : 0;
  permiso.puedeVer = val;
  permiso.puedeCrear = val;
  permiso.puedeEditar = val;
  permiso.puedeEliminar = val;
}

const onPuedeVerChange = (permiso) => {
  // Si quitamos el permiso de "Ver", automáticamente quitamos Crear, Editar y Eliminar
  // porque no tiene sentido poder hacer acciones sin poder ver el módulo.
  if (permiso.puedeVer === 0) {
    permiso.puedeCrear = 0;
    permiso.puedeEditar = 0;
    permiso.puedeEliminar = 0;
  }
}

const onPuedeAccionChange = (permiso) => {
  // Si marcamos Crear, Editar o Eliminar, automáticamente marcamos "Ver"
  // porque se necesita ver el módulo para hacer cualquier acción.
  if (permiso.puedeCrear === 1 || permiso.puedeEditar === 1 || permiso.puedeEliminar === 1) {
    permiso.puedeVer = 1;
  }
}

const guardarPermisos = async () => {
  try {
    await axios.put(`http://localhost:3007/api/roles/${rolSeleccionado.value.id}/permisos`, {
      permisos: permisosForm.value
    })
    alert('✅ Permisos actualizados exitosamente')
    cerrarModalPermisos()
  } catch (error) {
    console.error('Error al guardar permisos', error)
    alert('❌ Error al guardar los permisos')
  }
}

// GENERAL
const logout = () => {
  localStorage.clear()
  navigateTo('/login')
}

onMounted(async () => {
  rolID.value = localStorage.getItem('usuarioRol') || 2
  usuarioActual.value = localStorage.getItem('usuarioNombre') || 'Gerad Cole'
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

  cargarUsuarios()
  cargarRoles()
})
</script>