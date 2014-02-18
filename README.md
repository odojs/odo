# Odo - whatever you want it to be

A Nodejs framework for creating awesome things.

[Status and current work on Trello](https://trello.com/board/odo/4f7b3e995aa70d786202e667)

## Goals
1. Easy to install, use, modify, adapt and refactor
2. Modular and lightweight components that are useful independently
3. Strong cohesion where things change at the same rate, loose coupling where things change at a different rate
4. Few concepts needed in any one area of the code to keep mental effort of development low

## Techniques
- [Domain-driven design](http://martinfowler.com/tags/domain%20driven%20design.html)
- [Event sourcing](http://martinfowler.com/eaaDev/EventSourcing.html)
- [Command and Query Responsibility Segregation](http://martinfowler.com/bliki/CQRS.html)
- [Event-driven architecture](http://msdn.microsoft.com/en-nz/architecture/aa699424.aspx)
- [UI composition](http://www.udidahan.com/2012/06/23/ui-composition-techniques-for-correct-service-boundaries/)
- [Single-page applications](http://www.johnpapa.net/spa/)
- [Schema-less database](http://martinfowler.com/nosql.html)
- [Dependency injection](http://martinfowler.com/articles/injection.html)

# Get started

Fork [odo example](https://github.com/tcoats/odo-example)

# Overview
There are two types of code in Odo: infrastructure and plugins.

## Infrastructure
Tools, frameworks and techniques make up the odo infrastructure. Using existing 3rd party frameworks and libraries is prioritised over custom development. Where existing frameworks are not available small independent utilities have been written.

The goal of any infrastructure code is to accomplish one goal, do it well and have few touch points with any other code.

## Plugins
Plugins are independent features of the application loosely coupled to other plugins to make up the whole application. Usually plugins communicate through a combination of dependency injection and events.

Backend plugins can run in three contexts: web, domain and projection. This technique allows the web code, database logic, and validation rules for a particular piece of information to exist in the same codebase but run in three different contexts. Having all aspects in the same codebase increases speed of development and still provides good decoupling between concepts.

Frontend plugins are registered by backend code. They have the ability to register themselves against several hooks - most importantly single page application routes through durandal.

# Backend infrastructure

## Require.js
All of odo uses require.js to pull together plugins and components. In the backend node.js's require function is passed into require to include npm modules.

## Express
The root component to requirejs into your web application to setup an express website. Web plugins are given an opportunity to register against different parts of express to define routes and extend the express system.

## Config
A component to requirejs into your code to access the top level configuration json file. Use that file to store environment specific settings and other pieces of information you don't want in source control.

## Eventstore
A component to requirejs into your application to setup and connect to an eventstore. Exposes an extend method to add methods and properties to an aggregate object to support event sourcing and the CQRS pattern. Uses the eventstore library.

## Hub
A component to requirejs into your application to create a CQRS hub that is connected to redis. Bind event listers through the exported receive method and bind command handlers through the exported handle method. Use send and publish to send commands and publish events.

## Plugin
A component to help load other plugins. Provides web, domain and projection methods that call the same named method on an array of plugins passed to it's constructor.

# Backend plugins

## Messaging
Provides a sendcommand endpoint to make it easy to create commands from the web.

## Bower
An express plugin to host the /bower_components directory so anything you've installed with bower is available to the web. Also provides the inject library to the front end for UI composition.

## Durandal
An express plugin to host the contents of /odo/durandal/public to the web so the custom durandal components can be used by your odo durandal application. This includes dialogs, wizards and many extensions to the durandal system.

## Passport authentication - local, google, facebook and twitter
An express plugin that provides urls and methods to authenticate a user with passport and passport plugins. Custom local, twitter, facebook and google passport plugins have been provided.

# Technologies

## Technologies developed alongside Odo

- [Tapinto](https://github.com/tcoats/tapinto) (tap into classes and methods)
- [Injectinto](https://github.com/tcoats/injectinto) (dependency injection)
- [Peekinto](https://github.com/tcoats/peekinto) (ui composition)
- [Fetching](https://github.com/tcoats/fetching) (fetching strategies)

## Technologies used and available in nodejs

- [Requirejs](http://requirejs.org/) (dependency injection)
- [Express](http://expressjs.com/) (http server)
- [Redis](http://redis.io/) (storage)
- [Passport](http://passportjs.org/) (authentication)
- [hub.js](http://maxantoni.de/projects/hub.js/) (messaging)
- [Q](https://github.com/kriskowal/q) (promises)
- [node-uuid](https://github.com/broofa/node-uuid) (guids)
- [js-md5](https://github.com/emn178/js-md5) (md5 hash)
- [eventstore](https://github.com/jamuhl/nodeEventStore) (event sourcing)


## Technologies used and available in browser

- [Requirejs](http://requirejs.org/) (dependency injection)
- [Durandaljs](http://durandaljs.com/) (single page app)
- [Knockoutjs](http://knockoutjs.com/) (mvvm in browser)
- [Knockoutjs Validation](https://github.com/Knockout-Contrib/Knockout-Validation) (validation)
- [jQuery](http://jquery.com/) (dom manipulation)
- [Q](https://github.com/kriskowal/q) (promises)
- [Bootstrap](http://getbootstrap.com/) (scaffolding)
- [Animate.css](https://daneden.me/animate/) (css animations)
- [Mousetrap](http://craig.is/killing/mice) (keyboard shortcuts)
- [node-uuid](https://github.com/broofa/node-uuid) (guids)
