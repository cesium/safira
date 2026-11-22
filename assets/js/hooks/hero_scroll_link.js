export const HeroScrollLink = {
  mounted() {
    this.el.addEventListener("click", e => {
      const target = document.querySelector(this.el.getAttribute("href"))
      if (!target) return
      e.preventDefault()
      target.scrollIntoView({ behavior: "smooth" })
    })

    const hero = document.getElementById("hero")
    if (!hero) return
    this.observer = new IntersectionObserver(
      ([entry]) => {
        this.el.toggleAttribute("data-hidden", !entry.isIntersecting)
        this.el.inert = !entry.isIntersecting
      },
      { rootMargin: "-2px 0px -50% 0px" }
    )
    this.observer.observe(hero)
  },

  destroyed() {
    this.observer?.disconnect()
  }
}
