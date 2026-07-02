<template>
  <div class="h-screen bg-slate-50 flex items-center justify-center">
    <div class="text-slate-400 font-bold uppercase tracking-widest text-sm animate-pulse flex flex-col items-center gap-4">
      <div class="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
      Abriendo Formulario...
    </div>
  </div>
</template>

<script setup>
definePageMeta({
  middleware: [
    function (to, from) {
      return navigateTo('/empleados?nuevo=true')
    }
  ]
})
</script>