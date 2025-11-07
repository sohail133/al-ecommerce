import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]
  static values = { interval: { type: Number, default: 5000 } }

  connect() {
    this.currentIndex = 0
    this.showSlide(this.currentIndex)
    this.startAutoplay()
  }

  disconnect() {
    this.stopAutoplay()
  }

  next() {
    this.stopAutoplay()
    this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length
    this.showSlide(this.currentIndex)
    this.startAutoplay()
  }

  previous() {
    this.stopAutoplay()
    this.currentIndex = (this.currentIndex - 1 + this.slideTargets.length) % this.slideTargets.length
    this.showSlide(this.currentIndex)
    this.startAutoplay()
  }

  goToSlide(event) {
    this.stopAutoplay()
    this.currentIndex = parseInt(event.currentTarget.dataset.index)
    this.showSlide(this.currentIndex)
    this.startAutoplay()
  }

  showSlide(index) {
    this.slideTargets.forEach((slide, i) => {
      if (i === index) {
        slide.classList.remove('hidden', 'opacity-0')
        slide.classList.add('opacity-100')
      } else {
        slide.classList.add('hidden', 'opacity-0')
        slide.classList.remove('opacity-100')
      }
    })
  }

  startAutoplay() {
    this.autoplayTimer = setInterval(() => {
      this.next()
    }, this.intervalValue)
  }

  stopAutoplay() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer)
    }
  }
}

