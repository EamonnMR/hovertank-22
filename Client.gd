extends Node

var current_level = 0

var LEVELS = [
	{
		"name": "Deep Blue",
		"scene": "res://levels/Level1.tscn"
	}
]

var VEHICLES = {
	"heavy": {
		"name": "Heavy Tank",
		"scene": preload("res://entities/vehicles/Heavy.tscn"),
		"movement": "tank",
		"desc": "Large enough for the whole crew to stand in the turret."
	},
	"scout": {
		"name": "Scout Rover",
		"scene": preload("res://entities/vehicles/Scout.tscn"),
		"movement": "tank",
		"desc": "Six wheels of fun"
	},
	"hovertank": {
		"name": "Hover Tank",
		"scene": preload("res://entities/vehicles/hovertank.tscn"),
		"movement": "hover",
		"desc": "Nothing changes your perspective like being a meter off the ground"
	},
	"mecha": {
		"name": "Cassidy Mech",
		"scene": preload("res://entities/vehicles/Mecha.tscn"),
		"movement": "walk",
		"desc": "Light, by giant robot standards"
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
		"desc": "Double down close in weapon"
	}
}

var PILOTS = {
	"rev": {
		"name": "Revenant",
		"desc": "During an early Incursion, the Revenant made a solo expedition into [i]Their Place[/i] and, uniquely, returned to tell the tale."
	},
	"pro": {
		"name": "The Professional",
		"desc": "Unspeakable horror from another dimension, sworn to hunt maltech users across the multiverse. I guess they've got problems out there too."
	},
	"doc": {
		"name": "Doc",
		"desc": "Special dispensation was granted to allow them to keep using their maltech parts... for a price: piloting vehicles for The Pact."
	},
	"drn": {
		"name": "Drone",
		"desc": "Former Moloch Drone, grown for Maltech-use. Probably isn't going to revert to some secret sleeper agent conditioning... probably."
	}
}

var MOVEMENT = {
	"tank": preload("res://components/player_control/TankMovement.tscn"),
	"hover": preload("res://components/player_control/HoverMovement.tscn"),
	"walk": preload("res://components/player_control/WalkMovement.tscn")
}

var selected_vehicle: String
var selected_control_scheme: String
var selected_primary: String
var selected_secondary: String
var selected_pilot: String

var CONTROLLERS = {
	"absolute": preload("res://components/player_control/AbsoluteController.tscn"),
	"cardinal": preload("res://components/player_control/CardinalController.tscn")
}

func _ready():
	set_vehicle_selection(0)
	set_controller_selection(0)
	set_primary_selection(0)
	set_secondary_selection(1)
	set_pilot_selection(0)

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

func set_pilot_selection(index: int):
	var keys = PILOTS.keys()
	var byindex = keys[index]
	selected_pilot = PILOTS.keys()[index]

func spawn_player(world: Node):
	Heat.heat = 0
	var player = VEHICLES[selected_vehicle].scene.instance()
	var controller_instance = CONTROLLERS[selected_control_scheme].instance()
	controller_instance.name = "Controller"
	var movement_instance = MOVEMENT[VEHICLES[selected_vehicle].movement].instance()
	movement_instance.name = "Movement"
	
	player.add_child(movement_instance)
	player.add_child(controller_instance)
	
	var primary_ability_instance = preload("res://components/abilities/Teleport.tscn").instance()
	primary_ability_instance.primary = true
	player.add_child(primary_ability_instance)
	
	var energy_component = preload("res://components/energy.tscn").instance()
	energy_component.energy = 100
	energy_component.max_energy = 100
	player.add_child(energy_component)
	
	for turret in player.get_turrets():
		for slot in turret.get_primary_slots():
			slot.add_child(WEAPONS[selected_primary].scene.instance())
		for slot in turret.get_secondary_slots():
			slot.add_child(WEAPONS[selected_secondary].scene.instance())
			
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
