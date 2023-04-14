# Based subtantially on the demo project here: https://github.com/TheSHEEEP/godotdetour

extends Node3D

signal nav_ready

var nav_is_ready = false
var level_meshes = []

var navigation = null
var testIndex :int = -1
@onready var nextStepLbl : RichTextLabel = get_node("Control/NextStepLbl")
var debugMeshInstance :MeshInstance3D = null

func stick_to_ground(point: Vector3):
	var from = point + Vector3.UP * 25
	var collisionMask = 128
	# The pathfinding system only likes to interact with things that are stuck to the ground
	var to :Vector3 = point + Vector3.DOWN * 100
	var spaceState :PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	#var result :Dictionary = spaceState.intersect_ray(from, to, [], collisionMask)
	#if result.is_empty():
	#	print("Cannot stick to ground between ", from, " and ", to)
	#	return null
	#else:
	#	return result.position - Vector3(0, 0.2, 0)

func _ready():
	Client.spawn_player(self)
	
func add_level_mesh(transf: Transform3D, mesh: Mesh):
	assert(not nav_is_ready) #,"cannot add level meshes when nav mesh is already baked. For dynamic obstacles, use obstacle")
	level_meshes.push_back([transf, mesh])
	
func bake_level_mesh():
	var mesh = ArrayMesh.new()
	for level_mesh in level_meshes:
		var xform = level_mesh[0]
		# var xform = Transform3D()
		# xform.origin = transform.origin / 10
		var arrays = level_mesh[1].surface_get_arrays(0)
		var xformed_arrays = []
		for array in arrays:
			# This depends on the implementation details of the mesh internals
			if array is PackedVector3Array:
				var xformed_array = PackedVector3Array()
				for i in array:
					xformed_array.push_back(xform * i)
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
	var node = MeshInstance3D.new()
	node.mesh = mesh
	return node
