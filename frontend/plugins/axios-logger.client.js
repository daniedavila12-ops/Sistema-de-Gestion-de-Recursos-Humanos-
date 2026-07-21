import axios from 'axios'

export default defineNuxtPlugin((nuxtApp) => {
  axios.interceptors.response.use(
    (response) => {
      const method = response.config?.method?.toUpperCase()
      
      // Interceptar solo peticiones que modifiquen datos
      if (method && ['POST', 'PUT', 'DELETE'].includes(method) && !response.config.url.includes('/api/logs')) {
        
        let url = response.config.url
        let modulo = 'General'
        if (url.includes('/api/empleados')) modulo = 'Empleados'
        else if (url.includes('/api/usuarios')) modulo = 'Usuarios'
        else if (url.includes('/api/auth/login')) modulo = 'Autenticación'
        else if (url.includes('/api/auth')) modulo = 'Perfil'
        else if (url.includes('/api/tickets')) modulo = 'Tickets'
        else if (url.includes('/api/departamentos')) modulo = 'Departamentos'
        else if (url.includes('/api/roles')) modulo = 'Roles'
        else if (url.includes('/api/biblioteca')) modulo = 'Manuales'

        let accion = 'Modificación'
        if (method === 'POST') accion = url.includes('login') ? 'Login Exitoso' : 'Creación'
        if (method === 'PUT') accion = 'Actualización'
        if (method === 'DELETE') accion = 'Eliminación'

        let usuario_id = localStorage.getItem('usuarioID')
        
        // Si es login exitoso, el id viene en la respuesta
        if (url.includes('login') && response.data?.usuario?.id) {
            usuario_id = response.data.usuario.id
        }

        if (usuario_id) {
            // Generar log
            axios.post('/api/logs/registrar', {
                usuario_id: usuario_id,
                accion: accion,
                modulo: modulo,
                detalles: `Operación exitosa en ${url.split('/api')[1] || url}`,
                ip_address: '127.0.0.1' // Podría reemplazarse por lógica de IP real si es necesario
            }).catch(e => console.error('Error registrando log:', e))
        }
      }
      return response
    },
    (error) => {
      const method = error.config?.method?.toUpperCase()
      if (method && ['POST', 'PUT', 'DELETE'].includes(method) && !error.config.url.includes('/api/logs')) {
        let url = error.config.url
        let modulo = 'General'
        if (url.includes('/api/empleados')) modulo = 'Empleados'
        else if (url.includes('/api/usuarios')) modulo = 'Usuarios'
        else if (url.includes('/api/auth/login')) modulo = 'Autenticación'
        else if (url.includes('/api/auth')) modulo = 'Perfil'
        else if (url.includes('/api/tickets')) modulo = 'Tickets'
        else if (url.includes('/api/departamentos')) modulo = 'Departamentos'
        else if (url.includes('/api/roles')) modulo = 'Roles'
        else if (url.includes('/api/biblioteca')) modulo = 'Manuales'

        let accion = 'Error en Operación'
        if (url.includes('login')) accion = 'Intento de Login Fallido'

        let usuario_id = localStorage.getItem('usuarioID')
        // Si es login fallido, podríamos no tener id o intentar buscar el correo,
        // pero lo dejamos con el ID de la sesión actual o null

        if (usuario_id || url.includes('login')) {
            axios.post('/api/logs/registrar', {
                usuario_id: usuario_id || null,
                accion: accion,
                modulo: modulo,
                detalles: `Error en ${url.split('/api')[1] || url} - ${error.response?.data?.mensaje || error.message}`,
                ip_address: '127.0.0.1'
            }).catch(e => console.error('Error registrando log fallido:', e))
        }
      }
      return Promise.reject(error)
    }
  )
})
