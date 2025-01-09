export const Countdown = {
    mounted() {
        let countdownInterval = null;

        const startCountdown = (startTime) => {
            if (countdownInterval) {
                clearInterval(countdownInterval);
            }

            const textElement = document.getElementById("seconds-remaining");
            if (!textElement) {
                console.warn("Countdown element not found!");
                return;
            }

            countdownInterval = setInterval(() => {
                const now = Date.now();
                const secondsLeft = Math.round((startTime - now) / 1000);

                if (secondsLeft >= 0) {
                    textElement.textContent = formatTime(secondsLeft);
                } else {
                    clearInterval(countdownInterval);
                    textElement.textContent = "00";
                    window.location.reload();
                }
            }, 100);
        };

        window.addEventListener("phx:highlight", (e) => {
            const startTime = new Date(e.detail.start_time).getTime();
            startCountdown(startTime);
        });
    }
};

function formatTime(totalSeconds) {
    const dayToSeconds = 86400;
    const days = Math.floor(totalSeconds / dayToSeconds);
    const hours = Math.floor((totalSeconds % dayToSeconds) / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    const formattedTime = [
        days > 0 ? `${days} days` : null,
        `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`
    ].filter(Boolean).join(", ");

    return formattedTime;
}