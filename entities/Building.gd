extends Spatial


func _on_Health_damaged():
	print("Building took hit")
	# TODO: Switch out graphics for smashed version, play effects

func _on_Health_destroyed():
	print("Building Destroyed")
	queue_free()
	# TODO: Destroyed effects, spawn debris?
