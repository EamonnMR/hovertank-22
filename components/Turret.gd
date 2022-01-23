extends BoneAttachment

onready var skel = get_node("../")
onready var turret_bone = skel.find_bone(bone_name)
onready var turret_pose = skel.get_bone_pose(skel.find_bone("turret"))
onready var parent = skel.get_node("../../../")

var primary_weapons = []
var secondary_weapons = []

# Hacks for wonky models; ignore unless your model is wonky
export var bone_axis: Vector3 = Vector3(0,1,0)
export var bone_invert: bool = false
export var bone_offset = PI/2

var unrotated_position: Spatial

const AIM_EXTEND = 1000

func get_primary_slots():
	return _get_slots(true)

func get_secondary_slots():
	return _get_slots(false)

func _get_slots(primary):
	var slots = []
	for slot in $ElevationPivot.get_children():
		if slot.primary == primary:
			slots.append(slot)
	return slots


func _ready():
	for slot in $ElevationPivot.get_children():
		if slot.primary:
			primary_weapons.append(slot.get_weapon())
		else:
			secondary_weapons.append(slot.get_weapon())
	
	for weapon in primary_weapons + secondary_weapons:
		weapon.init(IffProfile.new(
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
	# var local_point = get_parent().to_local(aim_point)
	# TODO Ballistic calculation goes here
	var euler = Transform.IDENTITY.looking_at(
		local_point, Vector3.UP
	).basis.get_euler()
	return Vector2(euler.x, euler.y)

func try_shoot_primary():
	for weapon in primary_weapons:
		weapon.try_shoot()
	
func try_shoot_secondary():
	for weapon in secondary_weapons:
		weapon.try_shoot()

func _modify_aim(aim_y):
	return bone_offset + (
		PI - aim_y if bone_invert else aim_y 
	)

func _physics_process(delta):
	var aim_point = parent.get_node("Controller").get_aim_point()
	var aim_pose = _aim_to_turret_pose(aim_point)
	skel.set_bone_pose(
		turret_bone,
		turret_pose.rotated(bone_axis, _modify_aim(aim_pose.y))
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
	
	var first_weapon_emergepoint = primary_weapons[0].get_node("Emerge")
	
	var from = first_weapon_emergepoint.global_transform.origin
	var to = first_weapon_emergepoint.to_global(Vector3(AIM_EXTEND, 0, 0))
	var spaceState :PhysicsDirectSpaceState = get_world().direct_space_state
	var result :Dictionary = spaceState.intersect_ray(from, to, [], collisionMask)
	return result
	#$TurretPointMarker.show()
	#$TurretPointMarker.global_transform.origin = unrotated_position.global_transform.origin
	if result.has("position"):
		pass
		# $TurretPointMarker.show()
		# $TurretPointMarker.global_transform.origin = unrotated_position.global_transform.origin
	else:
		#pass
		$TurretPointMarker.hide()
	return result

func _add_position_tracker():
	print("Add turret position tracker for ", parent)
	unrotated_position.name = "PositionFor" + name
	# Entire skeleton is the parent, not the bone
	get_parent().add_child(unrotated_position)
	print("Position For Path: ", unrotated_position.get_path())
	$UnrotatedPositionMover.remote_path = unrotated_position.get_path()

func _exit_tree():
	unrotated_position.queue_free()
