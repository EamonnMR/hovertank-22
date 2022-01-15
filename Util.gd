extends Node

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
