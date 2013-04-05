express   = require('express')
mongoose  = require('mongoose')
config    = require('./server/config').config

# make config globally available
global.config = config

# connect to the MongoDB instance that was specified in the config
# mongoose.connect config.databaseHost, config.databaseName

# create the express app
app = express()

# configure the auth module
auth = require('./server/config/auth_config').auth

# configure the express app
require('./server/config/app_config')(app, auth)

# set up the routes
require('./server/routes')(app, auth)

# start the app
app.listen config.appPort

console.log 'Server started on port:', config.appPort