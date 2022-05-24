extends Movement

# Movement for player vehicles which can turn in place and don't hover

var left_wheels = []
var right_wheels = []

var left_tracks = []
var right_tracks = []

var track_count = 0

var brake_power = 5

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
	
	parent.steering = turn * parent.max_steering
	differential_power_for_steering(motion_impulse * parent.get_power())
	
func differential_power_for_steering(power: float):
	if power:
		if parent.steering == 0:
			set_wheel_power(left_wheels, power)
			set_wheel_power(right_wheels, power)
			set_track_power(left_tracks, power)
			set_track_power(right_tracks, power)
		if parent.steering < 0:
			set_wheel_power(left_wheels, power * 2)
			set_wheel_power(right_wheels, 0)
			set_track_power(left_tracks, power * 2)
			set_track_power(right_tracks, 0)
		if parent.steering > 0:
			set_wheel_power(left_wheels, 0)
			set_wheel_power(right_wheels, power * 2)
			set_track_power(left_tracks, 0)
			set_track_power(right_tracks, power * 2)
	else:
		# Turning in place
		if parent.steering == 0:
			set_track_power(left_tracks, 0)
			set_track_power(right_tracks, 0)
			set_wheel_power(left_wheels, 0)
			set_wheel_power(right_wheels, 0)
		# Double power to turn in place cause why not
		if parent.steering < 0:
			set_track_power(left_tracks, parent.turn_fudge * power)
			set_track_power(right_tracks, -1 * parent.turn_fudge * power)
			set_wheel_power(left_wheels, parent.turn_fudge * power)
			set_wheel_power(right_wheels, -1 * parent.turn_fudge * power)

		if parent.steering > 0:
			set_track_power(left_tracks, -1 * parent.turn_fudge * power)
			set_track_power(right_tracks, parent.turn_fudge * power)
			set_wheel_power(left_wheels, -1 * parent.turn_fudge * power)
			set_wheel_power(right_wheels, parent.turn_fudge * power)

# TODO: These functions are the same...
# Maybe we just make track use the same API as wheel
# (if we keep it at all)
func set_wheel_power(wheels: Array, power):
	for wheel in wheels:
		wheel.engine_force = power
		if not power:
			wheel.brake = parent.brake_power
		else:
			wheel.brake = power
			
func set_track_power(tracks, power):
	for track in tracks:
		track.engine_force = power
		if not power:
			track.brake = parent.brake_power
		else:
			track.brake = 0

func boolify(value: float) -> int:
	if value:
		return 1
	else:
		return 0
