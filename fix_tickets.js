const fs = require('fs');
let newFile = fs.readFileSync('frontend/pages/reportes/index.vue', 'utf8');

// 1. Get the Button HTML
const buttonHtml = `          <button @click="activeTab = 'tickets'" :class="['px-4 py-2.5 font-bold text-xs uppercase tracking-widest whitespace-nowrap rounded-xl transition-all duration-200 flex items-center gap-2', activeTab === 'tickets' ? 'bg-amber-600 text-white shadow-lg shadow-amber-600/20' : 'text-slate-500 hover:bg-amber-50 hover:text-amber-600']">
            🎫 Soporte & Tickets
            <span v-if="tickets.length" class="text-[9px] font-black px-1.5 py-0.5 rounded-full" :class="activeTab === 'tickets' ? 'bg-white/20 text-white' : 'bg-amber-100 text-amber-600'">{{ tickets.length }}</span>
          </button>`;

newFile = newFile.replace(/(<button @click="activeTab = 'reclutamiento'".*?<\/button>)/s, '$1\n' + buttonHtml);

// 2. Get the Tickets Section HTML
// We saved it properly in utf8 using Out-File -Encoding utf8 in powershell earlier.
const ticketsHtmlRaw = fs.readFileSync('tickets_tab.txt', 'utf8');
const ticketsHtml = ticketsHtmlRaw.split('\n').map(l => l.replace(/^\d+:\s>?\s?/, '')).join('\n').replace(/<!-- TAB: TICKETS -->.*?<\/div>\s*<!-- TAB: CONTROL DE TIEMPOS -->/s, match => match).replace('<!-- TAB: CONTROL DE TIEMPOS -->', '').trim();

newFile = newFile.replace(/<!-- TAB: CONTROL DE TIEMPOS -->/, ticketsHtml + '\n\n      <!-- TAB: CONTROL DE TIEMPOS -->');

