# TODO: Where are the damn wheels!?

extends VehicleBody

export var left: bool
export var right: bool

func _ready():
	call_deferred("setup_node_weirdness")

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
	var joint: Generic6DOFJoint = Generic6DOFJoint.new()
	joint.set_node_b(parent.get_path())
	joint.set_node_a(self.get_path())
	parent.add_child(joint)
	check_diff()
