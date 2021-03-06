# This contains information about one specific task requested by the card
# automation
#
# It also contains methods to return properties of the task and to find
# the required objects in the game
class_name ScriptTask
extends Reference

#---------------------------------------------------------------------
# Script Definition Keys
#
# The below are all the possible dictionary keys that can be set in a
# task definition.
# Most of them are only relevant for a specific task type
#---------------------------------------------------------------------

# Determines which card, if any, this script will try to affect.
#
# See the `KEY_SUBJECT_V_` consts for the possible values for this key
#
# If key does not exist, we set value to [], assuming there's no subjects
# in the task.
const KEY_SUBJECT := "subject"
# * If this is the value of the "subject" key,
# we initiate targetting from the owner card
const KEY_SUBJECT_V_TARGET := "target"
# * If this is the value of the "subject" key,
# then the task affects the owner card only.
const KEY_SUBJECT_V_SELF := "self"
# * If this is the value of the "subject" key,
# then we search all cards on the table
# by node order, and return **all** candidates that match the filter
#
# This allows us to make tasks which will affect more than 1 card at
# the same time (e.g. "All Soldiers")
const KEY_SUBJECT_V_BOARDSEEK := "boardseek"
# * If this is the value of the "subject" key,
# then we search all cards on the specified
# pile by node order, and pick the first candidate that matches the filter
const KEY_SUBJECT_V_TUTOR := "tutor"
# * If this is the value of the "subject" key,
# then we pick the card on the specified
# source pile by its index among other cards.
const KEY_SUBJECT_V_INDEX := "index"
# * If this is the value of the "subject" key,
# then we use the subject specified in the previous task
const KEY_SUBJECT_V_PREVIOUS := "previous"
# This key is used to mark a task as being a cost requirement before the
# rest of the defined tasks can execute.
#
# If any tasks marked as costs will not be able to fulfil, then the whole
# script is not executed.
#
# Currently the following tasks support being set as costs:
# * rotate_card
# * flip_card
# * mod_tokens
const KEY_IS_COST := "is_cost"
# Used when a script is triggered by a signal.
#
# Limits the execution depending on the triggering card. Value options are:
# * "self": Triggering card has to be the owner of the script
# * "another": Triggering card has to not be the owner of the script
# * "any" (default): Will execute regardless of the triggering card.
const KEY_TRIGGER := "trigger"
# Used when a script is using the rotate_card task
#
# These are the degress in multiples of 90, that the subjects will be rotated.
const KEY_DEGREES := "degrees"
# Used when a script is using the flip_card task. Values are:
# * true: The card will be set face-up
# * false: The card will be set face-down
const KEY_SET_FACEUP := "set_faceup"
# Used when a script is using one of the following tasks
# * move_card_cont_to_cont
# * move_card_cont_to_board
#
# Specifies the source container to pick the card from
const KEY_SRC_CONTAINER := "src_container"
# Used when a script is using one of the following tasks
# * move_card_to_container
# * move_card_cont_to_cont
# * shuffle_container
#
# Specifies the destination container to manipulate
const KEY_DEST_CONTAINER := "dest_container"
# Used when we're seeking a card inside a [CardContainer]
# in one of the following tasks
# * move_card_cont_to_board
# * move_card_cont_to_cont
#
# Default is to seek card at index 0
const KEY_SUBJECT_INDEX := "subject_index"
# Used when placing a card inside a [CardContainer]
# in one of the follwing tasks
# * move_card_to_container
# * move_card_cont_to_cont
#
# When -1 is defined, it is placed on the last position
const KEY_DEST_INDEX := "dest_index"
# Used when a script is using one of the following tasks
# * move_card_to_board
# * move_card_cont_to_board
#
# If Vector2(-1,-1) is specified, it uses the mouse position
# which obviously not good for scripts
const KEY_BOARD_POSITION := "board_position"
# Used when a script is using the mod_tokens task
#
# It specifies if we're modifying the existing amount
# or setting it to the exact one
const KEY_TOKEN_SET_TO_MOD := "set_to_mod"
# Used when a script is using the mod_tokens task
#
# It specifies the name of the token we're modifying
const KEY_TOKEN_NAME := "token_name"
# Used when a script is using the mod_tokens task
#
# It specifies the amount we're setting/modifying
# or setting it to the exact one
const KEY_TOKEN_MODIFICATION := "modification"
# Used when a script is using the spawn_card task
#
# This is the path to the card template scene to use for this card
const KEY_CARD_SCENE := "card_scene"

