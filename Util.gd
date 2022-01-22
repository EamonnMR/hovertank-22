extends Node

func _ready():
	unit_test_constrained_turn_with_possibility_of_reverse()

func _anglemod(angle: float) -> float:
	# Maybe the reason this isn't a builtin is that it happens whenever an angle is applied?
	return fmod(angle, PI * 2)

func constrained_turn(current_rotation: float, max_turn: float, ideal_face: float) -> Array:
	# This resolves how far and in what direction something should turn in order to match a rotation
	# given the constraint that it can only move so far in a single frame.
	var ideal_turn = _anglemod(ideal_face - current_rotation)
	if(ideal_turn > PI):
		ideal_turn = _anglemod(ideal_turn - 2 * PI)

	elif(ideal_turn < -1 * PI):
		ideal_turn = _anglemod(ideal_turn + 2 * PI)
	
	max_turn = sign(ideal_turn) * max_turn  # Ideal turn in the right direction
	
	if(abs(ideal_turn) > abs(max_turn)):
		return [max_turn, false]
	else:
		return [ideal_turn, true]

func constrained_turn_with_possibility_of_reverse(current_rotation, max_turn, ideal_face) -> Array:
	# Returns [turn: float, invert_movement: (1 or -1), is_ideal: bool]

	var invert_movement = 1
	
	# Never turn more than 180 - pick the right direction to turn in
	var ideal_turn = _anglemod(ideal_face - current_rotation)
	
	print("Initial: ", ideal_turn)
	
	
	if ideal_turn > PI * 1.5:
		print("ideal_turn > PI * 1.5; return 2PI-t")
		return limit_turn( 2 * PI - ideal_turn, max_turn, 1)
	if ideal_turn > PI / 2:
		print("ideal_turn > PI/2; return t - pi")
		return limit_turn( ideal_turn - PI, max_turn, -1)
	if ideal_turn > -PI / 2:
		print("ideal_turn > -PI/2; return t")
		return limit_turn( ideal_turn, max_turn, 1)
	if ideal_turn > -PI * 1.5:
		print("ideal_turn > -PI * 1.5; return t + PI")
		return limit_turn( ideal_turn + PI, max_turn, -1)
	else:
		print("else; return 2PI + t")
		return limit_turn( 2 * PI + ideal_turn, max_turn, 1)
	
func limit_turn(ideal_turn, max_turn, invert_movement) -> Array:
	# Limit the turn to what you can do
	max_turn = sign(ideal_turn) * max_turn
	
	print("Final: ", ideal_turn)
	if(abs(ideal_turn) > abs(max_turn)):
		return [max_turn, invert_movement, false]
	else:
		return [ideal_turn, invert_movement, true]

func unit_test_constrained_turn_with_possibility_of_reverse():
	# current_rotation, max_turn, ideal_face
	# # Returns [turn: float, invert_movement: (1 or -1), is_ideal: bool]
	var turn_cw = constrained_turn_with_possibility_of_reverse(
		0, 0.1, PI * 0.4
	)
	assert(turn_cw[0] == 0.1)
	assert(turn_cw[1] == 1)
	assert(turn_cw[2] == false)

