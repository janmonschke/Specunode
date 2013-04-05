context = global? or window

Backbone = if context.Backbone? then context.Backbone else require('backbone')

class Field extends Backbone.Model
  # Specifies a free field (free as in not owned by one of the players)
  @free: -1

  defaults: ->
    width:  20
    height: 20
    moves:  [0, 0]
    mode:   'single'

  initialize: (data) ->
    super
    @timeoutTime = 30 * 1000

    # create a random field if not field specified
    if !data or !data.colors
      field = Field.random @get('width'), @get('height')
      @set field

    # starting point for player 0
    @get('possessions')[0][0] = 0

    # starting point for player 1
    if @get('mode') is 'multi'
      @get('possessions')[@get('height')-1][@get('width')-1] = 1

  # Generates a random field with the sizes of this field instance
  # @return [{colors: Array, possessions: Array, original: Array}] the generated field
  @random: (width, height) ->
    field =
      colors:       []
      possessions:  []
      original:     []

    for i in [0...height]
      currow = []
      currowPosessions = []

      for u in [0...width]
        currow.push Math.floor Math.random() * 4 + 0.5
        currowPosessions.push Field.free

      field.colors.push currow
      field.possessions.push currowPosessions

    # copy the colors to `original`
    for y in [0...height]
      currow = []
      for x in [0...width]
        currow.push field.colors[y][x]
      field.original.push currow

    return field

  getPossessionPercentage: (playerIndex) ->
    possessions = @get 'possessions'
    width = @get 'width'
    height = @get 'height'
    needed = width * height
    playerPosessions = 0

    for i in [0...height]
      currowPosessions = possessions[i]

      for u in [0...width]
        if currowPosessions[u] == playerIndex # only increas if pixel is owned by the player
          playerPosessions++

    return Math.floor (playerPosessions / needed) * 100

  isOver: (player) ->
    playerPercentage = @getPossessionPercentage player

    if @get('mode') == 'single'
      return (playerPercentage == 100)
    else
      return (playerPercentage >= 50)

  # The player at playerIndex chose the given color, recalculate the possessions and colors
  playerPicked: (playerIndex, color) ->
    for y in [0...@get('height')]
      for x in [0...@get('width')]
        if @isColor(x, y, color) and @isFree(x, y) and @playerOwnsNeighbour(playerIndex, x, y)
          @fillForPlayer(playerIndex, color, x, y)

    @increaseMoves playerIndex

    @trigger 'change'
    if(@isOver(0) or @isOver(1)) # it's over when it's over for one of the players
      @trigger 'over'
      if @get('mode') is 'single'
        Backbone.trigger 'single_game_over', @
      else
        Backbone.trigger 'multi_game_over', @

  # Update the current user's moves
  increaseMoves: (playerIndex) ->
    @get('moves')[playerIndex]++

  # Is this field free?
  isFree: (x, y) ->
    (@get('possessions')[y]?[x] is Field.free)

  # Is this field of this color?
  isColor: (x, y, color) ->
    (@get('colors')[y]?[x] is color)

  # Does the player own a neighbour of this field?
  playerOwnsNeighbour: (playerIndex, x, y) ->
    possessions = @get('possessions')
    
    if possessions[y]?[x-1] is playerIndex # to the left
      return true
    
    if possessions[y]?[x+1] is playerIndex # to the right
      return true
    
    if possessions[y-1]?[x] is playerIndex # above
      return true
    
    if possessions[y+1]?[x] is playerIndex # underneath
      return true
    
    return false

  # Fills the possessions and colors for this player at (x/y) via floodfill
  fillForPlayer: (playerIndex, color, x, y) ->
    possessions = @get('possessions')
    # fill current position
    possessions[y][x] = playerIndex

    # fill to the right
    if @isColor(x+1, y, color) and (possessions[y]?[x+1] is Field.free)
      @fillForPlayer playerIndex, color, x+1, y

    # fill underneath
    if @isColor(x, y+1, color) and (possessions[y+1]?[x] is Field.free)
      @fillForPlayer playerIndex, color, x, y+1

    # fill above
    if @isColor(x, y-1, color) and (possessions[y-1]?[x] is Field.free)
      @fillForPlayer playerIndex, color, x, y-1
    
    # fill to the left
    if @isColor(x-1, y, color) and (possessions[y]?[x-1] is Field.free)
      @fillForPlayer playerIndex, color, x-1, y

module.exports = Field