// Generated by CoffeeScript 1.6.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(['knockout', 'articles'], function(ko, ArticleLogic) {
    var ReviewArticle;
    return ReviewArticle = (function() {
      function ReviewArticle() {
        this.close = __bind(this.close, this);
        this.submit = __bind(this.submit, this);
        this.activate = __bind(this.activate, this);
        this.articlename = ko.observable('');
        this.area = ko.observable('');
        this.articleLogic = new ArticleLogic();
      }

      ReviewArticle.prototype.activate = function(options) {
        var activationData;
        this.wizard = options.wizard, this.dialog = options.dialog, activationData = options.activationData;
        this.articlename(activationData.name);
        return this.area(activationData.area);
      };

      ReviewArticle.prototype.submit = function() {
        var article,
          _this = this;
        article = {
          name: this.articlename(),
          area: this.area()
        };
        return this.articleLogic.createArticle(article).then(function() {
          return _this.close(article);
        });
      };

      ReviewArticle.prototype.close = function(response) {
        return this.dialog.close(response);
      };

      return ReviewArticle;

    })();
  });

}).call(this);
