View  = require './view'

class GameOverView extends View
  
  initialize: ->
    super

    if @model.field.get 'mode' is 'single'
      @template = require './templates/navigation'

module.exports = GameOverView