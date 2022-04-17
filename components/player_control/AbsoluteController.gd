extends MouseAndKeyboardController

func get_turn_and_motion_impulse(delta, turn_speed) -> Array:
	var turn = 0
	var throttle = 0
	if (Input.is_key_pressed(KEY_A)):
		turn = delta * turn_speed
	elif (Input.is_key_pressed(KEY_D)):
		turn = -delta * turn_speed
	if (Input.is_key_pressed(KEY_W)):
		throttle = 1
	if (Input.is_key_pressed(KEY_S)):
		throttle = -1
	if not (turn or throttle):
		turn = _get_turret_turn() * delta * turn_speed
	return [turn, throttle]
