var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var crypto = require('crypto');
var _ = require('underscore');
var config = require('../config').config;

var userSchema = mongoose.Schema({
  name: { type: String, required: true, unique: true },
  email: { type: String, validations: ['email'] },
  from_service: { type: String, default: 'local', required: true },
  service_userid: { type: String },
  pwhash: { type: String },
  yummed: { type: [Schema.Types.ObjectId], default: [] },
  created_at: { type: Date, default: Date.now }
});

/* STATICS */

// Creates a salted hash from a password
var getSaltedHash = function(password){
  var pwhash = crypto.createHash('sha1');
  pwhash.update(password + config.salt + password);
  return 'hashed-' + pwhash.digest('hex');
};

// creates a user with password
userSchema.statics.createWithPassword = function(data, cb){
  if(data.password && data.password.length < 6) return cb('Password not long enough.', null);
  return this.create({
    name: data.username,
    email: data.email,
    pwhash: getSaltedHash(data.password)
  }, cb)
};

// finds a user by its name
userSchema.statics.findByName = function(name, cb){
  return this.findOne({name: name}, cb);
};

/* METHODS */

// checks if a password from a user
userSchema.methods.checkPassword = function(password){
  var hash1 = this.pwhash;
  var hash2 = getSaltedHash(password);
  return hash1 === hash2;
};

// Adds a yum to the yummed yums
userSchema.methods.addYum = function(yum, cb){
  if(this.yummed.indexOf(yum._id) > -1) return cb('User already yummed this.', null);
  this.yummed.push(yum._id);
  this.save(cb)
};

// Has this user yummed this specific yum?
userSchema.methods.hasYummed = function(yum){
  return (this.yummed.indexOf(yum._id) > -1);
};

// It's important to white-list the user properties here, or we otherwise show private stuff (e.g. pwhash)
userSchema.methods.toJSON = function(){
  return {
    _id: this._id,
    name: this.name,
    yummed: this.yummed
  };
};

module.exports = mongoose.model('User', userSchema);