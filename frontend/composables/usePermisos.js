import { ref } from 'vue';
import axios from 'axios';

// Global cache for permissions to avoid redundant network calls
const permisosCache = ref(null);
const loadingPermisos = ref(false);

export const usePermisos = () => {
  const getPermisos = async (rolId, usuarioId) => {
    if (permisosCache.value) return permisosCache.value;
    if (loadingPermisos.value) {
        // Wait until it finishes (simplified spinlock)
        await new Promise(resolve => setTimeout(resolve, 50));
        if (permisosCache.value) return permisosCache.value;
    }
    
    loadingPermisos.value = true;
    try {
      const url = usuarioId 
        ? `http://localhost:3007/api/permisos-granulares/${rolId}?usuario_id=${usuarioId}`
        : `http://localhost:3007/api/permisos-granulares/${rolId}`;
      const { data } = await axios.get(url);
      permisosCache.value = data;
      return data;
    } catch (error) {
      console.error('Error fetching permissions:', error);
      return {};
    } finally {
      loadingPermisos.value = false;
    }
  };

  const hasPermission = (modulo, accion) => {
    if (!permisosCache.value) return false; // Default safe false if not loaded
    // Admin override
    const rolID = localStorage.getItem('usuarioRol') || 2;
    if (rolID == 1) return true;

    const modPermisos = permisosCache.value[modulo];
    if (!modPermisos) return false;
    
    return modPermisos[accion] === 1;
  };

  const clearPermisos = () => {
    permisosCache.value = null;
  };

  return {
    getPermisos,
    hasPermission,
    clearPermisos
  };
};
