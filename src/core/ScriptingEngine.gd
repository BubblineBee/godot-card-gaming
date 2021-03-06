# This class contains all the functionality required to perform
# full rules enforcement on any card.
#
# The automation is based on [ScriptTask]s. Each such "task" performs a very specific
# manipulation of the board state, based on using existing functions
# in the object manipulated.
# Therefore each task function provides effectively a text-based API
#
# This class is loaded by each card invidually, and contains a link
# back to the card object itself
class_name ScriptingEngine
extends Reference

# Emitted when all tasks have been run succesfully
signal tasks_completed

# This flag will be true if we're attempting to find if the card
# has costs that need to be paid, before the effects take place.
var costs_dry_run := false
# This is set to true whenever we're doing a cost dry-run
# and any task marked "is_cost" wil lnot be able to manipulate the
# game state as required, either because the board is already at the
# requested state, or because something prevents it.
var can_all_costs_be_paid := true
# This is checked by the yield in [Card] execute_scripts()
# to know when the cost dry-run has completed, so that it can
# check the state of `can_all_costs_be_paid`.
var all_tasks_completed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Sets the owner of this Scripting Engine
func _init(card_owner: Card,
		scripts_queue: Array,
		trigger_card: Card,
		signal_details := {},
		check_costs := false) -> void:
	costs_dry_run = check_costs
	run_next_script(card_owner,
			scripts_queue.duplicate(),
			trigger_card,
			signal_details)

# The main engine starts here.
# It receives array with all the scripts to execute,
# then turns each array element into a ScriptTask object and
# send it to the appropriate tasks.
func run_next_script(card_owner: Card,
		scripts_queue: Array,
		trigger_card: Card,
		signal_details := {},
		prev_subjects := []) -> void:
	if scripts_queue.empty():
		#print('Scripting: All done!') # Debug
		# If we're doing a try run, we don't clean the targeting
		# as we will re-use it in the targeting phase.
		# We do clear it though if all the costs cannot be paid.
		if not costs_dry_run or (costs_dry_run and not can_all_costs_be_paid):
			card_owner.target_card = null
		if not costs_dry_run:
			card_owner.target_dry_run_card = null
		all_tasks_completed = true
		emit_signal("tasks_completed")
	# checking costs on multiple targeted cards in the same script,
	# is not supported at the moment due to the exponential complexities
	elif costs_dry_run and card_owner.target_dry_run_card and \
				scripts_queue[0].get(ScriptTask.KEY_SUBJECT) == "target":
			scripts_queue.pop_front()
			run_next_script(card_owner,
					scripts_queue,trigger_card,
					signal_details,prev_subjects)
	else:
		var script := ScriptTask.new(
				card_owner,
				trigger_card,
				signal_details,
				scripts_queue.pop_front(),
				prev_subjects)
		# In case the task involves targetting, we need to wait on further
		# execution until targetting has completed
		if not script.has_init_completed:
			yield(script,"completed_init")
		#print("Scripting: " + str(script.properties)) # Debug
		#print("Scripting Subjects: " + str(script.subjects)) # Debug
		if costs_dry_run and card_owner.target_card:
			card_owner.target_dry_run_card = card_owner.target_card
			card_owner.target_card = null
		if script.task_name == "custom_script":
			# This class contains the customly defined scripts for each
			# card.
			var custom := CustomScripts.new(costs_dry_run)
			custom.custom_script(script)
		elif script.task_name:
			if script.is_valid \
					and (not costs_dry_run
						or (costs_dry_run and script.get(script.KEY_IS_COST))):
				#print(script.is_valid,':',costs_dry_run)
				var retcode = call(script.task_name, script)
				if costs_dry_run and retcode != Card._ReturnCode.CHANGED:
					can_all_costs_be_paid = false
		else:
			 # If card has a script but it's null, it probably not coded yet. Just go on...
			print("[WARN] Found empty script. Ignoring...")
		# At the end of the task run, we loop back to the start, but of course
		# with one less item in our scripts_queue.
		run_next_script(card_owner,scripts_queue,trigger_card,signal_details,script.subjects)


# Task for rotating cards
#
# Supports KEY_IS_COST.
#
# Requires the following keys:
# * "degrees": int
func rotate_card(script: ScriptTask) -> int:
	var retcode: int
	for card in script.subjects:
		# The last arg is the "check" flag.
		# Unfortunately Godot does not support passing named vars
		# (See https://github.com/godotengine/godot-proposals/issues/902)
		retcode = card.set_card_rotation(script.get(script.KEY_DEGREES),
				false, true, costs_dry_run)
	return(retcode)


