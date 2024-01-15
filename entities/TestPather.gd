extends CharacterBody3D

# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_introduction_3d.html

var movement_speed: float = 2.0
@onready var movement_target_position = $Target.global_transform.origin

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	#if current_agent_position != next_path_position:
		#breakpoint
	#
	#if navigation_agent.target_position != global_position:
		#var tp = navigation_agent.target_position
		#var gp = global_position

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	set_velocity(new_velocity)
	move_and_slide()


func _on_navigation_agent_3d_path_changed():
	#breakpoint
	pass


func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	pass
	#breakpoint
