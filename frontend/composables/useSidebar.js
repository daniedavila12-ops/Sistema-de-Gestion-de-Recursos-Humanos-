import { useState } from '#app'

export const useSidebar = () => {
  const isMobileMenuOpen = useState('isMobileMenuOpen', () => false)
  const isSidebarCollapsed = useState('isSidebarCollapsed', () => false)
  
  const toggleMobileMenu = () => {
    isMobileMenuOpen.value = !isMobileMenuOpen.value
  }

  const toggleSidebar = () => {
    isSidebarCollapsed.value = !isSidebarCollapsed.value
  }
  
  return { isMobileMenuOpen, toggleMobileMenu, isSidebarCollapsed, toggleSidebar }
}
