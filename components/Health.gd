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
	assert(is_network_master())
	if health <= max_health:
		health += amount
		if health >= max_health:
			health = max_health
		emit_signal("healed")

func take_damage(damage):
	print("Server: Took Damage")
	assert(is_network_master())
	if health <= 0:  # Beating a dead horse
		return
	
	health -= damage
	_signal_for_damage()

func set_health(new_health):
	assert(not is_network_master())
	if health != new_health:
		print("Client: Took Damage")
		
		if new_health > health:
			health = new_health
			emit_signal("healed")
		elif new_health < health:
			health = new_health
			_signal_for_damage()

func _signal_for_damage():
	if health <= 0:
		emit_signal("destroyed")
	else:
		emit_signal("damaged")


static func do_damage(entity, damage):
	if entity is VehicleBody:
		var has_node = entity.has_node("Health")
		entity.print_tree_pretty()
		if entity.has_node("Health"):
			print("Do some damage to something")
			entity.get_node("Health").take_damage(damage)
		else:
			print(entity.name)
			print("Cannot damage: node does not have Health node? ", entity.has_node("Health"))
	else:
		print("Hit something other than a vehicle: ", entity.get_class(), ": ", entity.name)
