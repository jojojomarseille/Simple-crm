// app/javascript/controllers/organisation_form_controller.js
// app/javascript/controllers/organisation_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "countrySelect", 
    "statusField", 
    "statusSelect", 
    "searchField", 
    "searchFieldInput",
    "searchResults",
    "baseCompanyId" // Champ caché pour stocker l'ID
  ]

  connect() {
    console.log("Organisation form controller connected")

    const step = this.element.dataset.step
    if (step === "3") {
      // Logique pour l'étape 3 - Recherche d'entreprise
      this.initStep3()
    } else if (step === "4") {
      // Logique pour l'étape 4 - Pré-remplissage des champs
      this.initStep4()
    }
  }

  initStep3() {
    // Initialiser l'étape 3
    this.statusFieldTarget.style.display = 'none'
    if (this.hasSearchFieldTarget) {
      this.searchFieldTarget.style.display = 'none'
    }
    if (this.hasSearchResultsTarget) {
      this.searchResultsTarget.style.display = 'none'
    }
  }

  initStep4() {
    // Vérifier si on a un ID d'entreprise en paramètre
    const urlParams = new URLSearchParams(window.location.search)
    const companyId = urlParams.get('base_company_id')
    
    if (companyId) {
      console.log("Pré-remplissage avec l'entreprise ID:", companyId)
      this.prefillFormWithCompanyData(companyId)
    }
  }

  countryChanged() {
    const selectedCountry = this.countrySelectTarget.value
    
    if (selectedCountry === 'France') {
      this.statusFieldTarget.style.display = 'block'
      this.resetSearchAndResults()
    } else {
      this.statusFieldTarget.style.display = 'none'
      if (this.hasSearchFieldTarget) {
        this.searchFieldTarget.style.display = 'none'
      }
      
      // Afficher un message pour les autres pays
      alert("Nous sommes désolés, mais Simple CRM n'est pas encore disponible pour ce pays.")
    }
  }
  
  statusChanged() {
    const selectedStatus = this.statusSelectTarget.value
    
    if (selectedStatus !== 'ASSO-WITHOUT-SIRET' && selectedStatus !== '') {
      if (this.hasSearchFieldTarget) {
        this.searchFieldTarget.style.display = 'block'
      }
    } else {
      this.resetSearchAndResults()
    }
  }
  
  resetSearchAndResults() {
    if (this.hasSearchFieldTarget) {
      this.searchFieldTarget.style.display = 'none'
      if (this.hasSearchFieldInputTarget) {
        this.searchFieldInputTarget.value = ''
      }
    }
    if (this.hasSearchResultsTarget) {
      this.searchResultsTarget.style.display = 'none'
      this.searchResultsTarget.innerHTML = ''
    }
  }

  search() {
    if (!this.hasSearchFieldInputTarget) return
    
    const query = this.searchFieldInputTarget.value.trim()
    
    if (query.length < 2) {
      if (this.hasSearchResultsTarget) {
        this.searchResultsTarget.style.display = 'none'
      }
      return
    }
    
    fetch(`/api/base_companies/search?query=${encodeURIComponent(query)}`)
      .then(response => {
        if (!response.ok) throw new Error(`HTTP error: ${response.status}`)
        return response.json()
      })
      .then(data => {
        this.displaySearchResults(data)
      })
      .catch(error => {
        console.error("Erreur lors de la recherche:", error)
        if (this.hasSearchResultsTarget) {
          this.searchResultsTarget.innerHTML = '<div>Une erreur est survenue. Veuillez réessayer ou saisir les données manuellement.</div>'
          this.searchResultsTarget.style.display = 'block'
        }
      })
  }
  
  displaySearchResults(companies) {
    if (!this.hasSearchResultsTarget) return
    
    if (companies.length === 0) {
      this.searchResultsTarget.innerHTML = '<div>Aucune entreprise trouvée. Veuillez affiner votre recherche ou saisir les données manuellement.</div>'
    } else {
      const resultsList = companies.map(company => {
        return `<div class="search-result-item" data-action="click->organisation-form#selectCompany" data-company-id="${company.id}">
          <strong>${company.denomination_sociale || 'N/A'}</strong><br>
          SIRET: ${company.siret || 'N/A'} - ${company.adresse || ''} ${company.code_postal || ''}
        </div>`
      }).join('')
      
      this.searchResultsTarget.innerHTML = resultsList
    }
    
    this.searchResultsTarget.style.display = 'block'
  }
  
  selectCompany(event) {
    const companyId = event.currentTarget.dataset.companyId
    
    if (this.hasBaseCompanyIdTarget) {
      this.baseCompanyIdTarget.value = companyId
    } else {
      // Si le target n'existe pas, créer un champ caché
      const hiddenField = document.createElement('input')
      hiddenField.type = 'hidden'
      hiddenField.name = 'user[organisation_attributes][base_company_id]'
      hiddenField.value = companyId
      hiddenField.dataset.organisationFormTarget = "baseCompanyId"
      this.element.appendChild(hiddenField)
    }
    
    // Soumettre le formulaire si nous sommes à l'étape 3
    if (this.element.dataset.step === "3") {
      // Optionnel: vous pouvez afficher un message de confirmation avant de continuer
      alert("Entreprise sélectionnée! Vous allez maintenant passer à l'étape suivante pour compléter les informations.")
      this.element.submit()
    }
  }
  
  prefillFormWithCompanyData(companyId) {
    // Récupérer les données de l'entreprise via une requête AJAX
    fetch(`/api/base_companies/${companyId}`)
      .then(response => {
        if (!response.ok) throw new Error(`HTTP error: ${response.status}`)
        return response.json()
      })
      .then(company => {
        // Pré-remplir les champs
        this.prefillFields(company)
      })
      .catch(error => {
        console.error("Erreur lors du chargement des données de l'entreprise:", error)
      })
  }
  
  prefillFields(company) {
    // Remplir les champs avec les données de l'entreprise
    const fieldsMap = {
      'business_name': company.denomination_sociale,
      'identification_number': company.siret,
      'address': company.adresse,
      'postal_code': company.code_postal,
      // Autres mappings selon votre structure
    }
    
    Object.entries(fieldsMap).forEach(([fieldName, value]) => {
      const field = document.querySelector(`input[name="user[organisation_attributes][${fieldName}]"]`)
      if (field && value) {
        field.value = value
      }
    })
    
    // Ajouter un champ caché pour l'ID de l'entreprise si ce n'est pas déjà fait
    let baseCompanyIdField = document.querySelector('input[name="user[organisation_attributes][base_company_id]"]')
    if (!baseCompanyIdField) {
      baseCompanyIdField = document.createElement('input')
      baseCompanyIdField.type = 'hidden'
      baseCompanyIdField.name = 'user[organisation_attributes][base_company_id]'
      this.element.appendChild(baseCompanyIdField)
    }
    baseCompanyIdField.value = company.id
  }
}
