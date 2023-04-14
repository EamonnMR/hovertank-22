extends Node3D

@export var proactive: bool = false  # Notify anything that comes near, SLOW
@export var line_of_sight: bool= true # 
@export var cadence: float = 0.0 # Notify automatically on regular intervals
@export var radius: float = 60

var notification_source: Node
var query

# These are only used if we're in "active" mode
func _ready():
	$Shape3D.shape.radius = radius
	if not notification_source:
		notification_source = get_node("../")
	if proactive:
		enable_proactive()
	else:
		disable_proactive()
		
	_setup_query()

func enable_proactive():
	proactive = true
	$Shape3D.disabled = false

func disable_proactive():
	proactive = false
	$Shape3D.disabled = true
	if cadence > 0:
		call_deferred("_setup_cadence_timer")

func notify():
	for result in _bodies_in_area():
		if result.has("collider"):
			if result.collider == notification_source:
				continue
			_notify_body(result.collider)

func _notify_body(body):
	if body == notification_source:
		return
	if not body.has_method("alert"):
		return
	if line_of_sight and not _line_of_sight(body):
		return
	body.alert(notification_source)

func _setup_cadence_timer():
	var timer = Timer.new()
	timer.one_shot = false
	timer.autostart = true
	timer.wait_time = cadence
	timer.connect("timeout",Callable(self,"notify"))
	add_child(timer)

# Gross physics interface code

func _setup_query():
	query = PhysicsShapeQueryParameters3D.new()
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 2
	query.set_shape($Shape3D.shape)

func _bodies_in_area() -> Array:
	query.transform = $Shape3D.global_transform
	return get_world_3d().get_direct_space_state().intersect_shape(query)

func _line_of_sight(body) -> bool:
	var our_pos = 	notification_source.get_center_of_mass()
	var body_pos = body.get_center_of_mass()
	
	var space_state = get_world_3d().get_direct_space_state()
	
	var result = space_state.intersect_ray(our_pos, body_pos, [notification_source], 1)
	if result.has("collider"):
		if result.collider == body:
			return true
		else:
			return false
	else:
		return false
