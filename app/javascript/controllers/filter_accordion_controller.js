import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  connect() {
    const hasActiveFilters = this.element.querySelector('[data-filter-accordion-target="content"]')
      .querySelector('form').action.includes('?')
    
    if (hasActiveFilters || this.hasFiltersInURL()) {
      this.show()
    }
  }

  toggle() {
    if (this.contentTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.contentTarget.classList.remove("hidden")
    this.iconTarget.classList.add("rotate-180")
  }

  hide() {
    this.contentTarget.classList.add("hidden")
    this.iconTarget.classList.remove("rotate-180")
  }

  hasFiltersInURL() {
    const urlParams = new URLSearchParams(window.location.search)
    return urlParams.has('name') || urlParams.has('email') || 
           urlParams.has('role') || urlParams.has('status')
  }
}

