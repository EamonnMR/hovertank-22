# TODO: Where are the damn wheels!?

extends VehicleBody3D

@export var left: bool
@export var right: bool
@export var friction_slip: float

func _ready():
	call_deferred("setup_node_weirdness")
	for wheel in get_children():
		if wheel is VehicleWheel3D:
			wheel.wheel_friction_slip = friction_slip

func check_diff():
	var gp = global_transform.origin
	var op = get_children()[0].global_transform.origin
	var diff = op - gp

func setup_node_weirdness():
	var children = get_children()
	var parent = get_node("../")
	parent.remove_child(self)
	parent.get_node("../").add_child(self)
	global_transform.origin += parent.global_transform.origin
	var joint: Generic6DOFJoint3D = Generic6DOFJoint3D.new()
	joint.set_node_b(parent.get_path())
	joint.set_node_a(self.get_path())
	parent.add_child(joint)
	check_diff()
