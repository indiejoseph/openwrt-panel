'use strict'

angular.module('openwrtPanelApp.controllers', [])
	.controller 'MainCtrl', ($scope) ->
		$scope.awesomeThings = [
			'HTML5 Boilerplate'
			'AngularJS'
			'Karma'
		]
	.controller 'OptionsCtrl', ($scope) ->