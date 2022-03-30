extends Control

export var offset: Vector2
export var center: bool = true
export var debug_only: bool = true

func _ready():
	if (not get_tree().debug_collisions_hint) and debug_only:
		hide()

func _process(delta):
	if get_viewport().get_camera():
		rect_position = offset \
			+ get_viewport().get_camera().unproject_position(get_node("../").global_transform.origin) \
			- (rect_size / 2 if center else Vector2(0,0))
