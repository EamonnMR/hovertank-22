extends Spatial

var target: Spatial

func _ready():
	target = get_node("../../Player")

func is_player():
	return false

func get_aim_point() -> Vector3:
	if target:
		return target.global_transform.origin
	else:
		return Vector3()

func get_motion_and_facing() -> Array:
	var local_point = to_local(get_aim_point())
	var ideal_face = Transform.IDENTITY.looking_at(
		local_point, Vector3.UP
	).basis.get_euler().y + PI/2

	return [Vector3(1, 0, 0).rotated(Vector3.UP, ideal_face), ideal_face]
