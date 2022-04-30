extends KinematicBody

onready var core = get_node("VehicleCore")

var destroyed = false
var camera

export var speed: float = 30.0
export var accel: float = 3.0
export var turn: float = 5
export var match_ground: bool = true

# TODO: Load these from Client, make difficulty settings
const SPEED_NERF_FACTOR = 0.9
const ACCEL_NERF_FACTOR = 0.6
const TURN_NERF_FACTOR = 0.7

func alert(source):
	return core.alert(source)

func is_player():
	return core.is_player()

func get_center_of_mass():
	return core.get_center_of_mass()
	
func nerf_npc_stats_base():
	speed *= SPEED_NERF_FACTOR
	accel *= ACCEL_NERF_FACTOR
	turn *= TURN_NERF_FACTOR
