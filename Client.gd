extends Node

var current_level = 0

var LEVELS = [
	{
		"name": "Smoking Section",
		"desc": "Stranded, surrounded, and just woken up from cryo.",
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
		"desc": "A standard Warp Ranger choice."
	},
	"mecha": {
		"name": "Cassidy Mech",
		"scene": preload("res://entities/vehicles/Mecha.tscn"),
		"desc": "Light, by giant robot standards."
	},
	"tilter": {
		"name": "Tilter Halftrack",
		"scene": preload("res://entities/vehicles/Tilter.tscn"),
		"desc": "Very narrow traverse, high speed. Saddle up"
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
		"desc": "Standard heavy weapon. Decent splash."
	},
	"autocanon": {
		"name": "Autocannon",
		"scene": preload("res://components/weapons/AutoCannon.tscn"),
		"desc": "Standard light weapon. Limited utility against armored vehicles."
	}
}
	
var SPECIAL_WEAPONS = [
	{
		"name": "Laser",
		"scene": preload("res://components/weapons/Laser.tscn"),
		"desc": "Somewhat worse than the average sunburn.",
		"ammo_pickup_count": 30,
		"max_ammo": 90,
		"icon_tex": load("res://assets/danc_cc_by/green_wedge.png")
	},
	{
		"name": "Canister Shot",
		"scene": preload("res://components/weapons/Canister.tscn"),
		"desc": "Double down on close range combat; you won't hit anything else",
		"ammo_pickup_count": 20,
		"max_ammo": 100,
		"icon_tex": load("res://assets/danc_cc_by/brown_double.png")
	},

	{
		"name": "Steinbolt",
		"scene": preload("res://components/weapons/Steinbolt.tscn"),
		"desc": "Mind the delay. Enjoy the fireworks.",
		"ammo_pickup_count": 4,
		"max_ammo": 6,
		"icon_tex": load("res://assets/danc_cc_by/blue_gadget.png")
	},

	{
		"name": "Railgun",
		"scene": preload("res://components/weapons/Railgun.tscn"),
		"desc": "Know your target, and what's behind it. And what's behind that...",
		"ammo_pickup_count": 12,
		"max_ammo": 24,
		"icon_tex": load("res://assets/danc_cc_by/blue_chunky.png")
	},
	
	{
		"name": "Ripsaw",
		"scene": preload("res://components/weapons/Ripsaw.tscn"),
		"desc": "Anything but mini",
		"ammo_pickup_count": 60,
		"max_ammo": 300,
		"icon_tex": load("res://assets/danc_cc_by/minigun.png")
	}
]

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
	var player = VEHICLES[selected_vehicle].scene.instance()
	player_object = player
	
	var controller_instance = CONTROLLERS[selected_control_scheme].instance()
	controller_instance.name = "Controller"

	player.add_child(controller_instance)
	
	var ammo_component = preload("res://components/AmmoManager.tscn").instance()
	player.add_child(ammo_component)
	
	for turret in player.get_node("VehicleCore").get_turrets():
		for slot in turret.get_primary_slots():
			slot.add_child(WEAPONS[selected_primary].scene.instance())
		for slot in turret.get_secondary_slots():
			slot.add_child(WEAPONS[selected_secondary].scene.instance())
	
	player.get_node("VehicleCore").faction = 1  # Players always work for ITAR
	var camera_rig = preload("res://camera/CameraRig.tscn").instance()
	camera_rig.third_person = true # false
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
