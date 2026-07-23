<template>
  <div>
    <NuxtPage />
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';

const router = useRouter();
const route = useRoute();

let idleTimer = null;
const IDLE_TIMEOUT = 10 * 60 * 1000; // 10 minutos

const logoutUser = () => {
  const isPublicPage = route.path === '/login' || route.path.startsWith('/reclutamiento');
  if (!isPublicPage && localStorage.getItem('usuarioID')) {
    localStorage.clear();
    router.push('/login');
    alert('Tu sesión se ha cerrado por inactividad.');
  }
};

const resetTimer = () => {
  if (idleTimer) clearTimeout(idleTimer);
  
  const isPublicPage = route.path === '/login' || route.path.startsWith('/reclutamiento');
  if (!isPublicPage) {
    idleTimer = setTimeout(logoutUser, IDLE_TIMEOUT);
  }
};

onMounted(() => {
  const events = ['mousemove', 'mousedown', 'keydown', 'scroll', 'touchstart'];
  events.forEach(event => window.addEventListener(event, resetTimer));
  
  resetTimer();
});

onUnmounted(() => {
  const events = ['mousemove', 'mousedown', 'keydown', 'scroll', 'touchstart'];
  events.forEach(event => window.removeEventListener(event, resetTimer));
  
  if (idleTimer) clearTimeout(idleTimer);
});

watch(() => route.path, () => {
  resetTimer();
});
</script>

<style>
body {
  background-color: #0f172a;
}
</style>