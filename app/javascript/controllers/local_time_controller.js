import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "time", "date", "datetime", "shortdate", "ago", "indays" ]

  #timer

  initialize() {
    this.timeFormatter = new Intl.DateTimeFormat(undefined, { timeStyle: "short" })
    this.dateFormatter = new Intl.DateTimeFormat(undefined, { dateStyle: "long" })
    this.shortDateFormatter = new Intl.DateTimeFormat(undefined, { month: "short", day: "numeric" })
    this.dateTimeFormatter = new Intl.DateTimeFormat(undefined, { timeStyle: "short", dateStyle: "short" })
    this.agoFormatter = new AgoFormatter()
    this.daysAgoFormatter = new DaysAgoFormatter()
    this.indaysFormatter = new InDaysFormatter()
  }

  connect() {
    this.#timer = setInterval(() => this.#refreshRelativeTimes(), 30_000)
  }

  disconnect() {
    clearInterval(this.#timer)
  }

  timeTargetConnected(target) {
    this.#formatTime(this.timeFormatter, target)
  }

  dateTargetConnected(target) {
    this.#formatTime(this.dateFormatter, target)
  }

  datetimeTargetConnected(target) {
    this.#formatTime(this.dateTimeFormatter, target)
  }

  shortdateTargetConnected(target) {
    this.#formatTime(this.shortDateFormatter, target)
  }

  agoTargetConnected(target) {
    this.#formatTime(this.agoFormatter, target)
  }

  daysAgoTargetConnected(target) {
    this.#formatTime(this.daysAgoFormatter, target)
  }

  indaysTargetConnected(target) {
    this.#formatTime(this.indaysFormatter, target)
  }

  #refreshRelativeTimes() {
    this.agoTargets.forEach(target => {
      this.#formatTime(this.agoFormatter, target)
    })
  }

  #formatTime(formatter, target) {
    const dt = new Date(target.getAttribute("datetime"))
    target.textContent = formatter.format(dt)
    target.title = this.dateTimeFormatter.format(dt)
  }
}

class AgoFormatter {
  format(dt) {
    const now = new Date()
    const seconds = (now - dt) / 1000
    const minutes = seconds / 60
    const hours = minutes / 60
    const days = hours / 24
    const weeks = days / 7
    const months = days / (365 / 12)
    const years = days / 365

    if (years >= 1) return this.#pluralize("year", years)
    if (months >= 1) return this.#pluralize("month", months)
    if (weeks >= 1) return this.#pluralize("week", weeks)
    if (days >= 1) return this.#pluralize("day", days)
    if (hours >= 1) return this.#pluralize("hour", hours)
    if (minutes >= 1) return this.#pluralize("minute", minutes)

    return "Less than a minute ago"
  }

  #pluralize(word, quantity) {
    quantity = Math.floor(quantity)
    const suffix = (quantity === 1) ? "" : "s"
    return `${quantity} ${word}${suffix} ago`
  }
}

class DaysAgoFormatter {
  format(dt) {
    const now = new Date()

    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const startOfGivenDay = new Date(dt.getFullYear(), dt.getMonth(), dt.getDate())

    const msPerDay = 1000 * 60 * 60 * 24
    const dayDiff = Math.floor((startOfToday - startOfGivenDay) / msPerDay)

    if (dayDiff === 0) return "Today"
    if (dayDiff === 1) return "Yesterday"
    return `in ${dayDiff} days`
  }
}

class InDaysFormatter {
  format(dt) {
    const target = this.#beginningOfDay(dt)
    const today = this.#beginningOfDay(new Date())
    const days = Math.round((target - today) / (1000 * 60 * 60 * 24))

    if (days <= 0) {
      return "today"
    }
    if (days === 1) {
      return "tomorrow"
    }

    return `in ${Math.round(days)} days`
  }

  #beginningOfDay(dt) {
    return new Date(dt.getFullYear(), dt.getMonth(), dt.getDate())
  }
}
