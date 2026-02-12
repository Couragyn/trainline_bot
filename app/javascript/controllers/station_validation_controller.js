import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["from", "to"]

  connect() {
    if (this.hasFromTarget) {
      this.fromTarget.addEventListener('blur', this.validateStations.bind(this))
      this.fromTarget.addEventListener('input', this.clearError.bind(this))
    }
    if (this.hasToTarget) {
      this.toTarget.addEventListener('blur', this.validateStations.bind(this))
      this.toTarget.addEventListener('input', this.clearError.bind(this))
    }
  }

  validateStations() {
    if (this.hasFromTarget && this.hasToTarget) {
      const from = this.fromTarget.value.trim().toLowerCase()
      const to = this.toTarget.value.trim().toLowerCase()

      if (from && to && from === to) {
        this.toTarget.setCustomValidity('Departure and arrival stations must be different')
        this.toTarget.reportValidity()
      } else {
        this.toTarget.setCustomValidity('')
      }
    }
  }

  clearError() {
    if (this.hasFromTarget && this.hasToTarget) {
      this.toTarget.setCustomValidity('')
    }
  }
}
