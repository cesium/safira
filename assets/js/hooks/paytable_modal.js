export const PaytableModal = {
  mounted() {
    // For every payline group in the modal, cycle through its items every second.
    let groups = this.el.querySelectorAll(".payline-group");
    groups.forEach((group) => {
      let items = group.querySelectorAll(".payline-item");
      if (items.length <= 1) return;
      let idx = 0;
      setInterval(() => {
        items[idx].classList.add("hidden");
        idx = (idx + 1) % items.length;
        items[idx].classList.remove("hidden");
      }, 1000);
    });
  }
};