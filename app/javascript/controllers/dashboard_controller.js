// app/javascript/controllers/dashboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["gridContainer"]
  
  connect() {
    console.log("Dashboard controller connected");
    this.initSortable();

    const serverSavedOrder = this.element.dataset.dashboardSavedOrder;
    if (serverSavedOrder) {
        this.restoreBlocksOrderFromServer(JSON.parse(serverSavedOrder));
    } else {
        // Sinon, utiliser l'ordre du localStorage
        this.restoreBlocksOrder();
    }
  }
  
  initSortable() {
    // Utilisation de Sortable globale (depuis CDN)
    if (!window.Sortable) {
      console.error("⚠️ Sortable.js n'est pas disponible en tant que variable globale");
      return;
    }
    
    // Créer l'instance Sortable sur le conteneur de la grille
    this.sortable = new window.Sortable(this.gridContainerTarget, {
      animation: 150,
      handle: '.drag-handle', // Utilise uniquement l'icône comme poignée
      ghostClass: 'sortable-ghost', // Classe appliquée à l'élément fantôme (preview)
      chosenClass: 'sortable-chosen', // Classe appliquée à l'élément sélectionné
      dragClass: 'sortable-drag', // Classe appliquée pendant le déplacement
      
      // Événement déclenché après un déplacement
      onEnd: (evt) => {
        this.saveBlocksOrder();
      }
    });
    
    console.log("Sortable initialized ✅", this.sortable);
  }
  
  // Sauvegarde l'ordre des blocs
  saveBlocksOrder() {
    const blocksOrder = Array.from(this.gridContainerTarget.children).map(block => {
      return block.dataset.blockId;
    });
    
    console.log("Nouvel ordre des blocs:", blocksOrder);
    
    // Enregistrement en localStorage pour persistance locale
    localStorage.setItem('dashboardBlocksOrder', JSON.stringify(blocksOrder));
    
   this.sendOrderToServer(blocksOrder);
  }
  
  sendOrderToServer(blocksOrder) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    
    fetch('/pages/save_dashboard_order', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ blocks_order: blocksOrder })
    })
    .then(response => response.json())
    .then(data => {
      console.log('Ordre enregistré sur le serveur:', data);
    })
    .catch(error => {
      console.error('Erreur lors de l\'enregistrement:', error);
    });
  }

  restoreBlocksOrder() {
    const savedOrder = localStorage.getItem('dashboardBlocksOrder');
    
    if (savedOrder) {
      try {
        const blocksOrder = JSON.parse(savedOrder);
        
        // Réorganiser les éléments selon l'ordre sauvegardé
        blocksOrder.forEach(blockId => {
          const block = this.gridContainerTarget.querySelector(`[data-block-id="${blockId}"]`);
          if (block) {
            this.gridContainerTarget.appendChild(block);
          }
        });
        
        console.log("Ordre des blocs restauré ✅");
      } catch (e) {
        console.error("Erreur lors de la restauration de l'ordre:", e);
      }
    }
  }

  restoreBlocksOrderFromServer(blocksOrder) {
    // Similaire à restoreBlocksOrder mais avec l'ordre du serveur
    blocksOrder.forEach(blockId => {
      const block = this.gridContainerTarget.querySelector(`[data-block-id="${blockId}"]`);
      if (block) {
        this.gridContainerTarget.appendChild(block);
      }
    });
    
    console.log("Ordre des blocs restauré depuis le serveur ✅");
  }
  
}
