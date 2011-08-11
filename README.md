Lightweight is my web framework
===============================

A Nodejs framework for creating awesome things.

Requirements
------------

* Live on the Web
* Repos per project, with cross-over
* Central database server (redis)
* Messaging Framework
* Markdown and other text based documents are saved as text files
* Javascript library, up to date, easy to edit and examples
* Unit testing, automated testing
* Style library, use mindaweb techniques, examples
* Nodejs library and examples
* Public, private, family content (internet and intranet)
* Multiple logins
* Content Management: traditional, wiki, etc.
* Templating engine
* Most components of the system should function and be useful independently.
* This is the system I want to write software on.
* Others may join and write software in this system.
* SaaS
* iPad coding support
* Web coding support
* Eg. I want to be able to alter this code within itself
  * Ace is neat (iPad - branch with some intial ideas)


Extension Points
----------------

* Define custom configurations (per environment)
  
  So the module can configure itself, and be configured
  
* Define custom routes (order defined by invoking app)

  So the module can host apps

* Define custom sections of shadow file system
  
  So routes that provide handlers for specific file extensions 'just work'

* Define additional script and style resources to be loaded by the templating engine

  Question: How? Which urls? How does the invoking app control this?

* Define additional cms content types to be available

* Need some sort of Ninject 'registrations for this interface' concept


Question: Is it enough to use the express method of extension?
Answer: No, I want to provide other points of extension, eg CMS types, register script and style files to be included (for example)



Technologies
------------

* Nodejs
  * Express
  * Connect
  * Formidable
  * Lazy
  * Paperboy
  * Redis
  * Nun
* Javascript
  * jQuery
  * datejs
  * jQuery cycle
  * jQuery easing
  * jQuery fieldselection
  * jQuery bbq
  * jQuery autocomplete (may pull to voodoo ac)
  * jQuery tmpl
  * jQuery flip
  * qunit
  * knockout
  * showdown
  * jQuery ui (if I have to)
  * swf Object
  * d3
* voodoojs (should rename to lightweight)
  * dialog
  * overlay
  * wizard (rip from minda web)
  * flash
  * markdown
  * gallery (or replace with something else)
  * menu
  * tiptip
* Standards
  * HTML 5
  * CSS 3
  * SVG
  * REST
  * OAuth
* tools
  * phantomjs