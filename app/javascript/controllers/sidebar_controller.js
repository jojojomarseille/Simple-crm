import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["arrow", "menuToggle", "sidebar"]

  connect() {
    console.log("Sidebar controller connected")
  }

  toggleSubmenu(event) {
    // Sélectionner le parent du parent (li > div.iocn-link > i.arrow)
    const arrowParent = event.currentTarget.parentElement.parentElement
    arrowParent.classList.toggle("showMenu")
  }

  toggleSidebar() {
    this.sidebarTarget.classList.toggle("close")
  }
}
