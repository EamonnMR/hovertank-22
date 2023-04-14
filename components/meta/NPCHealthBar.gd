extends Sprite3D

var parent_health: Health
var base_width: float
func _ready():
	call_deferred("_free_if_player")
	parent_health = get_node("../Health")
	parent_health.connect("damaged",Callable(self,"_update"))
	parent_health.connect("healed",Callable(self,"_update"))

func _set_position():
	var parent = get_node("../")
	Util.show_above(self, parent.graphics())

func _update():
	if parent_health.health != parent_health.max_health:
		show()
	else:
		hide()
	region_rect.end.x = base_width * parent_health.health / parent_health.max_health

func _free_if_player():
	if get_node("../").is_player():
		queue_free()
	else:
		base_width = region_rect.end.x
		call_deferred("_set_position")
