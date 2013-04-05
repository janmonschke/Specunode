var should = require('should');
var User = require('../../server/models/user');
var Yum = require('../../server/models/yum');

describe('Yum', function (){
  var validYum = {
    loc: [1,2],
    image: 'image'
  };

  var validYum2 = {
    loc: [1.01,2.01],
    image: 'image'
  };

  var validYum3 = {
    loc: [10.01,20.01],
    image: 'image'
  };

  var user1, user2;

  // create users that should act as owners of yums
  before(function(done){
    User.create({name: 'a23'}, {name: 'b234'}, function(err, _user1, _user2){
      if(err) throw err;
      user1 = _user1; user2 = _user2;
      done();
    })
  });

  // remove all yums after each test
  afterEach(function(done){
    Yum.remove({}, done);
  });

  // remove the user after all tests
  after(function(done){
    User.remove({}, done);
  });

  describe('#parseGeo', function(){
    it('should fail for wrong formats', function(){
      Yum.parseGeo('').should.be.false;
      Yum.parseGeo('3.4').should.be.false;
      Yum.parseGeo('3').should.be.false;
      Yum.parseGeo('[3,3]').should.be.false;
      Yum.parseGeo('"3,3"').should.be.false;
    });

    it('should not fail for correct formats', function(){
      Yum.parseGeo('3,3').should.eql({ lat: '3', lon: '3' });
      Yum.parseGeo('3.2,3').should.eql({ lat: '3.2', lon: '3' });
      Yum.parseGeo('3,3.3').should.eql({ lat: '3', lon: '3.3' });
      Yum.parseGeo('14.345,15.3445').should.eql({ lat: '14.345', lon: '15.3445' });
    });
  });

  describe('#incrementYumCount', function(){
    it('should increment the yum count', function(done){
      validYum.owner = user1._id;
      Yum.create(validYum, function(err, yum){
        if(err) throw err;
        yum.yumCount.should.equal(0);
        yum.incrementYumCount(function(err, _yum){
          if(err) throw err;
          _yum.yumCount.should.equal(1);
          done();
        });
      });
    });
  });

  describe('#isOwnedBy', function(){
    it('should work with the correct user', function(done){
      validYum.owner = user1._id;
      Yum.create(validYum, function(err, yum){
        if(err) throw err;
        yum.isOwnedBy(user1).should.be.true;
        yum.isOwnedBy(user2).should.be.false;
        done();
      });
    });
  });

  describe('find', function(){
    var yum1, yum2, yum3;

    // create two yums
    beforeEach(function(done){
      validYum.owner = user1._id;
      validYum2.owner = user1._id;
      validYum3.owner = user2._id;
      Yum.create(validYum, validYum2, validYum3, function(err, y1, y2, y3){
        if(err) throw err;
        yum1 = y1;
        yum2 = y2;
        yum3 = y3;
        done();
      });
    });

    afterEach(function(){
      delete validYum.owner;
      delete validYum2.owner;
      delete validYum3.owner;
    });

    describe('geo', function(){
      it('should find the yums nearby', function(done){
        var lessThanAKilometer = 0.00001;
        Yum.nearby(validYum.loc[0]+lessThanAKilometer, validYum.loc[1]+lessThanAKilometer, function(err, yums){
          if(err) throw err;
          // only 1 yum is in the range of 1km
          yums.should.have.length(1);
          done();
        });
      });

      it('should find the yums by radius (10km)', function(done){
        Yum.findByLocation(validYum.loc[0], validYum.loc[1], 10, function(err, yums){
          if(err) throw err;
          // 2 yums are in the range of 10km
          yums.should.have.length(2);
          done();
        });
      });
      
      it('should find the yums by radius (1.5km)', function(done){
        Yum.findByLocation(validYum.loc[0], validYum.loc[1], 1.5, function(err, yums){
          if(err) throw err;
          // 1 yum in the range of 1.5km
          yums.should.have.length(1);
          done();
        });
      });
    });
    
    it('should find yums by a user', function(done){
      // user 1 -> 2 yums
      Yum.findByUser(user1._id, function(err, yums){
        if(err) throw err;
        yums.should.have.length(2);

        // user 2 -> 1 yum
        Yum.findByUser(user2._id, function(err, yums2){
          if(err) throw err;

          yums2.should.have.length(1);
          done();
        });
      });
    });

    it('should not create invalid yums', function(done){
      var data = {
        owner: user1,
        loc: 'wrongLoc',
        image: 'image'
      };

      Yum.createFromFormData(data, function(err, yum){
        should.exist(err);
        should.not.exist(yum);
        done();
      });
    });
  });
});