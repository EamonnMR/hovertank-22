extends Spatial

class_name Health

var already_destroyed: bool = false

signal damaged
signal healed
signal destroyed

export var max_health: int = 1
export var health: int = -1
export var explosion: PackedScene

func _ready():
	if health == -1:
		health = max_health

func heal(amount):
	if health <= max_health:
		health += amount
		if health >= max_health:
			health = max_health
		emit_signal("healed")

func take_damage(damage):
	if health <= 0:  # Beating a dead horse
		return
	
	health -= damage

	if health <= 0 and not already_destroyed:
		already_destroyed = true
		if not explosion == null:
			var explo = explosion.instance()
			explo.transform.origin = global_transform.origin
			get_node("../../").add_child(explo)
		else:
			print("No explosion for ", get_node("../"))
		emit_signal("destroyed")
		already_destroyed = true
	else:
		emit_signal("damaged")


static func do_damage(entity, damage):
	if entity.has_node("Health"):
		entity.get_node("Health").take_damage(damage)
