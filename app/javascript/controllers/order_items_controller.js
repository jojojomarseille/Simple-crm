// app/javascript/controllers/order_items_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "item", "productField", "productIdField", "autocompleteResults", "productDropdown", "lineTotal", "quantityField", "priceField", "orderTotal"]

  connect() {
    console.log("OrderItems controller connected");
    this.itemTargets.forEach(item => {
        this.initializeLineItemEvents(item)
      })
    this.updateAllLineTotals()
    this.element.addEventListener('order-items:lineTotalUpdated', this.updateOrderTotal.bind(this))
  }

  add(event) {
    event.preventDefault()
    console.log("Adding new order item")
    
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime());
    this.containerTarget.insertAdjacentHTML('beforeend', content)
    // Après avoir ajouté une nouvelle ligne, initialisons ses écouteurs d'événements
    const newItem = this.containerTarget.lastElementChild
    this.initializeLineItemEvents(newItem)
  }

  remove(event) {
    console.log("Removing order item")
    const item = event.target.closest('[data-order-items-target="item"]')
    
    // Si l'élément a un champ _destroy, le marquer pour destruction plutôt que de le supprimer
    const destroyField = item.querySelector('input[name*="[_destroy]"]')
    if (destroyField) {
      destroyField.value = '1'
      item.style.display = 'none'
    } else {
      item.remove()
      this.dispatch("lineTotalUpdated")
    }
  }

  searchProducts(event) {
    const query = event.target.value.trim()
    const autocompleteResults = event.target.closest('.product-field').querySelector('[data-order-items-target="autocompleteResults"]')
    
    console.log("Searching for products with query:", query)
    
    if (query.length < 2) {
      autocompleteResults.style.display = 'none'
      return
    }

    fetch(`/products/search?query=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(products => {
        console.log("Products received:", products)
        
        autocompleteResults.innerHTML = ''
        
        if (products.length === 0) {
          autocompleteResults.style.display = 'none'
          return
        }
        
        products.forEach(product => {
          const resultItem = document.createElement('div')
          resultItem.className = 'autocomplete-item'
          resultItem.textContent = product.name
          resultItem.dataset.productId = product.id
          resultItem.dataset.productName = product.name
          resultItem.dataset.productPrice = product.price || 0
          resultItem.dataset.action = 'click->order-items#selectProduct'
          
          autocompleteResults.appendChild(resultItem)
        })
        
        autocompleteResults.style.display = 'block'
      })
      .catch(error => {
        console.error('Error searching products:', error)
        autocompleteResults.style.display = 'none'
      })
  }

  selectProduct(event) {
    event.preventDefault()
    
    const productId = event.target.dataset.productId
    const productName = event.target.dataset.productName
    const productPrice = event.target.dataset.productPrice
    
    console.log(`Selecting product: ${productName} (ID: ${productId}, Price: ${productPrice})`)
    
    const item = event.target.closest('.order-item-row')
    const productField = item.querySelector('[data-order-items-target="productField"]')
    const productIdField = item.querySelector('[data-order-items-target="productIdField"]')
    const priceField = item.querySelector('.price-input')
    
    productField.value = productName
    productIdField.value = productId
    
    // Remplir le prix si vide
    if (priceField && (!priceField.value || priceField.value === '0')) {
      priceField.value = productPrice
    }

    if (productIdField) {
        productIdField.value = productId;
        // Déclencher l'événement change manuellement
        productIdField.dispatchEvent(new Event('change', { bubbles: true }));
    }
    
    // Masquer les résultats
    const autocompleteResults = item.querySelector('[data-order-items-target="autocompleteResults"]')
    autocompleteResults.style.display = 'none'
  }

  toggleProductDropdown(event) {
    event.preventDefault()
    console.log("Toggling product dropdown")
    
    const dropdown = event.target.closest('.product-field').querySelector('[data-order-items-target="productDropdown"]')
    dropdown.classList.toggle('d-none')
    
    // Si on ouvre le dropdown, charger les produits s'ils ne sont pas déjà chargés
    if (!dropdown.classList.contains('d-none') && dropdown.querySelector('.product-dropdown-list').children.length === 0) {
      this.loadProductsForDropdown(dropdown)
    }
    
    // Masquer les résultats d'autocomplétion si ouverts
    const autocompleteResults = event.target.closest('.product-field').querySelector('[data-order-items-target="autocompleteResults"]')
    autocompleteResults.style.display = 'none'
  }

  loadProductsForDropdown(dropdown) {
    console.log("Loading products for dropdown");
    
    fetch('/products.json')
      .then(response => response.json())
      .then(products => {
        console.log("Products loaded for dropdown:", products)
        
        const listContainer = dropdown.querySelector('.product-dropdown-list')
        listContainer.innerHTML = ''
        
        products.forEach(product => {
          const item = document.createElement('a')
          item.href = '#'
          item.className = 'product-dropdown-item'
          item.dataset.productId = product.id
          item.dataset.productName = product.name
          item.dataset.productPrice = product.price || 0
          item.dataset.action = 'click->order-items#selectProductFromDropdown'
          item.textContent = product.name
          
          listContainer.appendChild(item)
        })
      })
      .catch(error => console.error('Error loading products:', error))
  }

  selectProductFromDropdown(event) {
    event.preventDefault()
    
    const productId = event.target.dataset.productId
    const productName = event.target.dataset.productName
    const productPrice = event.target.dataset.productPrice
    
    console.log(`Selecting product from dropdown: ${productName} (ID: ${productId}, Price: ${productPrice})`)
    
    const item = event.target.closest('.order-item-row')
    const productField = item.querySelector('[data-order-items-target="productField"]')
    const productIdField = item.querySelector('[data-order-items-target="productIdField"]')
    const priceField = item.querySelector('.price-input')
    
    productField.value = productName
    productIdField.value = productId
    
    // Remplir le prix si vide
    if (priceField && (!priceField.value || priceField.value === '0')) {
      priceField.value = productPrice
    }

    if (productIdField) {
        productIdField.value = productId;
        // Déclencher l'événement change manuellement
        productIdField.dispatchEvent(new Event('change', { bubbles: true }));
    }
    
    // Fermer le dropdown
    const dropdown = item.querySelector('[data-order-items-target="productDropdown"]')
    dropdown.classList.add('d-none')
  }
  
  initializeLineItemEvents(item) {
    // Trouver les champs de prix et quantité dans cet élément
    const priceField = item.querySelector('input[name*="[price]"]')
    const quantityField = item.querySelector('input[name*="[quantity]"]')
    const productIdField = item.querySelector('input[name*="[product_id]"]')

    if (priceField) {
      priceField.dataset.action = (priceField.dataset.action || "") + " input->order-items#updateLineTotal"
    }
    
    if (quantityField) {
      quantityField.dataset.action = (quantityField.dataset.action || "") + " input->order-items#updateLineTotal"
    }

    if (productIdField) {
        productIdField.dataset.action = (productIdField.dataset.action || "") + " change->order-items#updateLineTotal"
    }

    // Initialiser le total pour cette ligne
    this.updateLineTotalForItem(item)
  }

  // Calcule et met à jour le total pour une ligne d'article
    updateLineTotalForItem(item) {
        const priceField = item.querySelector('input[name*="[price]"]')
        const quantityField = item.querySelector('input[name*="[quantity]"]')
        const totalDisplay = item.querySelector('[data-order-items-target="lineTotal"]')
        
        if (priceField && totalDisplay) {
            const price = parseFloat(priceField.value) || 0
            const quantity = quantityField ? (parseFloat(quantityField.value) || 1) : 1
            
            const total = price * quantity
            totalDisplay.textContent = total.toFixed(2) + ' €'
            
            // Émettre un événement pour le calcul du total général
            this.dispatch("lineTotalUpdated")
        }
    }

  updateAllLineTotals() {
    this.itemTargets.forEach(item => {
      this.updateLineTotalForItem(item)
    })
    this.updateOrderTotal()
  }

  updateLineTotal(event) {
    const item = event.target.closest('[data-order-items-target="item"]')
    this.updateLineTotalForItem(item)
    
    // Si vous avez un total de commande, mettez-le aussi à jour
    if (this.hasOrderTotalTarget) {
      this.updateOrderTotal()
    }
  }


  updateOrderTotal() {
    if (this.hasOrderTotalTarget) {
      let total = 0
      this.itemTargets.forEach(item => {
        const totalElement = item.querySelector('[data-order-items-target="lineTotal"]')
        if (totalElement) {
          const totalText = totalElement.textContent
          const totalValue = parseFloat(totalText.replace(/[^\d.-]/g, '')) || 0
          total += totalValue
        }
      })
      
      this.orderTotalTarget.textContent = total.toFixed(2) + ' €'
    }
  }

}

