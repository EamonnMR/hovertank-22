extends Spatial

class_name Movement

func match_ground_normal(_delta: float, parent: Spatial):
	# see: http://kidscancode.org/godot_recipes/3d/3d_align_surface/
	var ray_below_normal = $RayCast.get_collision_normal()
	if ray_below_normal != Vector3(0, 0, 0):
		parent.global_transform = parent.global_transform.interpolate_with(
			_align_with_y(parent.global_transform, $RayCast.get_collision_normal()), 
			0.2
		)

func _align_with_y(xform: Transform, new_y: Vector3) -> Transform:
	#var xform = Transform(transform)
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func _anglemod(angle: float) -> float:
	return fmod(angle, PI * 2)
