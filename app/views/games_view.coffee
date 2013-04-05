View          = require './view'
GameEntryView = require './game_entry_view'

class GamesView extends View
  id: 'games'

  className: 'eight columns'

  template: require './templates/games'

  events:
    'submit form': 'newGame'

  initialize: ->
    @listenTo application.games, 'add', @addGame
    @listenTo application.games, 'remove', @emptyList

  afterRender: ->
    @emptyMessage = @$('.empty')

    application.games.each (game) =>
      @addGame game

    if window.isWebTV
      @activateTVControls()
      @addInstructions()

    @

  activateTVControls: ->
    @currentGame = 0
    
    # select the current game's element
    @$('.games li').eq(@currentGame).addClass('selected')

    $(document).on 'keydown', @keyHandler

  keyHandler: (event) =>
    key = event.keyCode
    alert key
    if key == 101     # 1 -> new game
      alert socket.socket.sessionid
      return application.socket.emit 'create_public_game', socket.socket.sessionid
    else if key is 29443 # enter + submit-button
      return @startCurrentGame()
    else if key is 29460
      return @navigateUp()
    else if key is 29461 or key is 4
      return @navigateDown()
    
    event.stopPropagation()

  startCurrentGame: ->
    game = application.games.at(@currentGame)
    if game
      alert game.get('id')
      application.socket.emit 'join_public_game', game.get('id')

  navigateUp: ->
    @currentGame--
    @currentGame = application.games.length - 1 if @currentGame < 0
    @selectCurrentView()

  navigateDown: ->
    @currentGame++
    @currentGame = 0 if @currentGame > application.games.length - 1
    @selectCurrentView()

  selectCurrentView: ->
    alert @currentGame
    @$('.selected').removeClass('selected')
    @$('.games li').eq(@currentGame).addClass('selected')

  addInstructions: ->
    @$('.new-game').remove()
    @$('.games').prepend('<p>Press <strong>1</strong> in order to create a new game. Navigate with the arrow keys and select a game with the enter key.</p>')

  addGame: (game) =>
    @emptyMessage.hide()
    @$('.games ul').append new GameEntryView(model: game).render().el

  emptyList: =>
    if application.games.length is 0
      @emptyMessage.show()

  newGame: (event) =>
    event.preventDefault()
    application.socket.emit 'create_public_game', $('#newgameName').val()
    false

  remove: ->
    $(document).off 'keydown', @keyHandler
    super

module.exports = GamesView