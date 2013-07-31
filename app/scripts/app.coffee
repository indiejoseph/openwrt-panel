'use strict'

angular.module('openwrtPanelApp', ['openwrtPanelApp.controllers', 'openwrtPanelApp.directives'])
	.config ($routeProvider) ->
		$routeProvider
			.when '/',
				templateUrl: 'views/main.html',
				controller: 'MainCtrl'
			.when '/card/:cardID',
				templateUrl: 'views/card.html',
				controller: 'CardCtrl'
			.when '/settings',
				templateUrl: 'views/settings.html',
				controller: 'SettingCtrl'
			.when '/create',
				templateUrl: 'views/create.html',
				controller: 'CreateCtrl'
			.otherwise
				redirectTo: '/'
	.run ($rootScope, $location) ->
		$rootScope.previousPage = () ->
			if window.backCounter? && window.backCounter > 0
				return window.history.back()
			else
				return $location.path '/'