# Task for flipping cards
#
# Supports KEY_IS_COST.
#
# Requires the following keys:
# * "set_faceup": bool
func flip_card(script: ScriptTask) -> int:
	var retcode: int
	for card in script.subjects:
		retcode = card.set_is_faceup(script.get(script.KEY_SET_FACEUP),
				false,costs_dry_run)
	return(retcode)


# Task for moving cards to other containers
#
# Requires the following keys:
# * "container": CardContainer
# * (Optional) "dest_index": int
#
# The index position the card can be placed in, are:
# * index ==  -1 means last card in the CardContainer
# * index == 0 means the the first card in the CardContainer
# * index > 0 means the specific index among other cards.
func move_card_to_container(script: ScriptTask) -> void:
	var dest_index: int = script.get(script.KEY_DEST_INDEX)
	for card in script.subjects:
		card.move_to(script.get(script.KEY_DEST_CONTAINER), dest_index)


# Task for moving card to the board
#
# Requires the following keys:
# * "container": CardContainer
func move_card_to_board(script: ScriptTask) -> void:
	for card in script.subjects:
		card.move_to(cfc.NMAP.board, -1, script.get(script.KEY_BOARD_POSITION))


# Task for moving card from one container to another
#
# Requires the following keys:
# * "card_index": int
# * "src_container": CardContainer
# * "dest_container": CardContainer
# * (Optional) "dest_index": int
#
# The index position the card can be placed in, are:
# * index ==  -1 means last card in the CardContainer
# * index == 0 means the the first card in the CardContainer
# * index > 0 means the specific index among other cards.
func move_card_cont_to_cont(script: ScriptTask) -> void:
	var dest_container: CardContainer = script.get(script.KEY_DEST_CONTAINER)
	var dest_index: int = script.get(script.KEY_DEST_INDEX)
	for card in script.subjects:
		card.move_to(dest_container,dest_index)


# Task for playing a card to the board from a container directly.
#
# Requires the following keys:
# * "card_index": int
# * "src_container": CardContainer
func move_card_cont_to_board(script: ScriptTask) -> void:
	var board_position = script.get(script.KEY_BOARD_POSITION)
	for card in script.subjects:
		# We assume cards moving to board want to be face-up
		card.move_to(cfc.NMAP.board, -1, board_position)
		#card.is_faceup = true


# Task from modifying tokens on a card
#
# Supports KEY_IS_COST.
#
# Requires the following keys:
# * "token_name": String
# * "modification": int
# * (Optional) "set_to_mod": bool
func mod_tokens(script: ScriptTask) -> int:
	var retcode: int
	var token_name: String = script.get(script.KEY_TOKEN_NAME)
	var modification: int = script.get(script.KEY_TOKEN_MODIFICATION)
	var set_to_mod: bool = script.get(script.KEY_TOKEN_SET_TO_MOD)
	for card in script.subjects:
		retcode = card.mod_token(token_name,modification,set_to_mod,costs_dry_run)
	return(retcode)


# Task from creating a new card instance on the board
#
# Requires the following keys:
# * "card_scene": path to .tscn file
# * "board_position": Vector2
func spawn_card(script: ScriptTask) -> void:
	var card_scene: String = script.get(script.KEY_CARD_SCENE)
	var board_position: Vector2 = script.get(script.KEY_BOARD_POSITION)
	var card: Card = load(card_scene).instance()
	cfc.NMAP.board.add_child(card)
	card.position = board_position
	card.state = card.ON_PLAY_BOARD


# Task from shuffling a CardContainer
#
# Requires the following keys:
# * "container": CardContainer
func shuffle_container(script: ScriptTask) -> void:
	var container: CardContainer = script.get(script.KEY_DEST_CONTAINER)
	container.shuffle_cards()


# Task from making the owner card an attachment to another card
func attach_to_card(script: ScriptTask) -> void:
	for card in script.subjects:
		script.owner.attach_to_host(card)


# Task for attaching another card to the owner
func host_card(script: ScriptTask) -> void:
	# host_card can only ever have one subject
	var card: Card = script.subjects[0]
	card.attach_to_host(script.owner)
