'use strict'

angular.module('openwrtPanelApp.controllers', [])
	.controller 'MainCtrl', ($scope) ->
		$scope.cards = [
			{
				id: 1
				name: 'Test 1',
				inputs: [
					{}, {}
				]
			},
			{
				id: 2
				name: 'Test 2',
				inputs: [
					{}, {}
				]
			}
		]
	.controller 'CreateCtrl', ($scope) ->
		$scope = {}
	.controller 'CardCtrl', ($scope) ->
		$scope = {}
	.controller 'SettingCtrl', ($scope) ->