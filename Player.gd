extends KinematicBody
var aim_dir: float
var motion: Vector3 = Vector3(0,0,0)
var cooldown: bool
var health = 1
export var gravity = 60

const MOTION_SPEED = 50.0
const ACCEL = 1
const DRIFT = 0.5


func is_player():
	return true

signal destroyed(unit)
	
func _ready():
	var map = get_node("../../")
	# connect("destroyed", map, "unit_destroyed")
	$Health.connect("destroyed", self, "_dead")
	#if ProjectSettings.get_setting("Prefs/controller"):
		#add_child(preload("res://GamepadController.tscn").instance())
	#else:
	add_child(preload("res://MouseAndKeyboardController.tscn").instance())
	
func _physics_process(delta: float):
	aim_dir = $PlayerController.get_aim_dir()
	var motion_and_facing = $PlayerController.get_motion_and_facing()
	var facing = motion_and_facing[1]
	# Drifty movement:
	if motion_and_facing[0] != null:
		motion = lerp(motion, motion_and_facing[0], ACCEL * delta)
	else:
		motion = lerp(motion, Vector3(0,0,0), DRIFT * delta)
	if facing != null:
		$Graphics.rotation.y = facing
	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * MOTION_SPEED + gravity_delta
	move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP)

	_handle_shooting()

func _handle_shooting():
	if Input.is_action_pressed("shoot"):
		$PrimaryWeapon.try_shooting()
	if Input.is_action_pressed("shoot_secondary"):
		$SecondaryWeapon.try_shooting()

func _dead():
	explode()
	# Remove this node but keep the camera around
	#var camera = $Camera2D
	#remove_child(camera)
	#get_node("../").add_child(camera)
	#camera.position = position
	emit_signal("destroyed", self)
	queue_free()

func explode():
	# TODO: Explosion
	print("Boom")
	# var explo = get_explo()
	# explo.position = position
	# get_node("../").add_child(explo)
