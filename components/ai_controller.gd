extends Spatial

var target: Spatial
# TODO: Tweak Params
# export var standoff: false
# export var min_range
var path: Array
var navmesh
export var firing_range = 20

const MIN_GOAL_POINT_DIST = 10

func _ready():
	navmesh = get_node("../../NavigationMesh") # TODO: Different navmeshes for different movement capabilities

func is_player():
	return false

func get_aim_point() -> Vector3:
	if target and is_instance_valid(target):
		return target.get_center_of_mass()
	else:
		return Vector3()

func get_motion_and_facing() -> Array:
	var goal_point = get_aim_point()
	if path:
		goal_point = path[0]
	
	var local_point: Vector3 = to_local(goal_point)
	if local_point.length() < MIN_GOAL_POINT_DIST and path:
		path.pop_front()
		print("Reached point")
		if path:
			local_point = path[0]
		else:
			local_point = to_local(get_aim_point())
	var ideal_face = Transform.IDENTITY.looking_at(
		local_point, Vector3.UP
	).basis.get_euler().y + PI/2

	return [Vector3(1, 0, 0).rotated(Vector3.UP, ideal_face), ideal_face]


func _on_RecalcTimer_timeout():
	if target:
		recalculate_path()

func _obtain_target(target):
	self.target = target
	recalculate_path()
	
func recalculate_path():
	# var path = navmesh.find_path(global_transform.origin, target.global_transform.origin).points
	#path = get_node("../../../").get_simple_path(global_transform.origin, target.global_transform.origin)
	#print(global_transform.origin, " to ", target.global_transform.origin, " path: ", path)
	if target:
		get_node("../Movement").navigate_to_position(target.global_transform.origin)
	else:
		return Vector3()

func is_shooting():
	# TODO: Only when gun is ready to fire
	if is_instance_valid(target) and target.global_transform.origin.distance_to(global_transform.origin) < firing_range:
		var raycast_result = get_node("../").get_turret().project_ray()
		# TODO: If Raycast has result at all
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

func _on_DetectArea_body_entered(body):
	if not target and body.has_method("is_player") and body.is_player():
		_obtain_target(body)


func _on_DetectArea_body_exited(body):
	pass # Replace with function body.
