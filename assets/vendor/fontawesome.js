const plugin = require("tailwindcss/plugin")
const fs = require('fs')
const path = require('path')

module.exports = plugin(function({ matchComponents, theme }) {
  let iconsDir = path.join(__dirname, "../../deps/fontawesome/svgs")
  let values = {}
  let icons = [
    ["", "", "/regular"],
    ["-solid", "", "/solid"],
    ["", "brand-", "/brands"]
  ]
  
  icons.forEach(([suffix, prefix, dir]) => {
    fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
      let name = prefix + path.basename(file, ".svg") + suffix
      values[name] = { name, fullPath: path.join(iconsDir, dir, file) }
    })
  })
  
  matchComponents({
    "fa": ({ name, fullPath }) => {
      let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
      return {
        [`--fa-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
        "-webkit-mask": `var(--fa-${name})`,
        "mask": `var(--fa-${name})`,
        "mask-repeat": "no-repeat",
        "background-color": "currentColor",
        "vertical-align": "middle",
        "display": "inline-block",
        "width": theme("spacing.5"),
        "height": theme("spacing.5")
      }
    }
  }, { values })
})