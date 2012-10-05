define [], ->
	pub = {}

	# TODO: is there any way for get all of these from chrome.i18n?
	keys = [
		"appName"
		"appDesc"
		"aboutMenuItem"
		"clearGalleryButton"
		"clearGalleryConfirmation"
		"filtersButton"
		"backButton"
		"backToCameraButton"
		"saveButton"
		"deleteDialogTitle"
		"deleteConfirmation"
		"yesButton"
		"noButton"
		"normal"
		"andy"
		"blockhead"
		"blueberry"
		"bulge"
		"colorHalfTone"
		"chubbyBunny"
		"dent"
		"flush"
		"frogman"
		"ghost"
		"giraffe"
		"inverted"
		"kaleidoscope"
		"mirrorLeft"
		"oldFilm"
		"photocopy"
		"pinch"
		"pixelate"
		"quad"
		"reflection"
		"sepia"
		"swirl"
		"zoomBlur"
	]

	pub[key] = chrome.i18n.getMessage(key) for key in keys

	return pub