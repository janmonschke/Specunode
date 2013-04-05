var should = require('should');
var Venue = require('../../server/models/venue');
var User = require('../../server/models/user');
var Yum = require('../../server/models/yum');

describe('Venue', function(){
  var v1, v2, v3;
  var validVenue = {
    loc: [1,2],
    name: 'pepes trattoria'
  };

  var validVenue2 = {
    loc: [1.01,2.01],
    name: 'pepes café'
  };

  var validVenue3 = {
    loc: [10.01,20.01],
    name: 'mcdo'
  };

  var createVenues = function(done){
    Venue.create(validVenue, validVenue2, validVenue3, function(err, _v1, _v2, _v3){
      if(err) throw err;
      v1 = _v1; v2 = _v2; v3 = _v3;
      done();
    });
  };

  var removeVenues = function(done){
    Venue.remove({}, done);
  };

  describe('geo', function(){
    beforeEach(createVenues);
    afterEach(removeVenues);

    it('should find the venues nearby', function(done){
      var lessThanAKilometer = 0.00001;
      Venue.nearby(validVenue.loc[0]+lessThanAKilometer, validVenue.loc[1]+lessThanAKilometer, function(err, venues){
        if(err) throw err;
        // only 1 yum is in the range of 1km
        venues.should.have.length(1);
        done();
      });
    });

    it('should find the venues by radius (10km)', function(done){
      Venue.findByLocation(validVenue.loc[0], validVenue.loc[1], 10, function(err, venues){
        if(err) throw err;
        // 2 venues are in the range of 10km
        venues.should.have.length(2);
        done();
      });
    });
    
    it('should find the venues by radius (1.5km)', function(done){
      Venue.findByLocation(validVenue.loc[0], validVenue.loc[1], 1.5, function(err, venues){
        if(err) throw err;
        // 1 yum in the range of 1.5km
        venues.should.have.length(1);
        done();
      });
    });
  });
  
  describe('add/rm Yum', function(){
    var yum;
    // create the test yum
    beforeEach(function(done){
      User.create({name: 'hugo'}, function(err, u){
        if(err || !u) throw err;
        Yum.create({loc: [1.01,2.01], image: 'image', owner: u._id }, function(err, _yum){
          if(err || !_yum) throw err;
          yum = _yum;
          done();
        })
      })
    });
    beforeEach(createVenues);
    afterEach(removeVenues);
    afterEach(function(done){ User.remove({}, done)});

    it('should add a yum', function(done){
      v1.yums.should.have.length(0);
      Venue.addYum(v1._id, yum, function(err, v){
        if(err) throw err;
        v.yums.should.have.length(1);
        done();
      });
    });

    it('should add remove yum', function(done){
      v1.yums.should.have.length(0);
      Venue.addYum(v1._id, yum, function(err, v){
        if(err) throw err;
        v.yums.should.have.length(1);
        Venue.removeYum(v._id, yum, function(err, ven){
          if(err) throw err;
          ven.yums.should.have.length(0);
          done();
        });
      });
    });
  });
  
  describe('search by name', function(){
    beforeEach(createVenues);
    afterEach(removeVenues);
    
    it('should find the correct venues when searching by name', function(done){
      Venue.findByName('pepe', function(err, venues){
        if(err) throw err;
        // should find 2 venues
        venues.should.have.length(2);
        // ids should math the example data
        ((venues[0]._id == v1._id.toString()) || (venues[0]._id == v2._id.toString())).should.be.true;
        ((venues[1]._id == v1._id.toString()) || (venues[1]._id == v2._id.toString())).should.be.true;
        done();
      });
    })
  });
});