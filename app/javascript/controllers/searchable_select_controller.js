import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "trigger", "label", "menu", "query", "option"]
  static values = {
    placeholder: { type: String, default: "Select..." }
  }

  connect() {
    this.boundClose = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this.boundClose)
    this.setupDependency()
    this.syncLabel()
  }

  disconnect() {
    document.removeEventListener("click", this.boundClose)
    if (this.dependencySelect && this.boundDependencyChange) {
      this.dependencySelect.removeEventListener("change", this.boundDependencyChange)
    }
  }

  setupDependency() {
    const dependsOn = this.element.dataset.searchableSelectDependsOn
    if (!dependsOn) return

    this.dependencySelect = document.querySelector(dependsOn)
    if (!this.dependencySelect) return

    this.boundDependencyChange = () => this.applyDependencyFilter()
    this.dependencySelect.addEventListener("change", this.boundDependencyChange)
    this.applyDependencyFilter()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.closeOtherMenus()
    this.menuTarget.classList.remove("hidden")
    this.queryTarget.value = ""
    this.filterOptions()
    requestAnimationFrame(() => this.queryTarget.focus())
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }

  closeOtherMenus() {
    document.querySelectorAll("[data-searchable-select-target='menu']").forEach((menu) => {
      if (menu !== this.menuTarget) menu.classList.add("hidden")
    })
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  filter() {
    this.filterOptions()
  }

  filterOptions() {
    const query = this.queryTarget.value.trim().toLowerCase()

    this.optionTargets.forEach((option) => {
      const text = option.textContent.trim().toLowerCase()
      const matchesQuery = !query || text.includes(query)
      const matchesDependency = !option.dataset.dependencyHidden
      option.classList.toggle("hidden", !(matchesQuery && matchesDependency))
    })
  }

  applyDependencyFilter() {
    const parentValue = this.dependencySelect?.value || ""

    this.optionTargets.forEach((option) => {
      const isAllOption = option.dataset.value === ""
      const categoryId = option.dataset.categoryId || ""
      const visible = isAllOption || !parentValue || categoryId === String(parentValue)

      if (visible) {
        delete option.dataset.dependencyHidden
      } else {
        option.dataset.dependencyHidden = "true"
      }
    })

    const currentValue = this.selectTarget.value
    if (currentValue) {
      const currentOption = this.optionTargets.find((option) => option.dataset.value === currentValue)
      if (currentOption?.dataset.dependencyHidden) {
        this.setValue("")
      }
    }

    this.filterOptions()
    this.syncLabel()
  }

  choose(event) {
    event.preventDefault()
    event.stopPropagation()
    this.setValue(event.currentTarget.dataset.value)
    this.close()
  }

  setValue(value) {
    this.selectTarget.value = value
    this.selectTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.syncLabel()
  }

  syncLabel() {
    const selectedOption = Array.from(this.selectTarget.options).find(
      (option) => option.value === this.selectTarget.value
    )
    this.labelTarget.textContent = selectedOption?.text || this.placeholderValue
  }
}
