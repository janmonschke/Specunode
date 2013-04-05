View          = require './view'
FieldView     = require './field_view'
ControlsView  = require './controls_view'
GameOverView  = require './game_over_view'
StatsView     = require './stats_view'

class GameView extends View

  className: 'game'

  template: require('./templates/game')

  initialize: ->
    super

    # create the field subview
    @subView new FieldView 
      model: @model.field
      el: '.field .content'

    # create the controls subview
    @subView new ControlsView 
      model: @model
      el: '.controls'

    @subView new StatsView
      model: @model
      el: '.stats'

    @subView new GameOverView
      model: @model
      el: '.game_over'

  getRenderData: ->
    data = super
    data.mode = @model.field.get 'mode'
    data

module.exports = GameView