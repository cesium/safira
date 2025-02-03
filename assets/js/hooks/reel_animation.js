const rotationSpeed = 100
const extraTime = 1000
const iconSize = 79

export const ReelAnimation = {
  mounted() {
    const numIcons = this.el.dataset.numIcons
    this.positions = Array(3).fill(0)
    this.absolutePositions = Array(3).fill(0)
    this.rotations = Array(3).fill(0)
    this.isRolling = false
    
    this.handleEvent("roll_reels", ({ multiplier, target }) => {
      if (this.isRolling) {
        console.warn("Roll already in progress, skipping")
        return
      }
      
      this.isRolling = true
      const reelsList = document.querySelectorAll(".slots-container > .reel-slot")
      const promises = []

      for (let i = 0; i < reelsList.length; i++) {
        if (!reelsList[i]) {
          console.error(`Reel ${i} not found`)
          continue
        }
        promises.push(this.roll(reelsList[i], i, target[i]))
      }

      Promise.all(promises)
        .then(() => {
          this.pushEvent("roll_complete", { positions: this.positions })
        })
        .catch(err => {
          console.error("Roll failed:", err)
          this.pushEvent("roll_error", { error: err.message })
        })
        .finally(() => {
          this.isRolling = false
        })
    })
  },

  roll(reel, reelIndex, target) {
    return new Promise((resolve, reject) => {
      try {
        const style = window.getComputedStyle(reel)
        const backgroundImage = style.backgroundImage
        if (!backgroundImage) {
          throw new Error(`No background image for reel ${reelIndex}`)
        }
        
        const numImages = backgroundImage.split(',').length
        const minSpins = reelIndex + 2
        const currentPos = this.absolutePositions[reelIndex]
        const currentIcon = Math.floor((currentPos / iconSize) % numImages)
        
        const reversedTarget = numImages - target
        let distance = reversedTarget - currentIcon
        if (distance <= 0) {
          distance += numImages
        }

        const spinsInPixels = minSpins * numImages * iconSize
        const targetPixels = distance * iconSize
        const delta = spinsInPixels + targetPixels
        const newPosition = currentPos + delta
        
        // Clear previous transition
        reel.style.transition = 'none'
        reel.offsetHeight // Force reflow
        
        setTimeout(() => {
          const duration = (8 + delta/iconSize) * rotationSpeed
          const transitions = Array(numImages).fill(`background-position-y ${duration}ms cubic-bezier(.41,-0.01,.63,1.09)`)
          const positions = Array.from({length: numImages}, (_, index) => {
            const initialOffset = index * iconSize
            return `${newPosition + initialOffset}px`
          })
              
          reel.style.transition = transitions.join(', ')
          reel.style.backgroundPositionY = positions.join(', ')
        }, reelIndex * 150)


        setTimeout(() => {
          // Clear transition after animation
          reel.style.transition = 'none'
          this.absolutePositions[reelIndex] = newPosition
          // Also adjust the final position calculation
          this.positions[reelIndex] = numImages - Math.floor((newPosition / iconSize) % numImages)
          this.rotations[reelIndex]++
          resolve()
        }, (8 + delta/iconSize) * rotationSpeed + reelIndex * 150 + extraTime)
      } catch (err) {
        reject(err)
      }
    })
  }
}