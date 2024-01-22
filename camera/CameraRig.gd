extends Node3D

const RAYCAST_MASK = 1
var aim_position: Vector3
var aim_correct = false
var AIM_UP_CORRECTION = Vector3(0,1,0) # We don't want to be aiming right at the ground all the time
var zoom_target = 1.0
var TOPDOWN_OFFSET = Vector3(10,20,10)
@export var zoom_min = 0.01
@export var zoom_max = 3.0
@export var zoom_incriment = 0.25
@export var third_person: bool = true

@export var max_pitch = 35
@export var min_pitch = -90
@export var mouse_sensitivity = 2

var zoom = 1.0
var base_distance: Vector3
var aim: Vector2
var aim_smooth_goal: Vector2
var aim_smooth_lerp = 10
var current_camera: Camera3D

func _input(event):
	if event is InputEventMouseMotion:
		aim_smooth_goal -= event.relative
	if Input.is_action_just_pressed("ui_cancel"):
		Client.return_to_menu()

func _ready():
	if third_person:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		current_camera = $CameraOffset/PitchHelper/CameraLocation/Camera3D
		current_camera.make_current()
		base_distance = $CameraOffset/PitchHelper/CameraLocation.transform.origin
		#$CameraOffset/PitchHelper/CameraLocation.transform.origin.y *= .1
		#$CameraOffset/PitchHelper/CameraLocation.transform.origin = Vector3(0,0,0)
		#current_camera.look_at($CameraOffset.to_global(Vector3(0,0,0)), Vector3.UP)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		current_camera = $CameraOffset/PitchHelper/CameraLocation/Camera3D
		base_distance = TOPDOWN_OFFSET
		current_camera.look_at($CameraOffset.to_global(Vector3(0,0,0)), Vector3.UP)

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
	
	$AimMarker.position = current_camera.unproject_position(aim_position) # - ($AimMarker.size)

func _handle_topdown_mouse_aim(delta):
	current_camera.look_at($CameraOffset.to_global(Vector3(0,6,0)), Vector3.UP)
	var mouse_pos = $InvisibleControlForGettingMousePos.get_global_mouse_position()
	var result = _project_aim_ray(mouse_pos, false)
	if "position" in result:
		$PickerLocation.global_transform.origin = result.position
		if "collider" in result and result.collider.get_node("CenterOfMass"):
			$PickerLocation.global_transform.origin.y = result.collider.get_node("CenterOfMass").global_transform.origin.y
		$PointerMarker.position = current_camera.unproject_position(result.position) - $PointerMarker.size / 2

	# TODO: If there's an object under this, pick and set the picker location to the object's origin
	if "collider" in result and result.collider is StaticBody3D:
		aim_correct = true
	else:
		aim_correct = false

func _project_aim_ray(pos: Vector2, ignore_close: bool):  # Returns ray intersection result
	var from = current_camera.project_ray_origin(pos)
	if ignore_close:
		# TODO: Cache this?
		from = from + current_camera.project_ray_normal(pos) * base_distance.length() * zoom_target

	var to = from + current_camera.project_ray_normal(pos) * 1000
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		from, to, RAYCAST_MASK, [Client.player_object]
	))
	return result

func _handle_third_person_aim(delta):
	aim = lerp(aim, aim_smooth_goal, aim_smooth_lerp * delta)
	aim.y = clamp(aim.y, min_pitch, max_pitch)
	$CameraOffset.rotation_degrees.y = aim.x
	$CameraOffset/PitchHelper.rotation_degrees.x = aim.y
	var result = _project_aim_ray(
		# Middle of screen:
		$PointerMarker.position + $PointerMarker.size / 2,
		true
	)
	if "position" in result:
		$PickerLocation.global_transform.origin = result.position
	
	
func get_aim_point() -> Vector3:
	return $PickerLocation.get_global_transform().origin + (AIM_UP_CORRECTION if aim_correct else Vector3(0,0,0))

func get_aim_y() -> float:
	return current_camera.global_transform.basis.get_euler().y

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
