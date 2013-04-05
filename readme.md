Specunoode - a micro webframework / boilerplate
==============================================

Works great for classic websites as well as for single page apps. Also is great on hot toast :P
It's not a webframework in the sense or Rails or Django. Basically it's a combination of modules that worked well together for me in some node.js projects before and I finally wanted to have a biolerplate repo that I could use everytime I start a new project so that I won't have to start from scratch each time.

# Features

- Routing / Sessions (express.js)
- ORM (Mongoose.js)
- Authentication (passport.js)
- Controller-layer
- Erverything's already wired up for you (besides the config file ;))

# Requirements
- node (v0.8.x)
- MongoDB
- redis

# Specunoode - the name
This little piece of software has been developed while consuming unhealthy amounts of Speculoos pasta :P
Hence, the name :)

![Speculoos Pasta](http://farm4.static.flickr.com/3082/3216107732_5a4031dfd3.jpg)
Image by [Kim Tyo-Dickerson](http://www.flickr.com/photos/76282222@N00/3216107732/)

# yum.is

The deployed version of this project can be accessed at: <http://yum.is>

# Getting started

1. Install `mongodb`, `mongohub` (when on MacOSX), `redis`, `node (v0.8.x)`
2. Run `npm install`
3. Start mongodb (by executing `mongod`)
4. Start redis with `redis-server`
5. Copy the content of `server/config.sample.js` into a new file: `server/config.js`
6. Fill in your database information and salts
7. Add `127.0.0.1 YOURDEVDOMAIN` to your `/etc/hosts` (this step is only rquired if you want to use OAuth providers in the development environment)
8. Run `node server`
9. Go to <http://127.0.0.1:3000> (or whatever appPort or domain you specified)

# Running the tests

1. Check the test configuration in your `server/config.js`
2. `npm test`
3. Enjoy the console output :)

# Code organization

## Backend

The entry point for the backend code is `server.js`. It's the file that node.js takes to configure and start the server. In the first lines all the needed requirements are defined that are needed for starting it up (lines 1-13). After that we connect to the database and set up the auth-module (lines 15-43, [passport.js](http://passportjs.org)). The auth module is using some helper methods for creating new users in the database that come from `server/auth.js`.

In lines 45 to 101 there is more config for the routing and request framework ([express.js](http://expressjs.com)) we're using. It contains details about the session handling and the session storage, as well as a precompiler for our CSS preprocessor ([stylus](http://learnboost.github.com/stylus/)).

From line 107 on you can find the route-definitions that map routes to controller functions. They're grouped so that all the routes for one controller are one block for easier reading. We decided to keep the route definitions in the same file as the server config because it's very common in nodejs projects and also we we're then able to find things faster.

All controllers reside in `server/controllers`. They're normal node.js modules which export certain functions to the router. The functions are named after the RoR conventions: creating a new entitiy -> contoller#create, deleting an entity -> controller#destroy.

Controllers are using the models from `server/models` to execute logic. In general we tried to keep the contollers as thin as possible in order to have most of the logic in the models. Only `yum_controller#create` needs more validation in the controller than the others.

The models base on the ORM [MongooseJS](http://mongoosejs.com). Although MongoDB itself is a schema-free database, MongooseJS puts a schema definition on top of models for validations, indexes and default values. Each model has a set of static functions and methods. The static functions are used for queries e.g. Venue.findbyLocation(loc). Methods are used for operations an a specific model e.g. yum.isOwnedBy(user).

## Frontend

The views are organized in folders like in RoR, same for styles and js.

We're using [jade](http://jade-lang.com) as templating engine which provides an easy inheritance. 
The parent view is the `layout.jade`, which contains the basic layout like the header, footer and the meta information about the site. All other views are extending this view and overriding the content block (line 38 in `layout.jade`) with the specifiy one. 

In the `search/show.jade` view we include an other template, depending on the selected search. 

The basic responsiveness of the site is implemented with the [Skeleton](http://www.getskeleton.com/) CSS files. Skeleton resets the CSS of the site and provides some nice-looking-styles, e.g. buttons, input-fields etc. It provides an easy way for working with a grid based layout, so it is possible to create some columns and rows which are responsive, too. 

The CSS for the site is written with the [Stylus](http://learnboost.github.com/stylus/), a CSS preprocessor like yaml, that allows writing faster and cleaner CSS. We structured Stylus-files the way Ruby on Rails does it with css/yaml files. That means the styles for /search/yums are stored in /styles/search/yums and so on

We used the same structure for our views and JavaScript files, to have a consistent pattern throughout our project.

We made use of the Google Maps API v3 to display submitted yums with custom markers and wrapped the Google Maps functionality in a jQuery plugin which also checks for screen-width and screen-width-changes to display a list of yums instead of a map for smaller/mobile devices.

## Tests

For testing we're using [Mocha](http://visionmedia.github.com/mocha/) with [ShouldJS](https://github.com/visionmedia/should.js) on top, which allows us to formulate our tests in BDD-style. All test files are organized in folders and can be found in `test/[models|controllers]/`.
