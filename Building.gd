extends Spatial


func _on_Health_damaged():
	pass
	# TODO: Switch out graphics

func _on_Health_destroyed():
	queue_free()
	# TODO: Destroyed effects, spawn debris?
