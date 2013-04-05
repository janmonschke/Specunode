View  = require './view'

class ControlsView extends View
  template: require './templates/controls'

  events:
    'click td': 'colorSelected'
    'touchend td': 'colorTouched'

  initialize: ->
    # set the playerIndex. defaults to 0 if not set
    @playerIndex = @model.playerIndex or 0
    @currentColor = 0

    @listenTo @model.field, 'over', @remove

  colorSelected: (event) ->
    event.preventDefault()
    event.stopPropagation()
    
    # read out the picked color from the element
    el = $ event.currentTarget
    colorPicked = el.data 'color'
    @currentColor = colorPicked
    
    # select the currently selected color
    @select()

    if window.isWebTV
      $('.active').removeClass 'active'
      $(event.currentTarget).addClass 'active'

    false

  # proxy touches to the selected method: touchend is faster than click
  colorTouched: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @colorSelected event

    false

  select: ->
    vconsole.log "ControlsView#select -> #{@currentColor}"
    @model.colorPicked @currentColor, @playerIndex

  afterRender: ->
    if window.isWebTV
      @activateTVControls()

  activateTVControls: ->
    # debounce the navigation keys to prevent rendering bugs
    @navigateRight = _.debounce @navigateRight, 200
    @navigateLeft = _.debounce @navigateLeft, 200
    
    @$('.color0').addClass 'active'
    
    $(document).on 'keydown', @keyHandler

  keyHandler: (event) =>
    key = event.keyCode

    if key is 39 or key is 38 or key is 5       # right
      @navigateRight()
    else if key is 37 or key is 40 or key is 4  # left
      @navigateLeft()
    else if key is 13 or key is 29443           # enter + submit-button
      @select()
    else
      return # do nothing, don't even stop the event propagation

    # is only called if a key input was handled
    event.stopPropagation()

  navigateLeft: ->
    @currentColor--
    @currentColor = if @currentColor < 0 then 4 else @currentColor
    
    vconsole.log 'ControlsView#navigateLeft ' + @currentColor

    if window.isWebTV
      $('.active').removeClass 'active'
      $('.color' + @currentColor).addClass 'active'
    
  navigateRight: ->
    @currentColor++
    @currentColor = if @currentColor > 4 then 0 else @currentColor
    
    vconsole.log 'ControlsView#navigateRight ' + @currentColor
    
    if window.isWebTV
      $('.active').removeClass 'active'
      $('.color' + @currentColor).addClass 'active'

  remove: ->
    $(document).off 'keydown', @keyHandler
    super

module.exports = ControlsView