var should = require('should');
var controller = require('../../server/controllers/yum_controller');

describe('Yum Controller', function(){
  describe('add new yum', function(){
    it('should fail if no image in the request', function(){
      var req = {
        body: {},
        flash: function(err, message){
          err.should.equal('error');
          message.should.equal('No image in request.');
        }
      };
      var res = {
        redirect: function(url){
          url.should.equal('/yum/new');
        }
      }

      controller.create(req, res);
    });

    it('should fail if there is a mal-formatted image in the request', function(){
      var req = {
        body: { image: '234234' },
        flash: function(err, message){
          err.should.equal('error');
          message.should.equal('No image in request.');
        }
      };
      var res = {
        redirect: function(url){
          url.should.equal('/yum/new');
        }
      }

      controller.create(req, res);
    });
  });
});