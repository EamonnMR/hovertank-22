extends Spatial

var target: Spatial
# TODO: Tweak Params
# export var standoff: false
# export var min_range
var path: Array
var navmesh
export var firing_range = 20
var players_in_area: Array

const MIN_GOAL_POINT_DIST = 10

func _ready():
	navmesh = get_node("../../NavigationMesh") # TODO: Different navmeshes for different movement capabilities

func is_player():
	return false

func get_aim_point() -> Vector3:
	if target and is_instance_valid(target):
		var point = target.get_center_of_mass()
		print("AI Aiming at target: ", point)
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

func is_shooting():
	# TODO: Only when gun is ready to fire
	if is_instance_valid(target) and target.global_transform.origin.distance_to(global_transform.origin) < firing_range:
		var raycast_result = get_node("../").get_turret().project_ray()
		# TODO: If Raycast has result at all
		if raycast_result.has("collider"):
			if raycast_result.collider == self:
				print("Raycasted to self")
				return false
			elif raycast_result.collider == target:
				return true
			else:
				print("AI Aiming at: ", raycast_result.collider)
				return false
		else:
			return false
	else:
		return false

func _on_DetectArea_body_entered(body):
	if not target and body.has_method("is_player") and body.is_player():
		players_in_area.append(body)
	_check_for_target()

func _on_DetectArea_body_exited(body):
	players_in_area.erase(body)
	_check_for_target()
	
func _has_los_player(player):
	var our_pos = 	get_parent().get_center_of_mass()
	var player_pos = player.get_center_of_mass()
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(our_pos, player_pos, [], 1)
	var has_los =  result.has("collider") and result.collider == player
	print("Has los? ", has_los)
	return has_los

func _check_for_target():
	# TODO: Sort by distance
	for player in players_in_area:
		if _has_los_player(player):
			_obtain_target(player)
			return
	target = null
