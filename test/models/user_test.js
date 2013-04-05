var should = require('should');
var User = require('../../server/models/user');
var Yum = require('../../server/models/yum');

describe('User', function(){
  var invalidPassword = '12345';
  var validPassword = '123456';
  var validUsername = 'a';
  var invalidUsername = '';
  var validYum = {
    loc: [1,2],
    image: 'image'
  };

  afterEach(function(done){
    // remove all created users
    User.remove({}, function(err){
      if(err) throw err;
      // remove all created yums
      Yum.remove({}, done);
    });
  });

  // test the create functions
  describe('create', function(){
    it('should fail when password not long enough', function(){
      var data = {username: validUsername, password: invalidPassword};
      User.createWithPassword(data, function(err, user){
        should.exist(err);
        should.not.exist(user);
      });
    });

    it('should fail when there is no username', function(){
      var data = {username: validUsername, password: invalidPassword};
      User.createWithPassword({username: invalidUsername, password: validPassword}, function(err, user){
        should.exist(err);
        should.not.exist(user);
      });
    });

    it('should not fail with valid username and valid password', function(done){
      var data = {username: validUsername, password: validPassword};
      User.createWithPassword(data, done);
    });
  });

  // test the password hashing
  describe('password', function(){
    var user;
    before(function(done){
      var data = {username: validUsername, password: validPassword};
      user = User.createWithPassword(data, function(err, _user){
        user = _user;
        done();
      });
    });

    it('should fail when tested with wrong password', function(){
      user.checkPassword(invalidPassword).should.not.be.ok;
    });

    it('should not fail when tested with correct password', function(){
      user.checkPassword(validPassword).should.be.ok;
    });
  });

  // test the methos for the yum-button
  describe('a user\'s yummed yums', function(){
    var user, yum;

    // create a user and a yum before each test
    beforeEach(function(done){
      var data = {username: validUsername, password: validPassword};
      user = User.createWithPassword(data, function(err, _user){
        if(err) throw err;
        user = _user;
        validYum.owner = user._id;
        Yum.create(validYum, function(err, _yum){
          if(err) throw err;
          yum = _yum;
          done();
        })
      });
    });

    // remove the user after each test
    afterEach(function(done){
      User.remove(user, done);
    });

    it('should add a yum', function(done){
      user.yummed.should.have.length(0);
      user.addYum(yum, function(err){
        if(err) throw err;
        user.yummed.should.have.length(1);
        done();
      });
    });

    it('should not add a yum again', function(done){
      user.addYum(yum, function(err){
        if(err) throw err;
        user.addYum(yum, function(err){
          should.exist(err);
          done()
        });
      });
    });

    it('should report if a yum has already been yummed', function(done){
      user.hasYummed(yum).should.not.be.true
      user.addYum(yum, function(err){
        if(err) throw err;
        user.hasYummed(yum).should.be.true
        done()
      });
    });
  });

  // test the find functions
  describe('find', function(){
    before(function(done){
      var data = {username: validUsername, password: validPassword};
      var user = User.createWithPassword(data, function(err, _user){
        user = _user;
        done();
      });
    });

    it('should find a user by a name', function(done){
      User.findByName(validUsername, function(err, user){
        if(err || !user) throw err;
        should.exist(user);
        done();
      });
    });
  });

  // test the user whitelisting
  it('should not add secret information to the JSON representaion of a user', function(done){
    var data = {username: validUsername, password: validPassword};
    User.createWithPassword(data, function(err, user){
      if(err) throw err;
      user = user.toJSON();
      user.should.have.keys('_id', 'name', 'yummed');
      done();
    });
  })

});