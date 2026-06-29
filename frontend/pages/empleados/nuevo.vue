<template>
  <div class="h-screen bg-slate-50 flex flex-col font-sans overflow-hidden">
    <!-- Header Fijo -->
    <header class="flex-none px-8 py-5 flex justify-between items-center bg-white border-b border-slate-200 shadow-sm z-10">
      <div>
        <h1 class="text-2xl font-black text-slate-800 tracking-tight uppercase">Nuevo Empleado</h1>
        <p class="text-slate-500 mt-0.5 text-xs font-medium italic">Complete la ficha de información del colaborador.</p>
      </div>
      <div class="flex gap-4">
        <button @click="cerrarVentana" type="button" class="px-6 py-2.5 text-slate-500 hover:text-red-500 font-bold text-xs uppercase tracking-widest transition flex items-center gap-2 bg-slate-100 rounded-xl hover:bg-red-50">
          <span>❌</span> Cancelar
        </button>
        <button form="form-nuevo-empleado" type="submit" :disabled="loading" class="px-8 py-2.5 bg-blue-600 text-white rounded-xl font-black uppercase text-xs tracking-[0.2em] hover:bg-blue-700 shadow-lg shadow-blue-500/30 transition-all disabled:bg-slate-300 flex items-center gap-2">
          <span>💾</span> {{ loading ? 'Guardando...' : 'Guardar Ficha' }}
        </button>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 overflow-y-auto p-6 flex justify-center items-start">
      <form id="form-nuevo-empleado" @submit.prevent="guardarEmpleado" class="w-full max-w-7xl bg-white p-8 rounded-3xl shadow-xl border border-slate-100 flex flex-col gap-6">
        
        <!-- Row 1: Personal & Laboral -->
        <div class="flex flex-col lg:flex-row gap-6">
          <!-- Personal -->
          <div class="flex-[2] bg-slate-50/50 p-6 rounded-2xl border border-slate-100">
            <h2 class="text-[10px] font-black text-blue-500 uppercase tracking-[0.2em] mb-4 border-b border-slate-200 pb-2">1. Información Personal</h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
              <div v-for="field in camposPersonales" :key="field.id">
                <label class="block text-[9px] font-black text-slate-400 uppercase mb-1.5 ml-1">{{ field.label }}</label>
                <input v-model="form[field.id]" :type="field.type" :placeholder="field.placeholder" required
                  class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all shadow-sm">
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
                <input v-else v-model="form[field.id]" :type="field.type" :placeholder="field.placeholder"
                  class="w-full px-3 py-2.5 text-sm bg-white border border-slate-200 rounded-xl text-slate-800 focus:ring-2 focus:ring-slate-500/20 focus:border-slate-500 outline-none transition-all shadow-sm">
              </div>
            </div>
          </div>
        </div>
      </form>
    </main>
  </div>
</template>

<script setup>
import axios from 'axios'

const loading = ref(false)
const departamentos = ref([])

const form = ref({
  codigo_empleado: '', identidad: '', nombre: '', apellido: '', fecha_nacimiento: '', genero: 'Masculino',
  correo: '', telefono: '', direccion: '',
  tipo_contrato: 'Permanente', fecha_inicio: '', ciudad: '', ubicacion: '', departamento_id: '',
  emergencia_parentesco: '', emergencia_nombre: '', emergencia_telefono: '',
  emergencia_parentesco_2: '', emergencia_nombre_2: '', emergencia_telefono_2: ''
})

onMounted(async () => {
  try {
    const res = await axios.get('http://localhost:3007/api/departamentos/lista')
    departamentos.value = res.data
  } catch (error) {
    console.error("Error al cargar departamentos", error)
  }
})

const camposPersonales = [
  { id: 'codigo_empleado', label: 'Código Empleado', type: 'text', placeholder: 'Ej: EMP-001' },
  { id: 'identidad', label: 'Identidad', type: 'text', placeholder: '0000-0000-00000' },
  { id: 'nombre', label: 'Nombres', type: 'text', placeholder: 'Ej: Juan Alberto' },
  { id: 'apellido', label: 'Apellidos', type: 'text', placeholder: 'Ej: Perez Flores' },
  { id: 'fecha_nacimiento', label: 'F. Nacimiento', type: 'date' },
  { id: 'correo', label: 'Correo Personal', type: 'email', placeholder: 'empleado@correo.com' },
  { id: 'telefono', label: 'Teléfono', type: 'text', placeholder: '+504 0000-0000' }
]

const camposLaborales = [
  { id: 'fecha_inicio', label: 'Fecha de Inicio', type: 'date' },
  { id: 'ciudad', label: 'Ciudad', type: 'text' },
  { id: 'ubicacion', label: 'Ubicación / Piso', type: 'text' }
]

const camposEmergencia = [
  { id: 'emergencia_parentesco', label: 'Parentesco', type: 'select', options: ['Padre', 'Madre', 'Conyuge', 'Hermano(a)', 'Tio(a)', 'Otro (a)'] },
  { id: 'emergencia_nombre', label: 'Nombre Completo', type: 'text' },
  { id: 'emergencia_telefono', label: 'Teléfono Emergencia', type: 'text' }
]

const camposEmergencia2 = [
  { id: 'emergencia_parentesco_2', label: 'Parentesco', type: 'select', options: ['Padre', 'Madre', 'Conyuge', 'Hermano(a)', 'Tio(a)', 'Otro (a)'] },
  { id: 'emergencia_nombre_2', label: 'Nombre Completo', type: 'text' },
  { id: 'emergencia_telefono_2', label: 'Teléfono Emergencia', type: 'text' }
]

// Función para cerrar la pestaña
const cerrarVentana = () => {
  navigateTo('/empleados')
}

const guardarEmpleado = async () => {
  try {
    loading.value = true
    const res = await axios.post('http://localhost:3007/api/empleados/crear', form.value)
    
    alert('✅ ' + res.data.mensaje)
    
    // Regresa a la lista de empleados al guardar exitosamente
    navigateTo('/empleados')
    
  } catch (e) {
    alert('❌ ' + (e.response?.data?.mensaje || 'Error al guardar'))
  } finally {
    loading.value = false
  }
}
</script>