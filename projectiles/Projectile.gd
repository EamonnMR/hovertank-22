extends KinematicBody

export var speed = 30
export var damage = 20
export var already_exploded = false
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
	
func explode():
	# Blam!
	pass

func _do_impact(collider):
	print("Shot impact - do damage")
	if not iff.should_exclude(collider):
		Health.do_damage(collider, damage)
	print("Blam!")
	queue_free()
