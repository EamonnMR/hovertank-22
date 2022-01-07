extends BoneAttachment

onready var skel = get_node("../")
onready var turret_bone = skel.find_bone(bone_name)
onready var turret_pose = skel.get_bone_pose(skel.find_bone("turret"))
onready var parent = skel.get_node("../../../")

var unrotated_position

const AIM_EXTEND = 1000

func _ready():
	$ElevationPivot/Weapon.init(IffProfile.new(
		parent,
		not parent.is_player(),
		parent.is_player()
	))
	
	# This uses two extra nodes per turret
	unrotated_position = Spatial.new()
	call_deferred("_add_position_tracker")

func _aim_to_turret_pose(aim_point: Vector3) -> Vector2:
	# aim point: Global coordinates of the thing to aim at
	# Returns a Vector2 representing yaw and pitch to pose at that target
	# See:
	# https://www.reddit.com/r/godot/comments/p2v6av/quaterionlookrotation_equivalent/
	var local_point = unrotated_position.to_local(aim_point)
	# TODO Ballistic calculation goes here
	var euler = Transform.IDENTITY.looking_at(
		local_point, Vector3.UP
	).basis.get_euler()
	return Vector2(euler.x, euler.y + PI/2)

func try_shoot_primary():
	$ElevationPivot/Weapon.try_shoot()
	
func try_shoot_secondary():
	pass

func _physics_process(delta):
	var aim_point = parent.get_node("Controller").get_aim_point()
	var aim_pose = _aim_to_turret_pose(aim_point)
	skel.set_bone_pose(
		turret_bone,
		turret_pose.rotated(Vector3(0,1,0), aim_pose.y
		)
	)
	$ElevationPivot.rotation.z = aim_pose.x
	
	if parent.camera:
		var ray_result: Dictionary = project_ray()
		if ray_result.has("position"):
			parent.camera.set_turret_point(ray_result.position)

func project_ray():
	# What is the turret pointing at right now?
	var collisionMask = 1
	# The pathfinding system only likes to interact with things that are stuck to the ground
	var from = global_transform.origin
	var to = $ElevationPivot.to_global(Vector3(AIM_EXTEND, 0, 0))
	var spaceState :PhysicsDirectSpaceState = get_world().direct_space_state
	var result :Dictionary = spaceState.intersect_ray(from, to, [], collisionMask)
	if result.has("position"):
		$TurretPointMarker.show()
		$TurretPointMarker.global_transform.origin = result.position
	else:
		#pass
		$TurretPointMarker.hide()
	return result

func _add_position_tracker():
	unrotated_position.name = "PositionFor" + name
	parent.add_child(unrotated_position)
	print("Position For Path: ", unrotated_position.get_path())
	$UnrotatedPositionMover.remote_path = unrotated_position.get_path()
