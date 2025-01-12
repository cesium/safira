const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));

export const CoinFlip = {
  mounted() {
    const roomId = this.el.dataset.roomId;
    const streamId = this.el.dataset.streamId;
    const result = this.el.dataset.result;
    const finished = this.el.dataset.finished;
    const player1Id = this.el.dataset.player1Id;
    const player2Id = this.el.dataset.player2Id;
    const fee = this.el.dataset.fee;
    
    
    document.getElementById(`${streamId}-coin`).addEventListener('animationend', async (event) => {
      const player2Id = this.el.dataset.player2Id;
      const result = this.el.dataset.result;
      console.log('animation end');
      await delay(500);
      this.updateBetDisplay(streamId, player1Id, player2Id, fee, result);
      await delay(1000);
      this.pushEvent('animation-done', { room_id: roomId });
      console.log('animation done');
      console.log(event.animationName)
    });

    this.initializeGame(player1Id, player2Id, streamId, fee, result, finished);
  },
  updated() {
    const roomId = this.el.dataset.roomId;
    const streamId = this.el.dataset.streamId;
    const result = this.el.dataset.result;
    const finished = this.el.dataset.finished;
    const player1Id = this.el.dataset.player1Id;
    const player2Id = this.el.dataset.player2Id;
    const fee = this.el.dataset.fee;
    
    this.initializeGame(player1Id, player2Id, streamId, fee, result, finished);
  },
  
  initializeGame(player1Id, player2Id, streamId, fee, result, finished) {
    const coin = document.getElementById(`${streamId}-coin`);
    const counter = document.getElementById(`${streamId}-countdown`);
    coin.style.display = 'none';
    counter.style.display = 'none';

    const startCountdown = async () => {
      counter.style.display = 'flex';
      for (let i = 3; i > 0; i--) {
        counter.textContent = i.toString();
        counter.classList.add('countdown-animation');
        await delay(1000);
        counter.classList.remove('countdown-animation');
      };

      counter.style.display = 'none'
      coin.style.display = 'block';
    
      if (result === 'heads') {
        coin.classList.add('heads');
      } else {
        coin.classList.add('tails');
      }
      
    }
    
    if (finished === 'true') {
      counter.style.display = 'none';
      coin.style.display = 'block';
      if (result === 'heads') {
        coin.children[1].hidden = true;
      } else {
        coin.children[0].hidden = true;
        coin.children[1].style.transform = 'rotateY(0deg)';
      }
      this.updateBetDisplay(streamId, player1Id, player2Id, fee, result);
      return;
    }
    
    if (finished === 'false' && (result === 'heads' || result === 'tails')) {
    startCountdown();

    }
  },
  updateBetDisplay(streamId, player1Id, player2Id, fee, result) {
    const player1Card = document.getElementById(`${streamId}-${player1Id}-card`);
    const player1Bet = document.getElementById(`${streamId}-${player1Id}-bet`);
    const player2Card = document.getElementById(`${streamId}-${player2Id}-card`);
    const player2Bet = document.getElementById(`${streamId}-${player2Id}-bet`);

    if (!player1Bet || !player2Bet) {
      console.error('Bet elements not found');
      return;
    }

    if (result === 'heads') {
      player2Card.classList.add('gray-overlay');
      player1Bet.textContent = Math.round(player1Bet.dataset.bet * 2 * (1 - fee));
      // player1Bet.classList.add('text-green-500');
      player2Bet.textContent = `-${player2Bet.dataset.bet}`;
      player2Bet.classList.add('text-red-500');
    } else {
      player1Card.classList.add('gray-overlay');
      player1Bet.textContent = `-${player1Bet.dataset.bet}`;
      player1Bet.classList.add('text-red-500');
      player2Bet.textContent = Math.round(player2Bet.dataset.bet * 2 * (1 - fee));
      // player2Bet.classList.add('text-green-500');
    }
  }
};