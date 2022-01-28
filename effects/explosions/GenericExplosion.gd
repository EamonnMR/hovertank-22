extends Spatial

func _ready():
	$Particles.emitting = true
	$AudioStreamPlayer3D.play()
