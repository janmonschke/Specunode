should  = require 'should'
Model   = require('../../server/models/model')

describe 'User', ->
  mockDatabase =
    save: (id, doc, doc_rev, done) ->
      doc._rev = "#{doc_rev}1"
      done null, doc

  Model.prototype.db = -> mockDatabase

  it 'should not fail', -> should.exist Model

  it 'should edit a model', (done) ->
    m = new Model()
    doc = {a:'b', _rev: '1'}
    oldRev = doc._rev
    promise = m.edit '234', doc
    promise.done (_doc) ->
      oldRev.should.not.eql(_doc._rev)
      done()