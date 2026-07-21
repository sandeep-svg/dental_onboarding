import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkboxes"]

  connect() {
    this.bindJobFunctionChanges()
    this.filter()
  }

  bindJobFunctionChanges() {
    const select = document.querySelector("[name='candidate_profile[desired_job_function_id]']")
    if (select) {
      select.addEventListener("change", () => this.filter())
    }
  }

  filter() {
    const select = document.querySelector("[name='candidate_profile[desired_job_function_id]']")
    const jobFunctionId = select ? select.value : ""

    const nameMap = {
      1: "Dentist",
      2: "Dental hygienist",
      3: "Dental assistant",
      4: "Prevention assistant",
      5: "Paro-prevention assistant",
      6: "Orthodontic assistant",
      7: "Front-office",
      8: "Practice manager",
      9: "Dental technician",
      10: "Specialist"
    }

    const selectedGroup = nameMap[jobFunctionId] || ""

    this.checkboxesTarget.querySelectorAll("label").forEach(label => {
      const group = label.dataset.skillGroup
      if (!selectedGroup || group === selectedGroup) {
        label.classList.remove("hidden")
      } else {
        label.classList.add("hidden")
      }
    })
  }
}
