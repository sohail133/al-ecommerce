import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    this.selectTargets.forEach(select => {
      select.addEventListener("change", this.handleVariantChange.bind(this))
    })
  }

  async handleVariantChange(event) {
    const select = event.target
    const cartItemId = select.dataset.cartItemId
    const newVariantId = select.value
    const productId = select.dataset.productId

    try {
      const response = await fetch(`/cart/update_variant/${cartItemId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({
          variant_id: newVariantId
        })
      })

      if (response.ok) {
        const data = await response.json()
        if (data.success) {
          window.location.reload()
        } else {
          alert(data.error || "Failed to update variant")
        }
      } else {
        alert("Failed to update variant")
      }
    } catch (error) {
      console.error("Error updating variant:", error)
      alert("An error occurred while updating the variant")
    }
  }
}

