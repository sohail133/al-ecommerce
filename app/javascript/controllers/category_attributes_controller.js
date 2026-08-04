import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "attributeTemplate", "attribute"]

  addAttribute(event) {
    event.preventDefault()
    const html = this.attributeTemplateTarget.innerHTML.replace(/NEW_ATTRIBUTE/g, Date.now().toString())
    this.listTarget.insertAdjacentHTML("beforeend", html)
  }
}
