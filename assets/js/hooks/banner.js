export const Banner = {
  mounted() {
    bannerLogic(this.el, new Date(banner.getAttribute("data-end")));
  },
  updated() {
    bannerLogic(this.el, new Date(banner.getAttribute("data-end")));
  }
};
function bannerLogic(banner, endTime) {      
  banner.style.transition = "top 0.5s ease-in-out";
  banner.style.top = "0";
  // Hide the banner after the duration
  setTimeout(() => {
    banner.style.transition = "top 0.5s ease-in-out";
    banner.style.top = "-100px";
  }, (endTime - Date.now()));
  const countdownElement = banner.querySelector("#timer-countdown");
  // Update banner timer
  countdownInterval = setInterval(() => {
    const now = Date.now();
    const secondsLeft = Math.round((endTime - now) / 1000);
    if (secondsLeft >= 0) {
      countdownElement.textContent = formatTime(secondsLeft);
    } 
  }, 100);
}
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