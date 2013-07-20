'use strict'

angular.module('openwrtPanelApp', ['openwrtPanelApp.controllers', 'openwrtPanelApp.directives'])
	.config ($routeProvider) ->
		$routeProvider
			.when '/',
				templateUrl: 'views/main.html',
				controller: 'MainCtrl'
			.when '/options',
				templateUrl: 'views/options.html',
				controller: 'OptionsCtrl'
			.otherwise
				redirectTo: '/'
