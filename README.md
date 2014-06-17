# Odo - whatever you want it to be
A Nodejs framework for creating awesome things.

Install via npm

```zsh
npm install --save odo
```

[Status and current work on Trello](https://trello.com/board/odo/4f7b3e995aa70d786202e667)

## Goals
1. Easy to install, use, modify, adapt and refactor
2. Modular and lightweight components that are useful independently
3. Strong cohesion where things change at the same rate, loose coupling where things change at a different rate
4. Few concepts needed in any one area of the code to keep mental effort of development low

Odo hopefully follows these goals and also makes it easy to write applications that follow these goals.

## Techniques
- [Domain-driven design](http://martinfowler.com/tags/domain%20driven%20design.html)
- [Event sourcing](http://martinfowler.com/eaaDev/EventSourcing.html)
- [Command and Query Responsibility Segregation](http://martinfowler.com/bliki/CQRS.html)
- [Event-driven architecture](http://msdn.microsoft.com/en-nz/architecture/aa699424.aspx)
- [UI composition](http://www.udidahan.com/2012/06/23/ui-composition-techniques-for-correct-service-boundaries/)
- [Single-page applications](http://www.johnpapa.net/spa/)
- [Schema-less database](http://martinfowler.com/nosql.html)
- [Dependency injection](http://martinfowler.com/articles/injection.html)

---

# Get started
Fork [odo example](https://github.com/tcoats/odo-example)

# Overview
There are two types of code in Odo: infrastructure and plugins.

## Infrastructure
Tools, frameworks and techniques make up the odo infrastructure. Using existing 3rd party frameworks and libraries has been prioritised over custom development. Where existing frameworks are not available small independent utilities have been written.

The goal of any infrastructure code is to accomplish one task, do it well and have few touch points with any other code.

Infrastructure is included as and when you need it by code you write. Components like the hub 'odo/hub' and humanize 'odo/humanize' are examples of infrastructure.

## Plugins
Plugins are independent features of the application loosely coupled to other plugins to make up the whole application. Usually plugins communicate through a combination of dependency injection and events.

Plugins are added to the systems array in config.cson. Express web authentication modules 'odo/auth', 'odo/auth/local', 'odo/auth/facebook' and public folder 'odo/public' are examples of plugins.

## Execution context
Plugins can run in four contexts: web, api, domain and projection. This technique allows the web code, database logic, and validation rules for a particular piece of information to exist in the same codebase but run in four different contexts. Having all aspects in the same codebase increases speed of development and still provides good decoupling between concepts.

Plugins are loaded on startup and either expose themselves as a class or as a plain object. Specific methods are checked for and will be called depending on the context the plugin is running in. These methods are 'web', 'api', 'domain' and 'projection'.

```coffee
class ExamplePlugin
    web: =>
        console.log "I'm running in web context"
        # I can register express routes here
```

Frontend plugins are registered by backend code in the 'web' context. They have the ability to bind themselves to several hooks, most importantly as single page application routes through durandal.

---

# Backend infrastructure
## [Requirejs](http://requirejs.org/)
All of odo uses requirejs to pull together plugins and components. In the backend node.js's require function is passed into require to include npm modules.

```coffee
requirejs = require 'requirejs'
requirejs.config
    nodeRequire: require
    paths:
        odo: './node_modules/odo'
        local: './'
requirejs ['odo/bootstrap']
```

In the frontend requirejs is used more conventionally - included by a html file and configured by a javascript file.

## [Mandrill](http://mandrill.com/)
For sending emails.

```coffee
define ['odo/mandrill'], (Mandrill) ->
    options =
        message:
            text: 'An email sent with Mandrill'
            subject: 'Email from Odo'
            from_email: 'odo@odojs.com'
            from_name: 'Odo'
            to: [
                email: 'john.smith@example.com'
                name: 'John Smith'
                type: 'to'
            ]

    new Mandrill()
        .send(options)
        .then(-> console.log 'Email away!')
        .catch((err) -> console.log err)
```

## Configuration
Require 'odo/config' into your code to access all configuration.

Configuration is merged from five sources:

1. A local config.cson file
2. A cson formatted environment variable 'ODO_CONFIG'
3. Individual environment variables like 'EXPRESS_PORT'
4. A cson formatted environment variable 'ODO_EXAMPLE_ODO_CONFIG'
5. Individual environment variables like 'ODO_EXAMPLE_EXPRESS_PORT'

Use the local config.cson file to add plugins to your project, add configuration that won't change per environment and add events and commands you want published and sent at the start of the application.

Use the environment variable named 'ODO_CONFIG' for database details and other values that change between development and production environments and are shared across all applications running on the same computer.

Using the domain configuration set in config.cson an additional environment variable is also loaded. For example if odo: domain: 'odo-example' is present in the config.cson file then 'ODO_EXAMPLE_ODO_CONFIG' is also parsed. Use this for configuration specific to a project.

Direct environment variables are checked, see config.coffee for a template. For example both 'EXPRESS_PORT' and 'ODO_EXAMPLE_EXPRESS_PORT' will be checked to get the port express should run on, along with any values set in 'ODO_CONFIG' and 'ODO_EXAMPLE_ODO_CONFIG'.

## Eventstore
Eventstore provides tooling to help implement Event Sourcing. The infrastructure includes an extend method to add methods and properties to an aggregate object to support event sourcing and the CQRS pattern. It uses the eventstore library and is backed by redis.

See user.coffee for a web, domain and projection eventstore example.

## Hub
The hub used for cross plugin communication. It follows the CQRS pattern separating commands from events. The hub is using redis publish and subscribe with specific channels dedicated to each application. Event listers can be bound through the receive method and command handlers can be bound through the handle method. Send and publish methods are used to send commands and publish events.

```coffee
define ['odo/hub'], (hub) ->
    hub.receive 'userHasDisplayName', (event, cb) ->
        console.log "A new display name! #{event.payload.displayName}"
        cb()

    hub.send
        command: 'assignDisplayNameToUser'
        payload:
            id: 34
            displayName: 'John Smith'
            
    hub.publish
        event: 'subspotActivityHasIncreased'
        payload:
            amount: '100%'
```

## Plugin
Plugin is a component to help load other plugins. It provides web, api, domain and projection methods that call the same named method on an array of plugins passed to it's constructor.

```coffee
define [
    'odo/plugins'
    'local/identity/user'
    'local/identity/organisation'
    'local/identity/invitation'
    'local/identity/permissions'
    'local/identity/public'
], (Plugins, plugins...) ->
    new Plugins plugins
```

## Misc helpers
Recorder and sequencer are classes used internally, you're welcome to use them too although they might change.

---

# Backend plugins
## [Express](http://expressjs.com/)
The web context is based around express. Plugins exposed in the web context are given an opportunity to register against different parts of express to define routes and extend the express system.

```coffee
define ['odo/express'], (express) ->
    web: ->
        express.get '/test', (req, res) ->
            res.send 'Hello World'

```

'odo/express' needs to be included in the systems array after any plugins wanting web context.

## [Restify](http://mcavage.me/node-restify/)
The api context is based around restify. Plugins exposed in the api context are given the opportunity to register against different parts of restify to define routes and extend the restify system.

```coffee
define ['odo/restify'], (restify) ->
    web: ->
        restify.get '/test', (req, res) ->
            res.send 'Hello World'

```

'odo/restify' needs to be included in the systems array after any plugins wanting api context.

## Bower
The bower plugin hosts the /bower_components directory so anything you've installed with bower is available to the web.

E.g. `bower install --save jquery` will result in `http://localhost:1234/jquery/dist/jquery.min.js` being available, depending on your express port.

## Durandal
The durandal plugin allows other plugins to register components to be used in the Front End.

```coffee
define [
    'module'
    'odo/express'
    'odo/durandal'
], (module, express, durandal) ->
    web: ->
        express.route '/views', express.modulepath(module.uri) + '/public'
        durandal.register 'views/welcome'
```

And in a public folder is welcome.coffee and welcome.html:

```coffee
define ['knockout', 'plugins/router'], (ko, router) ->
    router.map
        route: ''
        moduleId: 'views/welcome'
    
    class Welcome
        title: 'Welcome'
        
        constructor: ->
            @displayName = ko.observable 'John Smith'
```

```html
<div class="test">
    <h1>Test Page</h1>
    <p>Welcome <span data-bind="text: displayName"></span><p>
</div>
```

## Handlebars
Handlebars is a plugin in the web context to register handlebars as the view engine for express and add additional functionality for handlebars including a custom render method.

```coffee
define ['odo/express'], (module, express) ->
    web: =>
        express.get '/test', (req, res) ->
            res.render
                view: 'templates/layout'
                data:
                    title: req.user.displayName
                    displayName: 'John Smith'
                partials:
                    content: 'test'
```

The code sample above will combine the layout template with the test template from a directory called 'templates' and pass in some information to be used when rendering.

layout.html:

```html
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge, chrome=1" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <title>{{title}}</title>
    </head>

    <body>
        {{hook 'content'}}
    </body>
</html>
```

test.html:

```html
<div class="test">
    <h1>Test Page</h1>
    <p>Welcome {{displayName}}<p>
</div>
```

## Public
The public plugin hosts the odo public directory through express which includes durandal components and identity and authentication code. Also hosts a public directory available in your application for static assets and durandal models and views.

## Passport authentication - local, google, facebook, twitter and metocean
The passport authentication plugins provide urls and methods to authenticate a user with passport and passport plugins. Custom local, twitter, facebook, google and metocean passport plugins have been provided.

---

# Technologies
## Developed alongside Odo
- [Tapinto](https://github.com/tcoats/tapinto) (tap into classes and methods)
- [Injectinto](https://github.com/tcoats/injectinto) (dependency injection)
- [Peekinto](https://github.com/tcoats/peekinto) (ui composition for express)
- [Fetching](https://github.com/tcoats/fetching) (fetching strategies)

## Backend and front end
- [Requirejs](http://requirejs.org/) (dependency injection)
- [Q](https://github.com/kriskowal/q) (promises)
- [node-uuid](https://github.com/broofa/node-uuid) (guids)
- [humanize](https://github.com/hubspot/humanize) (string formatting)

## Back end
- [Express](http://expressjs.com/) (http server)
- [Restify](http://mcavage.me/node-restify/) (rest api)
- [Redis](http://redis.io/) (storage)
- [Passport](http://passportjs.org/) (authentication)
- [js-md5](https://github.com/emn178/js-md5) (md5 hash)
- [eventstore](https://github.com/jamuhl/nodeEventStore) (event sourcing)
- [debug](https://github.com/visionmedia/debug) (tracing)
- [cson](https://github.com/bevry/cson) (coffeescript object notation)
- [multer](https://github.com/expressjs/multer) (file uploads)

## Front end
- [Durandaljs](http://durandaljs.com/) (single page app)
- [Knockoutjs](http://knockoutjs.com/) (mvvm in browser)
- [Knockoutjs Validation](https://github.com/Knockout-Contrib/Knockout-Validation) (validation)
- [jQuery](http://jquery.com/) (dom manipulation)
- [Bootstrap](http://getbootstrap.com/) (scaffolding)
- [Animate.css](https://daneden.me/animate/) (css animations)
- [Mousetrap](http://craig.is/killing/mice) (keyboard shortcuts)
