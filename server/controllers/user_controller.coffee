{Controller}  = require('./controller')
User          = require('../models/user')

class UserController extends Controller
  before: ->
    'me' : @loginIfNotLoggedIn

  constructor: (@auth) ->
    super

  # Renders the current user's page if the user is logged in
  me: (req, res) ->
    res.redirect('/user/' + req.user._id);

  show: (req, res) ->
    res.render('user/show')

  # Register a user from form daat
  register: (req, res) ->
    # structure the data
    data =
      username: req.body.username
      password: req.body.password
      email: req.body.email

    # create user from given data
    User.createWithPassword data, (err, user) ->
      # something went wrong
      if err or !user
        req.flash('Could not create a user, try again!', err)
        res.redirect('/login')
      else
        # User successfully created, log it in and redirect
        req.login user, (err) ->
          if err
            req.flash('Could not log you in, try again!', err)
            res.redirect('/login')
          else
            res.redirect('/me')

  # Render the login form template
  loginForm: (req, res) -> res.render('login')

  # Authenticate a user through login form submission
  authenticate: ->
    # proxy to the auth provider's authentication method
    return @auth.authenticate 'local',
      successRedirect: '/me'
      failureRedirect: '/login'
      failureFlash: true

  # Log the user out and redirect
  logout: (req, res) ->
    req.logout()
    res.redirect('/')

exports.UserController = UserController