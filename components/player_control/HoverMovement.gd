extends Movement

@export var drag = 0.25
@export var gravity = 90

var motion = Vector3(0,0,0)

func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	

func _physics_process(delta):
	if parent.destroyed:
		return
	var turn_and_motion_impulse = controller.get_turn_and_motion_impulse(delta, parent.turn)
	var turn = turn_and_motion_impulse[0]
	var motion_impulse = turn_and_motion_impulse[1]
	parent.rotation.y += turn

	if motion_impulse != 0:
			motion = lerp(motion, Vector3(motion_impulse, 0, 0).rotated(Vector3.UP, parent.rotation.y), parent.accel * delta)
	else:
		motion = lerp(motion, Vector3(0,0,0), drag * delta)

	var gravity_delta = gravity * delta * Vector3.DOWN
	var motion_total = motion * parent.speed + gravity_delta
	parent.set_velocity(motion_total)
	# TODOConverter40 looks that snap in Godot 4.0 is float, not vector like in Godot 3 - previous value `Vector3.DOWN`
	parent.set_up_direction(Vector3.UP)
	parent.move_and_slide()
	parent.velocity
	match_ground_normal(delta, parent, 0.02)
