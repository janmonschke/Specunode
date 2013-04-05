View  = require './view'

class NavigationView extends View
  template: require './templates/navigation'

  initialize: ->
    $(document).on 'keydown', @keyHandler

  keyHandler: (event) ->
    key = event.keyCode

    if key == 101     # 1 -> new game
      application.router.single_game()
    else if key == 98 # 2 -> multiplayer
      application.router.games()
    else if key == 6  # 3 -> stats
      application.router.stats()
    else if key == 8  # 3 -> instructions
      application.router.instructions()
    else
      return # do nothing

    event.stopPropagation()

  leave: (done) ->
    links = @$('.links a')
    delay = 150
    remove = @remove

    links.each (index, element) =>
      if index is links.length - 1 # last element -> remove the view when done
        _.delay (-> $(element).animate({ opacity: 0}, -> remove(); done(); )), index * delay
      else
        _.delay (-> $(element).animate({ opacity: 0})), index * delay

  remove: ->
    $(document).off 'keydown', @keyHandler
    super

module.exports = NavigationView