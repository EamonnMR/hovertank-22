extends Movement

# Movement for player vehicles which can turn in place and don't hover

var left_wheels = []
var right_wheels = []

var left_tracks = []
var right_tracks = []

var track_count = 0

func _ready():
	for child in parent.get_children():
		if child is VehicleWheel:
			if child.right:
				right_wheels.append(child)
			if child.left:
				left_wheels.append(child)
	for child in parent.get_children():
		if child is VehicleBody:
			if child.right:
				right_tracks.append(child)
			if child.left:
				left_tracks.append(child)
	track_count = len(left_tracks) + len(right_tracks)
	
func _physics_process(delta):
	if parent.destroyed:
		parent.engine_force = 0
		return
	var turn_and_motion_impulse = controller.get_turn_and_motion_impulse(delta, parent.turn)
	var turn = turn_and_motion_impulse[0]
	var motion_impulse = turn_and_motion_impulse[1]
	
	parent.engine_force = motion_impulse * parent.get_power()
	parent.steering = turn * parent.max_steering

	differential_power_for_steering()
	
func differential_power_for_steering():
	var power = parent.engine_force / track_count
	if parent.steering == 0:
		set_wheel_traction(left_wheels, true)
		set_wheel_traction(right_wheels, true)
		set_track_power(left_tracks, power)
		set_track_power(right_tracks, power)
	if parent.steering < 0:
		set_wheel_traction(left_wheels, true)
		set_wheel_traction(right_wheels, false)
		set_track_power(left_tracks, power * 2)
		set_track_power(right_tracks, 0)
	if parent.steering > 0:
		set_wheel_traction(left_wheels, false)
		set_wheel_traction(right_wheels, true)
		set_track_power(left_tracks, 0)
		set_track_power(right_tracks, power * 2)

func set_wheel_traction(wheels: Array, traction: bool):
	for wheel in wheels:
		wheel.use_as_traction = traction
		if traction:
			wheel.brake = 0
		else:
			wheel.brake = 10
			
func set_track_power(tracks, power):
	for track in tracks:
		track.engine_force = power
		if not power:
			track.brake = 10
		else:
			track.brake = 0
