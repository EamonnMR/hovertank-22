extends Spatial

class_name VehicleCore
onready var parent = get_node("../")
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
	return parent.has_node("Controller") and parent.get_node("Controller").is_player()
	
func _ready():
	# If this wasn't spawned as a player, add AI to it
	# TODO: This isn't as elegant as I'd like
	if not has_node("Controller"):
		add_ai()
		_nerf_npc_stats()
	
	if parent.is_player():
		# TODO: Not great for SOC
		camera = get_node("../CameraRig")
		$CameraMover.remote_path = camera.get_mover_path()
		$Notifier.enable_proactive()
		setup_player_skin()
		parent.name = "player"
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
	if not destroyed:
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
	if not destroyed:
		emit_signal("destroyed")
		destroyed = true
		if destroyed_shader:
			var graphics_node: MeshInstance = get_node(graphics)
			graphics_node.set_surface_material(0, destroyed_shader)
			if has_node("NPCHealthBar"):
				$NPCHealthBar.hide()
			$Health.health = $Health.max_health / 2
			$Health.already_destroyed = false
		else:
			queue_free()
	else:
		queue_free()

func get_center_of_mass():
	return $CenterOfMass.global_transform.origin

func get_turrets():
	if turret_path:
		return [get_node(turret_path)]
	if $Graphics/Armature is Skeleton:
		return  [$Graphics/Armature/Turret]
	return [$Graphics/Armature/Skeleton/Turret]

func alert(source):
	if destroyed:
		return
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
	parent.nerf_npc_stats_base()
	
	$Health.max_health *= HEALTH_NERF_FACTOR
	$Health.health = $Health.max_health
	
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
