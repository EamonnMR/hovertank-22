extends Movement

# Movement for player vehicles which can turn in place and don't hover

var parent: KinematicBody
var controller
var animation_player

export var gravity = 900
export var motion_speed = 30.0
export var accel = 0.5
export var turn_speed = 5
export var animation_transition_speed = 0.25
var motion = Vector3(0,0,0)
var motion_impulse
var grounded: bool

func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	animation_player = get_node("../Graphics/Armature/AnimationPlayer")
	

func _physics_process(delta):
	
	var turn_and_motion_impulse = controller.get_turn_and_motion_impulse(delta, turn_speed)
	var turn = turn_and_motion_impulse[0]
	motion_impulse = turn_and_motion_impulse[1]
	parent.rotation.y += turn
	var motion = Vector3(motion_impulse, 0, 0).rotated(Vector3.UP, parent.rotation.y)
	
	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * motion_speed + gravity_delta
	grounded = parent.is_on_floor()
	if grounded:
		motion.y = -0.01 # Need to keep touching floor to keep is_on_floor true
	parent.move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP)
	match_ground_normal(delta, parent)

	animation_player.play(
		"walk" if grounded and motion_impulse else "idle",
		animation_transition_speed
	)
