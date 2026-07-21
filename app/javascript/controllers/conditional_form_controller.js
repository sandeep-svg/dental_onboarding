import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "bigRegistrationField",
    "bigNumberField",
    "dailyRevenueField",
    "salaryField",
    "percentageField",
  ]

  connect() {
    this.updateForm()
    this.bindEmploymentChanges()
    this.updateEmployment()
  }

  updateForm() {
    const select = this.element.querySelector("[name='candidate_profile[desired_job_function_id]']")
    if (!select) return

    const jobFunctionId = select.value
    const showClinical = ["1", "2", "10"].includes(jobFunctionId)

    this.bigRegistrationFieldTarget.classList.toggle("hidden", !showClinical)
    this.bigNumberFieldTarget.classList.toggle("hidden", !showClinical)
    this.dailyRevenueFieldTarget.classList.toggle("hidden", !showClinical)
  }

  bindEmploymentChanges() {
    this.element.querySelectorAll("[name^='candidate_profile[desired_employment_type]']").forEach(cb => {
      cb.addEventListener("change", () => this.updateEmployment())
    })
  }

  updateEmployment() {
    const checked = Array.from(
      this.element.querySelectorAll("[name^='candidate_profile[desired_employment_type]']:checked")
    ).map(cb => cb.value)

    const hasEmployed = checked.includes("employed")
    const hasPercentage = checked.some(v => ["self_employed", "freelance", "percentage_based"].includes(v))

    this.salaryFieldTarget.classList.toggle("hidden", !hasEmployed)
    this.percentageFieldTarget.classList.toggle("hidden", !hasPercentage)
  }
}
