extends Spatial


func _on_Health_damaged():
	pass
	# TODO: Switch out graphics for smashed version, play effects

func _on_Health_destroyed():
	queue_free()
	# TODO: Destroyed effects, spawn debris?