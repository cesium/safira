export const ScratchCard = {
  mounted() { 
    this.scratchArea = document.getElementById("scratch-area");
    if (!this.scratchArea) return;

    this.context = this.scratchArea.getContext("2d");
    this.scratchAreaWidth = this.scratchArea.width;
    this.scratchAreaHeight = this.scratchArea.height;

    this.isScratching = false;
    this.gameEnded = false;
    this.canScratch = false;
    this.card_id = null;

    this.initializeCard();
    this.setupEventListeners();
    this.updateTouchAction();

    this.handleEvent("scratch-card", ({card_id}) => {
      this.card_id = card_id;
      this.startGame();
    })

    this.handleEvent("clear-card", () => {
      this.resetCard();
    })
  },

  startGame() {
    this.gameEnded = false;
    this.canScratch = true;
    this.updateTouchAction();
    this.resetCard();
  },

  endGame() {
    if (this.gameEnded) return;
    this.gameEnded = true;
    this.canScratch = false;
    this.updateTouchAction();
    
    this.scratchArea.style.opacity = "0";
    
    this.pushEvent("scratch-completed", {card_id: this.card_id});
  },

  initializeCard() {
    this.drawCover();
  },

  resetCard() {
    this.drawCover();
    this.scratchArea.style.opacity = "1";
  },

  updateTouchAction() {
    this.scratchArea.style.touchAction = this.canScratch ? "none" : "auto";
  },

  // Scratch-off foil: Safira's accent with subtle diagonal stripes
  drawCover() {
    const ctx = this.context;
    const width = this.scratchAreaWidth;
    const height = this.scratchAreaHeight;

    ctx.globalCompositeOperation = "source-over";
    ctx.clearRect(0, 0, width, height);

    ctx.fillStyle = "#ffdb0d";
    ctx.fillRect(0, 0, width, height);

    ctx.strokeStyle = "rgba(4, 4, 28, 0.08)";
    ctx.lineWidth = 6;
    for (let x = -height; x < width; x += 18) {
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x + height, height);
      ctx.stroke();
    }
  },

  scratchPoint(x, y) {
    this.context.globalCompositeOperation = "destination-out"
    this.context.beginPath();
    this.context.arc(x, y, 30, 0, 2*Math.PI);
    this.context.fill();
  },

  setupEventListeners() {

    this.scratchArea.addEventListener("pointerdown", (event) => {
      if (!this.canScratch) return;
      this.isScratching = true;
      this.scratchPoint(event.offsetX, event.offsetY);
    })

    this.scratchArea.addEventListener("pointermove", (event) => {
      if (!this.canScratch) return;
      if (this.isScratching) {
        this.scratchPoint(event.offsetX, event.offsetY);
      }
    })

    this.scratchArea.addEventListener("pointerup", () => {
      if (!this.canScratch) return;
      this.isScratching = false;
      this.checkScratchedPercentage();
    })

     this.scratchArea.addEventListener("pointerleave", () => {
      this.isScratching = false;
    })
  },

  checkScratchedPercentage() {
    const imageData = this.context.getImageData(0, 0, this.scratchAreaWidth, this.scratchAreaHeight);
    const pixelData = imageData.data;

    let scratchedPixelCount = 0;
    const totalPixels = pixelData.length / 4;

    for (let i = 0; i < pixelData.length; i += 4) {
      const alpha = pixelData[i + 3];

      if (alpha === 0) {
        scratchedPixelCount++;
      }
    }

    const scratchedPercentage = (scratchedPixelCount / totalPixels) * 100;
    
    if (scratchedPercentage >= 80) {
      this.endGame();
    }
  },

};