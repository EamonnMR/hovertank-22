extends Node3D

@onready var parent = get_node("../")
@onready var navmesh = get_node("../../NavigationMesh") # TODO: Different navmeshes for different movement capabilities
@onready var firing_range: float = parent.get_node("VehicleCore").derive_engagement_range()
@onready var chase_distance = firing_range / 2

var target: Node3D
var destination: Vector3

# TODO: Tweak Params
# export var standoff: false
# export var min_range

func next_weapon():
	return false

func previous_weapon():
	return true

func _has_target():
	return target != null and is_instance_valid(target)

func _ready():
	parent.add_to_group("enemies")
	call_deferred("recalculate_path")

func is_player():
	return false

func get_aim_point() -> Vector3:
	if target and is_instance_valid(target):
		var point = target.get_center_of_mass()
		return point
	else:
		return Vector3()

func recalculate_path():
	if target:
		recalculate_path_to_target()
	else:
		if get_node("../Movement"):
			if parent.core.wander:
				print("Picking new wander destination")
				destination = _random_destination()
				get_node("../Movement").navigate_to_position(destination)
			else:
				get_node("../Movement").stop()

func _obtain_target(target):
	print("Target Obtained: ", target)
	self.target = target
	recalculate_path_to_target()

func _random_destination():
	return parent.global_transform.origin + Vector3(
			randf_range(-100, 100),
			randf_range(0, 50),
			randf_range(-100, 100))
	
func recalculate_path_to_target():
	var movement = get_node("../Movement")
	if target and is_instance_valid(target) and _target_far_enough_away_to_chase():
		movement.navigate_to_position(target.global_transform.origin)
	else:		
		movement.stop()
		
func _target_far_enough_away_to_chase():
	return target.global_transform.origin.distance_to(global_transform.origin) > chase_distance

func is_shooting_secondary():
	return is_shooting()

func is_shooting():
	# TODO: Only when gun is ready to fire
	if is_instance_valid(target) and target.global_transform.origin.distance_to(global_transform.origin) < firing_range:
		var raycast_result = get_node("../VehicleCore").get_turrets()[0].project_ray()
		# TODO: If Raycast has result at all
		if raycast_result.has("collider"):
			if raycast_result.collider == self:
				print("Raycasted to self")
				return false
			elif raycast_result.collider == target:
				return true
			else:
				return false
		else:
			return false
	else:
		return false

func _has_los_player(player):
	var our_pos = parent.get_center_of_mass()
	var player_pos = player.get_center_of_mass()
	var space_state = get_world_3d().get_direct_space_state()
	var result: Dictionary = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(
		our_pos, player_pos, 1, [get_parent()]
	))
	var has_los = result.has("collider") and result.collider == player
	return has_los

func alert(alerting_body):
	if not parent:
		return
	if not parent.core.already_destroyed:
		if _is_foe(alerting_body):
			print("Alert!")
			if not _has_target():
				_obtain_target(alerting_body)

func use_ability_primary():
	return false
	
func use_ability_secondary():
	return false
	
	
func _is_foe(entity: Node) -> bool:
	if entity.has_node("VehicleCore"):
		var fac = entity.get_node("VehicleCore").faction
		var myfac = parent.core.faction
		return entity.get_node("VehicleCore").faction != parent.core.faction
	return false
