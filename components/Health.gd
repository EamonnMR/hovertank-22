extends Spatial

class_name Health

signal damaged
signal healed
signal destroyed

export var max_health: int = 1
export var health: int = -1

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
	_signal_for_damage()

func _signal_for_damage():
	if health <= 0:
		emit_signal("destroyed")
	else:
		emit_signal("damaged")


static func do_damage(entity, damage):
	if entity.has_node("Health"):
		# print("Do some damage to something")
		entity.get_node("Health").take_damage(damage)
	# else:
		# print(entity.name)
		# print("Cannot damage: node does not have Health node? ", entity.has_node("Health"))
