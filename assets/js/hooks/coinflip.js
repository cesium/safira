const ANIMATION_DELAYS = {
  RESULT_DISPLAY: 500,
  ANIMATION_DONE: 1000,
  COUNTDOWN: 1000
};

const GAME_STATES = {
  HEADS: 'heads',
  TAILS: 'tails',
  FINISHED: 'true'
};

const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

export const CoinFlip = {
  mounted() {
    this.initializeFromDOM();
    this.setupEventListeners();
  },

  updated() {
    this.initializeFromDOM();
  },

  initializeFromDOM() {
    const data = this.getGameData();
    this.initializeGame(data);
  },

  getGameData() {
    const { dataset } = this.el;
    return {
      roomId: dataset.roomId,
      streamId: dataset.streamId,
      result: dataset.result,
      finished: dataset.finished,
      player1Id: dataset.player1Id,
      player2Id: dataset.player2Id,
      fee: dataset.fee
    };
  },

  setupEventListeners() {
    const { streamId, roomId } = this.getGameData();
    const coin = document.getElementById(`${streamId}-coin`);
    
    coin.addEventListener("animationend", async () => {
      const { player1Id, player2Id, fee, result } = this.getGameData();
      
      await delay(ANIMATION_DELAYS.RESULT_DISPLAY);
      this.updateBetDisplay(streamId, player1Id, player2Id, fee, result);
      
      await delay(ANIMATION_DELAYS.ANIMATION_DONE);
      this.pushEvent("animation-done", { room_id: roomId });
    });
  },

  initializeGame({ player1Id, player2Id, streamId, fee, result, finished }) {
    const elements = this.getGameElements(streamId);
    this.hideInitialElements(elements);

    if (finished === GAME_STATES.FINISHED) {
      this.handleFinishedGame(elements, result);
      this.updateBetDisplay(streamId, player1Id, player2Id, fee, result);
      return;
    }

    if (finished === 'false' && (result === GAME_STATES.HEADS || result === GAME_STATES.TAILS)) {
      this.startCountdown(elements, result);
    }
  },

  getGameElements(streamId) {
    return {
      coin: document.getElementById(`${streamId}-coin`),
      counter: document.getElementById(`${streamId}-countdown`),
      vsText: document.getElementById(`${streamId}-vs-text`)
    };
  },

  hideInitialElements({ coin, counter, vsText }) {
    coin.style.display = "none";
    counter.style.display = "none";
  },

  async startCountdown({ vsText, counter, coin }, result) {
    vsText.style.display = "none";
    counter.style.display = "flex";

    for (let i = 3; i > 0; i--) {
      counter.textContent = i.toString();
      counter.classList.add("countdown-animation");
      await delay(ANIMATION_DELAYS.COUNTDOWN);
      counter.classList.remove("countdown-animation");
    }

    counter.style.display = "none";
    coin.style.display = "block";
    coin.classList.add(result);
  },

  handleFinishedGame({ vsText, counter, coin }, result) {
    vsText.style.display = "none";
    counter.style.display = "none";
    coin.style.display = "block";

    if (result === GAME_STATES.HEADS) {
      coin.children[1].hidden = true;
    } else {
      coin.children[0].hidden = true;
      coin.children[1].style.transform = "rotateY(0deg)";
    }
  },

  updateBetDisplay(streamId, player1Id, player2Id, fee, result) {
    const elements = {
      player1: {
        card: document.getElementById(`${streamId}-${player1Id}-card`),
        bet: document.getElementById(`${streamId}-${player1Id}-bet`)
      },
      player2: {
        card: document.getElementById(`${streamId}-${player2Id}-card`),
        bet: document.getElementById(`${streamId}-${player2Id}-bet`)
      }
    };

    if (!elements.player1.bet || !elements.player2.bet) {
      console.error("Bet elements not found");
      return;
    }

    const calculateWinnings = (bet) => Math.floor(bet * 2 * (1 - fee));

    if (result === GAME_STATES.HEADS) {
      elements.player2.card.classList.add("gray-overlay");
      elements.player1.bet.textContent = calculateWinnings(elements.player1.bet.dataset.bet);
      elements.player2.bet.textContent = `-${elements.player2.bet.dataset.bet}`;
      elements.player2.bet.classList.add("text-red-500");
    } else {
      elements.player1.card.classList.add("gray-overlay");
      elements.player1.bet.textContent = `-${elements.player1.bet.dataset.bet}`;
      elements.player1.bet.classList.add("text-red-500");
      elements.player2.bet.textContent = calculateWinnings(elements.player2.bet.dataset.bet);
    }
  }
};