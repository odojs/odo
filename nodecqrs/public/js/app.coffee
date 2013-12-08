(->
  
  # Create Backbone Model and Collection
  # ------------------------------------
  
  # model
  Item = Backbone.Model.extend(
    modelName: 'item' # so denormalizers can resolve events to model
    initialize: ->
      
      # bind this model to get event updates - a lot of magic ;)
      # not more to do the model gets updated now
      @bindCQRS()
  )
  
  # collection
  Items = Backbone.Collection.extend(
    model: Item
    url: '/allItems.json'
  )
  items = new Items()
  
  
  
  # Init Backbone.CQRS
  # ------------------
  
  # we just have to override eventNameAttr:
  Backbone.CQRS.hub.init eventNameAttr: 'event'
  
  # override Backbone.sync with CQRS.sync which allows only GET method
  Backbone.sync = Backbone.CQRS.sync
  
  
  
  # Wire up communication to/from server
  # ------------------------------------
  
  # create a socket.io connection
  socket = io.connect 'http://localhost:3000'
  
  # on receiving an event from the server via socket.io 
  # forward it to backbone.CQRS.hub
  socket.on 'events', (evt) ->
    Backbone.CQRS.hub.emit 'events', evt

  # forward commands to server via socket.io
  Backbone.CQRS.hub.on 'commands', (cmd) ->
    socket.emit 'commands', cmd

  
  
  
  # Create a few EventDenormalizers
  # -------------------------------
  
  # itemCreated event 
  itemCreateHandler = new Backbone.CQRS.EventDenormalizer(
    methode: 'create'
    model: Item
    collection: items
    
    # bindings
    forModel: 'item'
    forEvent: 'itemCreated'
  )
  
  # itemChanged event
  itemChangedHandler = new Backbone.CQRS.EventDenormalizer(
    forModel: 'item'
    forEvent: 'itemChanged'
  )
  
  # itemDeleted event 
  itemDeletedHandler = new Backbone.CQRS.EventDenormalizer(
    methode: 'delete'
    
    # bindings
    forModel: 'item'
    forEvent: 'itemDeleted'
  )
  
  # Create Backbone Stuff
  # ---------------------
  
  # view templates
  itemTemplate = _.template("<%= text %> <a class=\"deleteItem\" href=\"\">delete</a> <a class=\"editItem\" href=\"\">edit</a>")
  editItemTemplate = _.template("<input id=\"newText\" type=\"text\" value=\"<%= text %>\"></input><button id=\"changeItem\">save</button>")
  
  # views
  ItemView = Backbone.View.extend(
    tagName: 'li'
    className: 'item'
    initialize: ->
      @model.bind 'change', @render, this
      @model.bind 'destroy', @remove, this

    events:
      'click .editItem': 'uiEditItem'
      'click .deleteItem': 'uiDeleteItem'
      'click #changeItem': 'uiChangeItem'

    
    # render edit input
    uiEditItem: (e) ->
      e.preventDefault()
      @model.editMode = true
      @render()

    
    # send deletePerson command with id
    uiDeleteItem: (e) ->
      e.preventDefault()
      
      # CQRS command
      cmd = new Backbone.CQRS.Command(
        id: _.uniqueId 'msg'
        command: 'deleteItem'
        payload:
          id: @model.id
      )
      
      # emit it
      cmd.emit()

    
    # send changeItem command with new name
    uiChangeItem: (e) ->
      e.preventDefault()
      itemText = @$('#newText').val()
      @$('#newText').val ""
      @model.editMode = false
      @render()
      if itemText
        
        # CQRS command
        cmd = new Backbone.CQRS.Command(
          id: _.uniqueId 'msg'
          command: 'changeItem'
          payload:
            id: @model.id
            text: itemText
        )
        
        # emit it
        cmd.emit()

    render: ->
      if @model.editMode
        $(@el).html editItemTemplate(@model.toJSON())
      else
        $(@el).html itemTemplate(@model.toJSON())
      this

    remove: ->
      $(@el).fadeOut 'slow'
  )
  IndexView = Backbone.View.extend(
    el: '#index-view'
    initialize: ->
      _.bindAll this, 'addItem'
      @collection = app.items
      @collection.bind 'reset', @render, this
      @collection.bind 'add', @addItem, this

    events:
      'click #addItem': 'uiAddItem'

    
    # send createPerson command
    uiAddItem: (e) ->
      e.preventDefault()
      itemText = @$('#newItemText').val()
      if itemText
        
        # CQRS command
        cmd = new Backbone.CQRS.Command(
          id: _.uniqueId('msg')
          command: 'createItem'
          payload:
            text: itemText
        )
        
        # emit it
        cmd.emit()
      @$('#newItemText').val ''

    render: ->
      @collection.each @addItem

    addItem: (item) ->
      view = new ItemView(model: item)
      @$('#items').append view.render().el
  )
  
  # Bootstrap Backbone
  # ------------------
  app = {}
  init = ->
    app.items = items
    app.items.fetch()
    indexView = new IndexView()
    indexView.render()

  
  # kick things off
  $ init
)()