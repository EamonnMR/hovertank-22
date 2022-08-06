extends NavigationMeshInstance

func _ready():
	Client.spawn_player(self)

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
