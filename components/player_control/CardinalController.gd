extends MouseAndKeyboardController

# Facings to radians
const E = PI * 0
const SE = PI * .25
const S = PI * .5
const SW = PI * .75
const W = PI * 1
const NW = PI * 1.25
const N = PI * 1.5
const NE = PI * 1.75

func get_cardinal_motion_and_facing() -> Array:
	var ideal_face = null
	
	var l = false
	var r = false
	var u = false
	var d = false
	
	if (Input.is_key_pressed(KEY_A)):
		l = true
	if (Input.is_key_pressed(KEY_D)):
		r = true
	# Up and down inverted
	if (Input.is_key_pressed(KEY_W)):
		d = true
	if (Input.is_key_pressed(KEY_S)):
		u = true
		
	if r:
		if d:
			ideal_face = SE
		elif u:
			ideal_face = NE
		else:
			ideal_face = E
	elif l:
		if d:
			ideal_face = SW
		elif u:
			ideal_face = NW
		else:
			ideal_face = W
	elif u:
		ideal_face = N
	elif d:
		ideal_face = S
	else:
		return [false, null]
	
	return [true, ideal_face]

func get_turn_and_motion_impulse(delta, turn_speed) -> Array:
	var motion_and_facing = get_cardinal_motion_and_facing()
	var motion = motion_and_facing[0]
	var ideal_face = motion_and_facing[1]
	var turn = 0.0
	if ideal_face != null:
		var turn_sign_and_is_ideal = Util.constrained_turn_with_possibility_of_reverse(
			parent.rotation.y, delta * turn_speed, ideal_face
		)
		turn = turn_sign_and_is_ideal[0]
		var move_sign = turn_sign_and_is_ideal[1]
		var is_ideal = turn_sign_and_is_ideal[2]
		if motion: #  and is_ideal:
			return [turn, move_sign]
		else:
			return [turn, 0]
	else:
		if not turn:
			turn = _get_turret_turn()
		return [turn, 0]

