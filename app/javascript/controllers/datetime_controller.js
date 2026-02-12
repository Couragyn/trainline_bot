import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('input', this.validateInput.bind(this))
    this.element.addEventListener('keydown', this.preventOverflow.bind(this))
    this.element.addEventListener('blur', this.validateDateRange.bind(this))
  }

  validateInput(event) {
    const value = event.target.value
    if (value) {
      const datePattern = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})$/
      if (!datePattern.test(value)) {
        const fixed = value.replace(/^(\d{6,})-/, (match, year) => {
          return year.substring(0, 4) + '-'
        })
        if (fixed !== value) {
          event.target.value = fixed
        }
      }
    }
  }

  preventOverflow(event) {
    const input = event.target
    const value = input.value
    
    // Check if year has too many digits
    if (value) {
      const yearMatch = value.match(/^(\d+)/)
      if (yearMatch && yearMatch[1].length > 4) {
        input.value = value.replace(/^(\d{4})\d+/, '$1')
      }
    }
  }

  validateDateRange(event) {
    const input = event.target
    const value = input.value
    const min = input.getAttribute('min')
    const max = input.getAttribute('max')

    if (value && min && value < min) {
      input.setCustomValidity('Departure date cannot be before February 16, 2026')
      input.reportValidity()
    } else if (value && max && value > max) {
      input.setCustomValidity('Departure date cannot be more than one year in advance')
      input.reportValidity()
    } else {
      input.setCustomValidity('')
    }
  }
}
