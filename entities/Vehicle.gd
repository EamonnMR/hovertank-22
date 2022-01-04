extends KinematicBody
var aim_dir: float
var cooldown: bool
var camera

func is_player():
	return $Controller.is_player()

signal destroyed(unit)
	
func _ready():
	
	if $Controller.is_player():
		# TODO: Not great for SOC
		camera = get_node("../CameraRig")
		$CameraMover.remote_path = camera.get_mover_path()
	
	var map = get_node("../../")
	# connect("destroyed", map, "unit_destroyed")
	$Health.connect("destroyed", self, "_dead")
	#if ProjectSettings.get_setting("Prefs/controller"):
		#add_child(preload("res://GamepadController.tscn").instance())
	#else:
	add_child(preload("res://components/MouseAndKeyboardController.tscn").instance())
	
func _physics_process(delta: float):
	# Movement is handled by the movement component
	_handle_shooting()

func _handle_shooting():
	if $Controller.is_shooting():
		get_turret().try_shoot_primary()
		# TODO: Multi Turret vehicles
	#if $Controller.is_shooting_secondary()
	#	pass
	#	# $SecondaryWeapon.try_shooting()

func _dead():
	explode()
	# Remove this node but keep the camera around
	#var camera = $Camera2D
	#remove_child(camera)
	#get_node("../").add_child(camera)
	#camera.position = position
	emit_signal("destroyed", self)
	queue_free()

func explode():
	# TODO: Explosion
	print("Boom")
	# var explo = get_explo()
	# explo.position = position
	# get_node("../").add_child(explo)

func set_facing(facing: float):
	# $GraphicsPivoter.rotation.y = facing
	rotation.y = facing

func get_center_of_mass():
	return $CenterOfMass.global_transform.origin

func get_turret():
	return $Graphics/Armature/Skeleton/Turret
