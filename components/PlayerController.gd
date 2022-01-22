extends Node

class_name PlayerController

func get_aim_point() -> Vector3:
	return Vector3()

func is_player():
	return true

func is_shooting():
	return false

func _exit_tree():
	get_tree().change_scene("res://ui/SpawnMenu.tscn")
