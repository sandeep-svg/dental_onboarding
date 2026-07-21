import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.check()
    this.interval = setInterval(() => this.check(), 3000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  check() {
    fetch(this.urlValue)
      .then(r => r.json())
      .then(data => {
        if (data.status === "completed") {
          clearInterval(this.interval)
          location.reload()
        }
      })
      .catch(() => {})
  }
}
