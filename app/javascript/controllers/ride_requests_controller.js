import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pickupSelect", "dropoffSelect", "errorMessage"]
  
  connect() {
    console.log("Ride request controller connected")
    this.validateFormElements()
  }
  
  validateFormElements() {
    // Check that pickup and dropoff locations are different
    if (this.hasPickupSelectTarget && this.hasDropoffSelectTarget) {
      this.pickupSelectTarget.addEventListener('change', this.validateLocations.bind(this))
      this.dropoffSelectTarget.addEventListener('change', this.validateLocations.bind(this))
    }
  }
  
  validateLocations() {
    if (this.pickupSelectTarget.value && this.dropoffSelectTarget.value) {
      if (this.pickupSelectTarget.value === this.dropoffSelectTarget.value) {
        this.errorMessageTarget.textContent = "Pickup and dropoff locations cannot be the same."
        this.errorMessageTarget.classList.remove('d-none')
        this.disableSubmitButton(true)
      } else {
        this.errorMessageTarget.textContent = ""
        this.errorMessageTarget.classList.add('d-none')
        this.disableSubmitButton(false)
      }
    }
  }
  
  disableSubmitButton(disabled) {
    const submitButton = this.element.querySelector('input[type="submit"]')
    if (submitButton) {
      submitButton.disabled = disabled
    }
  }
  
  refreshWaitTime() {
    // For ride status page - implement AJAX refresh of wait time estimate
    const rideId = this.element.dataset.rideId
    if (!rideId) return
    
    fetch(`/ride_requests/${rideId}/wait_time`)
      .then(response => response.json())
      .then(data => {
        const waitTimeElement = document.getElementById('estimated-wait-time')
        if (waitTimeElement) {
          waitTimeElement.textContent = `${data.wait_time} minutes`
        }
      })
      .catch(error => {
        console.error('Error fetching wait time:', error)
      })
  }
  
  // Auto refresh wait time every 30 seconds for pending rides
  startWaitTimeRefresh() {
    this.waitTimeInterval = setInterval(() => {
      this.refreshWaitTime()
    }, 30000)
  }
  
  disconnected() {
    if (this.waitTimeInterval) {
      clearInterval(this.waitTimeInterval)
    }
  }
}