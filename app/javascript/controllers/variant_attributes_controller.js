import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productSelect", "attributesContainer", "nameField"]
  static values = {
    urlTemplate: String,
    autoload: { type: Boolean, default: false },
    variantId: { type: Number, default: 0 }
  }

  connect() {
    // Only fetch fresh attribute fields for new variants.
    // On edit, keep the server-rendered values already in the form.
    if (this.autoloadValue) {
      this.loadAttributes()
    }
  }

  changeProduct() {
    this.loadAttributes()
  }

  async loadAttributes() {
    if (!this.hasProductSelectTarget || !this.hasAttributesContainerTarget) return

    const productId = this.productSelectTarget.value
    if (!productId) {
      this.attributesContainerTarget.innerHTML = `
        <p class="text-sm text-green-muted">Select a product to load category attributes.</p>
      `
      return
    }

    let url = this.urlTemplateValue.replace("PRODUCT_ID", productId)
    if (this.variantIdValue > 0) {
      url += `&variant_id=${this.variantIdValue}`
    }

    this.attributesContainerTarget.innerHTML = `<p class="text-sm text-green-muted">Loading attributes...</p>`

    try {
      const response = await fetch(url, {
        headers: { Accept: "text/html" }
      })

      if (!response.ok) throw new Error("Failed to load attributes")
      this.attributesContainerTarget.innerHTML = await response.text()
    } catch (error) {
      console.error(error)
      this.attributesContainerTarget.innerHTML = `
        <p class="text-sm text-red-600">Could not load category attributes.</p>
      `
    }
  }
}
