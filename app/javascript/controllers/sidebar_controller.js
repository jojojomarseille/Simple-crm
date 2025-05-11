import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["arrow", "menuToggle", "sidebar"]

  connect() {
    console.log("Sidebar controller connected");
    this.topbarLogo = document.getElementById('topbar-logo');
  }

  toggleSubmenu(event) {
    // Sélectionner le parent du parent (li > div.iocn-link > i.arrow)
    const arrowParent = event.currentTarget.parentElement.parentElement
    arrowParent.classList.toggle("showMenu")
  }

//   toggleSidebar() {
//     this.sidebarTarget.classList.toggle("close")
//   }

  toggleSidebar() {
    this.sidebarTarget.classList.toggle('close');
    
    // Si on ouvre le sidebar, on anime la disparition du logo
    if (!this.sidebarTarget.classList.contains('close')) {
      if (this.topbarLogo) {
        this.topbarLogo.classList.add('hide-logo');
      }
    } else {
      // Si on ferme le sidebar, on anime l'apparition du logo
      if (this.topbarLogo) {
        this.topbarLogo.classList.remove('hide-logo');
      }
    }
  }
  
  toggleSubmenu(event) {
    let arrowParent = event.currentTarget.parentElement.parentElement;
    arrowParent.classList.toggle("showMenu");
  }
}



