extends Movement

# Movement for player vehicles which can turn in place and don't hover

var brake_power = 5
	
func _physics_process(delta):
	if parent.destroyed:
		parent.engine_force = 0
		return
	var turn_and_motion_impulse = controller.get_turn_and_motion_impulse(delta, parent.turn)
	var turn = turn_and_motion_impulse[0]
	var motion_impulse = turn_and_motion_impulse[1]
	
	# Not working for some reason. Don't care enough to fix for now.
	#parent.steering = turn * parent.max_steering
	#parent.engine_force = parent.get_power() * motion_impulse
	
	# TODO: To make this more robust, check the wheels
	parent.get_node("VehicleWheel3D").steering = turn * parent.max_steering
	parent.get_node("VehicleWheel2").engine_force = parent.get_power() * motion_impulse
	parent.get_node("VehicleWheel3").engine_force = parent.get_power() * motion_impulse
