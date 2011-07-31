Lightweight is my web framework
===============================

A Nodejs framework for creating awesome things.

Requirements
------------

* Live on the Web
* Single git repo (split out later? Once there is a nuget style thing for javascript...?)
* Central database server (redis)
* Markdown and other text based documents are saved as text files
* Javascript library, up to date, easy to edit and examples
* Unit testing, automated testing
* Style library, use mindaweb techniques, examples
* Nodejs library and examples
* Public, private, family content (internet and intranet)
* Multiple logins
* Content Management: traditional, wiki, etc.
* Templating engine


Core Stories
------------

* Use routes when looking for directory contents (Shadow File System)
* Evaluate MVC modules
  * Zappa?
    * Not much difference to express
    * Only supports on view engine
  * Express is good enough already!
  
* Authentication
* Signin
* Signout
* View Users
* Edit Users
* Permissions [epic]


Content Stories
---------------

* Wiki stories
  * Display wiki articles (linkified)
  * List all wiki articles
  * Jump wiki articles
  * Edit wiki articles (basic)
  * Edit wiki articles (ace editor - source code, common actions)
  * Load mapped wiki articles
* Sitemap editor
  * Display sitemap (iPad / Folder list style)
  * Filter list
  * Create new page (with page type)
  * Delete page
  * Move page
  * Page attributes
* Content Management
  * Display cms content (basic - plain text)
  * Edit cms content
  * Create cms content
  * Rich text
  * Header with levels
  * Image
  * Image with text
  * Image gallery
  * Image has caption
  * Table
  * Definition List
  * Bullet list
* Product System
  


Spikes
------

* Hosting
  * How do I backup redis?
  * How do I replicate redis (for development, or do I access redis from external, if so auth?)
  * Need git push / pull database functionality - can redis?
  * Eventually productionise on the web (host? VPS? Linux at least)
* Forms Auth
* OAuth
* Single Sign On
* Product system - investigate nopCommerce


Goals
-----

* Most components of the system should function and be useful independently.
* This is the system I want to write software on.
* Others may join and write software in this system.
* SaaS


Lofty Goals
-----------

* iPad coding support
* Web coding support
* Eg. I want to be able to alter this code within itself
  * Ace is neat (iPad - branch with some intial ideas)


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