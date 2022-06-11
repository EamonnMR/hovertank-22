extends Node

class_name PlayerController

onready var parent = get_node("../")

func next_weapon():
	return false
	
func previous_weapon():
	return false

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
	var timer :Timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(5)
	timer.connect("timeout", Client, "defeat_screen")
	get_tree().get_root().add_child(timer)
	timer.start()
	queue_free()
	
func _get_turret_turn():
	return parent.core.get_turrets()[0].request_turn
