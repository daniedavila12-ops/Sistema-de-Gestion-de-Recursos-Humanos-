export default defineNuxtRouteMiddleware(async (to, from) => {
  // Only run on client-side to access localStorage
  if (process.client) {
    const publicRoutes = ['/login', '/biblioteca', '/reporte-sms', '/reclutamiento', '/tickets-soporte', '/crear-reporte-incidencia'];
    const isPublic = publicRoutes.some(route => to.path === route || to.path.startsWith(route + '/'));
    
    const usuarioID = localStorage.getItem('usuarioID');
    const rolID = localStorage.getItem('usuarioRol');

    if (!usuarioID && !isPublic) {
      return navigateTo('/login');
    }

    if (usuarioID && to.path === '/login') {
      return navigateTo('/');
    }
    
    // Si está autenticado y va a una ruta privada, verificamos permisos
    if (usuarioID && !isPublic && to.path !== '/') {
        try {
            // Obtenemos los módulos permitidos para este usuario
            const apiBase = 'http://localhost:3007';
            const menu = await $fetch(`${apiBase}/api/menu/${rolID}?usuario_id=${usuarioID}`);
            
            // Extraer las rutas permitidas del menú
            let allowedPaths = ['/'];
            menu.forEach(item => {
                if (item.ruta) allowedPaths.push(item.ruta);
            });
            
            // Algunas rutas tienen subrutas (ej: /admin/candidatos, /empleados/nuevo)
            // Permitimos acceso si la ruta solicitada empieza con alguna de las permitidas
            const canAccess = allowedPaths.some(p => to.path === p || (p !== '/' && to.path.startsWith(p)));
            
            if (!canAccess) {
                console.warn('Acceso denegado a la ruta:', to.path);
                return navigateTo('/');
            }
        } catch (err) {
            console.error('Error verificando permisos en middleware', err);
            return navigateTo('/');
        }
    }
  }
});
