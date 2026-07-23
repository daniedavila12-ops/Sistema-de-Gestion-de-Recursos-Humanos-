<template>
  <div class="flex flex-col items-center justify-center text-center max-w-md px-6 py-2 bg-slate-50/50 rounded-2xl border border-slate-100 shadow-inner">
    <p class="text-xs md:text-sm font-medium text-slate-600 italic leading-relaxed">
      "{{ verse.text }}"
    </p>
    <span class="text-[10px] font-black text-blue-500 uppercase tracking-widest mt-2">
      — {{ verse.reference }}
    </span>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const verses = [
  { text: 'Todo lo puedo en Cristo que me fortalece.', reference: 'Filipenses 4:13' },
  { text: 'Porque yo sé muy bien los planes que tengo para ustedes —afirma el Señor—, planes de bienestar y no de calamidad, a fin de darles un futuro y una esperanza.', reference: 'Jeremías 29:11' },
  { text: 'Confía en el Señor de todo corazón, y no en tu propia inteligencia. Reconócelo en todos tus caminos, y él allanará tus sendas.', reference: 'Proverbios 3:5-6' },
  { text: 'El Señor es mi pastor, nada me falta; en verdes pastos me hace descansar.', reference: 'Salmo 23:1-2' },
  { text: 'Mira que te mando que te esfuerces y seas valiente; no temas ni desmayes, porque Jehová tu Dios estará contigo en dondequiera que vayas.', reference: 'Josué 1:9' },
  { text: 'Mas los que esperan a Jehová tendrán nuevas fuerzas; levantarán alas como las águilas; correrán, y no se cansarán; caminarán, y no se fatigarán.', reference: 'Isaías 40:31' },
  { text: 'Encomienda a Jehová tus obras, Y tus pensamientos serán afirmados.', reference: 'Proverbios 16:3' },
  { text: 'Pero el amor del Señor es eterno y siempre está con los que le temen.', reference: 'Salmo 103:17' },
  { text: 'Echad toda vuestra ansiedad sobre él, porque él tiene cuidado de vosotros.', reference: '1 Pedro 5:7' },
  { text: 'Pues Dios no nos ha dado un espíritu de timidez, sino de poder, de amor y de dominio propio.', reference: '2 Timoteo 1:7' },
  { text: 'El que habita al abrigo del Altísimo Morará bajo la sombra del Omnipotente.', reference: 'Salmo 91:1' },
  { text: 'Y sabemos que a los que aman a Dios, todas las cosas les ayudan a bien.', reference: 'Romanos 8:28' },
  { text: 'Acerquémonos, pues, confiadamente al trono de la gracia, para alcanzar misericordia y hallar gracia para el oportuno socorro.', reference: 'Hebreos 4:16' },
  { text: 'Jehová es mi luz y mi salvación; ¿de quién temeré? Jehová es la fortaleza de mi vida; ¿de quién he de atemorizarme?', reference: 'Salmo 27:1' },
  { text: 'Por tanto, os digo que todo lo que pidiereis orando, creed que lo recibiréis, y os vendrá.', reference: 'Marcos 11:24' },
  { text: 'Instruye al niño en su camino, y aun cuando fuere viejo no se apartará de él.', reference: 'Proverbios 22:6' },
  { text: 'Fíate de Jehová de todo tu corazón, y no te apoyes en tu propia prudencia.', reference: 'Proverbios 3:5' },
  { text: 'Porque de tal manera amó Dios al mundo, que ha dado a su Hijo unigénito, para que todo aquel que en él cree, no se pierda, mas tenga vida eterna.', reference: 'Juan 3:16' },
  { text: 'No os conforméis a este siglo, sino transformaos por medio de la renovación de vuestro entendimiento...', reference: 'Romanos 12:2' },
  { text: 'El que sigue la justicia y la misericordia, hallará la vida, la justicia y la honra.', reference: 'Proverbios 21:21' }
]

const getDayOfYear = (date) => {
  const start = new Date(date.getFullYear(), 0, 0);
  const diff = date - start;
  const oneDay = 1000 * 60 * 60 * 24;
  return Math.floor(diff / oneDay);
}

const verse = computed(() => {
  const day = getDayOfYear(new Date())
  const index = day % verses.length
  return verses[index]
})
</script>
