extends Movement

# Movement for player vehicles which can turn in place and don't hover

var parent: KinematicBody
var controller


export var gravity = 900
var motion = Vector3(0,0,0)

func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	

func _physics_process(delta):
	
	var turn_and_motion_impulse = controller.get_turn_and_motion_impulse(delta, parent.turn)
	var turn = turn_and_motion_impulse[0]
	var motion_impulse = turn_and_motion_impulse[1]
	parent.rotation.y += turn
	var motion = Vector3(motion_impulse, 0, 0).rotated(Vector3.UP, parent.rotation.y)

	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * parent.speed + gravity_delta
	
	parent.move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP)
	match_ground_normal(delta, parent)
