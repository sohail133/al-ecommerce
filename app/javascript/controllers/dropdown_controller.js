import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.stopPropagation()
    
    const isCurrentlyHidden = this.menuTarget.classList.contains("hidden")
    
    this.closeAllDropdowns()
    
    if (isCurrentlyHidden) {
      this.menuTarget.classList.remove("hidden")
    }
  }

  closeAllDropdowns() {
    const allMenus = document.querySelectorAll('[data-dropdown-target="menu"]')
    allMenus.forEach(menu => {
      menu.classList.add("hidden")
    })
  }

  close(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  connect() {
    document.addEventListener("click", (event) => this.close(event))
  }

  disconnect() {
    document.removeEventListener("click", (event) => this.close(event))
  }
}

