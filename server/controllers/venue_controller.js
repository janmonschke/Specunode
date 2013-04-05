var Venue = require('../models/venue');

// Gets all yums which are associated to the given venues and renders the venue template
exports.show = function(req, res){
  Venue.findOne({'_id': req.params.id}).populate('yums').exec(function(err, venue){
    if(err || !venue) return res.render('errors/404', 404);
    res.render('venue/show', {venue: venue});
  });
};