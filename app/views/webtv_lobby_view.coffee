View          = require './view'

class WebTVLobbyView extends View

  initialize: ->
    @listenTo application.games, 'add', @render
    @listenTo application.games, 'remove', @render

  