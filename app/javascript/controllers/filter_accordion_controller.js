import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  connect() {
    if (window.matchMedia("(min-width: 1024px)").matches) {
      this.show()
      return
    }

    if (this.hasFiltersInURL()) {
      this.show()
    }
  }

  toggle() {
    if (window.matchMedia("(min-width: 1024px)").matches) {
      return
    }

    if (this.contentTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.contentTarget.classList.remove("hidden")
    if (this.hasIconTarget) {
      this.iconTarget.classList.add("rotate-180")
    }
  }

  hide() {
    this.contentTarget.classList.add("hidden")
    if (this.hasIconTarget) {
      this.iconTarget.classList.remove("rotate-180")
    }
  }

  hasFiltersInURL() {
    const urlParams = new URLSearchParams(window.location.search)
    return urlParams.has("name") || urlParams.has("category_id") ||
           urlParams.has("subcategory_id") || urlParams.has("min_price") ||
           urlParams.has("max_price") || urlParams.has("sort")
  }
}
