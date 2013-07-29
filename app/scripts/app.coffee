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
			.otherwise
				redirectTo: '/'