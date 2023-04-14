extends Label

@onready var parent_ai = get_node("../../")

func _process(delta):
	text = (
		"Target: " + _fmt_target() + "\n" +
		"Destination " + _fmt_destination()
	)

func _fmt_target():
	if parent_ai.target:
		if is_instance_valid(parent_ai.target):
			return parent_ai.target.name
		else:
			return "<invalid>"
	else:
		return "<null>"

func _fmt_destination():
	if parent_ai.destination != null:
		return str(parent_ai.destination)
	else:
		return "Null"
