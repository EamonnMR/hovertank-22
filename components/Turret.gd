extends Spatial

func _aim_to_turret_pose(aim_point: Vector3) -> Vector2:
	# aim point: Global coordinates of the thing to aim at
	# Returns a Vector2 representing yaw and pitch to pose at that target
	# See:
	# https://www.reddit.com/r/godot/comments/p2v6av/quaterionlookrotation_equivalent/
	var local_point = to_local(aim_point)
	# TODO Ballistic calculation goes here
	var euler = Transform.IDENTITY.looking_at(
		local_point, Vector3.UP
	).basis.get_euler()
	print("aim_point: ", aim_point, " local_point: ", local_point, " euler: ", euler)
	return Vector2( euler.x, -1 * euler.y + (PI*1.5))

func try_shoot_primary():
	pass
	
func try_shoot_secondary():
	pass

func update(aim_point: Vector3):
	var aim_pose = _aim_to_turret_pose(aim_point)
	print("aim_point: ", aim_point, " aim_pose: ", aim_pose)
	# var aim_pose = Vector2(-0.078713, 3.865857)
	$RotationPivot.rotation.y = aim_pose.y
	$RotationPivot/ElevationPivot.rotation.x = aim_pose.x
