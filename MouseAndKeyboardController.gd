extends Node

func get_aim_dir() -> float:
	return 0.0
	# TODO: Steal 3d mouse code from vehicles

# Facings to radians
const E = PI * 0
const SE = PI * .25
const S = PI * .5
const SW = PI * .75
const W = PI * 1
const NW = PI * 1.25
const N = PI * 1.5
const NE = PI * 1.75

func get_motion_and_facing() -> Array:
	var ideal_face = null
	
	var l = false
	var r = false
	var u = false
	var d = false
	
	if (Input.is_key_pressed(KEY_A)):
		l = true
	if (Input.is_key_pressed(KEY_D)):
		r = true
	if (Input.is_key_pressed(KEY_W)):
		u = true
	if (Input.is_key_pressed(KEY_S)):
		d = true
		
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
		return [null, null]
	
	return [Vector3(1, 0, 0).rotated(Vector3.UP, ideal_face), ideal_face]
