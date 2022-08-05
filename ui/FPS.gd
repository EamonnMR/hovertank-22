extends Label

func _ready():
	# TODO: Hide FPS counter unless debug is on
	#if not get_tree().debug_collisions_hint:
	#	hide()
	pass

func _process(delta):
	text = "FPS: " + str(Engine.get_frames_per_second()) + "\n" + "Hovertank '22 TEST"
