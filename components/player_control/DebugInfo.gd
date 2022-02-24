extends Control

onready var parent = get_node("../")

func _process(delta):
	$Label.text = "Momentum: " + str(parent.momentum) + "\n " + "Basis: " + str(parent.global_transform.basis) + "\n" + "Hack Active? : " + str(parent.hacked) + "\n" + "Motion: " + str(parent.motion)
