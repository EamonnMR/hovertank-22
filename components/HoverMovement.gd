extends Movement

var parent: KinematicBody
var controller

export var gravity = 90
export var motion_speed = 30.0
export var accel = 0.5
export var drag = 0.25
export var turn_speed = 10

var motion = Vector3(0,0,0)

func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	

func _physics_process(delta):
	var motion_and_facing = controller.get_motion_and_facing()
	var motion_impulse = motion_and_facing[0]
	var ideal_face = motion_and_facing[1]
	# Drifty movement:
	if ideal_face != null:
		var turn_and_is_ideal = Util.constrained_turn(parent.rotation.y, delta * turn_speed, ideal_face)
		parent.rotation.y += turn_and_is_ideal[0]
		var is_ideal = turn_and_is_ideal[1]
		if motion_impulse:
			motion = lerp(motion, Vector3(1, 0, 0).rotated(Vector3.UP, parent.rotation.y), accel * delta)
	else:
		motion = lerp(motion, Vector3(0,0,0), drag * delta)
	# TODO: Lerp facing

	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * motion_speed + gravity_delta
	parent.move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP)
	match_ground_normal(delta, parent, 0.02)
