'use strict'

angular.module('openwrtPanelApp.directives', [])
	.value('transitionEndEvents', [
  		'webkitTransitionEnd'
  		'transitionend'
  		'oTransitionEnd'
  		'otransitionend'
  		'transitionend'
	])
	.directive 'cardView', ($http) ->

		{
			restrict: 'ECA'
			transclude: true
			template: '<div class="card"><div class="card-front"><div ng-transclude></div></div><div class="card-back"></div></div>'
			link: (scope, parentElm, attr) ->

		}

	.directive 'transitionView', ($http, $templateCache, $route, $anchorScroll, $compile, $controller, transitionEndEvents, $location, $window) ->
		### SASS
		.page {
			position: absolute;
			width: 100%;

			&.back.in,
			&.back.out,
			&.forward.in,
			&.forward.out {
				@include transition(all 0.5s ease-out);
			}
			&.back.out,
			&.forward {
				@include transform(translateX(100%));
			}
			&.back.in,
			&.forward.in {
				@include transform(translateX(0%));
			}
			&.back,
			&.forward.out {
				@include transform(translateX(-100%));
			}
		}
		###

		### HTML
			<div class="container" transition-view in-class="in" out-class="out"></div>
		###

		window.backCounter = -1 if !window.backCounter?

		if !window.onpopstate?
			window.onpopstate = () ->
				window.backCounter++
				# console.log 'pop!!', window.backCounter

		onTransitionEnd = (element, callback) -> element[0].addEventListener(evt, callback) for evt in transitionEndEvents

		{
			restrict: 'ECA'
			terminal: true
			link: (scope, parentElm, attr) ->
				currentView = null
				views = []
				locations = []
				classes = scope.$eval(attr.transClasses) ||
					forward: 'forward'
					back: 'back'
					in: 'in'
					out: 'out'

				View = (routeData) ->
					# Bug: if we do angular.element(template) on some templates,
					# angular.element will throw an error. so we manually do innerHTML
					# and get the child
					el = document.createElement 'div'
					el.innerHTML = routeData.locals.$template || ''
					@element = angular.element el.children[0] || el
					@locals = routeData.locals
					@scope = @locals.$scope = scope.$new()
					if routeData.controller
						@controller = $controller routeData.controller, @locals
						@element.contents().data '$ngControllerController', @controller
					@

				insertView = (view) ->
					$compile(view.element.contents()) view.scope
					parentElm.append view.element
					view.scope.$emit '$viewContentLoaded'

				destroyView = (view) ->
					view.scope.$destroy()
					view.element.remove()
					view = null # delete view?

				transition = (inView, outView) ->
					# Do a timeout so the initial class for the
					# element has time to 'take effect'
					transClass = if inView.isBack then classes.back else classes.forward
					inView.element.addClass transClass
					if outView
						outView.element.removeClass "#{classes.forward} #{classes.back}"
						outView.element.addClass transClass
					setTimeout () ->
						inView.element.addClass classes.in
						onTransitionEnd inView.element, updateViewQueue
						if outView
							outView.element.removeClass classes.in
							outView.element.addClass classes.out
							onTransitionEnd outView.element, () -> destroyView outView
					, 100

				updateViewQueue = () ->
					# Bring in a new view if it exists
					if views.length > 0 
						view = views.shift()
						insertView view
						transition view, currentView
						currentView = view 

				update = () ->
					if $route.current and $route.current.locals.$template
						view = new View $route.current
						# console.log 'update!!'
						if window.backCounter > 0
							window.backCounter--
							view.isBack = true
						views.push view
						updateViewQueue()

				scope.$on '$routeChangeSuccess', update
				update()
		}