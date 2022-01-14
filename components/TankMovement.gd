extends Movement

var parent: KinematicBody
var controller

export var gravity = 90
export var motion_speed = 30.0
export var accel = 0.5

var motion = Vector3(0,0,0)

func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	

func _physics_process(delta):
	var motion_and_facing = controller.get_motion_and_facing()
	var facing = motion_and_facing[1]
	if facing != null:
		parent.rotation.y = facing
	if motion_and_facing[0]:
		motion = Vector3(1, 0, 0).rotated(Vector3.UP, parent.rotation.y)
	else:
		motion = Vector3(0,0,0)
	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * motion_speed + gravity_delta
	
	parent.move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP)
	match_ground_normal(delta, parent)
	
func _constrained_turn(max_turn, ideal_face):
	var ideal_turn = _anglemod(ideal_face - parent.rotation.y)
	if(ideal_turn > PI):
		ideal_turn = _anglemod(ideal_turn - 2 * PI)

	elif(ideal_turn < -1 * PI):
		ideal_turn = _anglemod(ideal_turn + 2 * PI)
	
	max_turn = sign(ideal_turn) * max_turn  # Ideal turn in the right direction
	
	if(abs(ideal_turn) > abs(max_turn)):
		return [max_turn, ideal_face]
	else:
		return [ideal_turn, ideal_face]
