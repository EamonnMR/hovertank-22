extends PlayerController

class_name MouseAndKeyboardController

var cam_rig: Node
onready var parent = get_node("../")

func is_shooting():
	return Input.is_action_pressed("shoot")

func is_shooting_secondary():
	return Input.is_action_pressed("shoot_secondary")

func use_ability_primary():
	return Input.is_action_just_released("ability_primary")

func use_ability_secondary():
	return Input.is_action_just_released("ability_secondary")

func is_player():
	return true

func _ready():
	._ready()
	cam_rig = get_node("../../CameraRig")

func get_aim_point() -> Vector3:
	return cam_rig.get_aim_point()
