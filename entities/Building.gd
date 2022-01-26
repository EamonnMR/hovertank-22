extends StaticBody

signal destroyed

func _on_Health_damaged():
	print("Building took hit")
	# TODO: Switch out graphics for smashed version, play effects

func _on_Health_destroyed():
	print("Building Destroyed")
	emit_signal("destroyed")
	queue_free()
	# TODO: Destroyed effects, spawn debris?
