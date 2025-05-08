// form order dynamic fields adding
// document.addEventListener('DOMContentLoaded', function() {
//     const addButton = document.getElementById('add-button');
//     const list = document.getElementById('list');
//     const templateContainer = document.getElementById('template-container');
  
//     if (addButton) {
//       addButton.addEventListener('click', function() {
//         const newId = new Date().getTime();
//         const templateHTML = templateContainer.innerHTML.replace(/NEW_RECORD/g, newId);
  
//         const newFields = document.createElement('div');
//         newFields.innerHTML = templateHTML;
  
//         const removeButton = newFields.querySelector('.button-remove');
//         if (removeButton) {
//           // Ajouter un identifiant unique au bouton supprimer
//           removeButton.id = `remove-button-${newId}`;
//           attachRemoveEvent(removeButton);
//         }
        
//         list.appendChild(newFields.firstElementChild);
//       });
//     }
  
//     function attachRemoveEvent(button) {
//       button.addEventListener('click', function() {
//         button.closest('.list-item').remove();
//       });
//     }
  
//     // Initialiser les événements pour tous les boutons "remove" existants au départ
//     document.querySelectorAll('.button-remove').forEach(button => {
//       attachRemoveEvent(button);
//     });
//   });