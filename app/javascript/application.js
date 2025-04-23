// Configure your import map in config/importmap.rb

import "@hotwired/turbo-rails"
import "controllers"

// Add Bootstrap JavaScript functionality for dropdowns, alerts, etc.
document.addEventListener("turbo:load", function() {
  // Enable all tooltips
  const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  tooltipTriggerList.forEach(function (tooltipTriggerEl) {
    new bootstrap.Tooltip(tooltipTriggerEl)
  })

  // Enable all popovers
  const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  popoverTriggerList.forEach(function (popoverTriggerEl) {
    new bootstrap.Popover(popoverTriggerEl)
  })

  // Auto dismiss alerts
  const alerts = document.querySelectorAll('.alert:not(.alert-permanent)')
  alerts.forEach(function(alert) {
    setTimeout(function() {
      const closeButton = alert.querySelector('.btn-close')
      if (closeButton) {
        closeButton.click()
      }
    }, 5000)
  })
  
  // Enable form validation
  const forms = document.querySelectorAll('.needs-validation')
  forms.forEach(function(form) {
    form.addEventListener('submit', function(event) {
      if (!form.checkValidity()) {
        event.preventDefault()
        event.stopPropagation()
      }
      form.classList.add('was-validated')
    }, false)
  })
})