#---------------------------------------------------------------------
# Filter Definition Keys
#
# The below are all the possible dictionary keys that can be set in a
# filter definition.
# Most of them are only relevant for a specific task type
#---------------------------------------------------------------------

# Filter used for checking against Card.properties
#
# This is open ended in the end, as the check can be run either
# against the trigger card, or the subjects card
# see _check_properties()
const FILTER_PROPERTIES := "filter_properties_"
# Filter used in for checking against TRIGGER_DEGREES
const FILTER_DEGREES := "filter_degrees"
# Filter for checking against TRIGGER_FACEUP
const FILTER_FACEUP := "filter_faceup"
# Filter for checking against TRIGGER_SOURCE
const FILTER_SOURCE := "filter_source"
# Filter for checking against TRIGGER_DESTINATION
const FILTER_DESTINATION := "filter_destination"
# Filter used for checking against TRIGGER_NEW_TOKEN_VALUE
const FILTER_TOKEN_COUNT := "filter_token_count"
#  Filter compared against
# * TRIGGER_V_TOKENS_INCREASED
# * TRIGGER_V_TOKENS_DECREASED
const FILTER_TOKEN_DIFFERENCE := "filter_token_difference"
# Filter used for checking against TRIGGER_TOKEN_NAME
const FILTER_TOKEN_NAME := "filter_token_name"

#---------------------------------------------------------------------
# Signal Properties
#
# The below are all the possible dictionary keys send in the dictionary
# passed by a card trigger signal (See Card signals)
#
# Most of them are only relevant for a specific task type
#---------------------------------------------------------------------

# Filter value sent by the trigger Card `card_rotated` signal.
#
# These are the degress in multiples of 90, that the subjects was rotated.
const TRIGGER_DEGREES := "degrees"
# Filter value sent by the trigger Card `card_flipped` signal.
#
# This is the facing of trigger.
# * true: Trigger turned face-up
# * false: Trigger turned face-down
const TRIGGER_FACEUP := "is_faceup"
# Filter value sent by one of the trigger Card's following signals:
# * card_moved_to_board
# * card_moved_to_pile
# * card_moved_to_hand
# The value will be the node name the Card left
const TRIGGER_SOURCE := "source"
# Filter value sent by one of the trigger [Card]'s following signals:
# * card_moved_to_board
# * card_moved_to_pile
# * card_moved_to_hand
# The value will be the node name the Card moved to
const TRIGGER_DESTINATION := "destination"
# Filter value sent by the trigger Card `card_token_modified` signal.
#
# This is the current value of the token.
# If token was removed value will be 0
const TRIGGER_NEW_TOKEN_VALUE := "new_token_value"
# Filter value sent by the trigger Card `card_token_modified` signal.
#
# This is the value the token had before it was modified
# If token was removed value will be 0
const TRIGGER_PREV_TOKEN_VALUE := "previous_token_value"
# Filter value sent by the trigger Card `card_token_modified` signal.
#
# This is the value of the token name modified
const TRIGGER_TOKEN_NAME = "token_name"
# Filter value sent by the following signals.
# * card_attached
# * card_unattached
# It contains the host object onto which this card attached
# of from which it unattached
const TRIGGER_HOST = "token_name"


#---------------------------------------------------------------------
# Signal Values
#
# Some filter check signals against constants. They are defined below
#---------------------------------------------------------------------

const TRIGGER_V_TOKENS_INCREASED := "increased"
const TRIGGER_V_TOKENS_DECREASED := "decreased"

# Sent when the _init() method has completed
signal completed_init

