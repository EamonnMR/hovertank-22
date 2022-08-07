extends Movement

var world


var linear_velocity: Vector3
var lastUpdateTimestamp

onready var agent = $NavigationAgent

func _ready():
	world = parent.get_node("../")
	
	# TODO: This is leading to wonkyness because it's rotating just the skeleton.
	# parent.get_node("Graphics").rotation.y += PI/2
	parent.get_node("VehicleCore").connect("destroyed", self, "stop")
	agent.set_target_location(global_transform.origin)

func navigate_to_position(position: Vector3):
	#if parent.core.destroyed:
	#	return
	print("Navigation begins: ", parent.name, " to: ", position)
	# var maybe_position = world.stick_to_ground(position)
	# print("Update nav to: ", maybe_position)
	#if agent and maybe_position:
	#	position = maybe_position
	
	agent.set_target_location(position)
	#else:
	#	print("Could not stick to ground from ", position)

func _create_nav_agent(position_on_ground):
	print("Create nav agent")
	# TODO: Set agent radius based on parent size
	# TODO: Set max speed to vehicle's max speed
	
	#agent.connect("arrived_at_target", controller, "recalculate_path", [agent], CONNECT_DEFERRED)
	#agent.connect("no_progress", controller, "recalculate_path", [agent], CONNECT_DEFERRED)
	#agent.connect("no_movement", controller, "recalculate_path", [agent], CONNECT_DEFERRED)

func _physics_process(delta):
	#if agent and agent.isMoving == true:
	#	if usePrediction:
	#		var result: Dictionary = agent.getPredictedMovement(parent.translation, -parent.global_transform.basis.z, lastUpdateTimestamp, deg2rad(2.5))
	#		parent.translation = result["position"]
	#		parent.look_at(parent.translation + result["direction"], parent.transform.basis.y)
	#	else:
	#		parent.translation = agent.position
	#		parent.look_at(parent.translation + agent.velocity, parent.transform.basis.y)
	# Remember time of update
	#lastUpdateTimestamp = OS.get_ticks_msec()
	
	#parent.move_and_slide_with_snap(linear_velocity, Vector3.DOWN, Vector3.UP)
	
	var vel = \
		agent.get_next_location() \
		- (global_transform.origin)#  * 10)
	print("Next loc: ", agent.get_next_location())
	
	agent.set_velocity(
		vel
	)
	
	parent.move_and_slide_with_snap(vel, Vector3.DOWN, Vector3.UP)
	
	#if parent.match_ground:
	#	match_ground_normal(delta, parent)


func stop():
	pass
	# if agent != null:
	#	agent.stop()

#func moving():
#	#return agent.isMoving


func _on_NavigationAgent_velocity_computed(safe_velocity):
	linear_velocity = safe_velocity
