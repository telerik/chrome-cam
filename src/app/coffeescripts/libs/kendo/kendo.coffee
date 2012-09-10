define([
	'order!libs/kendo/kendo.core'
	'order!libs/kendo/kendo.fx'
	'order!libs/kendo/kendo.data'
	'order!libs/kendo/kendo.binder'
	'order!libs/kendo/kendo.history'
	'order!libs/kendo/kendo.draganddrop'
	'order!libs/kendo/kendo.mobile.scroller'
	'order!libs/kendo/kendo.mobile.view'
	'order!libs/kendo/kendo.mobile.loader'
	'order!libs/kendo/kendo.mobile.pane'
	'order!libs/kendo/kendo.mobile.application'
	'order!libs/kendo/kendo.userevents'
	'order!libs/kendo/kendo.touch'
], ->
  # Tell Require.js that this module returns a reference to jQuery
  return kendo
)
