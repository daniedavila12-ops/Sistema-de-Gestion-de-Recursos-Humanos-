<template>
  <div>
    <!-- Overlay for mobile -->
    <div 
      v-if="isMobileMenuOpen" 
      @click="toggleMobileMenu" 
      class="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-40 md:hidden"
    ></div>

    <aside 
      :class="[
        isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0',
        isSidebarCollapsed ? 'md:w-20' : 'w-64'
      ]"
      class="bg-slate-800 text-white flex flex-col shadow-xl fixed left-0 top-0 h-full z-50 transition-all duration-300"
    >
      <div class="p-6 text-2xl font-bold border-b border-slate-700 tracking-tight text-blue-400 uppercase flex justify-between items-center transition-all duration-300" :class="isSidebarCollapsed ? 'justify-center p-4 text-center' : ''">
        <span v-if="!isSidebarCollapsed">RRHH Innova</span>
        <span v-else class="text-3xl">R</span>
        <button @click="toggleMobileMenu" class="md:hidden text-slate-400 hover:text-white transition p-1">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
        </button>
      </div>
      
      <nav class="flex-1 p-4 space-y-1 overflow-y-auto scrollbar-thin overflow-x-hidden">
        <div v-for="(item, index) in menuUsuario" :key="item.ruta || index">
          <div v-if="item.esCabecera" class="text-[10px] font-black text-slate-500 uppercase tracking-widest mt-6 mb-2 px-3 transition-opacity duration-300" :class="isSidebarCollapsed ? 'opacity-0 h-0 my-0' : 'opacity-100'">
            {{ item.nombre }}
          </div>
          <button v-else-if="item.ruta === '/empleados/nuevo'" @click="abrirModalEmpleado"
             class="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-slate-700 transition-all duration-200 group"
             :title="isSidebarCollapsed ? item.nombre : ''"
             :class="isSidebarCollapsed ? 'justify-center' : ''">
            <span class="text-xl group-hover:scale-110 transition-transform shrink-0">{{ item.icono }}</span>
            <span v-if="!isSidebarCollapsed" class="text-sm font-medium whitespace-nowrap overflow-hidden transition-all duration-300">{{ item.nombre }}</span>
          </button>
          <NuxtLink v-else :to="item.ruta" @click="cerrarEnMovil"
            class="flex items-center gap-3 p-3 rounded-xl hover:bg-slate-700 transition-all duration-200 group"
            active-class="bg-blue-600 shadow-lg"
            :title="isSidebarCollapsed ? item.nombre : ''"
            :class="isSidebarCollapsed ? 'justify-center' : ''">
            <span class="text-xl group-hover:scale-110 transition-transform shrink-0">{{ item.icono }}</span>
            <span v-if="!isSidebarCollapsed" class="text-sm font-medium whitespace-nowrap overflow-hidden transition-all duration-300">{{ item.nombre }}</span>
          </NuxtLink>
        </div>
      </nav>

      <div class="p-4 border-t border-slate-700 bg-slate-900/50">
        <div v-if="!isSidebarCollapsed" class="mb-4 px-2 flex flex-col transition-opacity duration-300">
          <span class="text-[9px] font-black text-slate-500 uppercase tracking-widest">Nivel de Acceso</span>
          <span class="text-xs font-bold text-blue-400">{{ rolNombre }}</span>
        </div>
        <button @click="logout" class="w-full flex items-center gap-3 p-3 rounded-xl hover:bg-red-500/10 hover:text-red-400 transition-all font-bold text-xs uppercase tracking-widest group"
                :title="isSidebarCollapsed ? 'Cerrar Sesión' : ''"
                :class="isSidebarCollapsed ? 'justify-center' : ''">
          <span class="group-hover:scale-110 transition-transform shrink-0">🚪</span> 
          <span v-if="!isSidebarCollapsed" class="whitespace-nowrap transition-all duration-300">Cerrar Sesión</span>
        </button>
      </div>
    </aside>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { navigateTo } from '#app'
import axios from 'axios'
import { useSidebar } from '@/composables/useSidebar'

const { isMobileMenuOpen, toggleMobileMenu, isSidebarCollapsed } = useSidebar()
const menuUsuario = ref([])
const rolNombre = ref('Cargando...')
const rolID = ref(null)

const cerrarEnMovil = () => {
  if (isMobileMenuOpen.value) {
    toggleMobileMenu()
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
    const m = await axios.get(`/api/menu/${rolID.value}?usuario_id=${localStorage.getItem('usuarioID')}`)
    menuUsuario.value = m.data
  } catch (err) {
    console.error("Error cargando menu", err)
  }
})

const abrirModalEmpleado = () => {
  cerrarEnMovil()
  navigateTo('/empleados?nuevo=true')
}

const logout = () => {
  localStorage.clear();
  navigateTo('/login')
}
</script>
