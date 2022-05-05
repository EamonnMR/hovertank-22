extends Spatial

class_name VehicleCore
onready var parent = get_node("../")
onready var controller = parent.get_node("Controller")
var destroyed = false
signal destroyed

var camera

export var turret_path: NodePath
export var graphics: NodePath
export var match_ground: bool = true

export var player_shader: Material
export var destroyed_shader: Material

export var faction: int = 0
export var wander: bool = true

# TODO: Load these from Client, make difficulty settings
const HEALTH_NERF_FACTOR = 0.5
const DMG_NERF_FACTOR = 0.5
const COOLDOWN_NERF_FACTOR = 2.0
const SPREAD_NERF_FACTOR = 1.5

func is_player():
	return controller and controller.is_player()
	
func _ready():
	# If this wasn't spawned as a player, add AI to it
	# TODO: This isn't as elegant as I'd like
	if not has_node("../Controller"):
		_nerf_npc_stats()
		call_deferred("add_ai")
	
	if parent.is_player():
		# TODO: Not great for SOC
		camera = get_node("../../CameraRig")
		get_node("../CameraMover").remote_path = camera.get_mover_path()
		get_node("../Notifier").enable_proactive()
		setup_player_skin()
		parent.name = "player"
	else:
		get_node("../Notifier").disable_proactive()
	
	
	var map = get_node("../../")
	# connect("destroyed", map, "unit_destroyed")
	get_node("../Health").connect("destroyed", self, "_dead")
	#if ProjectSettings.get_setting("Prefs/controller"):
		#add_child(preload("res://GamepadController.tscn").instance())
	#else:
	# add_child(preload("res://components/player_control/MouseAndKeyboardController.tscn").instance())
	
func _physics_process(delta: float):
	# Movement is handled by the movement component
	if not destroyed:
		_handle_shooting()

func _handle_shooting():
	if not controller or destroyed:
		return
	if controller.is_shooting():
		for turret in get_turrets():
			turret.try_shoot_primary()
		# TODO: Multi Turret vehicles
	if controller.is_shooting_secondary():
		for turret in get_turrets():
			turret.try_shoot_secondary()

func _dead():
	# Remove this node but keep the camera around
	#var camera = $Camera2D
	#remove_child(camera)
	#get_node("../").add_child(camera)
	#camera.position = position
	if not destroyed:
		emit_signal("destroyed")
		destroyed = true
		if destroyed_shader:
			var graphics_node: MeshInstance = get_node(graphics)
			graphics_node.set_surface_material(0, destroyed_shader)
			if has_node("NPCHealthBar"):
				get_node("../NPCHealthBar").hide()
			get_node("../Health").health = get_node("../Health").max_health / 2
			get_node("../Health").already_destroyed = false
		else:
			parent.queue_free()
	else:
		parent.queue_free()

func get_center_of_mass():
	return get_node("../CenterOfMass").global_transform.origin

func get_turrets():
	if turret_path:
		return [get_node(turret_path)]
	if get_node("../Graphics/Armature") is Skeleton:
		return  [get_node("../Graphics/Armature/Turret")]
	return [get_node("../Graphics/Armature/Skeleton/Turret")]

func alert(source):
	if destroyed:
		return
	if controller and controller.has_method("alert"):
		controller.alert(source)

func add_ai():
	var mover = preload("res://components/AgentMovement.tscn").instance()
	controller = preload("res://components/ai_controller.tscn").instance()
	mover.name = "Movement"
	controller.name = "Controller"
	
	parent.add_child(mover)
	parent.add_child(controller)

func _nerf_npc_stats():
	parent.nerf_npc_stats_base()
	
	get_node("../Health").max_health *= HEALTH_NERF_FACTOR
	get_node("../Health").health = get_node("../Health").max_health
	
	for turret in get_turrets():
		for weapon in turret.get_weapons():
			weapon.dmg_factor = DMG_NERF_FACTOR
			weapon.get_node("Cooldown").wait_time *= COOLDOWN_NERF_FACTOR
			weapon.spread *= SPREAD_NERF_FACTOR

func setup_player_skin():
	if player_shader:
		var graphics_node: MeshInstance = get_node(graphics)
		graphics_node.set_surface_material(0, player_shader)

func derive_engagement_range():
	var weapon_ranges = []
	for turret in get_turrets():
		for weapon in turret.get_weapons():
			weapon_ranges.push_back(weapon.engagement_range)
	# TODO: average
	return weapon_ranges[0]
