import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "hidden"]
  
  connect() {
    if (this.element.dataset.initialized === "true") return
    
    // Vérifier que intlTelInput est disponible
    if (typeof window.intlTelInput === 'undefined') {
      console.error("intlTelInput n'est pas chargé. Assurez-vous d'avoir inclus le script dans votre layout.")
      return
    }
    
    this.initializePhoneInput()
    this.element.dataset.initialized = "true"
  }
  
  disconnect() {
    if (this.iti) {
      this.iti.destroy()
    }
  }
  
  initializePhoneInput() {
    // Initialisation du widget téléphone
    this.iti = window.intlTelInput(this.inputTarget, {
      utilsScript: "https://cdn.jsdelivr.net/npm/intl-tel-input@18.2.1/build/js/utils.js",
      preferredCountries: ["fr", "pt", "br"],
      separateDialCode: true,
      autoPlaceholder: "aggressive"
    })
    
    // Écouter les changements
    this.inputTarget.addEventListener("input", this.updateHiddenField.bind(this))
    this.inputTarget.addEventListener("countrychange", this.updateHiddenField.bind(this))
    
    // Initialiser la valeur
    this.updateHiddenField()
  }
  
  updateHiddenField() {
    // Reste du code inchangé...
    const isValid = this.iti.isValidNumber()
    const value = isValid ? this.iti.getNumber() : ''
    
    this.hiddenTarget.value = value
    
    if (this.inputTarget.value) {
      if (isValid) {
        this.inputTarget.classList.add("is-valid")
        this.inputTarget.classList.remove("is-invalid")
      } else {
        this.inputTarget.classList.add("is-invalid")
        this.inputTarget.classList.remove("is-valid")
      }
    } else {
      this.inputTarget.classList.remove("is-valid", "is-invalid")
    }
  }
}

