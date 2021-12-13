# Based subtantially on the demo project here: https://github.com/TheSHEEEP/godotdetour

extends Spatial


signal nav_ready

var terrain_mesh

const NAV_TERRAIN_MASK = 128
const DetourNavigation 	            :NativeScript = preload("res://addons/godotdetour/detournavigation.gdns")
const DetourNavigationParameters	:NativeScript = preload("res://addons/godotdetour/detournavigationparameters.gdns")
const DetourNavigationMeshParameters    :NativeScript = preload("res://addons/godotdetour/detournavigationmeshparameters.gdns")
const DetourCrowdAgent	            :NativeScript = preload("res://addons/godotdetour/detourcrowdagent.gdns")
const DetourCrowdAgentParameters    :NativeScript = preload("res://addons/godotdetour/detourcrowdagentparameters.gdns")
const DetourObstacle				:NativeScript = preload("res://addons/godotdetour/detourobstacle.gdns")

# Import classes
const HTerrain = preload("res://addons/zylann.hterrain/hterrain.gd")
const HTerrainData = preload("res://addons/zylann.hterrain/hterrain_data.gd")
const HTerrainTextureSet = preload("res://addons/zylann.hterrain/hterrain_texture_set.gd")
const HTerrainMesher = preload("res://addons/zylann.hterrain/hterrain_mesher.gd")


# You may want to change paths to your own textures
var grass_texture = load("res://assets/yughues_cc0/pattern_79_worn_stone/diffus.png")
var sand_texture = load("res://assets/yughues_cc0/pattern_80_mossy_rock/diffus.png")
var leaves_texture = load("res://assets/yughues_cc0/pattern_91_foliage/diffus.png")

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
var usePrediction			:bool = true
var navMeshToDisplay		:int = 0
var lastUpdateTimestamp		:int = OS.get_ticks_msec()
var offMeshID				:int = 0

func stick_to_ground(point: Vector3):
	var from = point + Vector3.UP * 25
	# The pathfinding system only likes to interact with things that are stuck to the ground
	var to :Vector3 = point + Vector3.DOWN * 100
	var spaceState :PhysicsDirectSpaceState = get_world().direct_space_state
	var result :Dictionary = spaceState.intersect_ray(from, to, [], NAV_TERRAIN_MASK)
	if result.empty():
		print("Cannot stick to ground between ", from, " and ", to)
		return null
	else:
		return result.position - Vector3(0, 0.2, 0)

func _ready():
	_terrain_ready()
	_navigation_ready()

# Navigation functions -- see godot detour demo

func _navigation_ready():
	print("initializeNavigation")
	yield(get_tree(), "idle_frame")
	yield(initializeNavigation(), "completed")
	yield(get_tree(), "idle_frame")
	drawDebugMesh()
	print("Drawing debug mesh")
	emit_signal("nav_ready")
	
func toggle_debug_display():
	if navMeshToDisplay == 1:
		navMeshToDisplay = 0
	elif navMeshToDisplay == 0:
		navMeshToDisplay = 1
	drawDebugMesh()
	
func toggle_prediction():
	usePrediction = !usePrediction

func add_obstacle(obstacle):
	pass
	# TODO

func get_agent():
	pass
	# TODO

func get_level_mesh():
	return terrain_mesh

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
	navMeshParamsSmall.cellSize = Vector2(.4, 0.1)
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
	navigation.initialize(get_level_mesh(), navParams)

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


# Called during physics process updates (doing creation/removal of obstacles and agents, etc.)
func doSaveLoadRoutine():
	# Save the current state (twice to see difference between compressed and raw)
	$Control/TempLbl.bbcode_text = "Saving current state..."
	yield(get_tree(), "idle_frame")
	navigation.save("user://navmeshes/stored_navmesh_raw.dat", false)
	navigation.save("user://navmeshes/stored_navmesh.dat", true)
	
	# Clear the navigation
	$Control/TempLbl.bbcode_text = "Clearing navigation..."
	yield(get_tree(), "idle_frame")
	navigation.clear()
	
	# Remove all agent references (no need to remove the DetourCrowdAgent, clear() did that)
	for agent in agents:
		remove_child(agent)
		agent.queue_free()
	agents.clear()
	
	# Remove all obstacle references (no need to destroy the DetourObstacle, clear() did that)
	for obstacle in obstacles:
		remove_child(obstacle)
		obstacle.queue_free()
	obstacles.clear()

	# Remove the debug mesh
	if debugMeshInstance != null:
		remove_child(debugMeshInstance)
		debugMeshInstance.queue_free()
		debugMeshInstance = null
	yield(get_tree().create_timer(2.0), "timeout")
	
	# Load the state
	$Control/TempLbl.bbcode_text = "Loading navmesh..."
	yield(get_tree(), "idle_frame")
	navigation.load("user://navmeshes/stored_navmesh.dat", true)
	
	# Retrieve the lists of agents, marked areas and obstacles and restore our lists
	var allAgents : Array = navigation.getAgents()
	var allObstacles : Array = navigation.getObstacles()
	var allMarkedAreaIDs : Array = navigation.getMarkedAreaIDs()
	
	# Re-add agent representations
	for detourCrowdAgent in allAgents:
		# Create an agent in Godot
		var newAgent :Spatial = $Agent.duplicate()
		newAgent.translation = detourCrowdAgent.position
		add_child(newAgent)
		agents[newAgent] = detourCrowdAgent
	
	# Re-add obstacles
	for detourObstacle in allObstacles:
		# Create an obstacle in Godot
		var newObstacle :RigidBody = $Obstacle.duplicate()
		newObstacle.translation = detourObstacle.position
		newObstacle.translation.y += 0.2
		add_child(newObstacle)
		
		# Create an obstacle in GodotDetour and remember both
		var targetPos :Vector3 = detourObstacle.position
		obstacles[newObstacle] = detourObstacle
	
	# Draw the debug mesh
	# Make sure everything loaded by the Navigation has been applied internally after the first internal navigation thread tick
	# Otherwise, we risk drawing an "unfinished" state
	# yield(navigation, "navigation_tick_done")
	# drawDebugMesh()
	
	# Done
	$Control/TempLbl.bbcode_text = ""

