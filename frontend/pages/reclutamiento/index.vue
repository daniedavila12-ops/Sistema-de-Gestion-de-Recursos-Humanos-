<template>
  <div class="min-h-screen bg-slate-50 flex items-center justify-center p-4">
    <div class="bg-white rounded-2xl shadow-xl p-8 max-w-lg w-full">
      <div class="text-center mb-8 flex flex-col items-center">
        <img src="http://localhost:3007/uploads/Logo/Logo.png" alt="Logo Innova" class="h-16 mb-4 object-contain" />
        <h1 class="text-3xl font-bold text-slate-800 tracking-tight uppercase">Trabaja en INNOVA</h1>
        <p class="text-slate-500 mt-2 font-medium">Únete a nuestro equipo de trabajo. Completa el formulario y adjunta tu CV.</p>
      </div>

      <form @submit.prevent="submitForm" class="space-y-5">
        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1">Nombre Completo</label>
          <input 
            type="text" 
            v-model="form.nombre_completo" 
            required 
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
            placeholder="Ej. Juan Pérez"
          />
        </div>

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1">Correo Electrónico</label>
          <input 
            type="email" 
            v-model="form.correo" 
            required 
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
            placeholder="ejemplo@correo.com"
          />
        </div>

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1">Teléfono</label>
          <input 
            type="tel" 
            v-model="form.telefono" 
            required 
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
            placeholder="+123456789"
          />
        </div>

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1">Puesto al que aplica</label>
          <input 
            type="text" 
            v-model="form.puesto_aplicado" 
            required 
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition"
            placeholder="Ej. Desarrollador Web"
          />
        </div>

        <div>
          <label class="block text-sm font-semibold text-slate-700 mb-1">Currículum Vitae (PDF)</label>
          <input 
            type="file" 
            @change="handleFileUpload" 
            accept=".pdf" 
            required 
            class="w-full px-4 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
          />
        </div>

        <button 
          type="submit" 
          :disabled="isSubmitting"
          class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition duration-200 disabled:opacity-50 disabled:cursor-not-allowed mt-4"
        >
          {{ isSubmitting ? 'Enviando Aplicación...' : 'Enviar Aplicación' }}
        </button>
      </form>

      <div v-if="mensaje" :class="['mt-6 p-4 rounded-lg text-center font-medium', alertType === 'success' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800']">
        {{ mensaje }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const form = ref({
  nombre_completo: '',
  correo: '',
  telefono: '',
  puesto_aplicado: ''
});
const file = ref(null);
const isSubmitting = ref(false);
const mensaje = ref('');
const alertType = ref('');

const handleFileUpload = (event) => {
  const selectedFile = event.target.files[0];
  if (selectedFile && selectedFile.type !== 'application/pdf') {
    mostrarMensaje('Solo se permiten archivos PDF.', 'error');
    event.target.value = '';
    file.value = null;
    return;
  }
  file.value = selectedFile;
};

const submitForm = async () => {
  if (!file.value) {
    mostrarMensaje('Por favor, adjunta tu CV.', 'error');
    return;
  }

  isSubmitting.value = true;
  mensaje.value = '';

  const formData = new FormData();
  formData.append('nombre_completo', form.value.nombre_completo);
  formData.append('correo', form.value.correo);
  formData.append('telefono', form.value.telefono);
  formData.append('puesto_aplicado', form.value.puesto_aplicado);
  formData.append('cv', file.value);

  try {
    const config = useRuntimeConfig();
    const apiUrl = 'http://localhost:3007/api/candidatos/upload'; // Fallback a localhost

    const response = await fetch(apiUrl, {
      method: 'POST',
      body: formData
    });

    const data = await response.json();

    if (response.ok) {
      mostrarMensaje(data.mensaje || 'Aplicación enviada con éxito.', 'success');
      resetForm();
    } else {
      mostrarMensaje(data.error || 'Error al enviar la aplicación.', 'error');
    }
  } catch (error) {
    mostrarMensaje('Error de conexión al servidor.', 'error');
  } finally {
    isSubmitting.value = false;
  }
};

const mostrarMensaje = (texto, tipo) => {
  mensaje.value = texto;
  alertType.value = tipo;
  setTimeout(() => { mensaje.value = '' }, 5000);
};

const resetForm = () => {
  form.value = { nombre_completo: '', correo: '', telefono: '', puesto_aplicado: '' };
  file.value = null;
  const fileInput = document.querySelector('input[type="file"]');
  if (fileInput) fileInput.value = '';
};
</script>
