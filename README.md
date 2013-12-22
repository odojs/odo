# Odo - whatever you want it to be

A Nodejs framework for creating awesome things.

## Goals

* Modular and lightweight
* Components useful independently
* Easy to install and modify
* Behaviour Driven Design and Test Driven Design
* Domain Driven Design
* Event Driven Architecture and messaging with events
* Single Page Applications
* Schema-less database
* Simple formats and micro formats
* Javascript frameworks and environment
* Style guidelines and structure
* Simple templating
* Service Oriented Architecture and Software as a Service

[Status and current work on Trello](https://trello.com/board/odo/4f7b3e995aa70d786202e667)


## Setup

```
./configure.sh
```

## Run

```
./thomascoats.com.sh
redis-server
```


## Unique technologies developed alongside Odo

* [Tapinto](https://github.com/tcoats/tapinto) (tap into classes and methods)
* [Injectinto](https://github.com/tcoats/injectinto) (dependency injection)
* [Peekinto](https://github.com/tcoats/peekinto) (ui composition)
* [Fetching](https://github.com/tcoats/fetching) (fetching strategies)


## Technologies used and available in nodejs

* [Express](http://expressjs.com/) (http server)
* [Moment.js](http://momentjs.com/) (date & time)
* [Redis](http://redis.io/) (storage)
* [Consolidate](http://jsdoc.info/visionmedia/consolidate.js/) (templating)
* [Handlebars](http://handlebarsjs.com/) (templating)
* [Passport](http://passportjs.org/) (authentication)
* [Passport Twitter](https://github.com/jaredhanson/passport-twitter) (authentication)
* [hub.js](http://maxantoni.de/projects/hub.js/) (messaging)
* [Underscore](http://underscorejs.org/) (collection utilities)
* [Requirejs](http://requirejs.org/) (dependency injection)
* [Q](https://github.com/kriskowal/q) (promises)


## Technologies used and available in browser

* [Durandaljs](http://durandaljs.com/) (single page app)
* [Knockoutjs](http://knockoutjs.com/) (mvvm in browser)
* [jQuery](http://jquery.com/) (dom manipulation)
* [Bootstrap](http://getbootstrap.com/) (scaffolding)
* [Underscore](http://underscorejs.org/) (collection utilities)
* [Requirejs](http://requirejs.org/) (dependency injection)
* [Animate.css](https://daneden.me/animate/) (css animations)
* [Mousetrap](http://craig.is/killing/mice) (keyboard shortcuts)
* [Q](https://github.com/kriskowal/q) (promises)

# Core libraries

Files in this directory are either components to requirejs into your application or plugins to load into the odo express  system to add functionality to the express environment.

## Bower

An express plugin to host the /bower_components directory so anything you've installed with bower is available on the web.

## Config

A component to requirejs into your code to access the top level configuration json file. Use that file to store environment specific settings and other pieces of information you don't want in source control.

## Durandal

An express plugin to host the contents of /odo/durandal-public to the web so the custom durandal components can be used by your odo durandal application.

## Eventstore

A component to requirejs into your application to setup and connect to an eventstore. Exposes an extend method to add methods and properties to an aggregate object to support event sourcing and the CQRS pattern. Uses the eventstore library.

## Express

The root component to requirejs into your application to setup an express server. Call it as a method and provide a list of odo express plugins to load into the runtime.

## Handlebars

An express plugin to extend the default handlebars implementation with additional features to support layouts, hooks and more.

## Hub

A component to requirejs into your application to create a CQRS hub that is connected to redis. Bind event listers through the exported receive method and bind command handlers through the exported handle method. Use send and publish to send commands and publish events.

## Injectinto

A component to requirejs into your application to provide the service locator pattern. Bind items to key string values and request items through the one, oneornull, and many methods.
Uses the injectinto library behind the scenes.

## Peek

Add the ability to 'peek' a request in express without fulfilling the request. This supports incremental loading of resources for templating, shared url authentication and other composition patterns. Uses the peekinto library behind the scenes.

## Twitter Auth

An express plugin that provides urls and methods to authenticate a user with twitter. Also hosts the twitterauth-public so durandal applications can communicate with the api.