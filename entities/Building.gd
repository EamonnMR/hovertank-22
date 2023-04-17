extends StaticBody3D

@export var faction: int = -1
@export var graphics_path: NodePath
signal destroyed

func is_player():
	return false

func graphics():
	return get_node(graphics_path)

func _on_Health_damaged():
	print("Building took hit")
	# TODO: Switch out graphics for smashed version, play effects

func _on_Health_destroyed():
	print("Building Destroyed")
	emit_signal("destroyed")
	queue_free()
	# TODO: Destroyed effects, spawn debris?
