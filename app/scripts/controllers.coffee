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
		$scope.inputs = [
			name: ''
			value: ''
			type: 0
		]
		$scope.addInput = ->
			$scope.inputs.push
				name: ''
				value: ''
				type: 0

	.controller 'CardCtrl', ($scope) ->
		$scope = {}
	.controller 'SettingCtrl', ($scope) ->