# Code for a sample playspace, you're expected to provide your own ;)
extends Board

const cardTemplate = preload("res://src/core/CardTemplate.tscn")

var allCards := [] # A pseudo-deck array to hold the card objects we want to pull


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# We're assigning our positions programmatically,
	# instead of defining them on the scene.
	# This way any they will work with any size of viewport in a game.
	# Discard pile goes bottom right
	$DiscardPile.position = Vector2(get_viewport().size.x
			- $DiscardPile/Control.rect_size.x - 10,get_viewport().size.y
			- $DiscardPile/Control.rect_size.y)
	# Deck goes bottom left
	$Deck.position = Vector2(0,get_viewport().size.y
			- $Deck/Control.rect_size.y)
	# Hand goes in the middle of the two
	$Hand.position = Vector2(150,get_viewport().size.y
			- $Hand/Control.rect_size.y + $Hand.bottom_margin)
	$FancyMovementToggle.pressed = cfc.fancy_movement
	$ScalingFocusOptions.selected = cfc.focus_style
	# Fill up the deck for demo purposes
	if not get_tree().get_root().has_node('Gut'):
		load_test_cards()


# This function is to avoid relating the logic in the card objects
# to a node which might not be there in another game
# You can remove this function and the FancyMovementToggle button
# without issues
func _on_FancyMovementToggle_toggled(_button_pressed) -> void:
	cfc.fancy_movement = $FancyMovementToggle.pressed


# Reshuffles all Card objects created back into the deck
func _on_ReshuffleAll_pressed() -> void:
	for c in allCards:
		if c.get_parent() != cfc.NMAP.deck:
			c.move_to(cfc.NMAP.deck)
			yield(get_tree().create_timer(0.1), "timeout")


# Button to change focus mode
func _on_ScalingFocusOptions_item_selected(index) -> void:
	cfc.focus_style = index


# Button to make all cards act as attachments
func _on_EnableAttach_toggled(_button_pressed: bool) -> void:
	for c in allCards:
		c.is_attachment = $EnableAttach.pressed


# Loads a sample set of cards to use for testing
func load_test_cards() -> void:
	var test_cards := []
	for ckey in cfc.card_definitions.keys():
		test_cards.append(ckey)
	var test_card_array := []
	for _i in range(12):
		var random_card_name = \
				test_cards[CardFrameworkUtils.randi() % len(test_cards)]
		test_card_array.append(cfc.instance_card(random_card_name))
	# I ensure there's of each test card, for use in GUT
	for card_name in test_cards:
		test_card_array.append(cfc.instance_card(card_name))
	for card in test_card_array:
		$Deck.add_child(card)
		# warning-ignore:return_value_discarded
		card.set_is_faceup(false,true)
		card._determine_idle_state()
		allCards.append(card) # Just keeping track of all the instanced card objects for demo purposes
		#card.modulate.a = 0 # We use this for a nice transition effect
	$Deck.reorganize_stack()
