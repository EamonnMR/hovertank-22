extends PlayerController

class_name MouseAndKeyboardController

var cam_rig: Node
onready var parent = get_node("../")

func is_shooting():
	return Input.is_action_pressed("shoot")

func is_player():
	return true

func _ready():
	# TODO: SOC
	cam_rig = get_node("../../CameraRig")

func get_aim_point() -> Vector3:
	return cam_rig.get_aim_point()
