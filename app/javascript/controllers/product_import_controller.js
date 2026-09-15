import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "submit", "submitLabel"]

  open(event) {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    const firstInput = this.modalTarget.querySelector("input[type='url'], input[name*='source_url']")
    if (firstInput) firstInput.focus()
  }

  close(event) {
    if (event) event.preventDefault()
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
    if (this.hasFormTarget) this.formTarget.reset()
    this.resetSubmit()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close(event)
  }

  closeOnEscape(event) {
    if (event.key === "Escape" && !this.modalTarget.classList.contains("hidden")) {
      this.close(event)
    }
  }

  submitting() {
    if (!this.hasSubmitTarget) return
    this.submitTarget.disabled = true
    if (this.hasSubmitLabelTarget) {
      this.submitLabelTarget.textContent = "Importing..."
    }
  }

  resetSubmit() {
    if (!this.hasSubmitTarget) return
    this.submitTarget.disabled = false
    if (this.hasSubmitLabelTarget) {
      this.submitLabelTarget.textContent = "Import Product"
    }
  }
}
