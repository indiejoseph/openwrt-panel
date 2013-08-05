'use strict'

angular.module('openwrtPanelApp.controllers', ['openwrtPanelApp'])
	.controller 'MainCtrl', ($scope) ->
		$scope.cards = []

	.controller 'CreateCtrl', ($scope, $rootScope, $cardFactory) ->
		$scope.master = {}
		$scope.types = [
			{ id: 'button', name: 'Button' }
			{ id: 'slider', name: 'Slider' }
			{ id: 'display', name: 'display' }
		]
		$scope.card =
			name: 'New Card'
			inputs: [
				name: ''
				value: ''
				type: 'button'
			]
		$scope.addInput = (input) ->
			$scope.card.inputs.push
				name: ''
				value: ''
				type: 'button'
		$scope.submit = ->
			newCard = new $cardFactory
			newCard.name = $scope.card.name
			newCard.inputs = $scope.card.inputs
			newCard.$save()

	.controller 'CardCtrl', ($scope) ->
		$scope = {}
	.controller 'SettingCtrl', ($scope) ->