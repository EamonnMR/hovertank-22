extends Node

var VEHICLES = {
	"heavy": {
		"name": "Heavy Tank",
		"scene": preload("res://entities/vehicles/Heavy.tscn"),
		"movement": "tank"
	},
	"scout": {
		"name": "Scout Rover",
		"scene": preload("res://entities/vehicles/Scout.tscn"),
		"movement": "tank"
	},
	"hovertank": {
		"name": "Hover Tank",
		"scene": preload("res://entities/vehicles/hovertank.tscn"),
		"movement": "hover"
	}
}

var MOVEMENT = {
	"tank": preload("res://components/player_control/TankMovement.tscn"),
	"hover": preload("res://components/player_control/HoverMovement.tscn")
}

var selected_vehicle: String
var selected_control_scheme

var CONTROLLERS = {
	"absolute": preload("res://components/player_control/AbsoluteController.tscn"),
	"cardinal": preload("res://components/player_control/CardinalController.tscn")
}

func _ready():
	set_vehicle_selection(0)
	set_controller_selection(0)

func set_vehicle_selection(index: int):
	var keys = VEHICLES.keys()
	var byindex = keys[index]
	selected_vehicle = VEHICLES.keys()[index]

func set_controller_selection(index: int):
	var keys = CONTROLLERS.keys()
	var byindex = keys[index]
	selected_control_scheme = CONTROLLERS.keys()[index]

func spawn_player(world: Node):
	var player = VEHICLES[selected_vehicle].scene.instance()
	var controller_instance = CONTROLLERS[selected_control_scheme].instance()
	controller_instance.name = "Controller"
	var movement_instance = MOVEMENT[VEHICLES[selected_vehicle].movement].instance()
	movement_instance.name = "Movement"
	
	player.add_child(movement_instance)
	player.add_child(controller_instance)
	world.add_child(player)
	player.global_transform.origin = world.get_node("SpawnPoint").global_transform.origin
