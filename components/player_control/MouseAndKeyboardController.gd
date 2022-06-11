extends PlayerController

class_name MouseAndKeyboardController

onready var cam_rig = get_node("../../CameraRig")

func is_shooting():
	return Input.is_action_pressed("shoot")

func is_shooting_secondary():
	return Input.is_action_pressed("shoot_secondary")

func is_player():
	return true

func get_aim_point() -> Vector3:
	return cam_rig.get_aim_point()

func get_aim_y() -> float:
	return cam_rig.get_aim_y()

func next_weapon():
	return Input.is_action_just_pressed("next_weapon")
	
func previous_weapon():
	return Input.is_action_just_pressed("next_weapon")
