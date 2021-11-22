extends Spatial

const RAYCAST_MASK = 1

func _physics_process(delta):
	var mouse_pos = $InvisibleControlForGettingMousePos.get_global_mouse_position()
	var camera = $Camera
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], RAYCAST_MASK)
	if "position" in result:
		$PickerLocation.global_transform.origin = result.position
		$PointerMarker.rect_position = $Camera.unproject_position(result.position)
