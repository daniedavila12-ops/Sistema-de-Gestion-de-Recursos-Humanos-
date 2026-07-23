<template>
  <div class="bg-[#1a365d] text-white rounded-2xl p-4 flex items-center justify-between shadow-sm border border-slate-700/50 min-w-[240px] shrink-0 hover:shadow-md transition-shadow">
    <div class="flex flex-col items-center">
      <span class="text-xs font-mono font-bold tracking-widest opacity-80 mb-1">{{ currentTime }}</span>
      <span class="text-4xl font-black tracking-tighter drop-shadow-sm">{{ temperature }}°C</span>
      <span class="text-[11px] font-bold mt-1 tracking-wide">{{ conditionText }}</span>
      <span class="text-[10px] opacity-60">La Ceiba</span>
    </div>
    <div class="text-5xl ml-4 drop-shadow-xl" style="filter: drop-shadow(0 4px 6px rgba(0,0,0,0.3));">
      {{ weatherEmoji }}
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const currentTime = ref('00:00:00')
const temperature = ref('--')
const conditionText = ref('Cargando...')
const weatherEmoji = ref('🌤️')

let timer
let weatherTimer

const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleTimeString('es-HN', { hour12: false })
}

const fetchWeather = async () => {
  try {
    // La Ceiba, Honduras coordinates: Lat 15.7597, Lon -86.7822
    const res = await fetch('https://api.open-meteo.com/v1/forecast?latitude=15.7597&longitude=-86.7822&current_weather=true')
    const data = await res.json()
    if (data && data.current_weather) {
      temperature.value = Math.round(data.current_weather.temperature)
      const code = data.current_weather.weathercode
      
      // WMO Weather interpretation codes (0-99)
      const wmoCodes = {
        0: { text: 'Despejado', emoji: '☀️' },
        1: { text: 'Mayormente despejado', emoji: '🌤️' },
        2: { text: 'Parcialmente nublado', emoji: '⛅' },
        3: { text: 'Nublado', emoji: '☁️' },
        45: { text: 'Niebla', emoji: '🌫️' },
        48: { text: 'Niebla con escarcha', emoji: '🌫️' },
        51: { text: 'Llovizna ligera', emoji: '🌧️' },
        53: { text: 'Llovizna moderada', emoji: '🌧️' },
        55: { text: 'Llovizna densa', emoji: '🌧️' },
        56: { text: 'Llovizna helada ligera', emoji: '🌧️' },
        57: { text: 'Llovizna helada densa', emoji: '🌧️' },
        61: { text: 'Lluvia leve', emoji: '🌧️' },
        63: { text: 'Lluvia moderada', emoji: '🌧️' },
        65: { text: 'Lluvia fuerte', emoji: '🌧️' },
        66: { text: 'Lluvia helada leve', emoji: '🌧️' },
        67: { text: 'Lluvia helada fuerte', emoji: '🌧️' },
        71: { text: 'Nieve leve', emoji: '🌨️' },
        73: { text: 'Nieve moderada', emoji: '🌨️' },
        75: { text: 'Nieve fuerte', emoji: '🌨️' },
        77: { text: 'Granos de nieve', emoji: '🌨️' },
        80: { text: 'Chubascos leves', emoji: '🌦️' },
        81: { text: 'Chubascos moderados', emoji: '🌦️' },
        82: { text: 'Chubascos violentos', emoji: '⛈️' },
        85: { text: 'Chubascos de nieve leves', emoji: '🌨️' },
        86: { text: 'Chubascos de nieve fuertes', emoji: '🌨️' },
        95: { text: 'Tormenta eléctrica', emoji: '⛈️' },
        96: { text: 'Tormenta con granizo', emoji: '⛈️' },
        99: { text: 'Tormenta fuerte', emoji: '⛈️' },
      }
      const condition = wmoCodes[code] || { text: 'Desconocido', emoji: '❓' }
      conditionText.value = condition.text
      weatherEmoji.value = condition.emoji
    }
  } catch (err) {
    console.error("Error al obtener el clima:", err)
    conditionText.value = "Sin conexión"
  }
}

onMounted(() => {
  updateTime()
  timer = setInterval(updateTime, 1000)
  
  fetchWeather()
  // Refresh weather every 15 minutes
  weatherTimer = setInterval(fetchWeather, 15 * 60 * 1000)
})

onUnmounted(() => {
  clearInterval(timer)
  clearInterval(weatherTimer)
})
</script>
