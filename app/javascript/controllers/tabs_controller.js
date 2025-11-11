import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.initializeTabs()
  }

  initializeTabs() {
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.active === "true"
      this.updateTabState(tab, isActive)
    })

    this.panelTargets.forEach(panel => {
      const tab = this.tabTargets.find(t => t.dataset.tab === panel.dataset.panel)
      const isActive = tab && tab.dataset.active === "true"
      
      if (isActive) {
        panel.classList.remove("hidden")
        panel.classList.add("block")
        panel.style.display = "block"
      } else {
        panel.classList.add("hidden")
        panel.classList.remove("block")
        panel.style.display = "none"
      }
    })
  }

  switchTab(event) {
    event.preventDefault()
    event.stopPropagation()
    const clickedTab = event.currentTarget
    const targetPanel = clickedTab.dataset.tab

    this.tabTargets.forEach(tab => {
      const isActive = tab === clickedTab
      tab.dataset.active = isActive ? "true" : "false"
      this.updateTabState(tab, isActive)
    })

    this.panelTargets.forEach(panel => {
      const panelName = panel.dataset.panel
      if (panelName === targetPanel) {
        panel.classList.remove("hidden")
        panel.classList.add("block")
        panel.style.display = "block"
      } else {
        panel.classList.add("hidden")
        panel.classList.remove("block")
        panel.style.display = "none"
      }
    })
  }

  updateTabState(tab, isActive) {
    if (isActive) {
      tab.classList.add("border-green-primary", "text-green-deep")
      tab.classList.remove("border-transparent", "text-green-muted", "hover:text-green-deep", "hover:border-green-light")
    } else {
      tab.classList.add("border-transparent", "text-green-muted", "hover:text-green-deep", "hover:border-green-light")
      tab.classList.remove("border-green-primary", "text-green-deep")
    }
  }
}

