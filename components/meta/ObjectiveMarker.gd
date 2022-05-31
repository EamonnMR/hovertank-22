extends Spatial

onready var parent = get_node("../")

func _ready():
	Util.show_above($Sprite3D, parent.graphics())
	parent.add_to_group("objectives")
	parent.connect("destroyed", self, "_on_parent_destroyed")

func _on_parent_destroyed():
	# If this is the last one
	if get_tree().get_nodes_in_group("objectives").size() == 1:
		Client.victory_screen()
