extends Movement

# Movement for player vehicles which can turn in place and don't hover

const gravity = 9
var motion = Vector3(0,0,0)
var momentum: float

func _physics_process(delta):
	
	var turn_and_motion_impulse = controller.get_turn_and_motion_impulse(delta, parent.turn)
	var turn = turn_and_motion_impulse[0]
	var motion_impulse = turn_and_motion_impulse[1]
	var slow_turn = false
	if turn != 0 and not motion_impulse:
		motion_impulse = 1
		slow_turn = true
	momentum = update_momentum(momentum, delta, motion_impulse)
	if slow_turn:
		parent.rotation.y += turn / 10
	else:
		parent.rotation.y += turn
	var motion = Vector3(momentum, 0, 0).rotated(Vector3.UP, parent.rotation.y)

	var gravity_delta = gravity * Vector3.DOWN
	var motion_total = motion + gravity_delta
	parent.move_and_slide(motion_total, Vector3.DOWN, true)
	match_ground_normal(delta, parent)
