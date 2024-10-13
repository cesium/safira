import Sortable from "../../vendor/sortable";

export const Sorting = {
    mounted() {
        const placeholder = document.createElement('div');
        new Sortable(this.el, {
          animation: 150,
          ghostClass: "opacity-20",
          dragClass: "shadow-2xl",
          handle: ".handle",
          onEnd: () => {
            const elements = Array.from(this.el.children)
            const ids = elements.map(elm => elm.id)
            this.pushEventTo(this.el, "update-sorting", {ids: ids})
          },
          setData: (dataTransfer, _) => {
            dataTransfer.setDragImage(placeholder, 0, 0);
          }
        })
      }
}