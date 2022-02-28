extends KinematicBody
var camera

export var speed: float = 30.0
export var accel: float = 3.0
export var turn: float = 5

export var faction: int = 0

# TODO: Load these from Client, make difficulty settings
const HEALTH_NERF_FACTOR = 0.5
const SPEED_NERF_FACTOR = 0.9
const ACCEL_NERF_FACTOR = 0.6
const TURN_NERF_FACTOR = 0.7
const DMG_NERF_FACTOR = 0.5
const COOLDOWN_NERF_FACTOR = 2.0
const SPREAD_NERF_FACTOR = 1.5

func is_player():
	return $Controller and $Controller.is_player()

signal destroyed

class_name Vehicle

func _ready():
	# If this wasn't spawned as a player, add AI to it
	# TODO: This isn't as elegant as I'd like
	if not has_node("Controller"):
		add_ai()
		_nerf_npc_stats()
	
	if is_player():
		# TODO: Not great for SOC
		camera = get_node("../CameraRig")
		$CameraMover.remote_path = camera.get_mover_path()
		$Notifier.enable_proactive()
	else:
		$Notifier.disable_proactive()
	
	
	var map = get_node("../../")
	# connect("destroyed", map, "unit_destroyed")
	$Health.connect("destroyed", self, "_dead")
	#if ProjectSettings.get_setting("Prefs/controller"):
		#add_child(preload("res://GamepadController.tscn").instance())
	#else:
	# add_child(preload("res://components/player_control/MouseAndKeyboardController.tscn").instance())
	
func _physics_process(delta: float):
	# Movement is handled by the movement component
	_handle_shooting()

func _handle_shooting():
	if $Controller.is_shooting():
		for turret in get_turrets():
			turret.try_shoot_primary()
		# TODO: Multi Turret vehicles
	if $Controller.is_shooting_secondary():
		for turret in get_turrets():
			turret.try_shoot_secondary()

func _dead():
	# Remove this node but keep the camera around
	#var camera = $Camera2D
	#remove_child(camera)
	#get_node("../").add_child(camera)
	#camera.position = position
	emit_signal("destroyed")
	queue_free()

func set_facing(facing: float):
	# $GraphicsPivoter.rotation.y = facing
	rotation.y = facing

func get_center_of_mass():
	return $CenterOfMass.global_transform.origin

func get_turrets():
	# TODO: Support multiple turrets
	if $Graphics/Armature is Skeleton:
		return  [$Graphics/Armature/Turret]
	return [$Graphics/Armature/Skeleton/Turret]

func alert(source):
	print("Alert")
	if $Controller.has_method("alert"):
		$Controller.alert(source)

func add_ai():
	var mover = preload("res://components/AgentMovement.tscn").instance()
	var controller = preload("res://components/ai_controller.tscn").instance()
	
	mover.name = "Movement"
	controller.name = "Controller"
	
	add_child(mover)
	add_child(controller)

func _nerf_npc_stats():
	$Health.max_health *= HEALTH_NERF_FACTOR
	$Health.health = $Health.max_health
	
	speed *= SPEED_NERF_FACTOR
	accel *= ACCEL_NERF_FACTOR
	turn *= TURN_NERF_FACTOR
	
	for turret in get_turrets():
		for weapon in turret.get_weapons():
			weapon.dmg_factor = DMG_NERF_FACTOR
			weapon.get_node("Cooldown").wait_time *= COOLDOWN_NERF_FACTOR
			weapon.spread *= SPREAD_NERF_FACTOR
