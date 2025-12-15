import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]
  static values = {
    timeout: { type: Number, default: 1500 }
  }

  connect() {
    this.dismissTimers = new WeakMap()
    this.messageTargets.forEach((element, index) => this.startTimer(element, index))
  }

  disconnect() {
    if (!this.dismissTimers) return
    this.messageTargets.forEach((element) => this.clearTimer(element))
  }

  messageTargetConnected(element) {
    const index = this.messageTargets.indexOf(element)
    this.startTimer(element, index)
  }

  messageTargetDisconnected(element) {
    this.clearTimer(element)
  }

  dismiss(element) {
    if (!element) return

    element.classList.add("opacity-0", "translate-y-1", "scale-[0.99]")
    element.style.transitionProperty = "opacity, transform"
    setTimeout(() => element.remove(), 220)
  }

  startTimer(element, index = 0) {
    if (!this.dismissTimers) this.dismissTimers = new WeakMap()
    this.clearTimer(element)
    const timer = setTimeout(() => this.dismiss(element), this.timeoutValue + index * 150)
    this.dismissTimers.set(element, timer)
  }

  clearTimer(element) {
    if (!this.dismissTimers?.has(element)) return
    clearTimeout(this.dismissTimers.get(element))
    this.dismissTimers.delete(element)
  }
}
