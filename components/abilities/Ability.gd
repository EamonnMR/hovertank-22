extends Spatial

onready var parent = get_node("../")
onready var controller = parent.get_node("Controller")
onready var energy = parent.get_node("Energy")
export var primary: bool
export var cost: int

var cooldown = false

func _is_trying():
	if primary:
		return controller.use_ability_primary()
	else:
		return controller.get_node("Controller").use_ability_secondary()

func _physics_process(_delta):
	if not cooldown and _is_trying() and energy.try_subtracting_energy(cost):
		activate()
		cooldown = true
		$Cooldown.start()

func activate():
	print("Do the thing here")

func _on_Cooldown_timeout():
	cooldown = false
