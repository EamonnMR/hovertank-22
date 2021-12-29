extends Spatial

func _ready():
	var owner = get_node("../")
	$RotationPivot/ElevationPivot/Weapon.init(IffProfile.new(
		owner,
		not owner.is_player(),
		owner.is_player()
	))

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
	return Vector2(euler.x, euler.y + PI/2)

func try_shoot_primary():
	$RotationPivot/ElevationPivot/Weapon.try_shoot()
	
func try_shoot_secondary():
	pass

func update(aim_point: Vector3):
	var aim_pose = _aim_to_turret_pose(aim_point)
	# var aim_pose = Vector2(-0.078713, 3.865857)
	$RotationPivot.rotation.y = aim_pose.y
	$RotationPivot/ElevationPivot.rotation.z = aim_pose.x

func project_ray():
	# Whatis the turret pointing at right now?
	var collisionMask = 1
	# The pathfinding system only likes to interact with things that are stuck to the ground
	var from = global_transform.origin
	var to = $RotationPivot/ElevationPivot.to_global(Vector3(1000, 0, 0))
	var spaceState :PhysicsDirectSpaceState = get_world().direct_space_state
	var result :Dictionary = spaceState.intersect_ray(from, to, [], collisionMask)
	if result.has("position"):
		$TurretPointMarker.show()
		$TurretPointMarker.global_transform.origin = result.position
	else:
		$TurretPointMarker.hide()
	# return {"position": to}
	return result
