View  = require './view'

class StatsView extends View
  template: require './templates/stats'

  initialize: ->
    @listenTo @model.field, 'change', @render
    @updateTimerInterval = setInterval @updateTimer, 1000
    @listenTo Backbone, 'you_won', @stopInterval
    @listenTo Backbone, 'you_lost', @stopInterval
    @listenTo Backbone, 'you_won', @showWon
    @listenTo Backbone, 'you_lost', @showLost
  
  getRenderData: ->
    playerIndex = @model.playerIndex or 0
    {
      percentage: @model.field.getPossessionPercentage playerIndex
      moves: @model.field.get('moves')[playerIndex]
      over: (@model.field.isOver(0) or @model.field.isOver(1))
      isNextPlayer: (@model.nextPlayer is playerIndex)
      mode: @model.field.get 'mode'
      timer: ' ' + @model.field.timeoutTime / 1000
    }

  afterRender: ->
    playerIndex = @model.playerIndex or 0
    @$('.your-color').addClass("player#{playerIndex}")

  stopInterval: =>
    clearInterval @updateTimerInterval

  updateTimer: =>
    timerElement = @$('.timer')
    timerValue = parseInt timerElement.text(), 10
    if timerValue <= 0
      @stopInterval()
      return
    else
      timerElement.text ' ' + --timerValue

  showWon: =>
    @$('.status').text 'You have won the match!'

  showLost: =>
    @$('.status').text 'You have lost the match!'

  remove: ->
    @stopInterval()
    super

module.exports = StatsView