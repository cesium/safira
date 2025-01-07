export const Timer = {
    mounted() {
        const finishTime = parseInt(this.el.dataset.finishTime, 10);
        const timerElement = this.el;

        const updateTimer = () => {
            const now = Math.floor(Date.now() / 1000);
            const remainingTime = Math.max(0, finishTime - now);

            if (remainingTime <= 0) {
                clearInterval(timerInterval);
                timerElement.textContent = "00:00:00";
                this.pushEvent("on_spotlight_end", {}); 
                return;
            }

            const hours = Math.floor(remainingTime / 3600);
            const minutes = Math.floor((remainingTime % 3600) / 60);
            const seconds = remainingTime % 60;

            timerElement.textContent = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
        };

        const timerInterval = setInterval(updateTimer, 1000);
        updateTimer(); 

        this.cleanup = () => {
            clearInterval(timerInterval);
        };
    },

    destroyed() {
        this.cleanup();
    },
};
