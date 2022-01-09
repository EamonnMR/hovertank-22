extends Spatial

const RAYCAST_MASK = 1
var aim_position: Vector3
var aim_correct = false
var AIM_UP_CORRECTION = Vector3(0,1,0) # We don't want to be aiming right at the ground all the time
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	$Camera.look_at($CameraOffset.to_global(Vector3(0,0,0)), Vector3.UP)
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
	if "collider" in result and result.collider is StaticBody:
		aim_correct = true
	else:
		aim_correct = false
	$AimMarker.rect_position = $Camera.unproject_position(aim_position)
func get_aim_point() -> Vector3:
	return $PickerLocation.get_global_transform().origin + (AIM_UP_CORRECTION if aim_correct else Vector3(0,0,0))

func get_mover_path() -> NodePath:
	return $CameraOffset.get_path()

func set_turret_point(aim_position: Vector3):
	self.aim_position = aim_position
