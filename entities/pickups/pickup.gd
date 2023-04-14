extends CharacterBody3D

class_name Pickup

var velocity: Vector3
@export var start_move_speed = 30
@export var gravity = 35.0
@export var drag = 0.01
@export var velo_retained_on_bounce = 0.8
var initialized = false

func _ready():
	velocity =(
		global_transform.basis.x
		* randf_range(0, start_move_speed)
	).rotated(
		Vector3(0, 1, 0),
		randf_range(0, PI * 2)
	)
	
func _physics_process(delta):
	print(global_transform.origin)
	print(velocity)
	velocity += -1 * velocity * drag + Vector3.DOWN * gravity * delta
	var collision = move_and_collide(velocity * delta)
	if false: # collision:
		# Calculate reflection
		var d = velocity
		var n = collision.normal
		var r = d - 2 * d.dot(n) * n
		velocity = r * velo_retained_on_bounce

func _on_PickupArea_body_entered(body):
	if is_instance_valid(body) and can_pickup(body):
		do_pickup_effect(body)
		queue_free()

func do_pickup_effect(body):
	pass

func can_pickup(body) -> bool:
	return false

