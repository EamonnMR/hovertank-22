extends KinematicBody

class_name Pickup

var velocity: Vector3
export var start_move_speed = 30
export var gravity = 35.0
export var drag = 0.01
export var velo_retained_on_bounce = 0.8
var initialized = false

func _ready():
	velocity = -1 * global_transform.basis.y * start_move_speed
	
func _physics_process(delta):
	velocity += -1 * velocity * drag + Vector3.DOWN * gravity * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
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