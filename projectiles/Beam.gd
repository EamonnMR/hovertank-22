extends Spatial

export var max_range = 1000
export var overpen_count = 0
export var damage = 1
export var aoe_damage = 0
export var aoe_radius = 0

var iff: IffProfile

func _ready():
	call_deferred("do_beam", global_transform.origin, [iff.owner], 0)

func init(iff):
	self.iff = iff

func do_beam(origin: Vector3, ignore: Array, pen_count):
	var collision = project_beam(global_transform.origin, ignore)
	if "collider" in collision:
		# TODO: Explosion at collision.position
		var collider = collision.collider
		if not iff.should_exclude(collider):
			Health.do_damage(collider, damage)
		if pen_count < overpen_count:
			# TODO: Keep track of deducted distance
			do_beam(collision.position, ignore + [collider], pen_count + 1)
		else:
			_update_graphics((collision.position - global_transform.origin).length())
			if aoe_radius:
				_do_aoe(collision.position)
	else:
		var endpoint = global_transform.origin + global_transform.basis.x * max_range
		_update_graphics(max_range)
		if aoe_radius:
			_do_aoe(endpoint)

func _update_graphics(beam_length: float):
	$Graphics.transform.origin.x += beam_length / 2
	$Graphics.mesh.height = beam_length

func project_beam(from: Vector3, ignore: Array) -> Dictionary:
	var collisionMask = 1
	var to = from + global_transform.basis.x * max_range 
	var spaceState :PhysicsDirectSpaceState = get_world().direct_space_state
	return spaceState.intersect_ray(from, to, ignore, collisionMask)

func _do_aoe(location: Vector3):
	for result in Util.generic_aoe_query(self, location, aoe_radius):
		if result.has("collider"):
			if not iff.should_exclude(result.collider):
				Health.do_damage(result.collider, damage)
