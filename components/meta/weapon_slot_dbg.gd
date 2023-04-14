extends Label
@onready var parent = get_node("../../")
func _process(delta):
	text = str(parent.get_weapon())
