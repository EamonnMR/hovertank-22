extends "res://components/abilities/Ability.gd"

func activate():
	parent.global_transform.origin = controller.get_aim_point()
