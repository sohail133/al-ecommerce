import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.element.addEventListener("click", this.handleClick.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("click", this.handleClick.bind(this))
  }

  handleClick(event) {
    // Don't navigate if clicking on links, buttons, forms, or elements with data-action
    // Also ignore clicks inside dropdown menus
    if (!event.target.closest("a, button, [data-action], form, [data-controller='dropdown'], .dropdown-menu")) {
      window.location.href = this.urlValue
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}

