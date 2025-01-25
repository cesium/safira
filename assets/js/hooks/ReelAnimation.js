const rotationSpeed = 100
const extraTime = 1000
const numIcons = 9
const iconSize = 79

export const ReelAnimation = {
  mounted() {
    this.positions = Array(3).fill(0)
    this.absolutePositions = Array(3).fill(0)
    this.rotations = Array(3).fill(0)
    
    this.handleEvent("roll_reels", ({ multiplier, target }) => {
      const reelsList = document.querySelectorAll(".slots-container > .reel-slot")
      const promises = []

      for (let i = 0; i < reelsList.length; i++) {
        promises.push(this.roll(reelsList[i], i, target[i]))
      }

      Promise.all(promises).then(() => {
        this.pushEvent("roll_complete", { positions: this.positions })
      })
    })
  },

  roll(reel, reelIndex, target) {
    const minSpins = reelIndex + 2
    const currentPos = this.absolutePositions[reelIndex]
    const currentIcon = Math.floor((currentPos / iconSize) % numIcons)
    
    // Calculate forward distance to target
    let distance = target - currentIcon
    if (distance <= 0) {
      distance += numIcons
    }

    const spinsInPixels = minSpins * numIcons * iconSize
    const targetPixels = distance * iconSize
    const delta = spinsInPixels + targetPixels
    
    return new Promise((resolve) => {
      const newPosition = currentPos + delta
      
      setTimeout(() => {
        const style = window.getComputedStyle(reel)
        const backgroundImage = style.backgroundImage
        const numImages = backgroundImage.split(',').length
                
        const duration = (8 + delta/iconSize) * rotationSpeed
        const transitions = Array(numImages).fill(`background-position-y ${duration}ms cubic-bezier(.41,-0.01,.63,1.09)`)
        
        // Use Array.from to ensure proper array creation and mapping
        const positions = Array.from({length: numImages}, (_, index) => {
          const initialOffset = index * iconSize
          return `${newPosition + initialOffset}px`
        })
            
        reel.style.transition = transitions.join(', ')
        reel.style.backgroundPositionY = positions.join(', ')
      }, reelIndex * 150)

      setTimeout(() => {
        this.absolutePositions[reelIndex] = newPosition
        this.positions[reelIndex] = Math.floor((newPosition / iconSize) % numIcons)
        this.rotations[reelIndex]++
        resolve()
      }, (8 + delta/iconSize) * rotationSpeed + reelIndex * 150 + extraTime)
    })
}
}