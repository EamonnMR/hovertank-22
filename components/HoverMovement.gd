extends Spatial

var parent: KinematicBody
var controller

export var gravity = 90
export var motion_speed = 30.0
export var accel = 0.5
export var drag = 0.25

var motion = Vector3(0,0,0)

func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	

func _physics_process(delta):
	var motion_and_facing = controller.get_motion_and_facing()
	var facing = motion_and_facing[1]
	var motion_impulse = Vector3(1, 0, 0).rotated(Vector3.UP, facing)
	# Drifty movement:
	if motion_and_facing[0]:
		motion = lerp(motion, motion_impulse, accel * delta)
	else:
		motion = lerp(motion, Vector3(0,0,0), drag * delta)
	# TODO: Lerp facing
	if facing != null:
		parent.rotation.y = facing
	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * motion_speed + gravity_delta
	parent.move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP)
