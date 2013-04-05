var mongoose = require('mongoose');
var config = require('../config').config;

// connect to DB 
mongoose.connect(config.databaseHost, config.databaseName);

var Venue = require( '../models/venue' );

// dummy data list for development
var venueList = [
  { name: 'Neben Mensa', loc: [ 52.459448,13.516681 ] },
  { name: 'Mensa', loc: [52.45614,13.524535] },
  { name: 'Brücke', loc: [52.457918,13.519685] },
  { name: 'Gemüse Döner', loc: [52.467227,13.431215] },
  { name: 'Rusticana', loc: [52.465854, 13.432417]},
  { name: 'Pho Phan', loc: [52.465697, 13.432524]}
];

// create items in database
for (var i = venueList.length - 1; i >= 0; i--) {
  Venue.create(venueList[i], function(err, venue) {
    console.log(err , venue);
  });
};

console.log('start import ....');