# The card which owns this Task
var owner: Card
# The card which triggered this Task.
#
# It is typically `"self"` during manual execution,
# but is `"another"` card during signal-based execution
var trigger: Card
# The subjects is typically a `Card` object
# in the future might be other things
var subjects: Array
# The name of the method to call in the ScriptingEngine
# to implement this task
var task_name: String
# Storage for all details of the task definition
var properties : Dictionary
# Stores the details arg passed the signal to use for filtering
var signal_details : Dictionary
# Used by the ScriptingEngine to know if the task
# has finished processing targetting
var has_init_completed := false
# If true if this task is valid to run.
# A task is invalid to run if some filter does not match.
var is_valid := true

# prepares the properties needed by the task to function.
func _init(card: Card,
		trigger_card: Card,
		details: Dictionary,
		script: Dictionary,
		prev_subjects: Array) -> void:
	# We store the card which executes this task
	owner = card
	# We store the card which triggered this task (typically via signal)
	trigger = trigger_card
	# We store all the task properties in our own dictionary
	properties = script
	# The function name to be called gets its own var
	signal_details = details
	# The function name to be called gets its own var
	task_name = get("name")
	# We test if this task is valid
	_filter_trigger()
	# We only seek targets if the task is valid
	if is_valid:
		# We discover which other card this task will affect, if any
		var ret =_find_subjects(prev_subjects)
		if ret is GDScriptFunctionState: # Still working.
			ret = yield(ret, "completed")
	# We emit a signal when done so that our ScriptingEngine
	# knows we're ready to continue
	emit_signal("completed_init")
	has_init_completed = true


# Returns the specified property of the string.
# Also sets appropriate defaults when then property has not beend defined.
func get(property: String):
	var default
	# for property details, see const definitionts
	match property:
		KEY_IS_COST:
			default = false
		KEY_TRIGGER:
			default = "any"
		KEY_SUBJECT_INDEX:
			default = 0
		KEY_DEST_INDEX:
			default = -1
		KEY_BOARD_POSITION:
			default = Vector2(-1,-1)
		KEY_TOKEN_SET_TO_MOD:
			default = false
		KEY_TOKEN_MODIFICATION:
			default = 1
		_:
			default = null
	return(properties.get(property,default))


# Figures out what the subjects of this script is supposed to be.
#
# Returns a Card object if subjects is defined, else returns null.
func _find_subjects(prev_subjects := []) -> Card:
	var subjects_array := []
	# See KEY_SUBJECT doc
	match get(KEY_SUBJECT):
		# Ever task retrieves the subjects used in the previous task.
		# if the value "previous" is given to the "subjects" key, 
		# it simple reuses the same ones.
		KEY_SUBJECT_V_PREVIOUS:
			subjects_array = prev_subjects
		KEY_SUBJECT_V_TARGET:
			if owner.target_dry_run_card:
				is_valid = _check_properties(owner.target_dry_run_card,"subject")
				subjects_array.append(owner.target_dry_run_card)
				owner.target_dry_run_card = null
			else:
				var c = _initiate_card_targeting()
				if c is GDScriptFunctionState: # Still working.
					c = yield(c, "completed")
				is_valid = _check_properties(c,"subject")
				subjects_array.append(c)
		KEY_SUBJECT_V_BOARDSEEK:
			for c in cfc.NMAP.board.get_all_cards():
				if _check_properties(c,"seek"):
					subjects_array.append(c)
		KEY_SUBJECT_V_TUTOR:
			# When we're tutoring for a subjects, we expect a
			# source CardContainer to have been provided.
			for c in get(KEY_SRC_CONTAINER).get_all_cards():
				if _check_properties(c,"tutor"):
					subjects_array.append(c)
					break
		KEY_SUBJECT_V_INDEX:
			# When we're seeking for index, we expect a
			# source CardContainer to have been provided.
			var index: int = get(KEY_SUBJECT_INDEX)
			var src_container: CardContainer = get(KEY_SRC_CONTAINER)
			subjects_array.append(src_container.get_card(index))
		KEY_SUBJECT_V_SELF:
			subjects_array.append(owner)
		_:
			subjects_array = []
	subjects = subjects_array
	return(subjects_array)


