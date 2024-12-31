export const CoinFlip = {
  mounted() {
    const roomId = this.el.dataset.roomId;
    const streamId = this.el.dataset.streamId;
    const result = this.el.dataset.result;
    const finished = this.el.dataset.finished;

    this.initializeGame(roomId, streamId, result, finished);
  },
  updated() {
    const roomId = this.el.dataset.roomId;
    const streamId = this.el.dataset.streamId;
    const result = this.el.dataset.result;
    const finished = this.el.dataset.finished;
    
    this.initializeGame(roomId, streamId, result, finished);
  },

  initializeGame(roomId, streamId, result, finished) {
    const delay = (ms) => new Promise(resolve => setTimeout(resolve, ms));
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
      return;
    }
    
    if (finished === 'false' && (result === 'heads' || result === 'tails')) {
    startCountdown();

  }
  
  document.getElementById(`${streamId}-coin`).addEventListener('animationend', async () => {
    await delay(1000);
    this.pushEvent('animation-done', { room_id: roomId });
    console.log('animation done');
    });
  }
};