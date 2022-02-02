extends Spatial

func _ready():
	$Particles.emitting = true
	$AudioStreamPlayer3D.play()
	$Lifetime.wait_time = $Particles.lifetime # * 10
	$Lifetime.start()

func _on_Lifetime_timeout():
	queue_free()
