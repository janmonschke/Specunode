AsyncRouter     = require './async_router'
NavigationView  = require('./views/navigation_view')
GamesView       = require './views/games_view'
GameView        = require './views/game_view'
MultiPlayerGameView = require './views/multiplayer_game_view'
PlayerStatsView = require './views/player_stats_view'
InstructionsView = require './views/instructions_view'
Game            = require './models/game'

class Router extends AsyncRouter

  routes: 
    ''  : 'index'
    '/' : 'index'
    'play': 'single_game'
    'play/': 'single_game'
    'new_game': 'new_game'
    'new_game/': 'new_game'
    'games': 'games'
    'games/': 'games'
    'stats': 'stats'
    'stats/': 'stats'
    'instructions': 'instructions'
    'instructions/': 'instructions'

  initialize: ->
    # auto-join a player when the server tells him to do so
    application.socket.on('joined', @game) if application.socket

  index: ->
    @switchToView new NavigationView()

  single_game: ->
    Backbone.trigger 'single_game_start'
    @switchToView new GameView
      model: new Game()

  new_game: ->
    @navigate '/play'

  games: ->
    vconsole.log 'have to fetch the games'
    vconsole.log application.games.url()
    
    # JSONP here because of WebTVs
    $.ajax({url: application.games.url(), dataType: 'jsonp'}).done((games) => 
      vconsole.log 'fetching done'
      application.games.reset games
      @switchToView new GamesView()
    ).error( (a,b,c) =>
      vconsole.log 'error fetching ' + a.status
    )

  game: (game) =>
    @navigate "/game/#{game.id}"
    Backbone.trigger 'multi_game_start'
    @switchToView new MultiPlayerGameView model: new Game(game)

  stats: ->
    @switchToView new PlayerStatsView()

  instructions: ->
    @switchToView new InstructionsView()

module.exports = Router