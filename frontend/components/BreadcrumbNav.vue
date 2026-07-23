<template>
  <div class="flex items-center justify-between text-sm text-slate-600 font-medium bg-white p-3 rounded-2xl shadow-sm border border-slate-100 mb-6 relative z-30">
    <div class="flex items-center gap-3">
      <button @click="toggleSidebar" class="p-1.5 hover:bg-slate-100 rounded-lg transition-colors flex items-center gap-2 text-slate-700 bg-slate-50 border border-slate-200" title="Retraer Menú">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path></svg>
      </button>
      
      <span class="text-slate-300">|</span>
      
      <div class="flex items-center gap-2 text-[13px] tracking-wide">
        <NuxtLink to="/dashboard" class="text-blue-600 font-bold hover:text-blue-800 transition-colors">Inicio</NuxtLink>
        <span v-for="(crumb, index) in crumbs" :key="index" class="flex items-center gap-2">
          <span class="text-slate-400 text-[10px] font-black">›</span>
          <NuxtLink v-if="crumb.to" :to="crumb.to" class="text-blue-600 font-bold hover:text-blue-800 transition-colors">{{ crumb.text }}</NuxtLink>
          <span v-else class="text-slate-500">{{ crumb.text }}</span>
        </span>
      </div>
    </div>
    
    <div class="flex items-center gap-6">
      <slot name="right"></slot>
    </div>
  </div>
</template>

<script setup>
import { useSidebar } from '@/composables/useSidebar'

const { toggleSidebar } = useSidebar()

defineProps({
  crumbs: {
    type: Array,
    default: () => []
  }
})
</script>
