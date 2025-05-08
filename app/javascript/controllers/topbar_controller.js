import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["bar"]
  
  connect() {
    this.lastScrollTop = 0
    this.threshold = 60
    window.addEventListener('scroll', this.handleScroll.bind(this))
  }
  
  disconnect() {
    window.removeEventListener('scroll', this.handleScroll.bind(this))
  }
  
  handleScroll() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop
    
    if (scrollTop > this.lastScrollTop && scrollTop > this.threshold) {
      // Scroll vers le bas
      this.element.classList.add('scroll-down')
      this.element.classList.remove('scroll-up')
    } else {
      // Scroll vers le haut ou en haut de page
      this.element.classList.remove('scroll-down')
      this.element.classList.add('scroll-up')
    }
    
    this.lastScrollTop = scrollTop <= 0 ? 0 : scrollTop
  }
}