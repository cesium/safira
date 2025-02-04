import JSZip from "../../vendor/jszip"

export const ZipUpload = {
    mounted() {
        this.el.addEventListener("input", e => {
            e.preventDefault()
            let zip = new JSZip()
            Array.from(e.target.files).forEach(file => {
              zip.file(file.webkitRelativePath || file.name, file, {binary: true})
            })
            zip.generateAsync({type: "blob"}).then(blob => this.upload("dir", [blob]))
          })
    }
}