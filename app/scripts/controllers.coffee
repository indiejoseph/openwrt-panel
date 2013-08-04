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
		$scope.master = {}
		$scope.types = [
			{ id: 'button', name: 'Button' }
			{ id: 'slider', name: 'Slider' }
			{ id: 'display', name: 'display' }
		]
		$scope.inputs = [
			name: ''
			value: ''
			type: 'button'
		]
		$scope.addInput = (input) ->
			$scope.inputs.push
				name: ''
				value: ''
				type: 'button'

	.controller 'CardCtrl', ($scope) ->
		$scope = {}
	.controller 'SettingCtrl', ($scope) ->