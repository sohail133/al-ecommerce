import { Controller } from "@hotwired/stimulus"

// Live character counter for SEO title/description fields.
export default class extends Controller {
  static targets = ["input", "count"]
  static values = { max: Number }

  connect() {
    this.update()
  }

  update() {
    if (!this.hasInputTarget || !this.hasCountTarget) return

    const length = this.inputTarget.value.length
    const max = this.maxValue || 160
    this.countTarget.textContent = `${length}/${max}`
    this.countTarget.classList.toggle("text-red-500", length > max)
    this.countTarget.classList.toggle("text-green-muted", length <= max)
  }
}
