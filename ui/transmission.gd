extends Control

func _ready():
	# TODO: Only trigger this sometimes
	call_deferred("start")
	
func start():
	var parent = get_node("../")
	parent.remove_child(self)
	Hud.add_child(self)
	show()
	$AudioStreamPlayer.play()
	parent.connect("tree_exited",Callable(self,"queue_free"))

func _on_AudioStreamPlayer_finished():
	queue_free()
