import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropzone", "fileInfo", "submitBtn", "processing"]

  connect() {
    this.bindDragEvents()
  }

  bindDragEvents() {
    ["dragenter", "dragover", "dragleave", "drop"].forEach(event => {
      this.dropzoneTarget.addEventListener(event, this.preventDefaults.bind(this))
    })

    ;["dragenter", "dragover"].forEach(event => {
      this.dropzoneTarget.addEventListener(event, () => this.dropzoneTarget.classList.add("border-blue-500", "bg-blue-50"))
    })

    ;["dragleave", "drop"].forEach(event => {
      this.dropzoneTarget.addEventListener(event, () => this.dropzoneTarget.classList.remove("border-blue-500", "bg-blue-50"))
    })

    this.dropzoneTarget.addEventListener("drop", this.handleDrop.bind(this))
    this.inputTarget.addEventListener("change", this.handleFileSelect.bind(this))
  }

  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  handleDrop(e) {
    const file = e.dataTransfer.files[0]
    if (file) this.setFile(file)
  }

  handleFileSelect(e) {
    const file = e.target.files[0]
    if (file) this.setFile(file)
  }

  setFile(file) {
    const validTypes = (this.element.dataset.allowedTypes || "application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document").split(",")

    if (!validTypes.includes(file.type)) {
      this.fileInfoTarget.textContent = "Unsupported file type. Please upload a PDF, DOC, or DOCX file."
      this.fileInfoTarget.className = "text-sm text-red-600 mt-2"
      this.submitBtnTarget.disabled = true
      return
    }

    const maxSizeMB = parseInt(this.element.dataset.maxCvSizeMb) || 25
    const maxSize = maxSizeMB * 1024 * 1024
    if (file.size > maxSize) {
      this.fileInfoTarget.textContent = "File too large. Maximum size is " + maxSizeMB + " MB."
      this.fileInfoTarget.className = "text-sm text-red-600 mt-2"
      this.submitBtnTarget.disabled = true
      return
    }

    const sizeMB = file.size / 1024 / 1024
    const sizeStr = sizeMB >= 1 ? sizeMB.toFixed(1) + " MB" : (file.size / 1024).toFixed(0) + " KB"
    this.fileInfoTarget.textContent = file.name + " (" + sizeStr + ")"
    this.fileInfoTarget.className = "text-sm text-green-600 mt-2"
    this.submitBtnTarget.disabled = false

    const dt = new DataTransfer()
    dt.items.add(file)
    this.inputTarget.files = dt.files
  }

  openFilePicker() {
    this.inputTarget.click()
  }

  submit() {
    if (!this.inputTarget.files.length) return
    this.dropzoneTarget.classList.add("hidden")
    this.fileInfoTarget.classList.add("hidden")
    this.submitBtnTarget.classList.add("hidden")
    this.processingTarget.classList.remove("hidden")
    this.element.querySelector("form").requestSubmit()
  }
}
