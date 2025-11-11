import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["star", "input"]

  connect() {
    const ratingInput = this.inputTarget || this.element.querySelector('input[type="hidden"][name*="rating"]')
    if (ratingInput && ratingInput.value > 0) {
      this.setRating(parseInt(ratingInput.value))
    }
  }

  selectRating(event) {
    const rating = parseInt(event.currentTarget.dataset.ratingValue)
    const ratingInput = this.inputTarget || this.element.querySelector('input[type="hidden"][name*="rating"]')
    if (ratingInput) {
      ratingInput.value = rating
    }
    this.setRating(rating)
  }

  hoverRating(event) {
    const rating = parseInt(event.currentTarget.dataset.ratingValue)
    this.highlightStars(rating)
  }

  resetRating() {
    const ratingInput = this.inputTarget || this.element.querySelector('input[type="hidden"][name*="rating"]')
    const currentRating = ratingInput ? parseInt(ratingInput.value) : 0
    this.setRating(currentRating)
  }

  setRating(rating) {
    this.starTargets.forEach((star, index) => {
      if (index < rating) {
        star.classList.remove("text-gray-300")
        star.classList.add("text-yellow-400")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }

  highlightStars(rating) {
    this.starTargets.forEach((star, index) => {
      if (index < rating) {
        star.classList.remove("text-gray-300")
        star.classList.add("text-yellow-400")
      } else {
        star.classList.remove("text-yellow-400")
        star.classList.add("text-gray-300")
      }
    })
  }
}

