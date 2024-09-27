import "../../vendor/confetti.js";

export const Confetti = {
    mounted() {
        const jsConfetti = new JSConfetti();
        if(this.el.dataset.is_win != undefined) {
            jsConfetti.addConfetti({
                confettiColors: ["#ff800d", "#fc993f"],
                confettiRadius: 6
            });
        }
    }
}