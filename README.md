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


Stories
-------

* Create a Shadow File System
  * irror file system calls
* Auto detect modules and load
  * Can modules define their own urls?
  * Templates need a hierarchy - a site should override
* Authentication
  * Signin
  * Signout
* User management
  * View Users
  * Edit Users
  * Permissions [epic]
* Wiki
  * Display wiki articles (linkified) [done]
  * List all wiki articles [done]
  * Jump wiki articles [done]
  * Make wiki system pretty
  * Edit wiki articles (basic)
  * Edit wiki articles (ace editor - source code, common actions)
  * Load mapped wiki articles (Shadow File System)
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
  * How do I backup redis? - Using the rdb file
  * Redis authentication
  * Which host? (http://no.de/)
* Forms Auth
* OAuth
* Single Sign On
* Product system - investigate nopCommerce


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