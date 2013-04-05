should  = require 'should'
sinon   = require 'sinon'
Model   = require('../../server/models/model')

describe 'User', ->
  mockDatabase =
    save: (id, doc, doc_rev, done) ->
      doc._rev = "#{doc_rev}1"
      done null, doc

  originalDbMethod = ->
  before ->
    originalDbMethod = Model.prototype.db
    Model.prototype.db = -> mockDatabase

  after ->
    Model.prototype.db = originalDbMethod

  it 'should not fail', -> should.exist Model

  describe '#edit', ->

    it 'should edit a model', (done) ->
      m = new Model()
      doc = {a:'b', _rev: '1'}
      oldRev = doc._rev
      promise = m.edit '234', doc
      promise.done (_doc) ->
        oldRev.should.not.eql(_doc._rev)
        done()