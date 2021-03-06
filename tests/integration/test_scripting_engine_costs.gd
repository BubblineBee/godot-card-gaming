extends "res://tests/UTcommon.gd"

var cards := []
var card: Card
var target: Card

func before_all():
	cfc.fancy_movement = false

func after_all():
	cfc.fancy_movement = true

func before_each():
	setup_board()
	cards = draw_test_cards(5)
	yield(yield_for(0.5), YIELD)
	card = cards[0]
	target = cards[2]


func test_self_and_rotate_costs():
	card.scripts = {"manual": {"board": [
			{"name": "rotate_card",
			"subject": "self",
			"is_cost": true,
			"degrees": 90},
			{"name": "flip_card",
			"subject": "self",
			"set_faceup": false}]}}
	cards[1].scripts = {"manual": {"board": [
			{"name": "rotate_card",
			"subject": "self",
			"is_cost": true,
			"degrees": 90},
			{"name": "flip_card",
			"subject": "self",
			"set_faceup": false}]}}
	yield(table_move(card, Vector2(100,200)), "completed")
	card.execute_scripts()
	yield(yield_to(card._flip_tween, "tween_all_completed", 0.5), YIELD)
	assert_false(card.is_faceup,
			"card turn face-down because "
			+ "rotation cost could be paid")
	yield(table_move(cards[1], Vector2(500,200)), "completed")
	cards[1].card_rotation = 90
	cards[1].execute_scripts()
	yield(yield_to(cards[1]._flip_tween, "tween_all_completed", 0.4), YIELD)
	assert_true(cards[1].is_faceup,
			"card should stay face-up because "
			+ "rotation cost could not be paid")

func test_target_costs():
	card.scripts = {"manual": {"hand": [
			{"name": "rotate_card",
			"subject": "target",
			"is_cost": true,
			"degrees": 90},
			{"name": "flip_card",
			"subject": "self",
			"set_faceup": false}]}}
	cards[1].scripts = {"manual": {"hand": [
			{"name": "rotate_card",
			"subject": "target",
			"is_cost": true,
			"degrees": 90},
			{"name": "flip_card",
			"subject": "self",
			"set_faceup": false}]}}
	yield(table_move(target, Vector2(100,200)), "completed")
	card.execute_scripts()
	yield(target_card(card,target), "completed")
	yield(yield_to(card._flip_tween, "tween_all_completed", 0.5), YIELD)
	assert_false(card.is_faceup,
			"card should turn face-down because "
			+ "target rotation cost could be paid")
	cards[1].execute_scripts()
	yield(target_card(cards[1],target), "completed")
	yield(yield_to(cards[1]._flip_tween, "tween_all_completed", 0.5), YIELD)
	assert_true(cards[1].is_faceup,
			"Target should stay face-up because "
			+ "target rotation cost could not be paid")

func test_multiple_costs():
	card.scripts = {"manual": {"hand": [
			{"name": "rotate_card",
			"subject": "target",
			"is_cost": true,
			"degrees": 90},
			{"name": "flip_card",
			"subject": "previous",
			"is_cost": true,
			"set_faceup": false},
			{"name": "flip_card",
			"subject": "self",
			"is_cost": true,
			"set_faceup": false}]}}
	yield(table_move(target, Vector2(100,200)), "completed")
	target.is_faceup = false
	card.execute_scripts()
	yield(target_card(card,target), "completed")
	yield(yield_to(card._flip_tween, "tween_all_completed", 0.5), YIELD)
	assert_true(card.is_faceup,
			"card should stay face-up because "
			+ "some costs could not be paid")
	assert_eq(0,target.card_rotation,
			"target should not be rotated from a cost test")

func test_flip_cost():
	card.scripts = {"manual": {"board": [
			{"name": "flip_card",
			"subject": "self",
			"is_cost": true,
			"set_faceup": false},
			{"name": "rotate_card",
			"subject": "self",
			"degrees": 90},]}}
	yield(table_move(card, Vector2(100,200)), "completed")
	card.is_faceup = false
	card.execute_scripts()
	yield(yield_to(card._tween, "tween_all_completed", 0.5), YIELD)
	assert_eq(0,target.card_rotation,
			"Card not rotated because flip cost could be paid")

func test_token_cost():
	card.scripts = {"manual": {"board": [
			{"name": "mod_tokens",
			"subject": "self",
			"is_cost": true,
			"token_name":  "bio",
			"modification": 3},
			{"name": "rotate_card",
			"subject": "self",
			"degrees": 90}]}}
	yield(table_move(card, Vector2(1000,200)), "completed")
	card.execute_scripts()
	yield(yield_to(card._tween, "tween_all_completed", 0.5), YIELD)
	assert_eq(90,card.card_rotation,
			"Card rotated because positive token cost can always be paid")
	card.scripts = {"manual": {"board": [
			{"name": "mod_tokens",
			"subject": "self",
			"is_cost": true,
			"token_name":  "bio",
			"modification": -2},
			{"name": "rotate_card",
			"subject": "self",
			"degrees": 180}]}}
	card.execute_scripts()
	yield(yield_to(card._tween, "tween_all_completed", 0.5), YIELD)
	assert_eq(180,card.card_rotation,
			"Card rotated because negative token cost could be be paid")
	card.scripts = {"manual": {"board": [
			{"name": "mod_tokens",
			"subject": "self",
			"is_cost": true,
			"token_name":  "bio",
			"modification": -2},
			{"name": "rotate_card",
			"subject": "self",
			"degrees": 0}]}}
	card.execute_scripts()
	yield(yield_to(card._tween, "tween_all_completed", 0.5), YIELD)
	assert_eq(180,card.card_rotation,
			"Card not rotated because negative token cost could not  be be paid")
	assert_eq(1,card.get_token("bio").count,
			"Token count that could not be paid remains the same")