// 3. Update Scripts (variables and functions)
const scriptsToInsert = `
// --- TICKETS REPORTE ---
const tickets = ref([])
const loadingTickets = ref(false)
const ticketsFiltroEstado = ref('todos')
const ticketsFiltroPrioridad = ref('todos')

const cargarTickets = async (isPolling = false) => {
  try {
    if (!isPolling) loadingTickets.value = true
    const res = await axios.get('http://localhost:3007/api/tickets/lista')
    tickets.value = res.data
  } catch (e) {
    console.error('Error cargando tickets:', e)
  } finally {
    loadingTickets.value = false
  }
}

const ticketsFiltrados = computed(() => {
  let list = tickets.value
  if (ticketsFiltroEstado.value !== 'todos') {
    if (ticketsFiltroEstado.value === 'pendientes_progreso') {
      list = list.filter(t => t.estado === 'Pendiente' || t.estado === 'En Progreso')
    } else if (ticketsFiltroEstado.value === 'resueltos_cerrados') {
      list = list.filter(t => t.estado === 'Resuelto' || t.estado === 'Cerrado')
    } else {
      list = list.filter(t => t.estado === ticketsFiltroEstado.value)
    }
  }
  if (ticketsFiltroPrioridad.value !== 'todos') {
    list = list.filter(t => t.prioridad === ticketsFiltroPrioridad.value)
  }
  if (searchQuery.value.trim() !== '') {
    const q = searchQuery.value.toLowerCase()
    list = list.filter(t => 
      (t.asunto && t.asunto.toLowerCase().includes(q)) || 
      (t.creadoPorNombre && t.creadoPorNombre.toLowerCase().includes(q)) ||
      (t.asignado_usuario_nombre && t.asignado_usuario_nombre.toLowerCase().includes(q)) ||
      (t.empleado_nombre && t.empleado_nombre.toLowerCase().includes(q))
    )
  }
  return list
})

const chartEstadoTicketsData = computed(() => {
  if (ticketsFiltrados.value.length === 0) return null;
  let pendiente = 0, progreso = 0, resuelto = 0, cerrado = 0;
  ticketsFiltrados.value.forEach(t => {
    if (t.estado === 'Pendiente') pendiente++;
    else if (t.estado === 'En Progreso') progreso++;
    else if (t.estado === 'Resuelto') resuelto++;
    else if (t.estado === 'Cerrado') cerrado++;
  });
  return {
    labels: ['Pendiente', 'En Progreso', 'Resuelto', 'Cerrado'],
    datasets: [{ backgroundColor: ['#fde047', '#3b82f6', '#10b981', '#64748b'], borderWidth: 0, data: [pendiente, progreso, resuelto, cerrado] }]
  }
})

const chartPrioridadTicketsData = computed(() => {
  if (ticketsFiltrados.value.length === 0) return null;
  let baja = 0, media = 0, alta = 0, urgente = 0;
  ticketsFiltrados.value.forEach(t => {
    if (t.prioridad === 'Baja') baja++;
    else if (t.prioridad === 'Media') media++;
    else if (t.prioridad === 'Alta') alta++;
    else if (t.prioridad === 'Urgente') urgente++;
  });
  return {
    labels: ['Baja', 'Media', 'Alta', 'Urgente'],
    datasets: [{ backgroundColor: ['#fde047', '#3b82f6', '#f97316', '#ef4444'], borderWidth: 0, data: [baja, media, alta, urgente] }]
  }
})

const tendenciaTickets = ref([])
const chartTendenciaTicketsData = computed(() => {
  if (tendenciaTickets.value.length === 0) return null;
  const labels = tendenciaTickets.value.map(row => {
    const d = new Date(row.fecha);
    return d.toLocaleDateString('es-HN', { day: '2-digit', month: 'short' });
  });
  const creados = tendenciaTickets.value.map(row => row.creados);
  const resueltos = tendenciaTickets.value.map(row => row.resueltos);
  return {
    labels: labels,
    datasets: [
      { label: 'Tickets Creados', borderColor: '#f59e0b', backgroundColor: '#f59e0b', data: creados, tension: 0.4, fill: false },
      { label: 'Tickets Resueltos', borderColor: '#10b981', backgroundColor: '#10b981', data: resueltos, tension: 0.4, fill: false }
    ]
  };
})

const cargarTendenciaTickets = async (isPolling = false) => {
  try {
    const res = await axios.get('http://localhost:3007/api/stats/tendencia-tickets')
    tendenciaTickets.value = res.data
  } catch (e) {
    console.error('Error cargando tendencia tickets:', e)
  }
}

const generarPDFTickets = async () => {
  if (ticketsFiltrados.value.length === 0) {
    Swal.fire('Aviso', 'No hay tickets para exportar con los filtros actuales.', 'warning');
    return;
  }
  try {
    const doc = new jsPDF();
    const pageHeight = doc.internal.pageSize.height;
    doc.setFontSize(16);
    doc.setTextColor(15, 23, 42);
    doc.setFont('helvetica', 'bold');
    doc.text('REPORTE DE SOPORTE Y TICKETS', 14, 20);
    doc.setFontSize(10);
    doc.setTextColor(100, 116, 139);
    doc.setFont('helvetica', 'normal');
    doc.text(\`Generado el: \${new Date().toLocaleString('es-HN')}\`, 14, 28);
    doc.text(\`Total de registros: \${ticketsFiltrados.value.length}\`, 14, 33);
    const imgLogo = new Image();
    imgLogo.crossOrigin = "Anonymous";
    imgLogo.src = 'http://localhost:3007/uploads/Logo/Logo.png';
    await new Promise((resolve) => { imgLogo.onload = resolve; imgLogo.onerror = resolve; });
    try { doc.addImage(imgLogo, 'PNG', 160, 10, 35, 15); } catch(e) {}
    
    let tableData = ticketsFiltrados.value.map(ticket => {
      let asignado = ticket.asignado_usuario_nombre || ticket.asignado_empleado_nombre || 'Sin asignar';
      let creador = ticket.creadoPorNombre || (ticket.empleado_nombre ? \`\${ticket.empleado_nombre} \${ticket.empleado_apellido || ''}\`.trim() : 'Desconocido');
      return [\`#\${ticket.id}\`, ticket.asunto || 'N/A', ticket.prioridad || 'N/A', ticket.estado || 'N/A', creador, asignado, ticket.respuestas_count ? \`\${ticket.respuestas_count}\` : '0', new Date(ticket.fecha_creacion).toLocaleDateString()];
    });

    autoTable(doc, {
      startY: 40,
      head: [['ID', 'Asunto', 'Prioridad', 'Estado', 'Creado Por', 'Asignado', 'Respuestas', 'Fecha']],
      body: tableData,
      theme: 'grid',
      headStyles: { fillColor: [37, 99, 235], textColor: [255, 255, 255], fontStyle: 'bold' },
      styles: { fontSize: 8, cellPadding: 3 },
      alternateRowStyles: { fillColor: [248, 250, 252] },
    });
    const totalPages = doc.internal.getNumberOfPages();
    for (let i = 1; i <= totalPages; i++) {
      doc.setPage(i);
      doc.setFontSize(8);
      doc.setTextColor(148, 163, 184);
      doc.text(\`Página \${i} de \${totalPages} - INNOVA RRHH\`, 196, pageHeight - 10, { align: 'right' });
    }
    doc.save('Reporte_Tickets.pdf');
  } catch (error) {
    console.error("Error al generar PDF de Tickets:", error);
    Swal.fire('Error', 'No se pudo generar el PDF', 'error');
  }
}
`;

if (!newFile.includes('const cargarTickets')) {
  newFile = newFile.replace(/(const cargarLegales = async \(isPolling = false\) => \{[\s\S]*?\n\})/, '$1\n' + scriptsToInsert);
}

// 4. Update the polling and loading calls
if (!newFile.includes('cargarTickets(false)')) {
  newFile = newFile.replace(/cargarLegales\(false\)/g, 'cargarLegales(false)\n  cargarTickets(false)\n  cargarTendenciaTickets(false)');
}
if (!newFile.includes('cargarTickets(true)')) {
  newFile = newFile.replace(/cargarLegales\(true\)/g, 'cargarLegales(true)\n    cargarTickets(true)\n    cargarTendenciaTickets(true)');
}

fs.writeFileSync('frontend/pages/reportes/index.vue', newFile, 'utf8');
console.log("DONE 2!");
