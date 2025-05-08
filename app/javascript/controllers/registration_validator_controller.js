// app/javascript/controllers/registration_validator_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Initialise les validations si nécessaire
    console.log("✅ Contrôleur registration-validator connecté");
    this.initializePasswordValidation();
    // this.setupPasswordToggles();
  }

  // Validation de l'email
  validateEmail(event) {
    console.log("📧 Validation de l'email en cours...", event.target.value);
    const emailInput = event.target;
    const emailError = document.getElementById('email-error');
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (emailPattern.test(emailInput.value)) {
      emailError.style.display = 'none';
    } else {
      emailError.style.display = 'block';
      emailError.textContent = 'Format de l\'email invalide';
    }
  }

  // Validation du mot de passe
  validatePassword(event) {
    console.log("🔑 Validation du mot de passe en cours...", event.target.value);
    const passwordInput = event.target;
    const passwordValue = passwordInput.value;

    const criteria = {
      uppercase: document.getElementById('criterion-uppercase'),
      length: document.getElementById('criterion-length'),
      number: document.getElementById('criterion-number'),
      lowercase: document.getElementById('criterion-lowercase')
    };

    this.updateCriterion(criteria.uppercase, /[A-Z]/.test(passwordValue));
    this.updateCriterion(criteria.length, passwordValue.length >= 8);
    this.updateCriterion(criteria.number, /\d/.test(passwordValue));
    this.updateCriterion(criteria.lowercase, /[a-z]/.test(passwordValue));

    // Vérifier aussi la correspondance si le champ de confirmation est rempli
    this.checkPasswordMatch();
  }

  // Vérification de la correspondance des mots de passe  
  checkPasswordMatch() {
    console.log("🔄 Vérification de la correspondance des mots de passe...");
    const passwordInput = document.querySelector('.sub-custom-input[type="password"]');
    const confirmPasswordInput = document.querySelector('.sub-custom-input[name="user[password_confirmation]"]');
    const matchCriterion = document.getElementById('criterion-match');

    if (!confirmPasswordInput.value) return;
    
    const passwordValue = passwordInput.value;
    const confirmPasswordValue = confirmPasswordInput.value;
    const iconElement = matchCriterion.querySelector('.icon');

    if (passwordValue === confirmPasswordValue && passwordValue !== "") {
      matchCriterion.classList.add('valid');
      iconElement.textContent = '✔';
      iconElement.style.color = 'green';
    } else {
      matchCriterion.classList.remove('valid');
      iconElement.textContent = '✖';
      iconElement.style.color = confirmPasswordValue ? 'red' : 'grey';
    }
  }

  // Utilitaire pour mettre à jour l'affichage d'un critère
  updateCriterion(criterionElement, isValid) {
    console.log(`🔍 Mise à jour du critère: ${criterionElement.textContent.trim()}, valide: ${isValid}`);
    const iconElement = criterionElement.querySelector('.icon');
    if (isValid) {
      criterionElement.classList.add('valid');
      iconElement.textContent = '✔';
      iconElement.style.color = 'green';
    } else {
      criterionElement.classList.remove('valid');
      iconElement.textContent = '✖';
      iconElement.style.color = 'red';
    }
  }

  // Initialisation de la validation des mots de passe
  initializePasswordValidation() {
    console.log("🚀 Initialisation de la validation du mot de passe");
    const passwordInput = document.querySelector('.sub-custom-input[type="password"]');
    if (passwordInput.value) {
      this.validatePassword({ target: passwordInput });
    }
  }

  // Gestion de l'affichage/masquage du mot de passe
  togglePassword(event) {
    console.log("👁️ Changement de visibilité du mot de passe", event.currentTarget.getAttribute('data-target'));
    const button = event.currentTarget;
    const targetId = button.getAttribute('data-target');
    const passwordField = document.getElementById(targetId) || 
                          document.querySelector(`[name="user[${targetId}]"]`);
    
    if (passwordField) {
      const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
      passwordField.setAttribute('type', type);
      
      const icon = button.querySelector('i');
      if (type === 'text') {
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
      } else {
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
      }
    }
  }

}
