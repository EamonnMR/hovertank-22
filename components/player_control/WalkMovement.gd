extends Movement

# Movement for player vehicles which can turn in place and don't hover
onready var animation_player = get_node("../Graphics/Armature/AnimationPlayer")

const gravity = -900
const animation_transition_speed = 0.25
var motion = Vector3(0,0,0)
var motion_impulse
var momentum: float = 0
var grounded: bool
export var match_ground: bool = false

func _physics_process(delta):
	if parent.destroyed:
		return
	var turn_and_motion_impulse = controller.get_turn_and_motion_impulse(delta, parent.turn)
	var turn = turn_and_motion_impulse[0]
	motion_impulse = turn_and_motion_impulse[1]
	
	momentum = update_momentum(momentum, delta, motion_impulse)
	
	parent.rotation.y += turn
	var motion = Vector3(momentum, 0, 0).rotated(Vector3.UP, parent.rotation.y)
	
	# var gravity_delta = gravity * delta * Vector3.DOWN
	var gravity_delta = Vector3(0, delta * gravity, 0)
	var motion_total = motion + gravity_delta
	grounded = parent.is_on_floor()
	if grounded:
		motion.y = -0.01 # Need to keep touching floor to keep is_on_floor true
	parent.move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP, true)
	if match_ground:
		match_ground_normal(delta, parent)

	animation_player.play(
		"walk" if grounded and momentum else "idle",
		animation_transition_speed * (momentum / parent.speed)
	)

