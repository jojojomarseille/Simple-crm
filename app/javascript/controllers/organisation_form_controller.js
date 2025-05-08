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
    "baseCompanyId", 
    "selectedCompanyInfo",
    "countryErrorMessage",
    "submitButton"
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
    
    if (this.hasCountryErrorMessageTarget) {
        this.countryErrorMessageTarget.style.display = 'none'
      }

      // Gérer le bouton suivant
        if (this.hasSubmitButtonTarget) {
            if (selectedCountry === 'France') {
            // Afficher le bouton pour la France
            this.submitButtonTarget.style.display = 'flex'
            } else if (selectedCountry) {
            // Cacher le bouton pour les autres pays
            this.submitButtonTarget.style.display = 'none'
            } else {
            // Si aucun pays n'est sélectionné, cacher aussi le bouton
            this.submitButtonTarget.style.display = 'none'
            }
        }

      if (selectedCountry === 'France') {
        // Pour la France, afficher les champs normaux
        this.statusFieldTarget.style.display = 'block'
        this.resetSearchAndResults()
      } else if (selectedCountry) {
        // Pour les autres pays (mais seulement si un pays est sélectionné)
        this.statusFieldTarget.style.display = 'none'
        
        if (this.hasSearchFieldTarget) {
          this.searchFieldTarget.style.display = 'none'
        }
        
        // Afficher le message d'erreur inline
        if (this.hasCountryErrorMessageTarget) {
          this.countryErrorMessageTarget.style.display = 'block'
          
          // Animation subtile pour attirer l'attention (facultatif)
          this.countryErrorMessageTarget.classList.add('animate-attention')
          setTimeout(() => {
            this.countryErrorMessageTarget.classList.remove('animate-attention')
          }, 500)
        }
      } else {
        // Si aucun pays n'est sélectionné (option 'prompt')
        this.statusFieldTarget.style.display = 'none'
        if (this.hasSearchFieldTarget) {
          this.searchFieldTarget.style.display = 'none'
        }
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
      if (this.hasNoResultsMessageTarget) {
        this.noResultsMessageTarget.style.display = 'none'
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
              this.searchResultsTarget.innerHTML = `
                <div class="search-result-item text-danger">
                  <i class="fas fa-exclamation-triangle"></i> 
                  Une erreur est survenue lors de la recherche.
                </div>
                <div class="search-result-item not-in-list-option" data-action="click->organisation-form#createNewCompany">
                  <i class="fas fa-plus-circle"></i> Mon entreprise n'est pas dans la liste
                </div>
              `
              this.searchResultsTarget.style.display = 'block'
            }
          })
    }
  
    displaySearchResults(companies) {
        if (!this.hasSearchResultsTarget) return
        
        let resultsList = '';
        
        // Afficher les entreprises trouvées
        if (companies.length > 0) {
          resultsList = companies.map(company => {
            return `<div class="search-result-item" data-action="click->organisation-form#selectCompany" data-company-id="${company.id}">
              <div class="company-name">${company.denomination_sociale || 'N/A'}</div>
              <div class="company-details">
                SIRET: ${company.siret || 'N/A'} 
                <br>
                ${company.adresse || ''} ${company.code_postal || ''}
              </div>
            </div>`
          }).join('')
          
          // Ajouter un message si peu de résultats
          if (companies.length < 3) {
            resultsList += `<div class="search-result-item text-muted pt-2 pb-2">
              <small>Continuez à taper pour affiner les résultats</small>
            </div>`
          }
        } else {
          // Message si aucune entreprise trouvée
          resultsList = `<div class="search-result-item text-muted">
            Aucune entreprise trouvée avec ces critères.
          </div>`
        }
        
        // Toujours ajouter l'option "Mon entreprise n'est pas dans la liste" à la fin
        resultsList += `<div class="search-result-item not-in-list-option" data-action="click->organisation-form#createNewCompany">
          <i class="fas fa-plus-circle"></i> Mon entreprise n'est pas dans la liste
        </div>`
        
        this.searchResultsTarget.innerHTML = resultsList
        this.searchResultsTarget.style.display = 'block'
      }
      
  
      selectCompany(event) {
        const companyId = event.currentTarget.dataset.companyId
        const companyName = event.currentTarget.querySelector('.company-name').textContent
        
        // Cacher les résultats de recherche
        this.searchResultsTarget.style.display = 'none'
        
        // Stocker l'ID de l'entreprise sélectionnée
        this.baseCompanyIdTarget.value = companyId
        
        // Afficher un message de confirmation
        if (this.hasSelectedCompanyInfoTarget) {
          this.selectedCompanyInfoTarget.innerHTML = `
            <i class="fas fa-check-circle"></i> Votre entreprise : <strong>${companyName}</strong>
            <button type="button" class="sub-step3-close" data-action="click->organisation-form#clearSelection">
              <span>&times;</span>
            </button>
          `
          this.selectedCompanyInfoTarget.style.display = 'block'
        }
        
        // Pré-remplir les données de l'entreprise
        this.prefillFormWithCompanyData(companyId)
        
        // Facultatif: effacer la recherche
        this.searchFieldInputTarget.value = ''

        const nextButton = document.querySelector(".step-navigation-next-btn")
        if (nextButton) {
            nextButton.focus()
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

  clearSelection() {
    if (this.hasBaseCompanyIdTarget) {
      this.baseCompanyIdTarget.value = ''
    }
    
    if (this.hasSelectedCompanyInfoTarget) {
      this.selectedCompanyInfoTarget.style.display = 'none'
    }
    
    // Réinitialiser les champs pré-remplis si nécessaire
    // this.resetPrefillFields()
  }

  createNewCompany() {
    // Effacer tout ID d'entreprise sélectionné
    if (this.hasBaseCompanyIdTarget) {
      this.baseCompanyIdTarget.value = ''
    }
    
    // Cacher les résultats de recherche
    if (this.hasSearchResultsTarget) {
      this.searchResultsTarget.style.display = 'none'
    }
    
    if (this.hasSelectedCompanyInfoTarget) {
      this.selectedCompanyInfoTarget.innerHTML = `
        <i class="fas fa-plus-circle"></i> Vous allez devoir renseigner manuellement les informations de votre entreprise
        <button type="button" class="sub-step3-close" data-action="click->organisation-form#clearSelection">
          <span>&times;</span>
        </button>
      `
      this.selectedCompanyInfoTarget.style.display = 'block'
    }
    
    // Si vous êtes à l'étape 3, vous pouvez passer à l'étape suivante ici
    if (this.element.dataset.step === "3") {
      // Passer à l'étape suivante
      // Si vous avez un bouton "next", vous pouvez déclencher son clic
      const nextButton = document.querySelector(".step-navigation-next-btn")
      if (nextButton) {
        nextButton.click()
      }
    }
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
