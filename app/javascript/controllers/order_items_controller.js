import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template", "item", "productField", "productIdField", "autocompleteResults", "autocompleteResults"]
  static values = { organisationId: Number }

  connect() {
    console.log("OrderItems controller connected, organisation ID:", this.organisationIdValue);
    
    // Initialiser avec au moins une ligne si aucune n'existe
    if (this.itemTargets.length === 0) {
      console.log("No items found, adding one");
      this.add();
    } else {
      console.log("Found", this.itemTargets.length, "existing items");
    }
    
    // Ajouter les événements de recherche pour les champs existants
    this.productFieldTargets.forEach((field, index) => {
      console.log("Setting up autocomplete for existing field", index);
      this._setupAutocompleteField(field);
    });
    
    // Afficher le bouton de suppression seulement s'il y a plus d'un élément
    this._updateRemoveButtons();
  }
  
  add(event) {
    if (event) event.preventDefault();
    console.log("Adding new order item");
    // Ajouter une nouvelle ligne
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime());
    this.listTarget.insertAdjacentHTML('beforeend', content);
    
    // Initialiser l'autocomplétion sur le nouveau champ
    const newField = this.productFieldTargets[this.productFieldTargets.length - 1];
    console.log("Setting up autocomplete for new field");
    this._setupAutocompleteField(newField);
    
    // Mettre le focus sur le nouveau champ produit
    newField.focus();
    
    this._updateRemoveButtons();
  }
  
  remove(event) {
    if (event) event.preventDefault();
    console.log("Removing order item");
    // Ne pas supprimer si c'est la dernière ligne
    if (this.itemTargets.length <= 1) {
      console.log("Can't remove the last item");
      return;
    }
    
    const item = event.target.closest('[data-order-items-target="item"]');
    item.remove();
    console.log("Item removed, remaining:", this.itemTargets.length);
    
    this._updateRemoveButtons();
  }
  
  searchProducts(event) {
    const field = event.target;
    const query = field.value.trim();
    console.log("Searching products for query:", query);
    
    if (query.length < 2) {
      console.log("Query too short, closing autocomplete");
      this._closeAutocomplete(field);
      return;
    }
    
    console.log("Fetching products, organisation ID:", this.organisationIdValue);
    fetch(`/api/products/search?q=${encodeURIComponent(query)}&organisation_id=${this.organisationIdValue}`)
      .then(response => {
        console.log("Search response status:", response.status);
        if (!response.ok) {
          throw new Error(`Server responded with ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        console.log("Products found:", data.length, data);
        this._displayResults(data, this.autocompleteResultsTarget, field);
      })      
      .catch(error => {
        console.error("Error searching products:", error);
      });
  }

  
  
  _displayResults(products, container, inputField) {
    console.log("Displaying results in container:", container);
    container.innerHTML = '';
    
    if (products.length === 0) {
      console.log("No products found");
      container.classList.remove('show');
      return;
    }
    
    // Limiter à 5 résultats maximum
    const limitedProducts = products.slice(0, 5);
    console.log("Displaying", limitedProducts.length, "products");
    
    limitedProducts.forEach(product => {
      const item = document.createElement('div');
      item.classList.add('autocomplete-item');
      item.textContent = product.name;
      item.dataset.id = product.id;
      item.dataset.price = product.price || '';
      
      item.addEventListener('click', () => {
        console.log("Product selected via click:", product);
        this._selectProduct(product, inputField);
        container.classList.remove('show');
      });
      
      container.appendChild(item);
    });
    
    container.classList.add('show');
  }
  
  _selectProduct(product, field) {
    console.log("Selecting product:", product);
    const row = field.closest('[data-order-items-target="item"]');
    const productIdField = row.querySelector('[data-order-items-target="productIdField"]');
    
    field.value = product.name;
    if (productIdField) {
      productIdField.value = product.id;
      console.log("Updated product ID field:", productIdField.value);
    }
    
    // Mettre à jour le prix si disponible
    if (product.price) {
      const priceField = row.querySelector('.price-input');
      if (priceField && !priceField.value) {
        priceField.value = product.price;
        console.log("Updated price field:", priceField.value);
      }
    }
    this._closeAutocomplete(field);
  }
  
  _closeAutocomplete(field) {
    console.log("Closing autocomplete");
    const container = field.nextElementSibling;
    if (container) {
      container.innerHTML = '';
      container.classList.remove('show');
    }
  }
  
  _setupAutocompleteField(field) {
    console.log("Setting up autocomplete events for field:", field);
    
    // Gérer la navigation au clavier (flèches haut/bas, entrée)
    field.addEventListener('keydown', (e) => {
      const container = field.nextElementSibling;
      const items = container.querySelectorAll('.autocomplete-item');
      
      if (!container.classList.contains('show')) return;
      
      let selectedIndex = Array.from(items).findIndex(item => item.classList.contains('selected'));
      console.log("Keyboard navigation, selected index:", selectedIndex);
      
      switch (e.key) {
        case 'ArrowDown':
          e.preventDefault();
          selectedIndex = (selectedIndex + 1) % items.length;
          console.log("Arrow down, new index:", selectedIndex);
          this._highlightItem(items, selectedIndex);
          break;
        case 'ArrowUp':
          e.preventDefault();
          selectedIndex = (selectedIndex - 1 + items.length) % items.length;
          console.log("Arrow up, new index:", selectedIndex);
          this._highlightItem(items, selectedIndex);
          break;
        case 'Enter':
          e.preventDefault();
          if (selectedIndex >= 0) {
            console.log("Enter pressed on item:", selectedIndex);
            const product = {
              id: items[selectedIndex].dataset.id,
              name: items[selectedIndex].textContent,
              price: items[selectedIndex].dataset.price
            };
            this._selectProduct(product, field);
            container.classList.remove('show');
          }
          break;
        case 'Escape':
          console.log("Escape pressed, closing autocomplete");
          container.classList.remove('show');
          break;
      }
    });
    
    // Fermer les résultats quand on clique ailleurs
    document.addEventListener('click', (e) => {
      if (!field.contains(e.target) && !field.nextElementSibling.contains(e.target)) {
        console.log("Click outside autocomplete, closing results");
        field.nextElementSibling.classList.remove('show');
      }
    });
  }
  
  _highlightItem(items, index) {
    console.log("Highlighting item at index:", index);
    items.forEach(item => item.classList.remove('selected'));
    if (index >= 0 && index < items.length) {
      items[index].classList.add('selected');
      items[index].scrollIntoView({ block: 'nearest' });
    }
  }

  _updateRemoveButtons() {
    // Afficher le bouton de suppression seulement s'il y a plus d'un élément
    const buttons = document.querySelectorAll('.remove-button');
    buttons.forEach(button => {
      if (this.itemTargets.length > 1) {
        button.style.display = 'block';
      } else {
        button.style.display = 'none';
      }
    });
  }
}

