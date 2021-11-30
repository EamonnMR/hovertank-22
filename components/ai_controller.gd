extends Spatial

var target: Spatial
# TODO: Tweak Params
# export var standoff: false
# export var min_range
var path: Array
var navmesh

const MIN_GOAL_POINT_DIST = 10

func _ready():
	navmesh = get_node("../../NavigationMesh") # TODO: Different navmeshes for different movement capabilities
	_obtain_target(get_node("../../../../Player"))

func is_player():
	return false

func get_aim_point() -> Vector3:
	if target:
		return target.global_transform.origin
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
	path = get_node("../../../").get_simple_path(global_transform.origin, target.global_transform.origin)
	print(global_transform.origin, " to ", target.global_transform.origin, " path: ", path)
	
