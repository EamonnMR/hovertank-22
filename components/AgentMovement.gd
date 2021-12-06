extends Spatial
const DetourCrowdAgentParameters    :NativeScript = preload("res://addons/godotdetour/detourcrowdagentparameters.gdns")

var parent: KinematicBody
var controller
var agent
var world

var lastUpdateTimestamp

export var usePrediction = true


func _ready():
	parent = get_node("../")
	controller = get_node("../Controller")
	world = parent.get_node("../")
	
	var sticky_point = world.stick_to_ground(parent.global_transform.origin)
	
	if world.navigation:
		_create_nav_agent(sticky_point)
	else:
		get_tree().get_root().get_node("World").connect("nav_ready", self, "_create_nav_agent", [sticky_point])

func navigate_to_position(position: Vector3):
	if agent:
		agent.moveTowards(position)

func _create_nav_agent(position_on_ground):
	print("Create nav agent")
	var params = DetourCrowdAgentParameters.new()
	params.position = position_on_ground - Vector3(0, 0.1, 0)
	params.radius = 0.3
	params.height = 1.6
	params.maxAcceleration = 6.0
	params.maxSpeed = 3.0
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
	if agent == null:
		print("Unable to place agent!")
	else:
		print("Able to create nav agent")
		agent.connect("arrived_at_target", self, "_on_agent_arrived", [agent], CONNECT_DEFERRED)
		agent.connect("no_progress", self, "_on_agent_no_progress", [agent], CONNECT_DEFERRED)
		agent.connect("no_movement", self, "_on_agent_movement", [agent], CONNECT_DEFERRED)

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
