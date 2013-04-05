var mongoose = require('mongoose');
var config = require('../server/config').config;

// connect the test database
mongoose.connect(config.databaseHost, config.databaseName);

// execute the model tests
require('./models/user_test');
require('./models/yum_test');
require('./models/venue_test');

// execute the controller tests
require('./controllers/user_controller_test');
require('./controllers/yum_controller_test');