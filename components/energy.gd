extends Spatial
onready var parent = get_node("../")

export var energy: int
export var max_energy: int

func try_subtracting_energy(amount: int):
	print("try_subtracting_energy: ", amount, " from: ", energy, "result: ", energy <= amount)
	if energy >= amount:
		energy -= amount
		return true
	return false
	
func add_energy(amount: int):
	energy += amount
	if energy > max_energy:
		energy = max_energy
		
func is_full():
	return energy == max_energy

func _ready():
	energy = max_energy
	parent.connect("destroyed", self, "_parent_destroyed")

func _parent_destroyed():
	var pickups = [
		preload("res://entities/pickups/PowerPickup.tscn").instance()
	]
	
	for pickup in pickups:
		pickup.transform.origin = global_transform.origin
		parent.get_node("../").add_child(pickup)
