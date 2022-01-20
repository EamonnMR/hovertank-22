extends Node

var cam_rig: Node

func is_shooting():
	return Input.is_action_pressed("shoot")

func is_player():
	return true

func _ready():
	# TODO: SOC
	cam_rig = get_node("../../CameraRig")

func get_aim_point() -> Vector3:
	return cam_rig.get_aim_point()

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

func _exit_tree():
	get_tree().change_scene("res://ui/SpawnMenu.tscn")
