# Based subtantially on the demo project here: https://github.com/TheSHEEEP/godotdetour

extends Spatial

signal nav_ready

var nav_is_ready = false
var level_meshes = []


const DetourNavigation 	            :NativeScript = preload("res://addons/godotdetour/detournavigation.gdns")
const DetourNavigationParameters	:NativeScript = preload("res://addons/godotdetour/detournavigationparameters.gdns")
const DetourNavigationMeshParameters    :NativeScript = preload("res://addons/godotdetour/detournavigationmeshparameters.gdns")
const DetourCrowdAgent	            :NativeScript = preload("res://addons/godotdetour/detourcrowdagent.gdns")
const DetourCrowdAgentParameters    :NativeScript = preload("res://addons/godotdetour/detourcrowdagentparameters.gdns")
const DetourObstacle				:NativeScript = preload("res://addons/godotdetour/detourobstacle.gdns")

var navigation = null
var testIndex :int = -1
onready var nextStepLbl : RichTextLabel = get_node("Control/NextStepLbl")
var debugMeshInstance :MeshInstance = null

var levelStaticBody			:StaticBody = null
var doPlaceRemoveObstacle 	:bool = false
var doMarkArea				:bool = false
var doPlaceRemoveAgent		:bool = false
var doSetTargetPosition		:bool = false
var rayQueryPos				:Vector3 = Vector3(0, 0, 0)
var obstacles				:Dictionary = {}
var agents					:Dictionary = {}
var shiftDown				:bool = false
var navMeshToDisplay		:int = 0
var lastUpdateTimestamp		:int = OS.get_ticks_msec()
var offMeshID				:int = 0

func stick_to_ground(point: Vector3):
	var from = point + Vector3.UP * 25
	var collisionMask = 128
	# The pathfinding system only likes to interact with things that are stuck to the ground
	var to :Vector3 = point + Vector3.DOWN * 100
	var spaceState :PhysicsDirectSpaceState = get_world().direct_space_state
	var result :Dictionary = spaceState.intersect_ray(from, to, [], collisionMask)
	if result.empty():
		print("Cannot stick to ground between ", from, " and ", to)
		return null
	else:
		return result.position - Vector3(0, 0.2, 0)

#func _ready():
func bla():
	print("initializeNavigation")
	yield(get_tree(), "idle_frame")
	yield(initializeNavigation(), "completed")
	yield(get_tree(), "idle_frame")
	print("Drawing debug mesh")
	drawDebugMesh()
	emit_signal("nav_ready")
	nav_is_ready = true
	Client.spawn_player(self)
	
func toggle_debug_display():
	if navMeshToDisplay == 1:
		navMeshToDisplay = 0
	elif navMeshToDisplay == 0:
		navMeshToDisplay = 1
	drawDebugMesh()
	
func add_level_mesh(transf: Transform, mesh: Mesh):
	assert(not nav_is_ready, "cannot add level meshes when nav mesh is already baked. For dynamic obstacles, use obstacle")
	level_meshes.push_back([transf, mesh])
	
func bake_level_mesh():
	var mesh = ArrayMesh.new()
	for level_mesh in level_meshes:
		var xform = level_mesh[0]
		# var xform = Transform()
		# xform.origin = transform.origin / 10
		var arrays = level_mesh[1].surface_get_arrays(0)
		var xformed_arrays = []
		for array in arrays:
			# This depends on the implementation details of the mesh internals
			if array is PoolVector3Array:
				var xformed_array = PoolVector3Array()
				for i in array:
					xformed_array.push_back(xform.xform(i))
				xformed_arrays.push_back(xformed_array)
			else:
				xformed_arrays.push_back(array)
		# TODO: Use transform.xform on each point in the arrays to offset the mesh
		#for i in range(0, len(arrays)):
		#	if arrays[i] != xformed_arrays[i]:
		#		assert(len(arrays[i]) == len(xformed_arrays[i]))
		#		for j in range(0, len(arrays[i])):
		#			var val = arrays[i][j]
		#			var xformed_val = xformed_arrays[i][j]
		#			assert(val == xformed_val)

		mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES,
			xformed_arrays
		)
	var node = MeshInstance.new()
	node.mesh = mesh
	return node

