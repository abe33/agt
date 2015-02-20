
widgets = require 'agt/widgets'

widgets 'form', 'form[data-action]', {
  on: 'load'
  login: (form, action) ->
    console.log form, action
}
