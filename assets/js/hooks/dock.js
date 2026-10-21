export const Dock = {
  mounted() {
    const current = this.el.dataset.active || "";
    const previous = sessionStorage.getItem("dock-active");
    sessionStorage.setItem("dock-active", current);

    if (!current || !previous || previous === current) return;

    this.el.style.setProperty("--dock-active", previous);

    const slide = () => {
      if (!this.el.isConnected) return requestAnimationFrame(slide);

      this.el.offsetWidth;
      this.el.style.setProperty("--dock-active", current);
    };

    slide();
  }
};
