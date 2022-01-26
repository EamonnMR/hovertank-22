extends Spatial

onready var parent = get_node("../")

func _ready():
	var aabb = get_node("../Graphics").get_aabb()
	var scale = get_node("../Graphics").scale.y
	$Sprite3D.transform.origin.y = (aabb.position.y + aabb.size.y + 2) * scale
	parent.add_to_group("objectives")
	parent.connect("destroyed", self, "_on_parent_destroyed")

func _on_parent_destroyed():
	# If this is the last one
	if get_tree().get_nodes_in_group("objectives").size() == 1:
		Client.victory_screen()
