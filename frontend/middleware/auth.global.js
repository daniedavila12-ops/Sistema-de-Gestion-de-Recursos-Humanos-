export default defineNuxtRouteMiddleware(async (to, from) => {
  // Only run on client-side to access localStorage
  if (process.client) {
    const publicRoutes = ['/', '/biblioteca', '/reporte-sms', '/reclutamiento', '/tickets-soporte', '/crear-reporte-incidencia'];
    const isPublic = publicRoutes.some(route => to.path === route || to.path.startsWith(route + '/'));
    
    const usuarioID = localStorage.getItem('usuarioID');
    const rolID = localStorage.getItem('usuarioRol');

    if (!usuarioID && !isPublic) {
      return navigateTo('/');
    }

    if (usuarioID && to.path === '/') {
      return navigateTo('/dashboard');
    }
    
    // Si está autenticado y va a una ruta privada, verificamos permisos
    if (usuarioID && !isPublic && to.path !== '/dashboard') {
        try {
            // Obtenemos los módulos permitidos para este usuario
            const apiBase = useRuntimeConfig().public.apiBase;
            const menu = await $fetch(`${apiBase}/api/menu/${rolID}?usuario_id=${usuarioID}`);
            
            // Extraer las rutas permitidas del menú
            let allowedPaths = ['/dashboard'];
            menu.forEach(item => {
                if (item.ruta) allowedPaths.push(item.ruta);
            });
            
            // Algunas rutas tienen subrutas (ej: /admin/candidatos, /empleados/nuevo)
            // Permitimos acceso si la ruta solicitada empieza con alguna de las permitidas
            const canAccess = allowedPaths.some(p => to.path === p || (p !== '/dashboard' && to.path.startsWith(p)));
            
            if (!canAccess) {
                console.warn('Acceso denegado a la ruta:', to.path);
                return navigateTo('/dashboard');
            }
        } catch (err) {
            console.error('Error verificando permisos en middleware', err);
            return navigateTo('/dashboard');
        }
    }
  }
});
