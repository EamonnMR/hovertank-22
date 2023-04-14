extends RigidBody3D

@export var speed = 50
@export var damage = 0
@export var splash_damage = 0
@export var splash_radius = 0
@export var already_exploded = false
@export var explosion: PackedScene
signal impact

var iff: IffProfile

func init(iff: IffProfile):
	self.iff = iff

func _ready():
	add_collision_exception_with(self.iff.owner)
	call_deferred("initial_velocity")

func initial_velocity():
	apply_central_impulse(
		(speed / mass) * transform.basis.x
	)

func _explode():
	# TODO: Calculate ricochet angle
	var explo = explosion.instantiate()
	explo.transform.origin = global_transform.origin
	if splash_damage:
		explo.init(splash_damage, splash_radius, false, iff)
	get_node("../").add_child(explo)

func do_impact(collider):
	print("Shot impact - do damage")
	if not iff.should_exclude(collider):
		Health.do_damage(collider, damage)
	emit_signal("impact")
	_explode()
	queue_free()
