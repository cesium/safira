export const Banner = {
  mounted() {
    const banner = this.el;

    if (banner) {
      const duration = parseInt(banner.getAttribute("data-duration"), 10) || 5000;

      banner.style.transition = "top 0.5s ease-in-out";
      banner.style.top = "0";

      setTimeout(() => {
        banner.style.transition = "top 0.5s ease-in-out";
        banner.style.top = "-100px";
      }, duration*100);
    }
  }
};
