var should = require('should');
var controller = require('../../server/controllers/user_controller');

describe('User Controller', function(){
  describe('User pages', function(){
    it('should fail for /me when not logged in', function(){
      try{
        controller.redirectToUserPage({ user: null }, null)
        false.should.be.ok;
      }catch(e){
        true.should.be.ok;
      }
    });

    it('should not fail for /me when logged in', function(){
      controller.redirectToUserPage({ user: {_id: 1} }, {
        redirect: function(url){
          url.should.equal('/user/1')
        }
      });
    });
  });

  it('should proxy to the auth provider for authentication', function(){
    var provider = {
      authenticate: function(method, options){ 
        method.should.equal('local');
        should.exist(options.successRedirect);
        options.successRedirect.should.equal('/yum/new');
        should.exist(options.failureRedirect);
        options.failureRedirect.should.equal('/login');
      }
    }
    controller.setAuthProvider(provider);
    controller.authenticate();
  });

  it('should set a flash and redirect to login if wrong data for register', function(){
    var flashSet = false;
    var redirectURL = '';
    var req = {
      body: { username: 'a', password: '2'},
      flash: function() { flashSet = true }
    };
    var res = {
      redirect: function(url){ redirectURL = url; }
    };
    
    controller.register(req, res);
    
    flashSet.should.be.ok;
    redirectURL.should.equal('/login');
  });

  it('should log out the user and redirect to home page', function(){
    var loggedOut = false;
    var redirectURL = '';
    var req = { logout: function(){ loggedOut = true; }};
    var res = { redirect: function(url){ redirectURL = url; }};
    
    controller.logout(req, res);
    
    loggedOut.should.be.ok;
    redirectURL.should.equal('/');
  });
});