extends Spatial

func _ready():
	var aabb = get_node("../Graphics").get_aabb()
	$Sprite3D.transform.origin.y = aabb.position.y + aabb.size.y + 2

func _exit_tree():
	get_tree().quit()
