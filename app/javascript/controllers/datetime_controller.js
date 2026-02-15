import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('input', this.validateInput.bind(this))
    this.element.addEventListener('blur', this.validateDateRange.bind(this))
  }

  // Guard against malformed datetime-local values as the user types.
  validateInput(event) {
    const value = event.target.value
    if (value) {
      const datePattern = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})$/
      if (!datePattern.test(value)) {
        // Trim oversized year input back to 4 digits.
        const fixed = value.replace(/^(\d{6,})-/, (match, year) => {
          return year.substring(0, 4) + '-'
        })
        if (fixed !== value) {
          event.target.value = fixed
        }
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
      input.setCustomValidity('Departure date cannot be after February 22, 2027')
      input.reportValidity()
    } else {
      input.setCustomValidity('')
    }
  }
}
