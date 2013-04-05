Model = require './model'
Field = require './field'

class Game extends Model

  initialize: ->
    super
    @nextPlayer = 0
    @field = new Field()

  colorPicked: (color, playerIndex) ->
    if @get('mode') == 'multi'
      application.socket.emit 'pick_color', color      
    else
      @field.playerPicked playerIndex, color

module.exports = Game