View = require './view'

class PlayerStatsView extends View

  className: 'player_stats'

  template: require('./templates/player_stats')

  getRenderData: ->
    storage = application.stats.storage
    data = {}
    data.singleGames = storage.getItem('single_game_count') or 0
    data.multiGames = storage.getItem('multi_game_count') or 0
    data.multiGamesWon = storage.getItem('multi_games_won') or 0
    data.winPercentage = if data.multiGames > 0 then '' + Math.floor(Number(data.multiGamesWon) / Number(data.multiGames) * 100) + '%' else 'No games played yet'
    data.bestGame = storage.getItem('best_single_game') or 0
    data

module.exports = PlayerStatsView