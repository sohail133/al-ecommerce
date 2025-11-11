import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variant", "input"]

  connect() {
    // Select the first variant by default
    if (this.variantTargets.length > 0) {
      const firstVariant = this.variantTargets[0]
      this.selectVariant(firstVariant)
    }
  }

  select(event) {
    event.preventDefault()
    event.stopPropagation()
    const clickedVariant = event.currentTarget
    this.selectVariant(clickedVariant)
  }

  selectVariant(variantElement) {
    // Remove selected state from all variants
    this.variantTargets.forEach(variant => {
      variant.classList.remove("border-green-primary", "bg-green-light")
      variant.classList.add("border-pink-border", "bg-white")
    })

    // Add selected state to clicked variant
    variantElement.classList.remove("border-pink-border", "bg-white")
    variantElement.classList.add("border-green-primary", "bg-green-light")

    // Update hidden input with selected variant ID
    const variantId = variantElement.dataset.variantId
    if (this.hasInputTarget) {
      this.inputTarget.value = variantId
    }
  }
}

