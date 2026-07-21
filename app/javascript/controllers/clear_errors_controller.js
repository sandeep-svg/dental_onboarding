import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundHandler = this.handleChange.bind(this)
    this.element.addEventListener("change", this.boundHandler)
    this.element.addEventListener("input", this.boundHandler)
  }

  disconnect() {
    this.element.removeEventListener("change", this.boundHandler)
    this.element.removeEventListener("input", this.boundHandler)
  }

  handleChange(e) {
    const el = e.target
    if (this.isEmpty(el)) {
      this.markInvalid(el)
    } else {
      this.markValid(el)
      if (el.name && el.name.indexOf("password_confirmation") !== -1) {
        this.checkPasswordMatch(el)
      }
    }
    this.hideErrorSummary()
  }

  checkPasswordMatch(el) {
    const form = el.closest("form")
    if (!form) return
    const password = form.querySelector("[name*='[password]']:not([name*='password_confirmation'])")
    if (!password) return
    if (el.value !== password.value) {
      el.setAttribute("aria-invalid", "true")
    }
  }

  hideErrorSummary() {
    const form = this.element
    const errorFields = form.querySelectorAll(".field_with_errors, [aria-invalid='true']")
    const summary = document.getElementById("error_explanation")
    if (summary) {
      if (errorFields.length === 0) {
        summary.style.display = "none"
      } else {
        summary.style.display = ""
      }
    }
  }

  isEmpty(el) {
    if (el.type === "checkbox") {
      if (el.name.match(/\[\]$/)) {
        const name = CSS.escape(el.name)
        const group = document.querySelectorAll(`input[name="${name}"]`)
        return !Array.from(group).some(cb => cb.checked)
      }
      return !el.checked
    }
    if (el.tagName === "SELECT") {
      return !el.value
    }
    return el.value.trim() === ""
  }

  findSection(el) {
    let parent = el.parentElement
    while (parent && parent !== this.element) {
      if (parent.querySelector && parent.querySelector(".section-label")) {
        return parent
      }
      parent = parent.parentElement
    }
    return null
  }

  markInvalid(el) {
    if (el.type === "checkbox" && el.name.match(/\[\]$/)) {
      const section = this.findSection(el)
      if (section) section.classList.add("has-error")
      return
    }
    el.setAttribute("aria-invalid", "true")
  }

  markValid(el) {
    if (el.type === "checkbox" && el.name.match(/\[\]$/)) {
      const section = el.closest(".has-error")
      if (section) section.classList.remove("has-error")
      return
    }
    el.removeAttribute("aria-invalid")
    this.unwrapError(el)
    if (el.labels) {
      Array.from(el.labels).forEach(l => this.unwrapError(l))
    }
  }

  unwrapError(el) {
    const wrapper = el.closest(".field_with_errors")
    if (wrapper && wrapper.isConnected) {
      wrapper.replaceWith(...wrapper.childNodes)
    }
  }
}