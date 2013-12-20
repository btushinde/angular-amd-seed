define [
  'app'
], (app) ->

  app.register.controller 'HomeCtrl', [
    '$scope'
    '$window'
    '$rootScope'
    '$timeout'
    ($scope, $window, $rootScope, $timeout) ->
  ]
