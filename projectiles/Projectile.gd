extends KinematicBody

export var speed = 50
export var damage = 20
export var already_exploded = false
export var explosion: PackedScene
signal impact

var iff: IffProfile

func init(iff: IffProfile):
	self.iff = iff
	add_collision_exception_with(iff.owner)
	
func _physics_process(delta):
	var collision: KinematicCollision = move_and_collide(
		global_transform.basis.x * speed * delta
	)
	
	if collision:
		var collider = collision.collider
		
		_do_impact(collider)
	
func _explode():
	# TODO: Calculate ricochet angle
	var explo = explosion.instance()
	explo.transform.origin = global_transform.origin
	get_node("../").add_child(explo)

func _do_impact(collider):
	print("Shot impact - do damage")
	emit_signal("impact")
	if not iff.should_exclude(collider):
		Health.do_damage(collider, damage)
	_explode()
	queue_free()
