extends Spatial

onready var parent = get_node("../")
onready var navmesh = get_node("../../NavigationMesh") # TODO: Different navmeshes for different movement capabilities
var target: Spatial
# TODO: Tweak Params
# export var standoff: false
# export var min_range
var path: Array

export var firing_range = 60
var players_in_area: Array

const MIN_GOAL_POINT_DIST = 10

func _has_target():
	return target != null and is_instance_valid(target)

func _ready():
	parent.add_to_group("enemies")

func is_player():
	return false

func get_aim_point() -> Vector3:
	if target and is_instance_valid(target):
		var point = target.get_center_of_mass()
		return point
	else:
		return Vector3()

func _on_RecalcTimer_timeout():
	_check_for_target()
	if target:
		recalculate_path()

func _obtain_target(target):
	print("Target Obtained: ", target)
	self.target = target
	recalculate_path()
	
func recalculate_path():
	if target:
		get_node("../Movement").navigate_to_position(target.global_transform.origin)

func is_shooting_secondary():
	return is_shooting()

func is_shooting():
	# TODO: Only when gun is ready to fire
	if is_instance_valid(target) and target.global_transform.origin.distance_to(global_transform.origin) < firing_range:
		var raycast_result = get_node("../").get_turrets()[0].project_ray()
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

func _on_DetectArea_body_entered(body):
	if body.has_method("is_player") and body.is_player():
		players_in_area.append(body)
	_check_for_target()

func _on_DetectArea_body_exited(body):
	players_in_area.erase(body)
	_check_for_target()
	
func _has_los_player(player):
	var our_pos = 	get_parent().get_center_of_mass()
	var player_pos = player.get_center_of_mass()
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_pos, [get_parent()], 1)
	var has_los =  result.has("collider") and result.collider == player
	return has_los

func _check_for_target():
	if _has_target() and _has_los_player(target):
		return
	else:
	# TODO: Sort by distance
		for player in players_in_area:
			if _has_los_player(player):
				_obtain_target(player)
				return
		target = null

func alert(alerting_body):
	print("Alert!")
	if not _has_target():
		_obtain_target(alerting_body)

func use_ability_primary():
	return false
	
func use_ability_secondary():
	return false
