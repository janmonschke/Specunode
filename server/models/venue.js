var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var config = require('../config').config;
var _ = require('underscore');
var Yum = require('./yum');

var venueSchema = mongoose.Schema({
  loc: { type: [Number], index: '2d', required: true },
  created_at: { type: Date, default: Date.now , required: true },
  name: { type: String, required: true, index: true },
  yums: [{ type: Schema.Types.ObjectId, ref: 'Yum' }]
});

/* find a venue by the given name */
venueSchema.statics.findByName = function(name, cb){
  var regex = new RegExp(name, 'gi');
  return this.find({'name': regex}, cb);
};

/* find nearby venues (-> ~1km) */
venueSchema.statics.nearby = function(lat, lon, cb){
  return this.findByLocation(lat, lon, 1, cb);
};

/* find a venue by location */
venueSchema.statics.findByLocation = function(lat, lon, distance, cb){
  var distance = distance / 6378.137; // kilometer to radians
  return this.find({loc: { $nearSphere: [lat, lon], $maxDistance: distance}}, cb);
};

/* associate the yum to this venue */
venueSchema.statics.addYum = function(venueId, yum, cb){
  this.findById(venueId, function(err, venue){
    if(err && cb) return cb('error:', err);
    venue.yums.push(yum._id);
    venue.save();
    if(cb) cb(null, venue);
  });
};

/* removes a yum from the venue */
venueSchema.statics.removeYum = function(venueId, yumId, cb){
  this.findById(venueId, function(err, venue){
    if(err && cb) return cb('error:', err);
    venue.yums = _.reject(venue.yums, function(yum){ return yum.toString() == yumId; });
    venue.save();
    if(cb) cb(null, venue);
  });
};

module.exports = mongoose.model('Venue', venueSchema);