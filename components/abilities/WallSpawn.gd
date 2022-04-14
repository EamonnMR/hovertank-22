extends "res://components/abilities/Ability.gd"

export var wall_entity: PackedScene
export var vfx: PackedScene

func activate():
	# TODO: make sure you don't fly right through a star/etc
	var wall_pos = controller.get_aim_point()
	
	var wall = wall_entity.instance()
	wall.transform.origin = wall_pos
	var fx = vfx.instance()
	fx.transform.origin = wall_pos
	
	var world = parent.get_node("../")
	world.add_child(fx)
	world.add_child(wall)
