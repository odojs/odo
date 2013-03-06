# Odo is my web framework

A Nodejs framework for creating awesome things.

## Setup

  bower install
  npm install
  cd components/x-editable
  grunt build

## Requirements

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
    * https://github.com/coreh/nide/



## Technologies

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


# Plan

## Bookmarklet to add a new link:

1. Show both the title and the link, they are editable
2. Type to autocomplete a page
3. Select a page
4. Eventually type again to select a section
5. Select new page if what you typed doesn't exist
6. Page tells you want it's going to do
7. Press button to add
8. Shows page with added content
9. Metadata extraction from link


## Main page

0. Background should be awesome photos from around the world
1. Type to autocomplete a page
2. Select a page to browse
3. Select new page if what you typed doesn't exist
4. New page is created and starts editable


## Browse page

1. Type to autocomplete other pages is always available, same functionality as main page.
2. Can scroll through page and view content
3. Can click on links and browse to other pages
4. Can click to edit current page
5. Page shows some indication of where you are - folder etc.


## Edit page

1. Can delete page, shows confirmation first
2. Can rename page, errors on a duplicate name
3. Can move a page to another section when available
4. Can make changes to the page
5. Function to make lists
6. Function to automatically strip ugly links
7. Function to remove line breaks in a selected piece of text
8. Shorthand to add a link to another page, shows autocomplete, same functionality as main page eg can create new page
9. As much as possible is navigatable through the keyboard
10. Saves as you type but has revert
11. Option to finish edits and change back to browse
12. Option to link to this page from, autocomplete same functionality as bookmarklet page eg can add to a list in the page
13. Metadata extraction from content added


## Folders

* Privacy on folders
* Files that aren't in folders
* Subfolders


## Pages

* Pages have a description
* Types of pages
* Templates
* Recipes
* Skip / remind me later



# Event Store

## Commands

- Single destination
- Error if not handled
- Error if more than one handler
- Used to initiate change in another system that you don't have control of
- Versioned, but not through interfaces
- The command is given to other systems


## Events

- Multiple destinations or even none
- Versioned through interfaces because subscriber independence matters
- Can only subscribe to the interface (or pattern)
- The event is consumed by other systems


## Domain Event

- An event that causes / has caused a change to the domain.
- Not communicated to outside systems


## Aggregate

- The outcome of several events
- Can be formed by several objects
- Largely independent from other parts of the system
- A pure domain entity
- Can be loaded from a stream of events
- Can be loaded from a snapshot
- Can be loaded from a projection
- Generally for writing and domain logic


## Projection

- An outcome of several events
- Serves a single purpose, generally for reading


## Snapshot

- A serialised representation of an aggregate or projection at a certain time
- Used to short circuit loading objects from a store


## Possible flows

1. An aggregate is hydrated
2. A method is called on the aggregate
3. The aggregate fires off an event to change it's own values
4. The aggregate handles the event and updates it's values
5. The event is added to a new transaction in the event store
6. The transaction is committed
7. Any subscribed listeners are sent the events in the current transaction
8. If anything happens during the operation or the event is unable to be sent to a listener the whole transaction is rolled back.