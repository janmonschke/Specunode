config = {}

# DEVELOPMENT
config.development = 
  appPort: 3000
  redisPort: 6379
  adminName: ''
  adminPassword: ''
  databaseHost: '127.0.0.1' # e.g. 127.0.0.1
  databasePort: '27017' # e.g. 5984
  databaseName: 'speculoos' # e.g. myCoolDatabase
  salt: '9wvpwiun28bv83vsc<b7ciuesb9w' # random characters
  sessionSecret: 'cez8rbv38ov.dbvoedvzc8wvcsev' # random characters
  twitterKey: ''
  twitterSecret: ''
  facebookKey: ''
  facebookSecret: ''
  facebookRedirectURL: ''

# TESTING
config.testing = 
  appPort: 3000
  redisPort: 6379
  adminName: ''
  adminPassword: ''
  databaseHost: '127.0.0.1' # e.g. 127.0.0.1
  databasePort: '27017' # e.g. 5984
  databaseName: '' # e.g. myCoolDatabase
  salt: 'keyboardcat' # random characters
  sessionSecret: 'anotherkeyboardcat' # random characters
  twitterKey: ''
  twitterSecret: ''
  facebookKey: ''
  facebookSecret: ''
  facebookRedirectURL: ''

# PRODUCTION
config.production = 
  appPort: 3000
  redisPort: 6379
  adminName: ''
  adminPassword: ''
  databaseHost: '127.0.0.1' # e.g. 127.0.0.1
  databasePort: '27017' # e.g. 5984
  databaseName: '' # e.g. myCoolDatabase
  salt: 'keyboardcat' # random characters
  sessionSecret: 'anotherkeyboardcat' # random characters
  twitterKey: ''
  twitterSecret: ''
  facebookKey: ''
  facebookSecret: ''
  facebookRedirectURL: ''

# get the node environment from the variable or default to development
node_env = process.env['NODE_ENV'] or 'development'
exports.config = config[node_env]