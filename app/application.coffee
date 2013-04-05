Router  = require('./router')
Field   = require('./models/field')
Games   = require('./models/games')
PlayerStats = require('./models/player_stats')

Application = 

  initialize: ->
    @hijackAnchors()

    vconsole.init()

    if window.io
      window.apiBase = ''

      if window.realtimePort
        if window.isWebTV
          socketServer = 'http://janmon.libra.uberspace.de:' + window.realtimePort
          window.apiBase = 'http://janmon.libra.uberspace.de/colorbattle'
        else
          socketServer = 'http://' + location.host + ':' + window.realtimePort
          window.apiBase = 'http://janmon.libra.uberspace.de/colorbattle'
      else
        socketServer = location.host

      @socket = io.connect(socketServer)
      @socket.on 'connect', ->
        $.post window.apiBase + '/register_socket', socketId: @socket.sessionid
      @socket.on 'new_game', (game) => @games.add(game)
      window.socket = @socket
    
    @games = new Games()
    @stats = new PlayerStats()
    @router = new Router()

  hijackAnchors: ->
    # enable pushState routing for anchors
    # source: https://github.com/chaplinjs/chaplin/blob/0a06ee7a57625cd980011fe316ff78c28f9de88c/src/chaplin/views/layout.coffee#L96
    $(document).on 'click', 'a[href]', (event) =>
      el = event.currentTarget
      $el = $(el)
      href = $el.attr('href')

      # return if invalid
      return if href is '' or href is undefined or href.charAt(0) is '#'

      # check for external link
      external = (el.hostname isnt '' && el.hostname isnt location.hostname) or ($el.attr('external') isnt undefined)

      # if external do nothing, else: let the router handle it
      if external
        return
      else
        path = el.pathname + el.search
        @router.navigate path, trigger: true
        event.preventDefault()

window.vconsole =
  consoleElement: $('#vconsole')

  init: ->
    $(document.body).append '<div id="vconsole"></div>'
    @consoleElement = $('#vconsole')
    @consoleElement.css 'display', 'none'

  log: (text) ->
    @consoleElement.prepend "<div>#{text}</div>"

module.exports = Application