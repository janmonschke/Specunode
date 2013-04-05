View = require('./view')

class GameEntryView extends View
  tagName: 'li'
  
  events:
    'click': 'joinGame'
  
  template: require('./templates/game_entry')
  
  initialize: ->
    super
    @listenTo @model.collection, 'remove', @removeIfMe

  joinGame: ->
    application.socket.emit 'join_public_game', @model.get('id')

  removeIfMe: (model) => 
    @remove() if model is @model

module.exports = GameEntryView