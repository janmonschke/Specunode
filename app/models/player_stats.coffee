Model = require './model'

class PlayerStats extends Model

  initialize: ->
    super

    return if not window.localStorage

    @storage = window.localStorage

    @listenTo Backbone, 'single_game_start', @incSingleGame
    @listenTo Backbone, 'multi_game_start', @incMultiGame
    @listenTo Backbone, 'single_game_over', @singleGameOver
    @listenTo Backbone, 'you_won', @incMultiWon

  incSingleGame: =>
    singleGames = @storage.getItem('single_game_count') or 0
    @storage.setItem 'single_game_count', ++singleGames

  incMultiGame: =>
    multiGames = @storage.getItem('multi_game_count') or 0
    @storage.setItem 'multi_game_count', ++multiGames

  incMultiWon: =>
    wonMultiGames = @storage.getItem('multi_games_won') or 0
    @storage.setItem 'multi_games_won', ++wonMultiGames

  singleGameOver: (field) =>
    # check if there is a new best game
    bestGame = @storage.getItem 'best_single_game'
    currentMoves = field.get('moves')[0]
    # if no best game submitted yet, set it to a less good result
    bestGame = currentMoves + 1 if not bestGame
    if currentMoves < bestGame
      @storage.setItem 'best_single_game', currentMoves

module.exports = PlayerStats