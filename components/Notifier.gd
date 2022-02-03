extends Spatial

export var proactive: bool = false  # Notify anything that comes near, SLOW
export var line_of_sight: bool= true # 
export var cadence: float = 0.0 # Notify automatically on regular intervals

var in_proactive_area = []

var notification_source: Node
var query

# These are only used if we're in "active" mode
func _ready():
	assert(not(proactive and cadence))
	if not notification_source:
		notification_source = get_node("../")
	$CollisionShape.disabled = not proactive
	if cadence > 0:
		_setup_cadence_timer()
		
	_setup_query()

func notify():
	for result in _bodies_in_area():
		if result.has("collider"):
			_notify_body(result.collider)

func _notify_body(body):
	if not body.has_method("notify"):
		return
	if line_of_sight and not _line_of_sight(body):
		return
	body.notify(notification_source)

func _setup_cadence_timer():
	# TODO: Create timer with cadence as wait time
	# Defer a call to add child and connect the timeout to notify
	pass

# Gross physics interface code

func _setup_query():
	query = PhysicsShapeQueryParameters.new()
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_layer = 1
	query.set_shape($CollisionShape.shape)

func _bodies_in_area() -> Array:
	query.transform = $CollisionShape.transform
	return get_world().get_direct_space_state().intersect_shape(query)

func _line_of_sight(body) -> bool:
	var our_pos = 	notification_source.get_center_of_mass()
	var body_pos = body.get_center_of_mass()
	
	var space_state = get_world().get_direct_space_state()
	
	var result = space_state.intersect_ray(our_pos, body_pos, [notification_source], 1)
	var has_los =  result.has("collider") and result.collider == body
	return has_los
