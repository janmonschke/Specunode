module.exports = (app, auth) ->
  # render the index page
  app.get   '/', (req, res) -> res.render('index')

  # users / login / register / OAuth providers
  {UserController} = require('./controllers/user_controller')
  user = new UserController auth

  app.post  '/register', user.register

  app.get   '/login', user.loginForm
  app.post  '/login', user.authenticate()

  ### again, optional OAuth services
  app.get   '/auth/twitter', auth.authenticate('twitter')
  app.get   '/auth/twitter/callback', auth.authenticate 'twitter',
    successRedirect: '/me'
    failureRedirect: '/login'

  app.get   '/auth/facebook', auth.authenticate('facebook')
  app.get   '/auth/facebook/callback', auth.authenticate 'facebook',
    successRedirect: '/me'
    failureRedirect: '/login'
  ###

  app.get   '/logout', user.logout

  app.get   '/me', user.me
  app.get   '/user/:id', user.show