extends Spatial

const RAYCAST_MASK = 1
var aim_position: Vector3
var aim_correct = false
var AIM_UP_CORRECTION = Vector3(0,1,0) # We don't want to be aiming right at the ground all the time
var zoom_target = 1.0
export var zoom_min = 0.01
export var zoom_max = 3.0
export var zoom_incriment = 0.25
export var third_person: bool
var zoom = 1.0
var base_distance: Vector3
var aim: Vector2
var aim_smooth_goal: Vector2
var aim_smooth_lerp = 10

func _input(event):
	print("Input")
	if event is InputEventMouseMotion:
		aim_smooth_goal -= event.relative

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	base_distance = $CameraOffset/PitchHelper/CameraLocation.transform.origin
	if third_person:
		pass
		# TODO: Place pointer market in center of screen
func _handle_zoom(delta: float):
	if Input.is_action_just_pressed("zoom_in"):
		zoom_in()
	if Input.is_action_just_pressed("zoom_out"):
		zoom_out()
	
	# TODO: Lerp for smoothing
	$CameraOffset/PitchHelper/CameraLocation.transform.origin = base_distance * zoom_target
	

func _process(delta):
	_handle_zoom(delta)
	if third_person:
		_handle_third_person_aim(delta)
	else:
		_handle_topdown_mouse_aim(delta)
	
	$AimMarker.rect_position = $Camera.unproject_position(aim_position) # - ($AimMarker.rect_size)

func _handle_topdown_mouse_aim(delta):
	$Camera.look_at($CameraOffset.to_global(Vector3(0,6,0)), Vector3.UP)
	var mouse_pos = $InvisibleControlForGettingMousePos.get_global_mouse_position()
	var result = _project_aim_ray(mouse_pos)
	if "position" in result:
		$PickerLocation.global_transform.origin = result.position
		$PointerMarker.rect_position = $Camera.unproject_position(result.position) - $PointerMarker.rect_size / 2

	# TODO: If there's an object under this, pick and set the picker location to the object's origin
	if "collider" in result and result.collider is StaticBody:
		aim_correct = true
	else:
		aim_correct = false

func _project_aim_ray(pos):
	var from = $Camera.project_ray_origin(pos)
	var to = from + $Camera.project_ray_normal(pos) * 1000
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], RAYCAST_MASK)
	return result

func _handle_third_person_aim(delta):
	aim = lerp(aim, aim_smooth_goal, aim_smooth_lerp * delta)
	$CameraOffset.rotation_degrees.y = aim.x
	$CameraOffset/PitchHelper.rotation_degrees.x = aim.y
	#$Camera.look_at($CameraOffset.to_global(Vector3(0,0,0)), Vector3.UP)
	$Camera.look_at($CameraOffset/LookSlightlyAbove.to_global(Vector3(0,0,0)), Vector3.UP)
	var result = _project_aim_ray(
		# Middle of screen:
		$PointerMarker.rect_position + $PointerMarker.rect_size / 2
	)
	if "position" in result:
		$PickerLocation.global_transform.origin = result.position
	
	
func get_aim_point() -> Vector3:
	return $PickerLocation.get_global_transform().origin + (AIM_UP_CORRECTION if aim_correct else Vector3(0,0,0))

func get_mover_path() -> NodePath:
	return $CameraOffset.get_path()

func set_turret_point(aim_position: Vector3):
	self.aim_position = aim_position

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func zoom_in():
	print("zoom in")
	zoom_target -= zoom_incriment
	if zoom_target <= zoom_min:
		zoom_target = zoom_min

func zoom_out():
	print("zoom out")
	zoom_target += zoom_incriment
	if zoom_target >= zoom_max:
		zoom_target = zoom_max
