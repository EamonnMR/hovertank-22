extends Spatial

const RAYCAST_MASK = 1

func _ready():
	$Camera.look_at(to_global(Vector3(0,0,0)), Vector3.UP)

func _physics_process(delta):
	var mouse_pos = $InvisibleControlForGettingMousePos.get_global_mouse_position()
	var camera = $Camera
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], RAYCAST_MASK)
	if "position" in result:
		$PickerLocation.global_transform.origin = result.position
		$PointerMarker.rect_position = camera.unproject_position(result.position)
	# TODO: If there's an object under this, pick and set the picker location to the object's origin

func get_aim_point() -> Vector3:
	return $PickerLocation.get_global_transform().origin
