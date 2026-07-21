import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "fields"]

  addRecord() {
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    const wrapper = document.createElement("div")
    wrapper.innerHTML = content
    this.fieldsTarget.appendChild(wrapper.firstElementChild)
  }

  removeRecord(event) {
    const row = event.target.closest("[data-nested-form-target='fields'] > div")
    if (!row) return

    const destroyInput = row.querySelector("input[name*='_destroy']")
    if (destroyInput) {
      destroyInput.value = "1"
    }
    row.classList.add("hidden")
  }
}
