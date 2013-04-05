var Yum = require('../models/yum');
var Venue = require('../models/venue');
var User = require('../models/user');
var fs = require('fs');

// Find the given yum and render the yum template
exports.show = function(req, res){
  Yum.findOne({'_id': req.params.id}).populate('venue').populate('owner').exec(function(err, yum){
    if(err || !yum) return res.render('errors/404', 404);
    res.render('yum/show', {yum: yum});
  });
};

// Render the new yum form
exports.newForm = function(req, res){
  res.render('yum/new');
};

// Create a yum from the form data
exports.create = function(req, res){
  // the canvas base64 data url starts with this string
  var base64intro = 'data:image/jpeg;base64,';
  // the soon to be filename for the image file
  var filename = '';
  // display the error and redirect back to the form
  var uploadFail = function(errrorMessage, errorObject){
    if(errorObject) console.log('upload problem:', errorObject.toString());
    req.flash('error', errrorMessage);
    res.redirect('/yum/new');
  };

  var createYumAtVenue = function(err, venue){
    if(err) return uploadFail('Could not associate yum to venue.', err);
    
    // structuring the form data
    var formData = { geo: req.body.geo, filename: filename, user: req.user };

    // if there was a venue, add it
    if(venue) formData.venue = venue;

    // create the yum
    Yum.createFromFormData(formData, function(err, yum){
      if(err || !yum) return uploadFail('Could not create yum.', err);
      if(yum.venue) Venue.addYum(yum.venue, yum);
      res.redirect('/yum/' + yum._id);
    });
  };

  // the image is now saved, we can create the yum now
  var imageFileSaved = function(filename){
    if(req.body.new_venue && Yum.parseGeo(req.body.geo)){
      var geo = Yum.parseGeo(req.body.geo);
      Venue.create({name: req.body.new_venue, loc: [geo.lat, geo.lon]}, createYumAtVenue);
    }else if(req.body.venue)
      Venue.findById(req.body.venue, createYumAtVenue);
    else
      createYumAtVenue(null, null);
  };

  // get the image from the request
  var image = req.body.image;

  // check if there is an image and if it has the correct type
  if(!image || image.length < 1 || image.indexOf(base64intro) < 0) return uploadFail('No image in request.');

  // remove the intro to make it a valid bas64 string
  image = image.replace(base64intro, '')
  // create a file from the base64 string
  filename = req.user._id.toString().replace('..', '') + '-' + new Date().getTime() + '.jpeg';
  var buffer = new Buffer(image, 'base64');
  fs.writeFile(__dirname + '/../../public/images/uploads/' + filename, buffer, function(err) {
    if(err) return uploadFail('Could not save the image, please try again.', err);
    imageFileSaved(filename);
  });
};

// Destroy the given yum
exports.destroy = function(req, res){
  Yum.findById(req.params.id, function(err, yum){
    if(err || !yum) return res.json({error: 'Could not find yum.'}, 404);
    // only allow the owner to delete a yum
    if(!yum.isOwnedBy(req.user))
      res.json({error: 'Unauthorized access.'}, 401);
    else
      yum.remove(function(err){
        if(err) return res.json({error: 'Could not delete yum.'}, 500);
        res.json({success: true});
      });
  });
};

// Yum-Button functionality
exports.yumMe = function(req, res){
  // find the yum
  Yum.findById(req.params.id, function(err, yum){
    if(err || !yum) return res.json({error: 'Yum not found.'}, 404);
    // add the yum to the users yummed yums
    req.user.addYum(yum, function(err, count){
      if(err) return res.json({error: 'Could not update yum count.'}, 500);
      // increment the number for the yum button
      yum.incrementYumCount(function(err, model){
        if(err) return res.json({error: 'Could not update yum count.'}, 500);
        res.json({success: true});
      });
    });
  })
};