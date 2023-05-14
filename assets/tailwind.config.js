// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

let plugin = require('tailwindcss/plugin')

module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {},
  },
  plugins: [
    // require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('daisyui'),
    plugin(({ addVariant }) => addVariant('phx-no-feedback', ['&.phx-no-feedback', '.phx-no-feedback &'])),
    plugin(({ addVariant }) => addVariant('phx-click-loading', ['&.phx-click-loading', '.phx-click-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-submit-loading', ['&.phx-submit-loading', '.phx-submit-loading &'])),
    plugin(({ addVariant }) => addVariant('phx-change-loading', ['&.phx-change-loading', '.phx-change-loading &']))
  ],
  daisyui: {
    themes: [
      {
        cupcake: removeThemeVariables(require("daisyui/src/colors/themes")["[data-theme=cupcake]"]),
        dracula: removeThemeVariables(require("daisyui/src/colors/themes")["[data-theme=dracula]"]),
      }
    ]
  },
  safelist: [
    'bg-primary', 'text-primary-content', 'hover:bg-primary-focus',
    'bg-secondary', 'text-secondary-content', 'hover:bg-secondary-focus',
    'bg-accent', 'text-accent-content', 'hover:bg-accent-focus',
    'bg-neutral', 'text-neutral-content', 'hover:bg-neutral-focus',
    'bg-base-200', 'text-base-content', 'hover:bg-base-300',
  ]
}

function removeThemeVariables(theme) {
  return Object.entries(theme).reduce((theme, [key, value]) => key.startsWith('--') ? theme : { ...theme, [key]: value }, {})
}