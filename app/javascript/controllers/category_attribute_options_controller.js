import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["optionsSection", "optionsList", "optionTemplate", "inputType", "option"]

  connect() {
    this.toggleOptions()
  }

  toggleOptions() {
    if (!this.hasOptionsSectionTarget || !this.hasInputTypeTarget) return

    if (this.inputTypeTarget.value === "select") {
      this.optionsSectionTarget.classList.remove("hidden")
    } else {
      this.optionsSectionTarget.classList.add("hidden")
    }
  }

  addOption(event) {
    event.preventDefault()
    const html = this.optionTemplateTarget.innerHTML.replace(/NEW_OPTION/g, Date.now().toString())
    this.optionsListTarget.insertAdjacentHTML("beforeend", html)
  }
}
