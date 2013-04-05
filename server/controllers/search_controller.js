var Venue = require('../models/venue');
var Yum = require('../models/yum');

// A before filter which treis to parse the lat/long information from
// a request. If the parsing goes wrong, it'll render an error
exports.parseLatLong = function(req, res, next){
  if(req.params.latlong && Yum.parseGeo(req.params.latlong)){
    req.latlong = Yum.parseGeo(req.params.latlong);
    next();
  }else{
    res.json({'error': 'Invalid search request'});
  }
};

// Renders a JSON representation of all venues that are found with the given name
exports.venuesByName = function(req, res){
  Venue.findByName(req.params.name, function(err, venues){
    if(err) return res.json({error: 'Could not perfom the search.'}, 500);
    res.json(venues);
  });
};

// Renders a JSON representation of all venues nearby the given coordinates
exports.venuesNearby = function(req, res){
  Venue.nearby(req.latlong.lat, req.latlong.lon, function(err, venues){
    if(err) return res.json({error: 'Could not perfom the search.'}, 500);
    res.json(venues);
  });
};

// Renders a JSON representation of all venues which are in the given radius
exports.venuesNearbyDistance = function(req, res){
  Venue.findByLocation(req.latlong.lat, req.latlong.lon, req.params.distance, function(err, venues){
    if(err) return res.json({error: 'Could not perfom the search.'}, 500);
    res.json(venues);
  });
};

// Renders a JSON representation of the yums nearby the given coordinates
exports.yumsNearby = function(req, res){
  Yum.nearby(req.latlong.lat, req.latlong.lon, function(err, yums){
    if(err) return res.json({error: 'Could not perfom the search.'}, 500);
    res.json(yums);
  });
};

// Renders a JSON representation of the yums nearby the given coordinates
exports.yumsNearbyDistance = function(req, res){
  Yum.findByLocation(req.latlong.lat, req.latlong.lon, req.params.distance, function(err, yums){
    if(err) return res.json({error: 'Could not perfom the search.'}, 500);
    res.json(yums);
  });
};

// Renders the plain show form
exports.show = function(req, res){
  res.render('search/show');
};

// Renders the 'search yums' form
exports.showYums = function(req, res){
  res.render('search/show', { type: 'yums'});
};

// Renders the 'search venues' form
exports.showVenues = function(req, res){
  res.render('search/show', { type: 'venues'});
};