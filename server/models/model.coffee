Q           = require 'q'
connection  = require('../config/connection_config').config.createConnection()

class Model

  databaseName: 'swm_data'
  
  db: -> connection.database @databaseName

  _rejectOrResolve: (deferred, doc, err) ->
    if err
      deferred.reject err
    else
      deferred.resolve doc

  get: (id) ->
    deferred = Q.defer()
    @db().get String(id), deferred.makeNodeResolver()
    return deferred.promise

  edit: (id, doc) ->
    deferred = Q.defer()
    @db().save id, doc._rev, doc, (err, res) =>
      return deferred.reject(err) if err 
      
      doc._rev = res.rev

      @_rejectOrResolve deferred, doc, err
    return deferred.promise

  create: (doc, done) ->
    deferred = Q.defer()
    # don't allow to set an id
    delete doc._id
    delete doc.id
    
    db.save doc, (err, res) ->
      return done(err) if err
      
      doc._rev = res.rev
      doc._id = res.id

      @_rejectOrResolve deferred, doc, err

    return deferred.promise

  remove: (id, done) ->
    deferred = Q.defer()
    
    db.get id, (err, doc) ->
      return deferred.reject(err) if err 
      
      db.remove id, doc._rev, (error, response) ->
        @_rejectOrResolve deferred, {}, err

    return deferred.promise

  removeAll: (docs, done) ->
    deferred = Q.defer()
    
    if(docs.length == 0)
      deferred.reject(message: 'No models to delete!')
      return deferred
    
    toDelete = []
    docs.forEach (doc) ->
      toDelete.push
        id: doc._id,
        _id: doc._id,
        _rev: doc._rev,
        _deleted: true

    db.save toDelete, deferred.makeNodeResolver()

    return deferred

module.exports = Model