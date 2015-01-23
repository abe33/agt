unless Object.getPropertyDescriptor?
  if Object.getPrototypeOf? and Object.getOwnPropertyDescriptor?
    Object.getPropertyDescriptor = (o, name) ->
      proto = o
      descriptor = undefined
      proto = Object.getPrototypeOf?(proto) or proto.__proto__ while proto and not (descriptor = Object.getOwnPropertyDescriptor(proto, name))
      descriptor
  else
    Object.getPropertyDescriptor = -> undefined

Object.NO_DEFINE_PROPERTY = not Object.defineProperty?

if Object.defineProperty?
  try
    Object.defineProperty(Array.prototype,'test', value: 'test')
  catch e
    Object.NO_DEFINE_PROPERTY = true
