View  = require './view'
Field = require '/models/field'

class FieldView extends View
  maxFieldWidth: 460
  
  template: require('./templates/field')

  initialize: ->
    @listenTo @model, 'change', @updateField
    $(window).on 'resize', @render

  afterRender: ->
    fieldWidth = Math.min $('.container').width(), @maxFieldWidth
    width = @model.get('width')
    height = @model.get('height')
    size = Math.floor fieldWidth / width
    colorsEl = @$('.colors')
    colorsEl.width fieldWidth
    colors = @model.get('colors')
    possessions = @model.get('possessions')

    for y in [0...height]
      for x in [0...width]
        color = if possessions[y][x] isnt Field.free then "player#{possessions[y][x]}" else "color#{colors[y][x]}"
        colorsEl.append "<div class='color #{color}' style='width:#{size}px; height:#{size}px;'>"

    vconsole.log "color-elements in the DOM: #{@$('.color').length}"

  updateField: =>
    vconsole.log 'FieldView#updateField'
    width = @model.get('width')
    height = @model.get('height')
    colorElements = @$('.color')
    colorRegex = /color[\d]+/
    possessions = @model.get('possessions')

    for y in [0...height]
      for x in [0...width]
        # get the current element
        element = colorElements.eq y * height + x
        # check if the field is still free
        matches = element.attr('class').match(colorRegex)
        # only check for color fields and not for player fields
        if matches? and possessions[y][x] isnt Field.free
          # remove the color
          element.removeClass matches[0]
          # add the owner's color
          element.addClass "player#{possessions[y][x]}"

    @

  destroy: ->
    $(window).off 'resize', @render
    super

module.exports = FieldView