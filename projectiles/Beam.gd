extends Spatial

export var max_range = 1000
export var overpen_count = 3
export var damage = 10000

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
			var beam_length: float = (collision.position - global_transform.origin).length()
			$Graphics.transform.origin.x += beam_length / 2
			$Graphics.mesh.height = beam_length
		
func project_beam(from: Vector3, ignore: Array) -> Dictionary:
	var collisionMask = 1
	var to = from + global_transform.basis.x * max_range 
	var spaceState :PhysicsDirectSpaceState = get_world().direct_space_state
	return spaceState.intersect_ray(from, to, ignore, collisionMask)
