extends Spatial

func _ready():
	var aabb = get_node("../Graphics").get_aabb()
	var scale = get_node("../Graphics").scale.y
	$Sprite3D.transform.origin.y = (aabb.position.y + aabb.size.y + 2) * scale

func _exit_tree():
	get_tree().change_scene("res://ui/main_menu.tscn")
