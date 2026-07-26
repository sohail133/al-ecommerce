import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["variant", "input", "price"]

  connect() {
    if (this.variantTargets.length > 0) {
      this.selectVariant(this.variantTargets[0])
    }
  }

  select(event) {
    event.preventDefault()
    event.stopPropagation()
    this.selectVariant(event.currentTarget)
  }

  selectVariant(variantElement) {
    this.variantTargets.forEach((variant) => {
      variant.classList.remove("border-green-primary", "bg-green-light", "text-green-primary")
      variant.classList.add("border-pink-border", "bg-white")
    })

    variantElement.classList.remove("border-pink-border", "bg-white")
    variantElement.classList.add("border-green-primary", "bg-green-light", "text-green-primary")

    const variantId = variantElement.dataset.variantId
    if (this.hasInputTarget && variantId) {
      this.inputTarget.value = variantId
    }

    if (this.hasPriceTarget && variantElement.dataset.variantPriceFormatted) {
      this.priceTarget.textContent = variantElement.dataset.variantPriceFormatted
    }
  }
}
