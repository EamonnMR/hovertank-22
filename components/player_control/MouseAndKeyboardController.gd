#extends PlayerController
extends Node


class_name MouseAndKeyboardController



@onready var parent = get_node("../")

func _ready():
	get_node("../").add_to_group("players")
	get_node("../").connect("destroyed",Callable(self,"_on_player_destroyed"))
func get_turn_and_motion_impulse(delta, turn_speed) -> Array:
	return [0.0, 0]

func is_player():
	return true

func _on_player_destroyed():
	var timer :Timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(5)
	timer.timeout.connect(Client.defeat_screen)
	get_tree().get_root().add_child(timer)
	timer.start()
	queue_free()
	
func _get_turret_turn():
	return parent.core.get_turrets()[0].request_turn

@onready var cam_rig = get_node("../../CameraRig")

func is_shooting():
	return Input.is_action_pressed("shoot")

func is_shooting_secondary():
	return Input.is_action_pressed("shoot_secondary")


func get_aim_point() -> Vector3:
	return cam_rig.get_aim_point()

func get_aim_y() -> float:
	return cam_rig.get_aim_y()

func next_weapon():
	return Input.is_action_just_pressed("next_weapon")
	
func previous_weapon():
	return Input.is_action_just_pressed("next_weapon")
