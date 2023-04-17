extends Node3D

var map_stale: bool = false

func rebake_map():
	map_stale = true
	

func stick_to_ground(point: Vector3):
	var from = point + Vector3.UP * 25
	var collisionMask = 128
	# The pathfinding system only likes to interact with things that are stuck to the ground
	var to :Vector3 = point + Vector3.DOWN * 100
	var spaceState :PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var result: Dictionary = spaceState.intersect_ray(PhysicsRayQueryParameters3D.create(
		from, to, collisionMask, []
	))
	if result.is_empty():
		print("Cannot stick to ground between ", from, " and ", to)
		return null
	else:
		return result.position - Vector3(0, 0.2, 0)

func _ready():
	Client.spawn_player(self)

func _on_rebake_timer_timeout():
	if map_stale:
		print("Baking map")
		$NavigationRegion3D.bake_navigation_mesh()
	map_stale = false
