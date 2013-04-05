Collection  = require('./collection')
Game        = require('./game')

class Games extends Collection
  url: -> window.apiBase + '/api/games'
  model: Game

module.exports = Games