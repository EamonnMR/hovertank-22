extends Node3D

var obstacle
@onready var world = get_tree().get_root().get_node("World")

func _exit_tree():
	world.rebake_map()
