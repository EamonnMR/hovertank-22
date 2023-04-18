extends Node3D

signal destroyed

func _on_Area_body_entered(body):
	if body.has_method("is_player") and body.is_player():
		emit_signal("destroyed")
		queue_free()
		Client.victory_screen()

func graphics():
	return $Graphics
