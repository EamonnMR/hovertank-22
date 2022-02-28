extends Spatial

onready var parent = get_node("../")
onready var controller = get_node("../Controller")

class_name Movement


func update_momentum(momentum: float, delta: float, motion_impulse: int) -> float:
	var max_diff = delta * parent.accel
	if motion_impulse:
		var new_momentum = momentum + delta * parent.accel * motion_impulse
		if abs(new_momentum) > parent.speed:
			return sign(new_momentum) * parent.speed
		else:
			return new_momentum
	else:
		if max_diff > momentum:
			return 0.0
		else:
			return sign(momentum) * max_diff

func match_ground_normal(_delta: float, parent: Spatial, factor: float = 0.2):
	# see: http://kidscancode.org/godot_recipes/3d/3d_align_surface
	var ray_below_normal = $RayCast.get_collision_normal()
	if ray_below_normal != Vector3(0, 0, 0):
		parent.global_transform = parent.global_transform.interpolate_with(
			_align_with_y(parent.global_transform, ray_below_normal), 
			factor
		)

func _align_with_y(xform: Transform, new_y: Vector3) -> Transform:
	#var xform = Transform(transform)
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

