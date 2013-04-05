var should = require('should');
var Model = require('../../server/models/model');

describe('User', function(){
  it('should not fail', function(){
    should.exist(Model)
  })
});