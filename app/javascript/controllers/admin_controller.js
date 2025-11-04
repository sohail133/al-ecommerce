import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "sidebarOverlay", "darkModeIcon", "lightModeIcon"]
  static values = { theme: String }

  connect() {
    this.initializeTheme()
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener('resize', this.handleResize)
  }

  disconnect() {
    window.removeEventListener('resize', this.handleResize)
  }

  openSidebar() {
    this.sidebarTarget.classList.remove('-translate-x-full')
    this.sidebarOverlayTarget.classList.remove('hidden')
    document.body.style.overflow = 'hidden'
  }

  closeSidebar() {
    this.sidebarTarget.classList.add('-translate-x-full')
    this.sidebarOverlayTarget.classList.add('hidden')
    document.body.style.overflow = ''
  }

  toggleDarkMode() {
    const isDark = document.documentElement.classList.contains('dark')
    this.setTheme(isDark ? 'light' : 'dark')
  }

  initializeTheme() {
    const savedTheme = localStorage.getItem('theme') || 'light'
    this.setTheme(savedTheme)
  }

  setTheme(theme) {
    if (theme === 'dark') {
      document.documentElement.classList.add('dark')
      this.darkModeIconTarget.classList.remove('hidden')
      this.lightModeIconTarget.classList.add('hidden')
    } else {
      document.documentElement.classList.remove('dark')
      this.darkModeIconTarget.classList.add('hidden')
      this.lightModeIconTarget.classList.remove('hidden')
    }
    localStorage.setItem('theme', theme)
  }

  handleResize() {
    if (window.innerWidth >= 1024) {
      this.closeSidebar()
    }
  }
}

