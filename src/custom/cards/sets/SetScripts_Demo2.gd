# See README.md
extends Reference

# This fuction returns all the scripts of the specified card name.
#
# if no scripts have been defined, an empty dictionary is returned instead.
func get_scripts(card_name: String, trigger: String) -> Dictionary:
	var scripts := {
		"Test Card 3": {
			"manual": {
				"board": [
					{
						"name": "flip_card",
						"subject": "target",
						"set_faceup": false,
					},
					{
						"name": "rotate_card",
						"subject": "previous",
						"degrees": 180,
					}
				],
				"hand": [
					{
						"name": "custom_script",
						"subject": "target",
					}
				]
			},
			"card_rotated": {
				"board": [
					{
						"name": "rotate_card",
						"subject": "self",
						"degrees": 270,
						"trigger": "another",
					},
				]
			},
		},
	}
	# We return only the scripts that match the card name and trigger
	return(scripts.get(card_name,{}).get(trigger,{}))
