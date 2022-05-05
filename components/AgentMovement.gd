extends Movement

const DetourCrowdAgentParameters:NativeScript = preload("res://addons/godotdetour/detourcrowdagentparameters.gdns")

var agent
var world


var lastUpdateTimestamp

export var usePrediction = true


func _ready():
	world = parent.get_node("../")
	var par: Node = parent
	print(parent)
	print(par.get_children())
	
	parent.graphics().rotation.y += PI/2
	parent.get_node("VehicleCore").connect("destroyed", self, "stop")
	
	var sticky_point = world.stick_to_ground(parent.global_transform.origin)
	assert(sticky_point)
	if world.navigation:
		_create_nav_agent(sticky_point)
	else:
		get_tree().get_root().get_node("World").connect("nav_ready", self, "_create_nav_agent", [sticky_point])

func navigate_to_position(position: Vector3):
	print("Navigation begins: ", parent.name, " to: ", position)
	if parent.core.destroyed:

		return
	var maybe_position = world.stick_to_ground(position)
	print("Update nav to: ", maybe_position)
	if agent and maybe_position:
		position = maybe_position
		agent.moveTowards(position)
	else:
		print("Could not stick to ground from ", position)

func _create_nav_agent(position_on_ground):
	print("Create nav agent")
	var params = DetourCrowdAgentParameters.new()
	params.position = position_on_ground - Vector3(0, 0.1, 0)
	params.radius = 1.5
	params.height = 1.6
	params.maxAcceleration = parent.accel
	params.maxSpeed = parent.speed
	params.filterName = "default"
	# Check more in-depth descriptions of the optimizations here:
	# http://digestingduck.blogspot.com/2010/11/path-corridor-optimizations.html
	# If this agent should anticipate turns and move accordingly.
	params.anticipateTurns = true
	# Optimize walked path based on visibility. Strongly recommended.
	params.optimizeVisibility = true
	# If shorter paths should be attempted under certain circumstances. Also recommended.
	params.optimizeTopology = true
	# If this agent should try to avoid obstacles (dynamic obstacles).
	params.avoidObstacles = true
	# If this agent should avoid other agents (will just walk through them if false)
	params.avoidOtherAgents = true
	# How much this agent should avoid obstacles. 0 - 3, with 0 being low and 3 high avoidance.
	params.obstacleAvoidance = 1
	# How strongly the other agents should try to avoid this agent (if they have avoidOtherAgents set).
	params.separationWeight = 1.0

	agent = world.navigation.addAgent(params)
	# assert(agent != null, "Check your params. Radius, for example, breaks over 1.5")
	# TODO: It should probably forward these and let the controller subscribe to them
	if agent != null:
		agent.connect("arrived_at_target", controller, "recalculate_path", [agent], CONNECT_DEFERRED)
		agent.connect("no_progress", controller, "recalculate_path", [agent], CONNECT_DEFERRED)
		agent.connect("no_movement", controller, "recalculate_path", [agent], CONNECT_DEFERRED)
	else:
		parent.get_node("Health").take_damage(1000)
		print("Unable to place agent for: ", parent.name)
func _physics_process(delta):
	if agent and agent.isMoving == true:
		if usePrediction:
			var result: Dictionary = agent.getPredictedMovement(parent.translation, -parent.global_transform.basis.z, lastUpdateTimestamp, deg2rad(2.5))
			parent.translation = result["position"]
			parent.look_at(parent.translation + result["direction"], parent.transform.basis.y)
		else:
			parent.translation = agent.position
			parent.look_at(parent.translation + agent.velocity, parent.transform.basis.y)
	# Remember time of update
	lastUpdateTimestamp = OS.get_ticks_msec()
	#if parent.match_ground:
	match_ground_normal(delta, parent)


func stop():
	if agent != null:
		agent.stop()

func _exit_tree():
	if world.navigation:
		world.navigation.removeAgent(agent)

func moving():
	return agent.isMoving
