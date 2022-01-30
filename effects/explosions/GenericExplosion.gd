extends Spatial

func _ready():
	$Particles.emitting = true
	$AudioStreamPlayer3D.play()
	$Lifetime.wait_time = $Particles.lifetime

func _on_Lifetime_timeout():
	queue_free()
