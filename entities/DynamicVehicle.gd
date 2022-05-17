extends RigidBody

onready var core = get_node("VehicleCore")

var engine_force: float
var steering: float

var destroyed = false

export var speed: float = 30.0
export var accel: float = 3.0
export var turn: float = 5
export var match_ground: bool = true

export var engine_torque = 100
export var max_steering = 1

# TODO: Load these from Client, make difficulty settings
const SPEED_NERF_FACTOR = 0.9
const ACCEL_NERF_FACTOR = 0.6
const TURN_NERF_FACTOR = 0.7

func get_power():
	# TODO: Implement power curve, gears, etc
	return engine_torque

func graphics():
	return core.get_node(core.graphics)

func alert(source):
	return get_node("VehicleCore").alert(source)

func is_player():
	return get_node("VehicleCore").is_player()

func get_center_of_mass():
	return get_node("VehicleCore").get_center_of_mass()
	
func nerf_npc_stats_base():
	speed *= SPEED_NERF_FACTOR
	accel *= ACCEL_NERF_FACTOR
	turn *= TURN_NERF_FACTOR