# Do something when an agent arrived
func onAgentArrived(detourAgent, agent :Spatial):
	print("Detour agent ", detourAgent, " arrived at ", detourAgent.target)
	var player :AudioStreamPlayer3D = agent.get_node("AudioPlayer")
	player.play()

# Below code is not a very good way to deal with this, a better way would be to increase the target distance with the number of reports coming in, or the number of agents blocking the way, etc.

# Do something when an agent reports that it couldn't make progress towards its target
func onAgentNoProgress(detourAgent, distanceLeft :float, agent :Spatial):
	# print("Detour agent ", detourAgent, " reported progress problem. Distance left: ", distanceLeft)
	if distanceLeft < 1.5 * agent.scale.x:
		detourAgent.stop()

# Do something when an agent reports that it didn't move in a second
func onAgentNoMovement(detourAgent, distanceLeft :float, agent :Spatial):
	# print("Detour agent ", detourAgent, " reported no movement. Distance left: ", distanceLeft)
	if distanceLeft < 0.75 * agent.scale.x:
		detourAgent.stop()

func redraw():
	var timer :Timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(0.1)
	timer.connect("timeout", self, "drawDebugMesh")
	add_child(timer)
	timer.start()

# Oh yes, we're also gonna copypasta in the entire hterrain procgen docs section
func _terrain_ready():
	# Create terrain resource and give it a size.
	# It must be either 513, 1025, 2049 or 4097.
	var terrain_data = HTerrainData.new()
	terrain_data.resize(513)

	var noise = OpenSimplexNoise.new()
	var noise_multiplier = 50.0

	# Get access to terrain maps
	var heightmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	var normalmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_NORMAL)
	var splatmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_SPLAT)

	heightmap.lock()
	normalmap.lock()
	splatmap.lock()

	# Generate terrain maps
	# Note: this is an example with some arbitrary formulas,
	# you may want to come up with your owns
	
	# Also note: This displays a totally janked up texture, mapping totally fails.
	# So, like, fix it I guess.
	for z in heightmap.get_height():
		for x in heightmap.get_width():
			# Generate height
			var h = noise_multiplier * noise.get_noise_2d(x, z)

			# Getting normal by generating extra heights directly from noise,
			# so map borders won't have seams in case you stitch them
			var h_right = noise_multiplier * noise.get_noise_2d(x + 0.1, z)
			var h_forward = noise_multiplier * noise.get_noise_2d(x, z + 0.1)
			var normal = Vector3(h - h_right, 0.1, h_forward - h).normalized()

			# Generate texture amounts
			var splat = splatmap.get_pixel(x, z)
			var slope = 4.0 * normal.dot(Vector3.UP) - 2.0
			# Sand on the slopes
			var sand_amount = clamp(1.0 - slope, 0.0, 1.0)
			# Leaves below sea level
			var leaves_amount = clamp(0.0 - h, 0.0, 1.0)
			splat = splat.linear_interpolate(Color(0,1,0,0), sand_amount)
			splat = splat.linear_interpolate(Color(0,0,1,0), leaves_amount)

			heightmap.set_pixel(x, z, Color(h, 0, 0))
			normalmap.set_pixel(x, z, HTerrainData.encode_normal(normal))
			splatmap.set_pixel(x, z, splat)

	heightmap.unlock()
	normalmap.unlock()
	splatmap.unlock()

	# Commit modifications so they get uploaded to the graphics card
	var modified_region = Rect2(Vector2(), heightmap.get_size())
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_NORMAL)
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_SPLAT)

	# Create texture set
	# NOTE: usually this is not made from script, it can be built with editor tools
	var texture_set = HTerrainTextureSet.new()
	texture_set.set_mode(HTerrainTextureSet.MODE_TEXTURES)
	texture_set.insert_slot(-1)
	texture_set.set_texture(0, HTerrainTextureSet.TYPE_ALBEDO_BUMP, grass_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(1, HTerrainTextureSet.TYPE_ALBEDO_BUMP, sand_texture)
	texture_set.insert_slot(-1)
	texture_set.set_texture(2, HTerrainTextureSet.TYPE_ALBEDO_BUMP, leaves_texture)

	# Create terrain node
	var terrain = HTerrain.new()
	terrain.set_shader_type(HTerrain.SHADER_CLASSIC4_LITE)
	terrain.set_data(terrain_data)
	terrain.set_texture_set(texture_set)
	terrain._collision_layer = 1 || NAV_TERRAIN_MASK
	add_child(terrain)
	terrain

	# No need to call this, but you may need to if you edit the terrain later on
	#terrain.update_collider()
	# Me attempting to generate a mesh out of the terrain
	var mesh_lod = 2
	var mesh_scale = Vector3(1,1,1)
	var mesh := HTerrainMesher.make_heightmap_mesh(heightmap, mesh_lod, mesh_scale)
	
	terrain_mesh = MeshInstance.new()
	terrain_mesh.mesh = mesh
	terrain_mesh.transform = terrain.transform

	print("Terrain Done")
