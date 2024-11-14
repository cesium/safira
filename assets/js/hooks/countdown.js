export const Countdown = {
    mounted() {
        const timeReceived = (start_time) => {
            console.log(start_time);
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
            }, 100);
        };

        window.addEventListener("phx:highlight", (e) => {
            console.log("Highlight");
            timeReceived(new Date(e.detail.start_time).getTime())
        });
    }
}

function formatTimeRemaining(seconds) {
    const timeUnits = {
        days: Math.floor(seconds / (24 * 60 * 60)),
        hours: Math.floor((seconds % (24 * 60 * 60)) / 3600),
        minutes: Math.floor((seconds % 3600) / 60),
        seconds: seconds % 60
    };

    // Format units to two digits except for days
    const formattedTime = {
        hours: String(timeUnits.hours).padStart(2, '0'),
        minutes: String(timeUnits.minutes).padStart(2, '0'),
        seconds: String(timeUnits.seconds).padStart(2, '0')
    };

    if (timeUnits.days > 0) {
        return `${timeUnits.days} days, ${formattedTime.hours}:${formattedTime.minutes}:${formattedTime.seconds}`;
    }
    if (timeUnits.hours > 0) {
        return `${formattedTime.hours}:${formattedTime.minutes}:${formattedTime.seconds}`;
    }
    if (timeUnits.minutes > 0) {
        return `${formattedTime.minutes}:${formattedTime.seconds}`;
    }
    return `${timeUnits.seconds}`;
}