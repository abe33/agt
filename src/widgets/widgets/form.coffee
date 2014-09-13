
agt.widgets.define 'form', (form, options={}) ->
  formAction = form.getAttribute('data-action')

  unless options[formAction]?
    throw new Error "Can't find action for `#{formAction}`"

  queryFields = '''
    input:not([type=submit]):not([type=reset]),
    textarea,
    select
  '''
  queryActions = 'input[type=submit], input[type=reset], button, a'

  fields = document.querySelectorAll(queryFields)
  actions = document.querySelectorAll(queryActions)

  Array::forEach.call fields, (field) ->
    # TODO create a field object for each input

  Array::forEach.call actions, (trigger) ->
    action = trigger.getAttribute('type') ? trigger.getAttribute('value')

    trigger.addEventListener 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()

      options[formAction](form, action)
