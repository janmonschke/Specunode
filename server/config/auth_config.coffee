# Setup the auth module
passport        = require('passport')
User            = require('../models/user')
LocalStrategy   = require('passport-local').Strategy

# looks for the user by its username and tries to authenticate it with the given password
authenticate = (username, pw, done) ->
  User.findByName username, (err, user) ->
    return done(err, null, err) if err or !user or !user.checkPassword(pw)
    done null, user

# Set up password auth
passport.use new LocalStrategy
  usernameField: 'username'
  passwordField: 'password'
, authenticate

# (De-)Serialization of users

# only the user's id is important
serializeUser = (user, done) ->
  id = if user.id? then user.id else user._id
  done null, id

# find the user by the id
deserializeUser = (id, done) ->
  User.findById id, (err, user) ->
    return done(err, null, null) if err or !user
    done null, user

# make passport use the above defined methods
passport.serializeUser serializeUser
passport.deserializeUser deserializeUser

### This is how you would add more auth strategies (don't forget to ad the keys in config.coffee)

TwitterStrategy = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy

authenticateSocial = (userid, username, service, done) ->
  # Find the user by the given id...
  User.findOne {service_userid: userid}, (err, user) ->
    return done(err, null, err) if err
    if user
      done null, user
    else
      # ...or create the user if it's not defined yet
      User.create
        name: username
        from_service: service
        service_userid: userid
      , done

# authenticate a Twitter user
authenticateTwitter = (token, tokenSecret, profile, done) ->
  authenticateSocial String(profile.id), profile.username, 'twitter', done

passport.use new TwitterStrategy
  consumerKey: config.twitterKe,
  consumerSecret: config.twitterSecret
, auth.authenticateTwitter

# Authenticate a Facebook user
authenticateFacebook = (accesToken, refreshToken, profile, done) ->
  authenticateSocial String(profile.id), profile.username, 'facebook', done

passport.use new FacebookStrategy
  clientID: config.facebookKey
  clientSecret: config.facebookSecret
  callbackURL: config.facebookRedirectURL
, auth.authenticateFacebook
###

exports.auth = passport