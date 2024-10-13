export const Wheel = {
    mounted() {
        this.handleEvent("spin-wheel", data => {
            rotateWheel(this.el.querySelector("#wheel"), 3400, 5, () => {
                this.pushEventTo(this.el, "get-prize", {});
            })
            rotateWheel(this.el.querySelector("#arrow"), -3400, 5)
        });
    }
}

function rotateWheel(element, speed, duration, callback) {
    let start = null;
    duration *= 1000;
    const totalRotations = (speed / 1000) * 360; // Total degrees to rotate based on speed
    const randomFinalRotation = Math.random() * 360; // Choose a random angle between 0 and 360

    // Easing function (ease-out)
    function easeOut(t) {
        return 1 - Math.pow(1 - t, 3);
    }

    function rotate(timestamp) {
        if (!start) start = timestamp;
        const elapsed = timestamp - start;
        const progress = Math.min(elapsed / duration, 1); // Normalize to a value between 0 and 1

        // Apply easing
        const easedProgress = easeOut(progress);

        // Calculate the current rotation with easing and add the random final angle
        const rotation = easedProgress * totalRotations + easedProgress * randomFinalRotation;

        // Apply the rotation to the element
        element.style.transform = `rotate(${rotation % 360}deg)`;

        if (elapsed < duration) {
            requestAnimationFrame(rotate);
        } else {
            element.style.transform = `rotate(${(totalRotations + randomFinalRotation) % 360}deg)`;
            if (callback) callback();
        }
    }

    requestAnimationFrame(rotate);
}