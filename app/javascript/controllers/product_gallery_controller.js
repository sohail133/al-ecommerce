import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["main", "thumb"]

  select(event) {
    event.preventDefault()
    const button = event.currentTarget
    const url = button.dataset.productGalleryUrlParam || button.dataset.url
    if (!url || !this.hasMainTarget) return

    this.mainTarget.src = url
    this.mainTarget.alt = button.dataset.alt || this.mainTarget.alt

    this.thumbTargets.forEach((thumb) => {
      thumb.classList.remove("ring-2", "ring-green-primary", "border-green-primary")
      thumb.classList.add("border-pink-border")
      thumb.setAttribute("aria-pressed", "false")
    })

    button.classList.add("ring-2", "ring-green-primary", "border-green-primary")
    button.classList.remove("border-pink-border")
    button.setAttribute("aria-pressed", "true")
  }
}
