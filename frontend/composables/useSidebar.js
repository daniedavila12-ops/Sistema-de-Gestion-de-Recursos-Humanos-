import { useState } from '#app'

export const useSidebar = () => {
  const isMobileMenuOpen = useState('isMobileMenuOpen', () => false)
  
  const toggleMobileMenu = () => {
    isMobileMenuOpen.value = !isMobileMenuOpen.value
  }
  
  return { isMobileMenuOpen, toggleMobileMenu }
}
