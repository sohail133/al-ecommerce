import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Favorite controller connected to:", this.element.id)
  }

  submit(event) {
    event.preventDefault()
    event.stopPropagation()
    
    console.log("Favorite submit clicked")
    
    // The form is this.element since the controller is on the form
    const form = this.element
    if (!form) {
      console.error("No form found")
      return
    }
    
    console.log("Submitting form:", form.action)
    
    // Submit form via Turbo
    form.requestSubmit()
  }
}

