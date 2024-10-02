export const Countdown = {
    mounted() {
        const timeReceived = (start_time) => {
            if(this.clock !== undefined) {
                clearInterval(this.clock);
            }

            this.clock = setInterval(() => {
                const now = new Date().getTime();
                const seconds_left = Math.round((start_time - now) / 1000);
                const text_element = document.getElementById("seconds-remaining");

                if(seconds_left >= 0) {
                    text_element.innerHTML = formatTimeRemaining(seconds_left);
                } else {
                    text_element.innerText = "00";
                    clearInterval(this.clock);
                    window.location.reload();
                }
            }, 1000);
        };

        window.addEventListener("phx:highlight", (e) => 
            timeReceived(new Date(e.detail.start_time).getTime()));
    }
}

function formatTimeRemaining(seconds) {
    // Calculate days, hours, minutes, and seconds
    const days = Math.floor(seconds / (24 * 60 * 60)); // Calculate total days
    seconds %= 24 * 60 * 60; // Get remaining seconds after extracting days
    const hours = Math.floor(seconds / 3600); // Calculate hours
    seconds %= 3600; // Get remaining seconds after extracting hours
    const minutes = Math.floor(seconds / 60); // Calculate minutes
    const remainingSeconds = seconds % 60; // Remaining seconds

    // Format hours, minutes, and seconds to always be two digits
    const formattedHours = String(hours).padStart(2, '0');
    const formattedMinutes = String(minutes).padStart(2, '0');
    const formattedSeconds = String(remainingSeconds).padStart(2, '0');

    if(days > 0)
        return `${days} days, ${formattedHours}:${formattedMinutes}:${formattedSeconds}`;

    if(hours > 0)
        return `${formattedHours}:${formattedMinutes}:${formattedSeconds}`;  
    
    if(minutes > 0)
        return `${formattedMinutes}:${formattedSeconds}`;

    return `${seconds}`;
}