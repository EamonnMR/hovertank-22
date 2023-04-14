extends Node3D

@onready var world = get_tree().get_root().get_node("World")
@onready var parent = get_node("../")

func _ready():
	var transform_and_mesh = _obtain_mesh()
	world.add_level_mesh(
		transform_and_mesh[0],
		transform_and_mesh[1]
	)
	
func _obtain_mesh():
	if parent is MeshInstance3D:
		return [parent.global_transform, parent.mesh]
	#elif parent is CSGShape3D:
	#	var root_shape = parent.is_root_shape()
	#	var meshes = parent.get_meshes()
	#	assert(parent.is_root_shape()) #,"CCG only works with root shape")
	#	return parent.get_meshes()
	else:
		assert(false) #,"Unrecognized mesh class: " + parent.get_class())
