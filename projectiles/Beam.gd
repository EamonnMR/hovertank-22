extends Spatial

export var max_range 1000
export var overpen

var iff: IffProfile

func _ready():
	pass # Replace with function body.

func project_beam():
	global_transform.basis.x * range

func project_ray() -> Dictionary:
	var collisionMask = 1
	
	var first_weapon_emergepoint = $ElevationPivot
	var from = global_transform.origin
	var to = global_transform.origin + global_transform.basis.x * max_range 
	var spaceState :PhysicsDirectSpaceState = get_world().direct_space_state
	return spaceState.intersect_ray(from, to, [], collisionMask)
	
