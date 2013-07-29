'use strict'

angular.module('openwrtPanelApp.controllers', [])
	.controller 'MainCtrl', ($scope) ->
		console.log $scope.cards
		$scope.cards = [
			{
				name: 'Test 1',
				inputs: [
					{}, {}
				]
			},
			{
				name: 'Test 2',
				inputs: [
					{}, {}
				]
			}
		]

	.controller 'CardCtrl', ($scope) ->
		$scope = {}
	.controller 'SettingCtrl', ($scope) ->