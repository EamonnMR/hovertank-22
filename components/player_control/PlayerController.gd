extends Node

class_name PlayerController

onready var parent = get_node("../")

func _ready():
	get_node("../").add_to_group("players")
	get_node("../").connect("destroyed", self, "_on_player_destroyed")
func get_turn_and_motion_impulse(delta, turn_speed) -> Array:
	return [0.0, 0]

func get_aim_point() -> Vector3:
	return Vector3()

func is_player():
	return true

func is_shooting():
	return false

func is_shooting_secondary():
	return false

func _on_player_destroyed():
	Client.defeat_screen()

func _get_turret_turn():
	return parent.get_turrets()[0].request_turn
