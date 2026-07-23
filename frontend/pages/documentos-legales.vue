<template>
  <div class="min-h-screen bg-gray-100 flex font-sans overflow-x-hidden">
    <!-- SIDEBAR -->
    <AppSidebar />

    <!-- MAIN CONTENT -->
    <main :class="['w-full overflow-x-hidden transition-all duration-300 flex-1 p-4 md:p-8', isSidebarCollapsed ? 'md:ml-20' : 'md:ml-64']">
      <BreadcrumbNav :crumbs="[{ text: 'Archivero Legal' }]">
        <template #right>
          <div class="relative w-full md:w-auto flex justify-end">
            <div @click="dropdownPerfilAbierto = !dropdownPerfilAbierto" class="flex items-center gap-3 pl-6 border-l border-slate-200 cursor-pointer hover:bg-slate-50 p-2 rounded-xl transition-colors no-print">
              <div v-if="fotoUsuario" class="h-10 w-10 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-slate-100">
                <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
              </div>
              <div v-else class="h-10 w-10 rounded-full bg-slate-800 flex items-center justify-center text-blue-400 font-black text-lg ring-2 ring-slate-100 uppercase">
                {{ usuarioActual ? usuarioActual.charAt(0) : 'U' }}
              </div>
              <div class="flex flex-col text-left hidden md:flex">
                <span class="text-[10px] text-slate-400 font-black uppercase tracking-widest">Usuario Activo</span>
                <span class="text-base font-black text-slate-900 leading-tight">{{ usuarioActual || 'Cargando...' }}</span>
              </div>
            </div>

            <!-- Dropdown Menu -->
            <div v-if="dropdownPerfilAbierto" class="absolute right-0 mt-14 w-64 bg-white rounded-2xl shadow-xl border border-slate-100 overflow-hidden z-50 animate-in slide-in-from-top-2 duration-200 no-print">
              <div class="p-5 border-b border-slate-100 bg-slate-50 flex items-center gap-4">
                <div v-if="fotoUsuario" class="h-12 w-12 rounded-full flex items-center justify-center overflow-hidden ring-2 ring-white shadow-sm shrink-0">
                  <img :src="`${$config.public.apiBase}${fotoUsuario}`" class="w-full h-full object-cover" />
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
        </template>
      </BreadcrumbNav>

      <header class="mb-8 flex justify-between items-center bg-white p-5 rounded-3xl shadow-sm border border-slate-100">
        <div class="flex items-center gap-4">
          <button @click="toggleMobileMenu" class="md:hidden p-2 text-slate-500 hover:text-slate-800 hover:bg-slate-100 rounded-lg transition-colors shrink-0">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
          </button>
          <div>
            <h1 class="text-3xl font-black text-slate-800 tracking-tight uppercase">Archivero <span class="text-amber-500">Legal</span></h1>
            <p class="text-slate-500 mt-1 font-medium italic">Repositorio seguro de documentos legales y normativas.</p>
          </div>
        </div>
        <div class="flex gap-3">
          <button @click="abrirModal" class="bg-amber-600 hover:bg-amber-500 text-white px-6 py-3 rounded-xl font-black uppercase text-xs transition-all shadow-lg shadow-amber-900/20 flex items-center gap-2">
            <span>➕</span> Subir Documento
          </button>
        </div>
      </header>

    <div v-if="cargando" class="text-center py-20 text-slate-500">
      <p class="text-xl italic font-medium">Accediendo al archivero...</p>
    </div>

    <div v-else class="w-full grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      <div v-for="doc in documentosFiltrados" :key="doc.id" 
        class="bg-white rounded-2xl overflow-hidden shadow-sm border border-slate-200 group hover:shadow-md hover:-translate-y-1 transition-all duration-300 relative flex flex-col">
        <div class="h-1.5 bg-gradient-to-r from-amber-500 to-amber-600"></div>
        
        <!-- Botones Acción -->
        <div class="absolute top-4 right-4 flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
          <button @click="abrirModalEdicion(doc)" class="p-1.5 text-slate-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="Editar documento">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>
          </button>
          <button @click="eliminarDocumento(doc.id)" class="p-1.5 text-slate-400 hover:text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="Eliminar documento">
            <svg class="w-4 h-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
          </button>
        </div>

        <div class="p-5 flex-1 flex flex-col">
          <div class="mb-3 pr-16">
            <span class="inline-flex items-center px-2 py-0.5 bg-amber-50 text-amber-700 text-[9px] font-bold uppercase rounded-md tracking-widest border border-amber-200">
              {{ doc.categoria || 'General' }}
            </span>
          </div>
          <h3 class="text-[15px] font-bold text-slate-800 mb-1.5 leading-snug group-hover:text-amber-600 transition-colors">{{ doc.titulo }}</h3>
          <p class="text-slate-500 text-[11px] leading-relaxed mb-4 line-clamp-2 flex-1">{{ doc.descripcion || 'Sin descripción' }}</p>
          
          <div class="flex justify-between items-center text-[10px] text-slate-400 font-medium mb-4 border-t border-slate-100 pt-3">
            <span class="flex items-center gap-1"><svg class="w-3 h-3" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg> {{ new Date(doc.fecha_creacion).toLocaleDateString() }}</span>
            <span v-if="doc.creadoPorNombre" class="truncate max-w-[100px]" :title="doc.creadoPorNombre">Por: {{ doc.creadoPorNombre }}</span>
          </div>

          <div class="flex flex-col gap-1.5 mt-auto">
            <!-- Legacy File -->
            <button v-if="doc.archivo && (!doc.archivos || doc.archivos.length === 0)" @click="descargarUrl(doc.archivo)" 
              class="w-full py-2 bg-slate-50 text-slate-600 rounded-lg font-bold uppercase text-[10px] tracking-widest hover:bg-amber-50 hover:text-amber-700 hover:border-amber-200 transition-all flex items-center justify-center gap-2 border border-slate-200">
              <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg> Descargar (Legacy) <span class="font-normal opacity-70">{{ doc.tamano }}</span>
            </button>
            
            <!-- Multiple Files -->
            <div v-for="(arch, idx) in doc.archivos" :key="'arch-'+arch.id" class="flex flex-col gap-1">
              <button @click="descargarUrl(arch.archivo_url)" 
                class="w-full py-2 bg-slate-50 text-slate-600 rounded-lg font-bold uppercase text-[10px] tracking-widest hover:bg-amber-50 hover:text-amber-700 hover:border-amber-200 transition-all flex items-center justify-center gap-2 border border-slate-200">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg> Archivo {{ idx + 1 }} <span class="font-normal opacity-70">{{ arch.tamano }}</span>
              </button>
            </div>

            <!-- Legacy Link -->
            <a v-if="doc.link_web && (!doc.links || doc.links.length === 0)" :href="doc.link_web" target="_blank"
              class="w-full py-2 bg-slate-50 text-slate-600 rounded-lg font-bold uppercase text-[10px] tracking-widest hover:bg-blue-50 hover:text-blue-700 hover:border-blue-200 transition-all flex items-center justify-center gap-2 border border-slate-200">
              <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/></svg> Link (Legacy)
            </a>

            <!-- Multiple Links -->
            <div v-for="(l, idx) in doc.links" :key="'link-'+l.id" class="flex flex-col gap-1">
              <a :href="l.link_url" target="_blank"
                class="w-full py-2 bg-slate-50 text-slate-600 rounded-lg font-bold uppercase text-[10px] tracking-widest hover:bg-blue-50 hover:text-blue-700 hover:border-blue-200 transition-all flex items-center justify-center gap-2 border border-slate-200">
                <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/></svg> Link {{ idx + 1 }}
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="!cargando && documentosFiltrados.length === 0" class="text-center py-20 text-slate-500 bg-white rounded-3xl border border-slate-100 w-full shadow-sm">
      <span class="text-6xl mb-4 block opacity-50">🗄️</span>
      <p class="text-xl italic font-medium">El archivero está vacío o no hay resultados.</p>
    </div>

    <!-- Modal para subir documento -->
    <div v-if="mostrarModal" class="fixed inset-0 bg-slate-900/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
      <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden border border-slate-200">
        <div class="bg-slate-800 p-6 flex justify-between items-center">
          <h2 class="text-white font-black text-xl tracking-tighter uppercase flex items-center gap-2">
            <span class="text-amber-500">{{ isEditing ? '✏️' : '➕' }}</span> {{ isEditing ? 'Editar Registro' : 'Nuevo Registro' }}
          </h2>
          <button @click="cerrarModal" class="text-slate-400 hover:text-white transition-colors">
            ❌
          </button>
        </div>
        
        <form @submit.prevent="subirDocumento" class="p-8 overflow-y-auto max-h-[75vh]">
          <div class="mb-5">
            <label class="block text-slate-700 text-xs font-bold uppercase tracking-widest mb-2">Título *</label>
            <input v-model="form.titulo" type="text" required
              class="w-full bg-slate-50 border border-slate-200 p-3 rounded-xl text-slate-800 outline-none focus:border-amber-500 focus:bg-white transition-all">
          </div>
          
          <div class="mb-5">
            <div class="flex justify-between items-center mb-2">
              <label class="block text-slate-700 text-xs font-bold uppercase tracking-widest">Categoría</label>
              <button type="button" @click="abrirModalCategorias" class="text-[10px] text-amber-600 hover:text-amber-800 font-bold underline">
                ⚙️ Gestionar Categorías
              </button>
            </div>
            <select v-model="form.categoria" 
              class="w-full bg-slate-50 border border-slate-200 p-3 rounded-xl text-slate-800 outline-none focus:border-amber-500 focus:bg-white transition-all">
              <option v-for="cat in listaCategorias" :key="cat.id" :value="cat.nombre">{{ cat.nombre }}</option>
              <option v-if="listaCategorias.length === 0" value="General">General</option>
            </select>
          </div>

          <div class="mb-5">
            <label class="block text-slate-700 text-xs font-bold uppercase tracking-widest mb-2">Descripción</label>
            <textarea v-model="form.descripcion" rows="3"
              class="w-full bg-slate-50 border border-slate-200 p-3 rounded-xl text-slate-800 outline-none focus:border-amber-500 focus:bg-white transition-all"></textarea>
          </div>

          <div class="mb-6 bg-slate-50 p-4 rounded-2xl border border-slate-200">
            <div class="flex justify-between items-center mb-3">
              <label class="block text-slate-700 text-xs font-bold uppercase tracking-widest">Archivos</label>
              <button type="button" @click="agregarInputArchivo" class="text-[10px] bg-amber-100 text-amber-700 hover:bg-amber-200 px-2 py-1 rounded font-bold uppercase tracking-widest transition-colors">
                + Agregar Archivo
              </button>
            </div>
            
            <!-- Archivos Existentes (Edición) -->
            <div v-if="isEditing" class="space-y-2 mb-3">
              <div v-for="arch in form.archivosExistentes" :key="arch.id" class="flex justify-between items-center bg-white p-2 rounded border border-slate-200 text-xs text-slate-600">
                <span class="truncate pr-2">Archivo {{ arch.id }} ({{ arch.tamano }})</span>
                <button type="button" @click="marcarArchivoParaEliminar(arch.id)" class="text-red-500 hover:text-red-700" title="Eliminar archivo">❌</button>
              </div>
            </div>

            <!-- Nuevos Archivos -->
            <div class="space-y-2">
              <div v-for="(fileInput, index) in form.archivosInputs" :key="fileInput.id" class="flex items-center gap-2">
                <input type="file" @change="(e) => handleMultipleFileChange(e, index)" accept=".pdf,.doc,.docx,.png,.jpg,.jpeg"
                  class="flex-1 text-sm text-slate-500 file:mr-2 file:py-2 file:px-3 file:rounded-full file:border-0 file:text-xs file:font-bold file:bg-amber-50 file:text-amber-700 hover:file:bg-amber-100 transition-all cursor-pointer">
                <button v-if="form.archivosInputs.length > 1 || isEditing" type="button" @click="removerInputArchivo(index)" class="text-red-500 hover:text-red-700 text-sm">❌</button>
              </div>
            </div>
          </div>

          <div class="mb-6 bg-slate-50 p-4 rounded-2xl border border-slate-200">
            <div class="flex justify-between items-center mb-3">
              <label class="block text-slate-700 text-xs font-bold uppercase tracking-widest">Links Web</label>
              <button type="button" @click="agregarInputLink" class="text-[10px] bg-blue-100 text-blue-700 hover:bg-blue-200 px-2 py-1 rounded font-bold uppercase tracking-widest transition-colors">
                + Agregar Link
              </button>
            </div>
            <div class="space-y-2">
              <div v-for="(linkObj, index) in form.linksInputs" :key="linkObj.id" class="flex items-center gap-2">
                <input v-model="linkObj.url" type="url" placeholder="https://ejemplo.com"
                  class="flex-1 bg-white border border-slate-200 p-2 rounded-xl text-sm text-slate-800 outline-none focus:border-amber-500 transition-all">
                <button v-if="form.linksInputs.length > 1 || isEditing" type="button" @click="removerInputLink(index)" class="text-red-500 hover:text-red-700 text-sm">❌</button>
              </div>
            </div>
          </div>

          <div class="mb-8 flex items-center gap-2" v-if="!isEditing">
            <input type="checkbox" id="seguirAgregando" v-model="seguirAgregando" class="w-4 h-4 text-amber-600 rounded border-slate-300 focus:ring-amber-500">
            <label for="seguirAgregando" class="text-sm font-bold text-slate-700 cursor-pointer">Guardar y seguir agregando</label>
          </div>

          <div class="flex gap-4">
            <button type="button" @click="cerrarModal" 
              class="flex-1 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold uppercase text-xs tracking-widest hover:bg-slate-200 transition-colors">
              Cancelar
            </button>
            <button type="submit" :disabled="subiendo"
              class="flex-1 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold uppercase text-xs tracking-widest hover:bg-slate-200 transition-colors disabled:opacity-50">
              {{ subiendo ? (isEditing ? 'Actualizando...' : 'Subiendo...') : (isEditing ? 'Actualizar' : 'Guardar') }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Modal Gestionar Categorías -->
    <div v-if="mostrarModalCategorias" class="fixed inset-0 bg-slate-900/90 backdrop-blur-sm flex items-center justify-center p-4 z-[60]">
      <div class="bg-white rounded-3xl shadow-2xl w-full max-w-sm overflow-hidden border border-slate-200">
        <div class="bg-slate-800 p-5 flex justify-between items-center">
          <h2 class="text-white font-black text-lg tracking-tighter uppercase flex items-center gap-2">
            ⚙️ Categorías
          </h2>
          <button @click="cerrarModalCategorias" class="text-slate-400 hover:text-white transition-colors">
            ❌
          </button>
        </div>
        
        <div class="p-6">
          <div class="flex gap-2 mb-6">
            <input v-model="nuevaCategoria" type="text" placeholder="Nueva categoría..."
              class="flex-1 bg-slate-50 border border-slate-200 p-2 rounded-xl text-sm outline-none focus:border-amber-500">
            <button @click="agregarCategoria" :disabled="!nuevaCategoria.trim()"
              class="bg-slate-900 text-white px-4 rounded-xl text-sm font-bold hover:bg-slate-800 transition disabled:opacity-50">
              Añadir
            </button>
          </div>

          <div class="max-h-60 overflow-y-auto pr-2 space-y-2">
            <div v-if="listaCategorias.length === 0" class="text-center text-slate-400 text-sm italic py-4">
              No hay categorías.
            </div>
            <div v-for="cat in listaCategorias" :key="cat.id" class="flex items-center justify-between bg-slate-50 p-3 rounded-xl border border-slate-100 group">
              <div v-if="editandoId === cat.id" class="flex-1 flex gap-2 mr-2">
                <input v-model="editNombre" type="text" class="w-full bg-white border border-slate-300 p-1 rounded text-sm outline-none focus:border-blue-500">
                <button @click="guardarEdicionCategoria(cat.id)" class="text-green-600 hover:text-green-800">✅</button>
                <button @click="cancelarEdicion" class="text-slate-400 hover:text-slate-600">❌</button>
              </div>
              <div v-else class="flex-1 flex justify-between items-center">
                <span class="text-sm font-bold text-slate-700">{{ cat.nombre }}</span>
                <div class="opacity-0 group-hover:opacity-100 transition-opacity flex gap-3">
                  <button @click="iniciarEdicion(cat)" class="text-blue-500 hover:text-blue-700" title="Editar">✏️</button>
                  <button @click="eliminarCategoria(cat.id)" class="text-red-400 hover:text-red-600" title="Eliminar">🗑️</button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Modal Perfil -->
    <div v-if="modalAbiertoPerfil" class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[70] flex justify-center items-center p-4">
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
import { useSidebar } from '@/composables/useSidebar'
const { toggleMobileMenu, isSidebarCollapsed } = useSidebar()
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const rolID = ref(null)
const rolNombre = ref('Cargando...')
const usuarioActual = ref('')
const fotoUsuario = ref(null)

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

const logout = () => {
  localStorage.clear()
  router.push('/login')
}

const config = useRuntimeConfig()
const search = ref('')
const listaDocumentos = ref([])
const listaCategorias = ref([])
const cargando = ref(true)
const mostrarModal = ref(false)
const subiendo = ref(false)
const isEditing = ref(false)
const editDocumentoId = ref(null)
const seguirAgregando = ref(false)

// Estados para Modal Categorías
const mostrarModalCategorias = ref(false)
const nuevaCategoria = ref('')
const editandoId = ref(null)
const editNombre = ref('')

const generarIdUnico = () => Math.random().toString(36).substr(2, 9)

const form = ref({
  titulo: '',
  descripcion: '',
  categoria: 'General',
  archivosInputs: [{ id: generarIdUnico(), file: null }],
  archivosExistentes: [],
  archivosEliminar: [],
  linksInputs: [{ id: generarIdUnico(), url: '' }]
})

const resetForm = () => {
  form.value = {
    titulo: '',
    descripcion: '',
    categoria: form.value.categoria,
    archivosInputs: [{ id: generarIdUnico(), file: null }],
    archivosExistentes: [],
    archivosEliminar: [],
    linksInputs: [{ id: generarIdUnico(), url: '' }]
  }
}

const agregarInputArchivo = () => {
  form.value.archivosInputs.push({ id: generarIdUnico(), file: null })
}

const removerInputArchivo = (index) => {
  form.value.archivosInputs.splice(index, 1)
}

const handleMultipleFileChange = (e, index) => {
  if (e.target.files.length > 0) {
    form.value.archivosInputs[index].file = e.target.files[0]
  } else {
    form.value.archivosInputs[index].file = null
  }
}

const marcarArchivoParaEliminar = (id) => {
  form.value.archivosEliminar.push(id)
  form.value.archivosExistentes = form.value.archivosExistentes.filter(a => a.id !== id)
}

const agregarInputLink = () => {
  form.value.linksInputs.push({ id: generarIdUnico(), url: '' })
}

const removerInputLink = (index) => {
  form.value.linksInputs.splice(index, 1)
}

const cargarDocumentos = async () => {
  try {
    const res = await fetch(`${config.public.apiBase}/api/documentos-legales`)
    if (res.ok) {
      listaDocumentos.value = await res.json()
    }
  } catch (error) {
    console.error('Error cargando documentos legales:', error)
  }
}

const cargarCategorias = async () => {
  try {
    const res = await fetch(`${config.public.apiBase}/api/categorias-legales`)
    if (res.ok) {
      listaCategorias.value = await res.json()
      if (listaCategorias.value.length > 0 && !listaCategorias.value.find(c => c.nombre === form.value.categoria)) {
        form.value.categoria = listaCategorias.value[0].nombre;
      }
    }
  } catch (error) {
    console.error('Error cargando categorías legales:', error)
  }
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
    const m = await fetch(`${config.public.apiBase}/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    if (m.ok) {
      menuUsuario.value = await m.json()
    }
  } catch (e) {
    console.error('Error cargando menú', e)
  }

  cargando.value = true
  await Promise.all([cargarDocumentos(), cargarCategorias()])
  cargando.value = false
})

const documentosFiltrados = computed(() => {
  const query = search.value.toLowerCase()
  return listaDocumentos.value.filter(doc => 
    doc.titulo.toLowerCase().includes(query) || 
    (doc.categoria && doc.categoria.toLowerCase().includes(query)) ||
    (doc.descripcion && doc.descripcion.toLowerCase().includes(query))
  )
})

const descargarUrl = (url) => {
  if (url) {
    window.open(`${config.public.apiBase}${url}`, '_blank');
  }
}

const abrirModal = () => {
  isEditing.value = false
  editDocumentoId.value = null
  resetForm()
  mostrarModal.value = true
}

const abrirModalEdicion = (doc) => {
  isEditing.value = true
  editDocumentoId.value = doc.id
  
  // Prepare existing files and links
  let archivosExistentes = doc.archivos ? [...doc.archivos] : []
  let linksInputs = doc.links && doc.links.length > 0 
    ? doc.links.map(l => ({ id: generarIdUnico(), url: l.link_url })) 
    : []
    
  // Handle legacy single link
  if (doc.link_web && (!doc.links || doc.links.length === 0)) {
    linksInputs.push({ id: generarIdUnico(), url: doc.link_web })
  }
  
  // If no links, add one empty input
  if (linksInputs.length === 0) {
     linksInputs.push({ id: generarIdUnico(), url: '' })
  }

  form.value = {
    titulo: doc.titulo,
    descripcion: doc.descripcion || '',
    categoria: doc.categoria || 'General',
    archivosInputs: [{ id: generarIdUnico(), file: null }],
    archivosExistentes: archivosExistentes,
    archivosEliminar: [],
    linksInputs: linksInputs
  }
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
}

const subirDocumento = async () => {
  const linksValidos = form.value.linksInputs.map(l => l.url.trim()).filter(url => url !== '')
  const archivosNuevos = form.value.archivosInputs.filter(inp => inp.file !== null)
  
  // Validation: Must have at least one file (new or existing) OR one link
  const totalFiles = archivosNuevos.length + (form.value.archivosExistentes ? form.value.archivosExistentes.length : 0);
  
  if (totalFiles === 0 && linksValidos.length === 0) {
    alert('Debe subir al menos un archivo o ingresar un link.')
    return
  }

  subiendo.value = true
  const formData = new FormData()
  formData.append('titulo', form.value.titulo)
  formData.append('descripcion', form.value.descripcion)
  formData.append('categoria', form.value.categoria)
  
  // Append multiple files
  archivosNuevos.forEach(inp => {
    formData.append('archivos', inp.file)
  })
  
  // Append links as JSON
  formData.append('links', JSON.stringify(linksValidos))
  
  // Append files to delete (for edit mode)
  if (isEditing.value) {
     formData.append('archivosEliminar', JSON.stringify(form.value.archivosEliminar))
  }
  
  let userId = localStorage.getItem('usuarioID') || 1;

  formData.append('creado_por', userId)

  try {
    let url = `${config.public.apiBase}/api/documentos-legales`
    let method = 'POST'
    
    if (isEditing.value) {
      url = `${config.public.apiBase}/api/documentos-legales/${editDocumentoId.value}`
      method = 'PUT'
    }

    const res = await fetch(url, {
      method: method,
      body: formData
    })
    
    if (res.ok) {
      if (!isEditing.value && seguirAgregando.value) {
        resetForm()
        alert('Documento guardado con éxito. Puede continuar agregando otro.')
      } else {
        cerrarModal()
      }
      await cargarDocumentos()
    } else {
      const errorData = await res.json()
      alert(`Error al ${isEditing.value ? 'actualizar' : 'subir'}: ` + (errorData.error || 'Desconocido'))
    }
  } catch (error) {
    console.error('Error:', error)
    alert('Error de conexión al guardar documento.')
  } finally {
    subiendo.value = false
  }
}

const eliminarDocumento = async (id) => {
  if (!confirm('¿Estás seguro de que deseas eliminar este registro? Esta acción no se puede deshacer y borrará todos sus archivos y links.')) return

  try {
    const res = await fetch(`${config.public.apiBase}/api/documentos-legales/${id}`, {
      method: 'DELETE'
    })
    
    if (res.ok) {
      await cargarDocumentos()
    } else {
      alert('Error al eliminar el documento.')
    }
  } catch (error) {
    console.error('Error al eliminar:', error)
  }
}

// --- GESTIÓN DE CATEGORÍAS ---
const abrirModalCategorias = () => {
  mostrarModalCategorias.value = true
}

const cerrarModalCategorias = () => {
  mostrarModalCategorias.value = false
  nuevaCategoria.value = ''
  cancelarEdicion()
}

const agregarCategoria = async () => {
  if (!nuevaCategoria.value.trim()) return
  try {
    const res = await fetch(`${config.public.apiBase}/api/categorias-legales`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: nuevaCategoria.value.trim() })
    })
    if (res.ok) {
      nuevaCategoria.value = ''
      await cargarCategorias()
    } else {
      const err = await res.json()
      alert(err.error || 'Error al agregar')
    }
  } catch(e) {
    console.error(e)
  }
}

const eliminarCategoria = async (id) => {
  if(!confirm('¿Eliminar esta categoría?')) return
  try {
    const res = await fetch(`${config.public.apiBase}/api/categorias-legales/${id}`, { method: 'DELETE' })
    if (res.ok) await cargarCategorias()
  } catch(e) {
    console.error(e)
  }
}

const iniciarEdicion = (cat) => {
  editandoId.value = cat.id
  editNombre.value = cat.nombre
}

const cancelarEdicion = () => {
  editandoId.value = null
  editNombre.value = ''
}

const guardarEdicionCategoria = async (id) => {
  if (!editNombre.value.trim()) return
  try {
    const res = await fetch(`${config.public.apiBase}/api/categorias-legales/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre: editNombre.value.trim() })
    })
    if (res.ok) {
      cancelarEdicion()
      await cargarCategorias()
    } else {
       const err = await res.json()
       alert(err.error || 'Error al actualizar')
    }
  } catch(e) {
    console.error(e)
  }
}
</script>
