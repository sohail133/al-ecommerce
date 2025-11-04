import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    setTimeout(() => {
      this.close()
    }, 5000)
  }

  close() {
    this.element.classList.add("hidden")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}

