import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    console.log("🗓️ Datepicker controller connected")
    this.initFlatpickr()
  }

  disconnect() {
    if (this.flatpickrInstance) {
      this.flatpickrInstance.destroy()
    }
  }

  initFlatpickr() {
    // flatpickr est disponible globalement via CDN
    this.flatpickrInstance = flatpickr(this.inputTarget, {
      dateFormat: "Y-m-d",
      maxDate: "today",
      minDate: "1900-01-01",
      onChange: (selectedDates, dateStr, instance) => {
        instance.setDate(dateStr, true)
      },
      locale: "fr",
      firstDayOfWeek: 1
    })
  }
}
