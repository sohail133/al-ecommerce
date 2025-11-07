import "@hotwired/turbo-rails"
import "./controllers"

document.addEventListener('turbo:load', () => {
  if (typeof AOS !== 'undefined') {
    AOS.init({
      duration: 800,
      once: true,
      offset: 100,
      easing: 'ease-in-out'
    })
  }
})

document.addEventListener('DOMContentLoaded', () => {
  if (typeof AOS !== 'undefined') {
    AOS.init({
      duration: 800,
      once: true,
      offset: 100,
      easing: 'ease-in-out'
    })
  }
})
