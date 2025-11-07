import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["review", "container"]
  static values = { interval: { type: Number, default: 3000 } }

  connect() {
    this.currentIndex = 0
    this.updateSlider()
    this.startAutoplay()
  }

  disconnect() {
    this.stopAutoplay()
  }

  next() {
    this.stopAutoplay()
    const maxIndex = this.reviewTargets.length - this.visibleCards()
    if (this.currentIndex < maxIndex) {
      this.currentIndex++
    } else {
      this.currentIndex = 0
    }
    this.updateSlider()
    this.startAutoplay()
  }

  previous() {
    this.stopAutoplay()
    if (this.currentIndex > 0) {
      this.currentIndex--
    } else {
      this.currentIndex = this.reviewTargets.length - this.visibleCards()
    }
    this.updateSlider()
    this.startAutoplay()
  }

  updateSlider() {
    const cardWidth = this.reviewTargets[0].offsetWidth
    const gap = 24
    const offset = -(this.currentIndex * (cardWidth + gap))
    this.containerTarget.style.transform = `translateX(${offset}px)`
    this.containerTarget.style.transition = 'transform 0.5s ease-in-out'
  }

  visibleCards() {
    const width = window.innerWidth
    if (width >= 1024) return 3
    if (width >= 768) return 2
    return 1
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

