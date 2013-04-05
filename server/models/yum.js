var fs = require('fs');
var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var Venue = require('./venue');

var yumSchema = mongoose.Schema({
  loc: { type: [Number], index: '2d', required: true },
  created_at: { type: Date, default: Date.now , required: true },
  image: { type: String, required: true },
  owner: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  yumCount: { type: Number, default: 0 },
  tags: [String],
  venue: { type: Schema.Types.ObjectId, ref: 'Venue', default: null }
});

/* HOOKS */
// executed when a yum is removed
yumSchema.post('remove', function (doc) {
  // remove its image from the filesystem
  fs.unlink(__dirname + '/../../' + 'public/images/uploads/' + doc.image, function(err){
    if(err) console.log('error:', 'could not unlink', err);
  });

  // remove the yum from the venue
  if(doc.venue) Venue.removeYum(doc.venue, doc._id);
});

/* STATICS */

// Finds all yums by the given user
yumSchema.statics.findByUser = function(userId, cb){
  return this.find({owner: userId}, cb);
};

// find nearby yums (-> 1km)
yumSchema.statics.nearby = function(lat, lon, cb){
  return this.findByLocation(lat, lon, 1, cb);
};

// find a yum by location and distance
yumSchema.statics.findByLocation = function(lat, lon, distance, cb){
  var distance = distance / 6378.137; // kilometer to radians
  return this.find({loc: { $nearSphere: [lat, lon], $maxDistance: distance}}).populate('owner').populate('venue').exec(cb);
};

// parses a geo String ('13.44,12.4') into a lat/lon hash
var latLongRegEx = /^(\d+(?:\.\d*)?),(\d+(?:\.\d*)?)/;
yumSchema.statics.parseGeo = function(geo){
  if(latLongRegEx.test(geo)){
    var latlong = geo.split(',');
    return { lat: latlong[0], lon: latlong[1] };
  }else
    return false;
};

// Creates a yum from form data
yumSchema.statics.createFromFormData = function(data, cb){
  var geo = this.parseGeo(data.geo);
  if(geo){
    // structure the data
    var yumData = {
      loc: [geo.lat, geo.lon],
      owner: data.user._id,
      image: data.filename
    };

    // set to the venues geo if there is one
    if(data.venue){
      geo = data.venue.geo;
      yumData.venue = data.venue;
    }

    this.create(yumData, cb);
  }else
    cb('Invalid geo signature. Expected \'lat,lon\', but got: ' + data.geo);
};

/* METHODS */
// Is this yum owned by the given user?
yumSchema.methods.isOwnedBy = function(user){
  // get the id from the model or use the plain id
  var id = this.owner._id ? this.owner._id : this.owner;
  return (id.toString() == user._id.toString());
};

// increment the yum count
yumSchema.methods.incrementYumCount = function(cb){
  this.model('Yum').findByIdAndUpdate(this._id, { $inc: { yumCount: 1 }}, cb);
};

module.exports = mongoose.model('Yum', yumSchema);