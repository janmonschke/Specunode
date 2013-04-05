View          = require './view'
FieldView     = require './field_view'
ControlsView  = require './controls_view'
StatsView     = require './stats_view'
Field         = require 'models/field'

class MultiplayerGameView extends View

  className: 'game'

  template: require('./templates/game')

  initialize: ->
    application.socket.on 'game_start', @initializeGame
    application.socket.on 'field_changed', @updateField
    application.socket.on 'you_won', @youWon
    application.socket.on 'you_lost', @youLost

  initializeGame: (data) =>
    @$('.status').remove()

    @model.field = new Field data.field
    @model.playerIndex = data.playerIndex

    # create the field subview
    @fv = @subView new FieldView 
      model: @model.field
      el: '.field .content'
    @fv.render()

    # create the controls subview
    @cv = @subView new ControlsView 
      model: @model
      el: '.controls'
    @cv.render()

    @sv = @subView new StatsView
      model: @model
      el: '.stats'
    @sv.render()

  updateField: (fieldData) =>
    @model.nextPlayer = if @model.nextPlayer is 0 then 1 else 0
    @model.field.set fieldData

  youWon: (reason) =>
    alert "You won! Reason: #{reason}"
    Backbone.trigger 'you_won'
    @cv.remove()

  youLost: =>
    alert "You lost!"
    Backbone.trigger 'you_lost'
    @cv.remove()

  getRenderData: ->
    data = super
    data.mode = @model.field.get 'mode'
    data

  remove: ->
    application.socket.removeAllListeners 'game_start'
    application.socket.removeAllListeners 'field_changed'
    application.socket.removeAllListeners 'you_won'
    application.socket.removeAllListeners 'you_lost'

    super

module.exports = MultiplayerGameView