extends "res://components/abilities/Ability.gd"

export var port_out_vfx: PackedScene
export var port_in_vfx: PackedScene

func activate():
	
	# TODO: make sure you don't fly right through a star/etc
	var new_pos = controller.get_aim_point()
	
	var port_out = port_out_vfx.instance()
	port_out.transform.origin = parent.global_transform.origin
	
	var port_in = port_in_vfx.instance()
	port_in.transform.origin = new_pos
	
	parent.global_transform.origin = new_pos
	
	var world = parent.get_node("../")
	world.add_child(port_in)
	world.add_child(port_out)
