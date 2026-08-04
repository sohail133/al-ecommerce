import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "price",
    "stock",
    "option",
    "group",
    "groupHint",
    "availability",
    "submit",
    "submitLabel"
  ]

  static values = {
    variants: Array,
    productId: Number
  }

  connect() {
    this.selected = {}
    if (this.groupTargets.length === 0) return

    const restored = this.restoreSelection()
    if (!restored) this.initializeDefaults()
    this.refresh({ softMissing: !restored })
  }

  storageKey() {
    return `variant-selection-${this.productIdValue || "unknown"}`
  }

  persistSelection() {
    try {
      sessionStorage.setItem(this.storageKey(), JSON.stringify(this.selected))
    } catch (_error) {
      // Ignore storage failures (private browsing, etc.)
    }
  }

  restoreSelection() {
    try {
      const raw = sessionStorage.getItem(this.storageKey())
      if (!raw) return false

      const saved = JSON.parse(raw)
      if (!saved || typeof saved !== "object") return false

      let restoredAny = false
      this.groupTargets.forEach((group) => {
        const attribute = group.dataset.attributeName
        const value = saved[attribute]
        if (!value) return

        const option = this.optionsFor(attribute).find((item) => item.dataset.optionValue === value)
        if (!option || option.disabled) return

        this.selected[attribute] = value
        this.highlightGroup(attribute, value)
        restoredAny = true
      })

      return restoredAny
    } catch (_error) {
      return false
    }
  }

  // Optional attributes get a default. Required size starts empty until chosen/restored.
  initializeDefaults() {
    this.groupTargets.forEach((group) => {
      if (this.isMandatory(group)) return

      const attribute = group.dataset.attributeName
      const first = this.optionsFor(attribute)[0]
      if (!first) return

      this.selected[attribute] = first.dataset.optionValue
      this.highlightGroup(attribute, first.dataset.optionValue)
    })
  }

  isMandatory(group) {
    return group.dataset.mandatory === "true"
  }

  optionsFor(attribute) {
    return this.optionTargets.filter((option) => option.dataset.attributeName === attribute)
  }

  select(event) {
    event.preventDefault()
    const button = event.currentTarget

    this.element.querySelectorAll("[data-variant-id]").forEach((el) => {
      el.classList.remove("border-green-primary", "bg-green-light", "text-green-primary")
      el.classList.add("border-pink-border", "bg-white", "text-green-deep")
    })

    button.classList.remove("border-pink-border", "bg-white", "text-green-deep")
    button.classList.add("border-green-primary", "bg-green-light", "text-green-primary")

    if (this.hasInputTarget) this.inputTarget.value = button.dataset.variantId
    if (this.hasPriceTarget && button.dataset.variantPriceFormatted) {
      this.priceTarget.textContent = button.dataset.variantPriceFormatted
    }
  }

  selectOption(event) {
    event.preventDefault()
    const button = event.currentTarget
    if (button.disabled) return

    const attribute = button.dataset.attributeName
    this.selected[attribute] = button.dataset.optionValue
    this.highlightGroup(attribute, button.dataset.optionValue)
    this.persistSelection()
    this.refresh({ softMissing: false })
  }

  highlightGroup(attribute, value) {
    this.optionsFor(attribute).forEach((option) => {
      const selected = option.dataset.optionValue === value
      option.classList.toggle("border-green-primary", selected)
      option.classList.toggle("bg-green-light", selected)
      option.classList.toggle("text-green-primary", selected)
      option.classList.toggle("border-pink-border", !selected)
      option.classList.toggle("bg-white", !selected)
    })
  }

  missingGroups() {
    return this.groupTargets.filter((group) => {
      return this.isMandatory(group) && !this.selected[group.dataset.attributeName]
    })
  }

  refresh({ softMissing = false } = {}) {
    this.updateDisabledOptions()

    const missing = this.missingGroups()
    if (missing.length > 0) {
      this.blockCheckout(missing, { soft: softMissing })
      return
    }

    this.groupHintTargets.forEach((hint) => hint.classList.add("hidden"))

    const match = this.variantsValue.find((variant) => {
      return Object.entries(this.selected).every(([attribute, value]) => variant.attrs[attribute] === value)
    })

    if (!match) {
      this.setAvailability("This combination is unavailable", true)
      this.setSubmit(false, "Unavailable")
      return
    }

    if (this.hasInputTarget) this.inputTarget.value = match.id
    if (this.hasPriceTarget) this.priceTarget.textContent = match.price_formatted
    if (this.hasStockTarget) {
      this.stockTarget.textContent = match.stock > 0 ? `${match.stock} in stock` : "Out of stock"
    }

    if (match.stock > 0) {
      this.setAvailability("Ready to ship", false)
      this.setSubmit(true, "Add to Cart")
    } else {
      this.setAvailability("Currently out of stock", true)
      this.setSubmit(false, "Out of stock")
    }
  }

  blockCheckout(missing, { soft = false } = {}) {
    const names = missing.map((group) => group.dataset.attributeName.toLowerCase())

    this.groupHintTargets.forEach((hint) => {
      hint.classList.toggle("hidden", soft)
    })

    if (soft) {
      this.setAvailability("Choose a size to add this item", false)
    } else {
      this.setAvailability(`Please select a ${names.join(" and ")} to continue`, true)
    }

    this.setSubmit(false, `Select ${names[0]}`)
    if (this.hasInputTarget) this.inputTarget.value = ""
  }

  setAvailability(message, warning) {
    if (!this.hasAvailabilityTarget) return

    this.availabilityTarget.textContent = message
    this.availabilityTarget.classList.toggle("text-red-600", warning)
    this.availabilityTarget.classList.toggle("text-green-muted", !warning)
  }

  setSubmit(enabled, label) {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !enabled
      this.submitTarget.classList.toggle("opacity-50", !enabled)
      this.submitTarget.classList.toggle("cursor-not-allowed", !enabled)
    }

    if (this.hasSubmitLabelTarget) this.submitLabelTarget.textContent = label
  }

  updateDisabledOptions() {
    this.groupTargets.forEach((group) => {
      const attribute = group.dataset.attributeName

      this.optionsFor(attribute).forEach((option) => {
        const candidate = { ...this.selected, [attribute]: option.dataset.optionValue }
        const exists = this.variantsValue.some((variant) => {
          return Object.entries(candidate).every(([key, value]) => variant.attrs[key] === value)
        })

        option.disabled = !exists
        option.classList.toggle("opacity-40", !exists)
        option.classList.toggle("cursor-not-allowed", !exists)
      })
    })
  }
}
