Model = require('./model')

class User extends Model
  
  isLoggedIn: ->
    return @has('_id') and @has('_rev')

module.exports = User