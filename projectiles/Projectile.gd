extends KinematicBody

export var speed = 10
export var damage = 20
export var already_exploded = false

func init(owner: Node):
	add_collision_exception_with(owner)
	
func _physics_process(delta):
	var collision: KinematicCollision = move_and_collide(
		-global_transform.basis.x * speed * delta
	)
	
	if collision:
		var collider = collision.collider
		
		_do_impact(collider)
	
func explode():
	# Blam!
	pass

func _do_impact(collider):
	print("Shot impact - do damage")
	Health.do_damage(collider, damage)
	print("Blam!")
	queue_free()
