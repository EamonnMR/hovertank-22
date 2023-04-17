extends Movement

# TODO: Somewhere in this class, we're moving something we shouldn't.

var agent
var world


var lastUpdateTimestamp

@export var usePrediction = true

var navigating = false


func _ready():
	world = parent.get_node("../")
	var par: Node = parent
	
	# TODO: This is leading to wonkyness because it's rotating just the skeleton.
	parent.get_node("Graphics").rotation.y += PI/2
	parent.get_node("VehicleCore").destroyed.connect(self.stop)
	
	var sticky_point = world.stick_to_ground(parent.global_transform.origin)
	
	# new stuff
	$NavigationAgent3D.path_desired_distance = 0.5
	$NavigationAgent3D.target_desired_distance = 0.5


func navigate_to_position(position: Vector3):
	navigating = true
	$NavigationAgent3D.target_position = position

func _physics_process(delta):
	if $NavigationAgent3D.is_navigation_finished() or not navigating:
		return

	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = $NavigationAgent3D.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * parent.speed

	parent.set_velocity(new_velocity)
	parent.move_and_slide()

func stop():
	navigating = false

func moving():
	return navigating