# Initializes the navigation
func initializeNavigation():
	# Create the navigation parameters
	var navParams = DetourNavigationParameters.new()
	navParams.ticksPerSecond = 10 # How often the navigation is updated per second in its own thread, extra low to showcase prediction
	navParams.maxObstacles = 256 # How many dynamic obstacles can be present at the same time

	# Create the parameters for the "small" navmesh
	var navMeshParamsSmall = DetourNavigationMeshParameters.new()
	# It is important to understand that recast/detour operates on a voxel field internally.
	# The size of a single voxel (often called cell internally) has significant influence on how a navigation mesh is created.
	# A tile is a rectangular region within the navigation mesh. In other words, every navmesh is divided into equal-sized tiles, which are in turn divided into cells.
	# The detail mesh is a mesh used for determining surface height on the polygons of the navigation mesh.
	# Units are usually in world units [wu] (e.g. meters, or whatever you use), but some may be in voxel units [vx] (multiples of cellSize).

	# x = width & depth of a single cell (only one value as both must be the same) | y = height of a single cell. [wu]
	navMeshParamsSmall.cellSize = Vector2(1, 0.1)
	# The maximum number of agents that can be active on this navmesh
	navMeshParamsSmall.maxNumAgents = 256
	# How steep an angle can be to still be considered walkable. In degree. Max 90.0.
	navMeshParamsSmall.maxAgentSlope = 40.0
	# The maximum height of an agent supported in this navigation mesh. [wu]
	navMeshParamsSmall.maxAgentHeight = 2.0
	# How high a single "stair" can be to be considered walkable by an agent. [wu]
	navMeshParamsSmall.maxAgentClimb = 0.75
	# The maximum radius of an agent in this navigation mesh. [wu]
	navMeshParamsSmall.maxAgentRadius = 0.5
	# The maximum allowed length for contour edges along the border of the mesh. [wu]
	navMeshParamsSmall.maxEdgeLength = 2.0
	# The maximum distance a simplified contour's border edges should deviate the original raw contour. [vx]
	navMeshParamsSmall.maxSimplificationError = 1.3
	# How many cells an isolated area must at least have to become part of the navmesh.
	navMeshParamsSmall.minNumCellsPerIsland = 8
	# Any regions with a span count smaller than this value will, if possible, be merged with larger regions.
	navMeshParamsSmall.minCellSpanCount = 20
	# Maximum number of vertices per polygon in the navigation mesh.
	navMeshParamsSmall.maxVertsPerPoly = 6
	# The width & depth of a single tile. [vx]
	navMeshParamsSmall.tileSize = 42
	# How many vertical layers a single tile is expected to have. Should be less for "flat" levels, more for something like tall, multi-floored buildings.
	navMeshParamsSmall.layersPerTile = 4
	# The sampling distance to use when generating the detail mesh. [wu]
	navMeshParamsSmall.detailSampleDistance = 6.0
	# The maximum allowed distance the detail mesh should deviate from the source data. [wu]
	navMeshParamsSmall.detailSampleMaxError = 1.0
	navParams.navMeshParameters.append(navMeshParamsSmall)

	# Create the parameters for the "large" navmesh
	var navMeshParamsLarge = DetourNavigationMeshParameters.new()
	navMeshParamsLarge.cellSize = Vector2(0.4, 0.28)
	navMeshParamsLarge.maxNumAgents = 128
	navMeshParamsLarge.maxAgentSlope = 45.0
	navMeshParamsLarge.maxAgentHeight = 3.0
	navMeshParamsLarge.maxAgentClimb = 1.0
	navMeshParamsLarge.maxAgentRadius = 1.5
	navMeshParamsLarge.maxEdgeLength = 12.0
	navMeshParamsLarge.maxSimplificationError = 1.3
	navMeshParamsLarge.minNumCellsPerIsland = 8
	navMeshParamsLarge.minCellSpanCount = 20
	navMeshParamsLarge.maxVertsPerPoly = 6
	navMeshParamsLarge.tileSize = 42
	navMeshParamsLarge.layersPerTile = 4
	navMeshParamsLarge.detailSampleDistance = 6.0
	navMeshParamsLarge.detailSampleMaxError = 1.0
	navParams.navMeshParameters.append(navMeshParamsLarge)

	# Mark an area in the center as grass, this is doable before initalization
	if navigation == null:
		navigation = DetourNavigation.new()
	
	#How to add special areas
	#var vertices :Array = []
	#vertices.append(Vector3(-2.0, -0.5, 1.7))
	#vertices.append(Vector3(3.2, -0.5, 2.2))
	#vertices.append(Vector3(2.3, -0.5, -2.0))
	#vertices.append(Vector3(-1.2, -0.5, -3.1))
	#var markedAreaId = navigation.markConvexArea(vertices, 1.5, 4) # 4 = grass

	# Initialize the navigation with the mesh instance and the parameters
	navigation.initialize(bake_level_mesh(), navParams)

	# Set a few query filters
	var weights :Dictionary = {}
	weights[0] = 5.0		# Ground
	weights[1] = 5.0		# Road
	weights[2] = 999999.0	# Water
	weights[3] = 10.0		# Door
	weights[4] = 150.0		# Grass
	weights[5] = 150.0		# Jump
	navigation.setQueryFilter(0, "default", weights)
	weights[0] = 1.0
	weights[1] = 1.0
	weights[2] = 1.0
	weights[3] = 1.0
	weights[4] = 1.0
	weights[5] = 1.0
	navigation.setQueryFilter(1, "all-the-same", weights)
	
	# Wait until the first tick is done to add an off-mesh connection and rebuild
	yield(navigation, "navigation_tick_done")
	offMeshID = navigation.addOffMeshConnection($Portal1.translation, $Portal2.translation, true, 0.35, 0)
	navigation.rebuildChangedTiles()

# Draws and displays the debug mesh
func drawDebugMesh() -> void:
	if not get_tree().debug_collisions_hint:
		return
	# Don't do anything if navigation is not initialized
	if not navigation.isInitialized():
		return
	print("Redraw debug mesh")
	# Free the old instance
	if debugMeshInstance != null:
		remove_child(debugMeshInstance)
		debugMeshInstance.queue_free()
		debugMeshInstance = null

	# Create the debug mesh
	debugMeshInstance = navigation.createDebugMesh(navMeshToDisplay, false)
	if !debugMeshInstance:
		printerr("Debug meshInst invalid!")
		return

	# Add the debug mesh instance a little elevated to avoid flickering
	debugMeshInstance.translation = Vector3(0.0, 0.05, 0.0)
	# No idea what the point of this bit is
	# var displayMeshInst :MeshInstance = get_node("MeshInstance")
	# debugMeshInstance.rotation = displayMeshInst.rotation
	print("Debug mesh drawn")
	add_child(debugMeshInstance)

func redraw():
	var timer :Timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.1)
	timer.connect("timeout", self, "drawDebugMesh")
	add_child(timer)
	timer.start()
