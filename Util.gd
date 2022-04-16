extends Node

func _ready():
	unit_test_constrained_turn_with_possibility_of_reverse()
	# I guess this is just where unit tests live now
	unit_test_turret_calculates_front_quarter_bounds_correctly()
	unit_test_turret_calculates_rear_quarter_bounds_correctly()
	unit_test_traverse_works_90_traverse()
	unit_test_traverse_works_270_traverse_looking_forward()
	unit_test_traverse_works_270_traverse_looking_backward()

func show_above(child, parent):
	var aabb = parent.get_aabb()
	var scale = parent.scale.y
	child.transform.origin.y = (aabb.position.y + aabb.size.y + 2) * scale

func get_point_above(parent):
	var aabb = parent.get_aabb()
	var scale = parent.scale.y
	return Vector3(
		parent.global_transform.origin.x,
		(aabb.position.y + aabb.size.y + 2) * scale,
		parent.global_transform.origin.z
	)


	
func generic_aoe_query(node: Spatial, origin: Vector3, radius: float):
	var shape: SphereShape = SphereShape.new()
	shape.radius = radius
	var query = PhysicsShapeQueryParameters.new()
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 2
	query.set_shape(shape)
	query.transform.origin = origin
	return node.get_world().get_direct_space_state().intersect_shape(query)

func _anglemod(angle: float) -> float:
	# Maybe the reason this isn't a builtin is that it happens whenever an angle is applied?
	return fmod(angle, PI * 2)

func flatten(vec: Vector3) -> Vector2:
	return Vector2(vec.x, vec.z)

func constrained_turn(current_rotation: float, max_turn: float, ideal_face: float) -> Array:
	# This resolves how far and in what direction something should turn in order to match a rotation
	# given the constraint that it can only move so far in a single frame.
	var ideal_turn = _anglemod(ideal_face - current_rotation)
	if(ideal_turn > PI):
		ideal_turn = _anglemod(ideal_turn - 2 * PI)

	elif(ideal_turn < -1 * PI):
		ideal_turn = _anglemod(ideal_turn + 2 * PI)
	
	max_turn = sign(ideal_turn) * max_turn  # Ideal turn in the right direction
	
	if(abs(ideal_turn) > abs(max_turn)):
		return [max_turn, false]
	else:
		return [ideal_turn, true]

func constrained_turn_with_possibility_of_reverse(current_rotation, max_turn, ideal_face) -> Array:
	# Returns [turn: float, invert_movement: (1 or -1), is_ideal: bool]

	var invert_movement = 1
	
	# Never turn more than 180 - pick the right direction to turn in
	var ideal_turn = _anglemod(ideal_face - current_rotation)
	
	print("Initial: ", ideal_turn)
	
	
	if ideal_turn > PI * 1.5:
		print("ideal_turn > PI * 1.5; return 2PI-t")
		return limit_turn( 2 * PI - ideal_turn, max_turn, 1)
	if ideal_turn > PI / 2:
		print("ideal_turn > PI/2; return t - pi")
		return limit_turn( ideal_turn - PI, max_turn, -1)
	if ideal_turn > -PI / 2:
		print("ideal_turn > -PI/2; return t")
		return limit_turn( ideal_turn, max_turn, 1)
	if ideal_turn > -PI * 1.5:
		print("ideal_turn > -PI * 1.5; return t + PI")
		return limit_turn( ideal_turn + PI, max_turn, -1)
	else:
		print("else; return 2PI + t")
		return limit_turn( 2 * PI + ideal_turn, max_turn, 1)
	
func limit_turn(ideal_turn, max_turn, invert_movement) -> Array:
	# Limit the turn to what you can do
	max_turn = sign(ideal_turn) * max_turn
	
	print("Final: ", ideal_turn)
	if(abs(ideal_turn) > abs(max_turn)):
		return [max_turn, invert_movement, false]
	else:
		return [ideal_turn, invert_movement, true]

func unit_test_constrained_turn_with_possibility_of_reverse():
	# current_rotation, max_turn, ideal_face
	# # Returns [turn: float, invert_movement: (1 or -1), is_ideal: bool]
	var turn_cw = constrained_turn_with_possibility_of_reverse(
		0, 0.1, PI * 0.4
	)
	assert(turn_cw[0] == 0.1)
	assert(turn_cw[1] == 1)
	assert(turn_cw[2] == false)

func unit_test_turret_calculates_front_quarter_bounds_correctly():
	print("unit_test_turret_calculates_front_quarter_bounds_correctly")
	var turret = Turret.new()
	turret.traverse_degrees = 90
	turret._setup_traverse()
	print("Lbound: ", rad2deg(turret.l_bound))
	print("Rbound: ", rad2deg(turret.r_bound))
	assert(turret.l_bound == deg2rad(-135))
	assert(turret.r_bound == deg2rad(-45))

func unit_test_turret_calculates_rear_quarter_bounds_correctly():
	print("unit_test_turret_calculates_rear_quarter_bounds_correctly")
	var turret = Turret.new()
	turret.traverse_degrees = 270
	turret._setup_traverse()
	print("Lbound: ", rad2deg(turret.l_bound))
	print("Rbound: ", rad2deg(turret.r_bound))
	assert(turret.l_bound == deg2rad(45))
	assert(turret.r_bound == deg2rad(135))

func unit_test_traverse_works_90_traverse():
	print("unit_test_traverse_works_90_traverse")
	var turret = Turret.new()
	turret.traverse_degrees = 90
	turret._setup_traverse()
	var new_aim = turret._constrain_aim_by_traverse(deg2rad(-90))
	print("new aim: ", rad2deg(new_aim))
	assert(rad2deg(new_aim) == -90)
	assert(turret.bounds_in_front == true)

func unit_test_traverse_works_270_traverse_looking_forward():
	print("unit_test_traverse_works_270_traverse_looking_forward")
	var turret = Turret.new()
	turret.traverse_degrees = 270
	turret._setup_traverse()
	var new_aim = turret._constrain_aim_by_traverse(deg2rad(-90))
	print("new aim: ", rad2deg(new_aim))
	assert(rad2deg(new_aim) == -90)

func unit_test_traverse_works_270_traverse_looking_backward():
	print("unit_test_traverse_works_270_traverse_looking_backward")
	var turret = Turret.new()
	turret.traverse_degrees = 270
	turret._setup_traverse()
	var new_aim = turret._constrain_aim_by_traverse(deg2rad(10))
	print("new aim: ", rad2deg(new_aim))
	assert(turret.bounds_in_front == false)
	assert(rad2deg(new_aim) == 10)
