extends Spatial

var parent: KinematicBody
var controller

export var gravity = 90
export var motion_speed = 30.0
export var accel = 0.5

var motion = Vector3(0,0,0)

func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	

func _physics_process(delta):
	var motion_and_facing = controller.get_motion_and_facing()
	var facing = motion_and_facing[1]
	if facing != null:
		parent.rotation.y = facing
	if motion_and_facing[0]:
		motion = Vector3(1, 0, 0).rotated(Vector3.UP, parent.rotation.y)
	else:
		motion = Vector3(0,0,0)
	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * motion_speed + gravity_delta
	
	parent.move_and_slide_with_snap(motion_total, Vector3.DOWN, Vector3.UP)
	#parent.global_transform.interpolate_with(align_with_y(parent.global_transform, $RayCast.get_collision_normal()), .2)
	# Something fucky is going on here
	# see: http://kidscancode.org/godot_recipes/3d/3d_align_surface/
	var ray_below_normal = $RayCast.get_collision_normal()
	if ray_below_normal != Vector3(0, 0, 0):
		parent.global_transform = _align_with_y(parent.global_transform, $RayCast.get_collision_normal())
	else:
		print("Empty normal below")
func _constrained_turn(max_turn, ideal_face):
	var ideal_turn = _anglemod(ideal_face - parent.rotation.y)
	if(ideal_turn > PI):
		ideal_turn = _anglemod(ideal_turn - 2 * PI)

	elif(ideal_turn < -1 * PI):
		ideal_turn = _anglemod(ideal_turn + 2 * PI)
	
	max_turn = sign(ideal_turn) * max_turn  # Ideal turn in the right direction
	
	if(abs(ideal_turn) > abs(max_turn)):
		return [max_turn, ideal_face]
	else:
		return [ideal_turn, ideal_face]

func _align_with_y(xform: Transform, new_y: Vector3) -> Transform:
	#var xform = Transform(transform)
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func _anglemod(angle: float) -> float:
	return fmod(angle, PI * 2)
