extends BoneAttachment3D

class_name Turret

@onready var skel = get_node("../")
@onready var turret_bone = skel.find_bone(bone_name)
@onready var turret_pose = skel.get_bone_pose(skel.find_bone("turret"))
var parent

var primary_slots = []
var secondary_slots = []


# Hacks for wonky models; ignore unless your model is wonky
@export var bone_axis: Vector3 = Vector3(0,1,0)
@export var elevation_axis: Vector3 = Vector3(0,0,1)
@export var bone_invert: bool = false
@export var bone_offset = PI/2
@export var traverse_degrees: int = 0

var traverse: bool = false
var l_bound: float = 0
var r_bound: float = 0
var bounds_in_front: bool = true

var unrotated_position: Node3D

var request_turn = 0

var aim_pose: Vector2 # Cache so other things can query it.

const AIM_EXTEND = 1000

#debugging cache values
var last_aim_input = 0.0 
var cond_branch = ""

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

func get_weapons():
	var weapons = []
	for slot_airity in [true, false]:
		for slot in _get_slots(slot_airity):
			if slot.has_weapon():
				weapons.append(slot.get_weapon())
	return weapons

func _ready():
	if traverse_degrees:
		_setup_traverse()
	
	parent = _get_parent()
	
	assert($ElevationPivot.get_children().size() > 0)
	for slot in $ElevationPivot.get_children():
		if slot.has_weapon():
			if slot.primary:
				primary_slots.append(slot)
			else:
				secondary_slots.append(slot)
	
	# This uses two extra nodes per turret
	unrotated_position = Node3D.new()
	call_deferred("_add_position_tracker")

func _aim_to_turret_pose(aim_point: Vector3) -> Vector2:
	# aim point: Global coordinates of the thing to aim at
	# Returns a Vector2 representing yaw and pitch to pose at that target
	# See:
	# https://www.reddit.com/r/godot/comments/p2v6av/quaterionlookrotation_equivalent/
	var local_point = unrotated_position.to_local(aim_point)
	# var local_point = get_parent().to_local(aim_point)
	# TODO Ballistic calculation goes here
	var euler = Transform3D.IDENTITY.looking_at(
		local_point, Vector3.UP
	).basis.get_euler()
	return Vector2(euler.x, euler.y)

func try_shoot_primary():
	for slot in primary_slots:
		slot.get_weapon().try_shoot()
	
func try_shoot_secondary():
	for slot in secondary_slots:
		slot.get_weapon().try_shoot()

func _modify_aim(aim_y):
	return bone_offset + (
		PI - aim_y if bone_invert else aim_y 
	)

func get_aim_y():
	return _modify_aim(aim_pose.y)

func _process(delta):
	if parent.core.already_destroyed:
		return
	var aim_point = parent.get_node("Controller").get_aim_point()
	aim_pose = _aim_to_turret_pose(aim_point)
	if traverse:
		aim_pose.y = _constrain_aim_by_traverse(aim_pose.y)
	skel.set_bone_pose_rotation(
		turret_bone,
		Quaternion(bone_axis, _modify_aim(aim_pose.y))
	)
	$ElevationPivot.rotation = aim_pose.x * elevation_axis
	
	if parent.core.camera:
		var ray_result: Dictionary = project_ray()
		if ray_result.has("position"):
			parent.core.camera.set_turret_point(ray_result.position)

func project_ray():
	# What is the turret pointing at right now?
	var collisionMask = 1
	# The pathfinding system only likes to interact with things that are stuck to the ground
	
	var first_weapon_emergepoint = $ElevationPivot
	var from = first_weapon_emergepoint.global_transform.origin
	var to = first_weapon_emergepoint.to_global(Vector3(AIM_EXTEND, 0, 0))
	var spaceState: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result: Dictionary = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(
		from, to, collisionMask, []
	))
	#$TurretPointMarker.show()
	$TurretPointMarker.global_transform.origin = unrotated_position.global_transform.origin
	return result
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
	print("Position For Path3D: ", unrotated_position.get_path())
	$UnrotatedPositionMover.remote_path = unrotated_position.get_path()

func _exit_tree():
	unrotated_position.queue_free()

func _setup_traverse():
	traverse = true
	var centerline = -PI/2
	bounds_in_front = true
	if bone_invert:
		centerline *= -1
	print("Traverse Degrees: ", traverse_degrees)
	if traverse_degrees > 180:
		traverse_degrees -= 180
		centerline = -1 * centerline
		bounds_in_front = not bounds_in_front
	var traverse_width = deg_to_rad(float(traverse_degrees) / 2.0)
	l_bound = centerline - traverse_width
	r_bound = centerline + traverse_width

func _constrain_aim_by_traverse(aim: float) -> float:
	last_aim_input = aim
	# Aim is slightly wonky. The front quarter is inverted and negative.
	# The rear quarter is not inverted and positive
	# There's probably a less tabley way to do this
	
	# The cond_branch stuff is in there in case you need to debug this again.
	cond_branch = ""
	request_turn = 0
	if bone_invert and aim >= l_bound and aim <= r_bound:
		cond_branch = "this is fine"
		return aim
	else:
		var rear_facing = (aim <= 0) if bone_invert else (aim >= 0)
		if rear_facing:
			cond_branch += "Rear; "
			if bounds_in_front:
				cond_branch += "Bounds in front; "
				if aim > PI/2:
					request_turn = -1
					cond_branch += "Rear; bounds in front; aim > 90; turn L bound"
					return l_bound
				else:
					request_turn = 1
					cond_branch += "Rear; bounds in front; aim < 90; turn R bound"
					return r_bound
			else:
				cond_branch += "Bounds in rear; "
				if aim > l_bound and aim < r_bound:
					cond_branch += "r_bound > aim > l_bound; aim"
					if aim > PI/2:
						request_turn = -1
						cond_branch += "aim < 90; turn R bound"
						return r_bound
					else:
						request_turn = 1
						cond_branch += "aim <= 90; turn L bound"
						return l_bound
		else: # Front Facing
			cond_branch += "Front; "
			if bounds_in_front:
				cond_branch += "Bounds in front; "
				if aim < l_bound:
					request_turn = -1
					cond_branch += "aim < l_bound; turn L bound"
					return l_bound
				if aim > r_bound:
					request_turn = 1
					cond_branch += "aim > r_bound; turn R bound"
					return r_bound
			else:
				cond_branch += "Bounds not in front; no op"
		if aim >= 0: # Rear Quarter
			if bounds_in_front:
				if aim > PI/2:
					request_turn = -1
					return l_bound
				else:
					request_turn = 1
					return r_bound
			else:
				if aim > l_bound and aim < r_bound:
					if aim > PI/2:
						request_turn = -1
						return r_bound
					else:
						request_turn = 1
						return l_bound
		else: # Front Quarter
			if bounds_in_front:
				if aim < l_bound:
					request_turn = -1
					return l_bound
				elif aim > r_bound:
					request_turn = 1
					return r_bound
	request_turn = 0
	return aim

func _get_parent():
	var maybe_parent = self
	while parent != get_tree().get_root():
		maybe_parent = maybe_parent.get_node("../")
		if maybe_parent is VehicleBody3D \
			or maybe_parent is RigidBody3D \
			or maybe_parent is CharacterBody3D:
				return maybe_parent 
	assert(false)
