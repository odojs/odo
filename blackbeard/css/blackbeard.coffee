class App extends Backbone.Model

class EvaluationCollection extends Backbone.Collection
  model: Evaluation

class Evaluation extends Backbone.Model
  initialize: ->
    @set
      Skill: 0.05
      Output: 0.05
      Group: 0.05
      Delivery: 0.05
  


class ViewApp extends kb.ViewModel
  EditEvaluation: (evaluation) =>
    @EditingEvaluation evaluation
      
  SaveEvaluation: =>
    @EditingEvaluation undefined
    
  EditingEvaluation: ko.observable null


$ () ->
  window.model = new App {
    Evaluations: new EvaluationCollection [
      new Evaluation {
        Name: 'Thomas Coats'
      }
      new Evaluation {
        Name: 'Mathew'
      }
    ]
  }
  ko.applyBindings(new ViewApp window.model)
  
  $('.wizard').wizard();