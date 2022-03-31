extends Label

onready var parent_ai = get_node("../../")

func _process(delta):
	text = "Target: " + _fmt_target()

func _fmt_target():
	if parent_ai.target:
		if is_instance_valid(parent_ai.target):
			return parent_ai.target.name
		else:
			return "<invalid>"
	else:
		return "<null>"
