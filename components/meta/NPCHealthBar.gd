extends Sprite3D

var parent_health: Health
var base_width: float
func _ready():
	if get_node("../").is_player():
		call_deferred("queue_free")
	else:
		base_width = region_rect.end.x
		call_deferred("_set_position")
	parent_health = get_node("../Health")
	parent_health.connect("damaged", self, "_update")
	parent_health.connect("healed", self, "_update")

func _set_position():
	var parent = get_node("../")
	Util.show_above(self, parent.graphics())

func _update():
	if parent_health.health != parent_health.max_health:
		show()
	else:
		hide()
	region_rect.end.x = base_width * parent_health.health / parent_health.max_health
