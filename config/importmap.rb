# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
# pin "@hotwired/stimulus", to: "stimulus.min.js"
# pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
# pin "intl-tel-input", to: "https://ga.jspm.io/npm:intl-tel-input@18.2.1/build/js/intlTelInput.min.js"
# pin "intl-tel-input/build/js/utils", to: "https://ga.jspm.io/npm:intl-tel-input@18.2.1/build/js/utils.js"