# Handles initiation of target seeking.
# and yields until it's found.
#
# Returns a Card object.
func _initiate_card_targeting() -> Card:
	# We wait a centisecond, to prevent the card's _input function from seeing
	# The double-click which started the script and immediately triggerring
	# the target completion
	yield(owner.get_tree().create_timer(0.1), "timeout")
	owner.initiate_targeting()
	# We wait until the targetting has been completed to continue
	yield(owner,"target_selected")
	var target = owner.target_card
	#owner.target_card = null
	return(target)

# Ensures that all filters requested by the script are respected
#
# Will set is_valid to false if any filter does not match reality
func _filter_trigger():
	# Here we check that the trigger matches the _request_ for trigger
	# A trigger which requires "another" card, should not trigger
	# when itself causes the effect.
	# For example, a card which rotates itself whenever another card
	# is rotated, should not automatically rotate when itself rotates.
	if get("trigger") == "self" and trigger != owner:
		is_valid = false
	if get("trigger") == "another" and trigger == owner:
		is_valid = false

	# Checking card properties is its own function as it might be
	# called from other places as well
	is_valid = _check_properties(trigger, "trigger")

	# Card Rotation filter checks
	if get(FILTER_DEGREES) \
			and get(FILTER_DEGREES) != signal_details.get(TRIGGER_DEGREES):
		is_valid = false

	# Card Flip filter checks
	if get(FILTER_FACEUP) \
			and get(FILTER_FACEUP) != signal_details.get(TRIGGER_FACEUP):
		is_valid = false

	# Card move filter checks
	if get(FILTER_SOURCE) \
			and get(FILTER_SOURCE) != signal_details.get(TRIGGER_SOURCE):
		is_valid = false
	if get(FILTER_DESTINATION) \
			and get(FILTER_DESTINATION) != signal_details.get(TRIGGER_DESTINATION):
		is_valid = false

	# Card Tokens filter checks
	if get(FILTER_TOKEN_COUNT) \
			and get(FILTER_TOKEN_COUNT) != signal_details.get(TRIGGER_NEW_TOKEN_VALUE):
		is_valid = false
	if get(FILTER_TOKEN_DIFFERENCE):
		var prev_count = signal_details.get(TRIGGER_PREV_TOKEN_VALUE)
		var new_count = signal_details.get(TRIGGER_NEW_TOKEN_VALUE)
		# Is true if the amount of tokens decreased
		if get(FILTER_TOKEN_DIFFERENCE) == TRIGGER_V_TOKENS_INCREASED \
				and prev_count > new_count:
			is_valid = false
		# Is true if the amount of tokens increased
		if get(FILTER_TOKEN_DIFFERENCE) == TRIGGER_V_TOKENS_DECREASED \
				and prev_count < new_count:
			is_valid = false
	if get(FILTER_TOKEN_NAME) \
			and get(FILTER_TOKEN_NAME) != signal_details.get(TRIGGER_TOKEN_NAME):
		is_valid = false

func _check_properties(card: Card, type := "trigger") -> bool:
	var card_matches := true
	# Card properties filter checks. We use the type of seek we're doing
	# To know which dictionary property to pass for the required dict
	# This way a script can be limited on more than one thing according to
	# properties. For example limit on the properties of the trigger card
	# and the properties of the subjects card.
	if get(FILTER_PROPERTIES + type):
		# prop_limits is the variable which will hold the dictionary
		# detailing which card properties on the subjects must match
		# to satisfy this limit
		var prop_limits : Dictionary = get(FILTER_PROPERTIES + type)
		for property in prop_limits:
			if property in CardConfig.PROPERTIES_ARRAYS:
				# If it's an array, we assume they passed on element
				# of that array to check against the card properties
				if not prop_limits[property] in card.properties[property]:
					card_matches = false
			else:
				#print(type,prop_limits[property], card.properties[property])
				if prop_limits[property] != card.properties[property]:
					card_matches = false
	return(card_matches)
