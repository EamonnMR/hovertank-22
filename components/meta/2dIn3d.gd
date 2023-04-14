extends Control

"For dropping debug overlays into 3d scenes."

@export var offset: Vector2
@export var center: bool = true
@export var debug_only: bool = true

func _ready():
	if (not get_tree().debug_collisions_hint) and debug_only:
		queue_free()

func _process(delta):
	if get_viewport().get_camera_3d():
		position = offset \
			+ get_viewport().get_camera_3d().unproject_position(get_node("../").global_transform.origin) \
			- (size / 2 if center else Vector2(0,0))
