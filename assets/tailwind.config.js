const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")
const colors = require("tailwindcss/colors");

module.exports = {
  //darkMode: "selector",
  content: [
    "./js/**/*.js",
    "../lib/safira_web.ex",
    "../lib/safira_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        primary: "#04041C",
        accent: "#ffdb0d",
        light: "#ffffff",
        lightMuted: "#a1a1aa",
        lightShade: "#e5e7eb",
        dark: "#09090b",
        darkMuted: "#71717a",
        darkShade: "#27272a",
        secondary: colors.sky,
        success: colors.green,
        danger: colors.red,
        warning: colors.yellow,
        info: colors.blue,
        gray: colors.gray
      },
      fontFamily: {
        terminal: ["Terminal"],
        iregular: ["Inter-Regular"]
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    }),

    // Embeds FontAwesome icons (https://fontawesome.com/) into app.css bundle
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/fontawesome/svgs")
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
  ]
}