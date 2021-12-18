extends Spatial

var parent: KinematicBody
var controller

export var gravity = 90
export var motion_speed = 30.0
export var accel = 0.5
export var drift = 0.25

var motion = Vector3(0,0,0)


func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	

func _physics_process(delta):
	var motion_and_facing = controller.get_motion_and_facing()
	var facing = motion_and_facing[1]
	# Drifty movement:
	if motion_and_facing[0] != null:
		motion = lerp(motion, motion_and_facing[0], accel * delta)
	else:
		motion = lerp(motion, Vector3(0,0,0), drift * delta)
	# TODO: Lerp facing
	if facing != null:
		parent.set_facing(facing + PI/2)
	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * motion_speed + gravity_delta
	parent.move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP)
