extends Node

var current_level = 0

var LEVELS = [
	{
		"name": "Smoking Section",
		"desc": "You want to strike a blow against the Domains? They're storing a fuel in an under-guarded outpost. Should burn real well.",
		"scene": "res://levels/Level1.tscn"
	},
	{
		"name": "Dancing With A Ghost",
		"desc": "An opportunity presents itself; a general is making an inspection of this outpost to raise morale. Lower it.",
		"scene": "res://levels/Level2.tscn"
	}
]

var VEHICLES = {
	"hovertank": {
		"name": "Hover Tank",
		"scene": preload("res://entities/vehicles/hovertank.tscn"),
		"desc": "If any nation could field more than a handful of these, they'd already run the planet."
	},
	"mecha": {
		"name": "Cassidy Mech",
		"scene": preload("res://entities/vehicles/Mecha.tscn"),
		"desc": "Light, by giant robot standards."
	},
	"cobra": {
		"name": "Cobra Light TD",
		"scene": preload("res://entities/vehicles/rat.tscn"),
		"desc": "Everything sacrified at the altar of speed and a bigger gun. Mounts no secondary weapon. Handling is, well, you'll see."
	}
}

var WEAPONS = {
	"cannon": {
		"name": "Heavy Cannon",
		"scene": preload("res://components/weapons/Cannon.tscn"),
		"desc": "Real big"
	},
	"autocanon": {
		"name": "Autocannon",
		"scene": preload("res://components/weapons/AutoCannon.tscn"),
		"desc": "Real fast"
	},
	"canister": {
		"name": "Canister Shot",
		"scene": preload("res://components/weapons/Canister.tscn"),
		"desc": "Double down on close range combat; you won't hit anything else"
	},
	"steinbolt": {
		"name": "Steinbolt",
		"scene": preload("res://components/weapons/Steinbolt.tscn"),
		"desc": "Long range, long reload particle accelerator"
	},
	"railgun": {
		"name": "Railgun",
		"scene": preload("res://components/weapons/Railgun.tscn"),
		"desc": "Know your target, and what's behind it."
	},
	"laser": {
		"name": "Laser",
		"scene": preload("res://components/weapons/Laser.tscn"),
		"desc": "Somewhat worse than the average sunburn"
	},
	"ripsaw": {
		"name": "Ripsaw",
		"scene": preload("res://components/weapons/Ripsaw.tscn"),
		"desc": "Anything but mini"
	}
}


var FACTIONS = [
	{"name": "Domains"},
	{"name": "Rebels"}
]

var selected_vehicle: String
var selected_control_scheme: String
var selected_primary: String
var selected_secondary: String

var CONTROLLERS = {
	"absolute": preload("res://components/player_control/AbsoluteController.tscn")
}

var player_object: Node

func _ready():
	set_vehicle_selection(0)
	set_controller_selection(0)
	set_primary_selection(0)
	set_secondary_selection(1)

func set_vehicle_selection(index: int):
	var keys = VEHICLES.keys()
	var byindex = keys[index]
	selected_vehicle = VEHICLES.keys()[index]

func set_controller_selection(index: int):
	var keys = CONTROLLERS.keys()
	var byindex = keys[index]
	selected_control_scheme = CONTROLLERS.keys()[index]

func set_primary_selection(index: int):
	var keys = WEAPONS.keys()
	var byindex = keys[index]
	selected_primary = WEAPONS.keys()[index]

func set_secondary_selection(index: int):
	var keys = WEAPONS.keys()
	var byindex = keys[index]
	selected_secondary = WEAPONS.keys()[index]
	
func spawn_player(world: Node):
	Heat.heat = 0
	var player = VEHICLES[selected_vehicle].scene.instance()
	player_object = player
	
	var controller_instance = CONTROLLERS[selected_control_scheme].instance()
	controller_instance.name = "Controller"

	player.add_child(controller_instance)
	
	var primary_ability_instance = preload("res://components/abilities/Teleport.tscn").instance()
	primary_ability_instance.primary = true
	player.add_child(primary_ability_instance)
	
	var secondary_ability_instance = preload("res://components/abilities/WallSpawn.tscn").instance()
	secondary_ability_instance.primary = false
	player.add_child(secondary_ability_instance)
	
	var energy_component = preload("res://components/energy.tscn").instance()
	energy_component.energy = 100
	energy_component.max_energy = 100
	player.add_child(energy_component)
	
	for turret in player.get_node("VehicleCore").get_turrets():
		for slot in turret.get_primary_slots():
			slot.add_child(WEAPONS[selected_primary].scene.instance())
		for slot in turret.get_secondary_slots():
			slot.add_child(WEAPONS[selected_secondary].scene.instance())
	
	player.get_node("VehicleCore").faction = 1  # Players always work for ITAR
	var camera_rig = preload("res://camera/CameraRig.tscn").instance()
	camera_rig.third_person = true
	world.add_child(camera_rig)
	world.add_child(player)
	Hud.add_player(player)
	player.global_transform.origin = world.get_node("SpawnPoint").global_transform.origin


func start_level():
	get_tree().change_scene(LEVELS[current_level].scene)

func return_to_menu():
	get_tree().change_scene("res://ui/SpawnMenu.tscn")

func defeat_screen():
	get_tree().change_scene("res://ui/Defeat.tscn")

func victory_screen():
	get_tree().change_scene("res://ui/Victory.tscn")
