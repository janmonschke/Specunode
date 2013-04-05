cradle = require 'cradle'
config = require('../config').config

cradle.setup
  raw: false
  cache: true
  host: "http://#{config.databaseHost}"
  port: config.databasePort
  auth:
    username: config.adminName
    password: config.adminPassword

connection =
  createConnection : -> new(cradle.Connection)()

exports.config = connection